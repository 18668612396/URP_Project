Shader "Cartoon/Face"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FaceShadow("FaceShadow",2D) = "white"{}
        _test("test",Range(-1,1)) = 0
        [Toogle] _switch("switch",float) = 0
    }



    
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100



        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : MESH_UV;
                float4 vertex : SV_POSITION;
                float3 objectPos :OBJ_POSITION;
                float3 normal: WORLD_NORMAL;
                float3 forwardDir :FORWARD_DIR;
            };
            //remap函数
            float remap(float In ,float InMin ,float InMax ,float OutMin, float OutMax)
            {
                return OutMin + (In - InMin) * (OutMax - OutMin) / (InMax - InMin);
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _FaceShadow;

            float _test;
            float _switch;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.objectPos = v.vertex.xyz;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.forwardDir = normalize(UnityObjectToWorldDir(float4(0.0,0.0,1.0,1.0)));
                return o;
            }

            fixed3 frag (v2f i) : SV_Target
            {
                //准备向量
                float3 Ambient = UNITY_LIGHTMODEL_AMBIENT;
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed4 var_MainTex = tex2D(_MainTex, i.uv);

                float switchShadowTex = dot(lightDir.x,UnityObjectToWorldDir(float4(1.0,0.0,0.0,1.0)).x);//用来切换两张贴图的变量
                float4 var_FaceShadow;
                //float4 shadowTex = switchShadowTex < 0.0 ? var_FaceShadow:var_FaceShadow_Inv;//切换两张相反的脸部阴影贴图
                if (switchShadowTex < 0.0)
                {
                    var_FaceShadow = tex2D(_FaceShadow,i.uv);
                }
                else
                {
                    var_FaceShadow = tex2D(_FaceShadow,float2(-i.uv.x,i.uv.y));
                }

                float faceShadowRange =1 - remap(dot(lightDir.xz,i.forwardDir.xz),-1,1,0,1);//阴影边界位置（实际上是计算了模型方向与光照方向的夹角，但不知道为何数值并非-1 ~ 1 ，所以用remap函数重映射了一下范围）
                float faceShadow =  var_FaceShadow < faceShadowRange  ? 0.0 : 1.0 ; 
                float3 shadow = lerp(unity_ShadowColor,1,faceShadow);

                float3 diffColor = var_MainTex;
                float3 specColor = 0.04;
                return var_MainTex * shadow + diffColor * (1 - specColor) * UNITY_LIGHTMODEL_AMBIENT * 1;
                float3 finalRGB = var_MainTex * shadow ;
                return  finalRGB;

            }
            ENDCG
        }
    }
}
