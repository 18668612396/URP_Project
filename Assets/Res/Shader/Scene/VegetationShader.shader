Shader "Custom/Scene/VegetationShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_TopColor("TopColor",Color) = (1.0,1.0,1.0,1.0)
        [HDR] _DownColor("DownColor",Color) = (0.0,0.0,0.0,0.0)
        _GradientVector("_GradientVector",vector) = (0.0,1.0,0.0,0.0)
        _CutOff("Cutoff",Range(0.0,1.0)) = 0.0
        _WindAnimToggle("_WindAnimToggle",int) = 1
        
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGINCLUDE
        #include "../ShaderFunction.hlsl"
        uniform sampler2D _MainTex;
        uniform float _CutOff;
        uniform float4 _TopColor;
        uniform float4 _DownColor;
        uniform float4 _GradientVector;
        uniform float _OcclusionIntensity;
        struct Vegetation
        {
            float3 albedo;
            float3 shadow;
            float3 occlustion;
        };
        ENDCG
        Pass
        {
            Tags {
                "RenderType"="Opaque"
                "LightMode"="ForwardBase" //这个一定要加，不然阴影会闪烁
                "Queue" = "Geometry"
            } 
            LOD 100
            Cull off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color:COLOR;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 localPos:TEXCOORD2;
                float4 vertexColor:COLOR;
                float3 worldNormal:NORMAL;
                float4 worldPos:TEXCOORD3;
                LIGHTING_COORDS(98,99)
            };


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);//初始化顶点着色器
                
                WIND_ANIM(v)
                GRASS_INTERACT(v);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex;
                o.worldPos =mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                o.vertexColor = v.color;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                //采样贴图
                fixed4 var_MainTex = tex2D(_MainTex, i.uv);
                //准备向量
                float4 localPos = i.localPos;
                float3 lightDir = normalize(_WorldSpaceLightPos0).xyz;
                float3 normalDir = normalize(i.worldNormal);

                //点乘计算
                float NdotL = saturate(dot(normalDir,lightDir));
                //基础颜色Albedo
                float Gradient = saturate(smoothstep(_GradientVector.x,_GradientVector.y,localPos.y  + _GradientVector.z));
                float3 Albedo  = lerp(_DownColor,_TopColor,Gradient) * var_MainTex.r;
                //Occlusion
                float Occlustion = lerp(_GradientVector.z,_GradientVector.w,i.vertexColor.b);//和PBR相同  使用B通道来作为AO的输入
                //主光源影响
                float shadow = SHADOW_ATTENUATION(i);
                float3 lightContribution = Albedo * _LightColor0.rgb * NdotL * shadow * CLOUD_SHADOW(i);
                //环境光源影响
                float3 Ambient = ShadeSH9(float4(normalDir,1));
                float3 indirectionContribution = Ambient * Albedo * Occlustion;
                //光照合成
                float3 finalRGB = lightContribution + indirectionContribution;
                BIGWORLD_FOG(i,finalRGB);//大世界雾效
                //AlphaTest
                clip(var_MainTex.g - _CutOff);
                //输出
                return finalRGB.rgbb;
            }
            ENDCG
        }
        pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}	
            Cull off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color:COLOR;
                float3 normal:NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f 
            {
                V2F_SHADOW_CASTER;
                float2 uv : TEXCOORD0;
                
            };

            v2f vert (appdata v)
            {
                v2f o;
                
                WIND_ANIM(v);
                GRASS_INTERACT(v);
                o.uv = v.uv;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                
                return o;
            }
            float4 frag(v2f i ):SV_Target
            {
                
                fixed4 var_MainTex = tex2D(_MainTex, i.uv);
                clip(var_MainTex.g - _CutOff);
                SHADOW_CASTER_FRAGMENT(i)//这个要放到最后一位
            } 
            ENDCG
        }
    }
    CustomEditor "VegetationShaderGUI"
}
