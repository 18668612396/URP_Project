Shader "Custom/Scene/IceShader"
{
    Properties
    {
        _IceLand("IceLand",Range(0,1)) = 0
        [Header(Albedo)]
        _IceTop("IceTop",2D) = "white"{}
        _IceBottom ("Texture", 2D) = "white" {}
        _snowColor("_snowColor",Color) = (1,1,1,1)
        _snowDepth("snowDepth",Range(0,1)) = 0
        [HDR]_IceBottomColor01("IceBottomColor01",Color) = (1,1,1,1)
        _IceBottomColor02("IceBottomColor02",Color) = (0,0,0,0)
        _RefractIns("RefractIns",Range(0,1)) = 0
        [Header(Specular)]
        _IceSpecularPow("IceSpecularPow",float) = 0
        _IceSpecularIns("IceSpecularIns",Range(0,1)) = 0.5
        _SnowSpecularPow("SnowSpecularPow",float) = 0
        _SnowSpecularIns("SnowSpecularIns",Range(0,1)) = 0.5
        [Header(Normal)]
        _Normal("Normal",2D) = "bump" {}
        
        
        _Color ("Color",Color) = (1,1,1,1)
        
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGINCLUDE
        uniform sampler2D _IceBottom;
        uniform float4 _IceBottom_ST;
        uniform sampler2D _IceTop;
        uniform float4 _IceTop_ST;
        uniform sampler2D _Normal;
        uniform float4 _Normal_ST;

        uniform float4 _IceBottomColor01;
        uniform float4 _IceBottomColor02;
        uniform float _RefractIns;

        uniform float _IceSpecularPow;
        uniform float _IceSpecularIns;
        uniform float _SnowSpecularPow;
        uniform float _SnowSpecularIns;
        uniform float _IceLand;

        uniform float4 _snowColor;
        uniform float _snowDepth;
        //Noise计算END
        ENDCG
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float4 color:COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 worldPos :TEXCOORD1;
                
                float3 tangent:TANGENT;
                float3 btangent:TEXCOORD2;
                float3 normal:NORMAL;
                float3 objectPos:TEXCOORD3;

                float4 color:COLOR;
                
            };

            //ACES_Tonemapping
            float3 ACES_Tonemapping(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;

                float3 finalRGB = saturate((x*(a*x + b)) / (x*(c*x + d) +e));
                return finalRGB;
            }
            v2f vert (appdata i)
            {
                v2f o;
                o.uv = i.uv;
                o.normal = UnityObjectToWorldNormal(i.normal);
                o.tangent = UnityObjectToWorldDir(i.tangent).xyz;
                o.worldPos = mul(unity_ObjectToWorld,i.vertex);
                o.vertex = mul(unity_MatrixVP,o.worldPos);
                o.btangent = cross(o.normal,o.tangent.xyz) * i.tangent.w;
                o.objectPos = i.vertex.xyz;
                o.color = i.color;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //雪 ....因为牵扯到要参与两层法线的融合 所以要把他放到前面来
                float4 var_IceTop    = tex2D(_IceTop,i.uv * _IceTop_ST.xy );//采样冰面顶部贴图//顶部贴图为使用默认UV采样 不需要根据镜头移动进行偏移
                float4 vertexColor = i.color;//定义顶点色
                float4 snowMask = saturate(vertexColor.r + _snowDepth - var_IceTop.a);//雪的遮罩计算
                
                //采样法线贴图
                float4 var_Normal = tex2D(_Normal,i.uv * _Normal_ST) * 2 - 1;
                
                //从一张贴图里拆出两层法线并根据雪的遮罩进行合并
                var_Normal = float4(lerp(var_Normal.xy,var_Normal.zw,snowMask),1,1);
                //构建TBN矩阵
                float3 tangent = normalize(i.tangent).xyz;
                float3 btangent = normalize(i.btangent);
                float3 normal = normalize(i.normal);
                float3x3 TBN = float3x3(tangent,btangent,normal);
                //准备向量
                float3 lightDir = _WorldSpaceLightPos0.xyz;//灯光角度
                float3 worldPos = i.worldPos;//世界空间顶点坐标
                float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);//世界空间视角方向
                float3 normalDir = mul(float3(var_Normal.xy,1).xyz,TBN);//利用TBN矩阵转换法线
                float2 iceMidUV = reflect(_WorldSpaceCameraPos * _IceLand * 2 - worldPos,normal).xz;//冰面中间层纹理的UV
                float2 iceMinUV = reflect(_WorldSpaceCameraPos * _IceLand - worldPos,normal).xz;//冰面底部层纹理的UV
                float3 halfDir =normalize(lightDir + viewDir);
                // 采样冰底贴图
                float4 var_IceBottomMin = tex2D(_IceBottom, iceMidUV * _IceBottom_ST.xy + normalDir.xy * _RefractIns * 2); //越往下折射扭曲越强
                float4 var_IceBottomMid = tex2D(_IceBottom, iceMinUV * _IceBottom_ST.zw + normalDir.xy *_RefractIns );
                
                //Dot
                float NdotH = saturate(max(0.0,dot(normalDir,halfDir)));//计算blinnPhong模式高感光
                //计算冰底
                float4 iceBottomColor = (lerp(_IceBottomColor02,_IceBottomColor01,var_IceBottomMin.r) + var_IceBottomMid.g * 0.3) ;
                
                //高光
                float iceSpecular = saturate(pow(NdotH,_IceSpecularPow) * _IceSpecularIns);
                float snowSpecular = saturate(pow(NdotH,_SnowSpecularPow) * _SnowSpecularIns);
                float Specular = lerp(iceSpecular,snowSpecular,snowMask);
                //基础颜色
                float4 Albedo = var_IceTop *0.5+ iceBottomColor * 0.5;
                Albedo = lerp(Albedo,_snowColor ,snowMask);

                float4 finalRGB  = Albedo + Specular;
                finalRGB.rgb = pow(finalRGB,2.2);
                finalRGB.rgb = ACES_Tonemapping(finalRGB);
                finalRGB.rgb = pow(finalRGB,1/2.2);
                return finalRGB.rgbb;
            }
            ENDCG
        }
    }
}

/*<冰的特性>

带裂缝的纹理
带有菲尼尔的反射(可以用cubemap也可以用matcap)
靠近岸边会有白色的凝霜物(也可以说是雪)
会存在一些SSS(仅非冰面物体)

*/

