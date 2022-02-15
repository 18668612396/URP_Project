

Shader "Custom/Subsurface"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" { }
        
        _Color("Color",Color) = (1.0,1.0,1.0,1.0)
        _Transmitting("Transmitting",Range(0.0,1.0)) = 0.0
    }
    SubShader
    {
        Tags 
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque" 
        }

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward" 
            }
            
            Cull Back
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _Color;
            half _Transmitting;
            CBUFFER_END


            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 worldPos:TEXCOORD1;
            };

                //计算额外光源贡献
                float3 additionaLightContribution (float3 normalDir,float3 worldPos)
                {
                    float lighting = 0.0;
                    InputData inputData; //貌似是unity的内部数据
                    int addLightsCount = GetAdditionalLightsCount();
                    for(int idx = 0; idx < addLightsCount; idx++)
                    {
                        Light light = GetAdditionalLight(idx, worldPos,inputData.shadowMask);
                        //准备向量
                        float3 lightDir   = normalize(light.direction);
                        //点乘结果
                        float NdotL = max(0.00001,dot(normalDir,lightDir));
                                    light.color *= light.shadowAttenuation  * light.distanceAttenuation;
                                               lighting += NdotL;
                    }
                    return lighting;
                }
                
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f, o); //初始化顶点着色器
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldPos = TransformObjectToWorld(v.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                Light light = GetMainLight();
                half3 normalDir = normalize(i.worldNormal);
                half3 lightDir  = normalize(light.direction);
                half  NdotL = (dot(normalDir,lightDir)  + additionaLightContribution(normalDir,i.worldPos)) * 0.5 + 0.5;
                half3 Subsurface = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,float2(NdotL,_Transmitting));
                half4 finalColor = var_MainTex * _Color;
                
                return Subsurface.xyzz * _Color;
            }
            ENDHLSL
            
        }
    }
    FallBack "Diffuse"
}
