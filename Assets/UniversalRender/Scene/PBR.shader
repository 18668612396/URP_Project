Shader "URP/PBR"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map",2D) = "bump"{}
        _NormalScale("Normal Scale",range(0.0001,1)) = 1
        _MetallicMap ("Metallic Map",2D) = "white"{}
        _RoughnessMap ("RoughnessMap",2D) = "white" {}
        _AoMap ("Ambient Occlussion",2D) = "white" {}
        _BaseColor("Albedo",Color) = (1,1,1,1)
        [Toggle(CUSTOM)]_Custom ("Custom", float) = 0
        _Metalness ("Metalness",range(0.001,1)) = 0.5
        _Roughness ("Roughness",range(0.001,1)) = 0.5
        

    }
    SubShader
    {
        Tags { 
            "RenderPipeline" = "UniversalRenderPipeline"
            "RenderType"="Opaque" 
            }
        Pass
        {
            Tags{
                "LightMode" = "UniversalForward"
                }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // 接收阴影所需关键字
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _SHADOWS_SOFT

            #pragma shader_feature_local_fragment CUSTOM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"  
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _BaseColor;
                float _NormalScale;
                float _Metalness;
                float _Roughness;
            CBUFFER_END
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);

            TEXTURE2D(_MetallicMap);
            SAMPLER(sampler_MetallicMap);

            TEXTURE2D(_RoughnessMap);
            SAMPLER(sampler_RoughnessMap);

            TEXTURE2D(_AoMap);
            SAMPLER(sampler_AoMap);


            struct a2v
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangentOS: TANGENT;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                
                float3 positionWS : TEXCOORD1;
                float2 uv : TEXCOORD0;
                float3 normalWS : NORMAL;
                float4 tangentWS : TANGENT;
                float4 BtangentWS : TEXCOORD2;
            };
            //F : 菲涅尔方程
            float3 fresnelSchlick(float cosTheta,float3 F0)
            {
                return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
            }
            //G : 几何函数
            float GeometrySchlickGGX(float NdotV,float roughness)
            {
                float r = (roughness + 1.0);
                float k = (r*r) / 8.0;
            
                float nom   = NdotV;
                float denom = NdotV * (1.0 - k) + k;
            
                return nom / denom;
            }
            float GeometrySmith(float3 N,float3 V,float3 L,float roughness)
            {
                float NdotV = max(dot(N, V), 0.0);
                float NdotL = max(dot(N, L), 0.0);
                float ggx2  = GeometrySchlickGGX(NdotV, roughness);
                float ggx1  = GeometrySchlickGGX(NdotL, roughness);

                return ggx1 * ggx2;
            }
            
            //D : 正态分布函数 Or 直接光镜面反射
            float DistributionGGX(float3 N, float3 H, float roughness)
            {
                float a      = roughness*roughness;
                float a2     = a*a;
                float NdotH  = max(dot(N, H), 0.0);
                float NdotH2 = NdotH*NdotH;
            
                float nom   = a2;
                float denom = (NdotH2 * (a2 - 1.0) + 1.0);
                denom = PI * denom * denom;
            
                return nom / denom;
            
                
            }
            v2f vert(a2v i)
            {
               v2f o;
                o.positionCS = TransformObjectToHClip(i.positionOS.xyz);
                o.positionWS = TransformObjectToWorld(i.positionOS.xyz);
                
                o.normalWS = TransformObjectToWorldNormal(i.normalOS.xyz,false);
                o.tangentWS.xyz = normalize(TransformObjectToWorld(i.tangentOS.xyz));
                o.BtangentWS.xyz = cross(o.normalWS.xyz,o.tangentWS.xyz) * i.tangentOS.w * unity_WorldTransformParams.w;                    

                o.uv = TRANSFORM_TEX(i.uv,_MainTex);
                return o;
            }

            real4 frag(v2f i) : SV_Target
            {
                i.normalWS = normalize(i.normalWS);
                
                float3 albedo = pow(SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv),2.2);
                float metallic = SAMPLE_TEXTURE2D(_MetallicMap,sampler_MetallicMap,i.uv).r;
                float roughness = SAMPLE_TEXTURE2D(_RoughnessMap,sampler_RoughnessMap,i.uv).r;
                float ao = SAMPLE_TEXTURE2D(_AoMap,sampler_AoMap,i.uv).r;
                
                real4 normalTex = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,i.uv);
                
                float3x3 TBN = {i.tangentWS.xyz,i.BtangentWS.xyz,i.normalWS.xyz};
                float3 normalTS = UnpackNormalScale(normalTex,_NormalScale);
                normalTS.z = pow((1-pow(normalTS.x,2)-pow(normalTS.y,2)),0.5);
                float3 normal = mul(normalTS,TBN);
                
                #if CUSTOM
                    metallic = _Metalness;
                    roughness = _Roughness;
                #endif


                
                Light mainLight = GetMainLight(TransformWorldToShadowCoord(i.positionWS.xyz));
                float3 N = normalize(normal.xyz);
                float3 L = normalize(mainLight.direction);
                float3 V = normalize(_WorldSpaceCameraPos - i.positionWS).xyz;

                float3 lightColor = mainLight.color;
                float cosTheta = max(dot(L,N),0);
                float attenuation = mainLight.shadowAttenuation;
                float3 H = normalize(V + L);

                
                float3 F0 = float(0.04);
                F0 = lerp(F0,albedo,metallic);
                //Diffuse
                float radiance = lightColor * attenuation ;

                float NDF = DistributionGGX(N,H,roughness);
                float G = GeometrySmith(N,V,L,roughness);
                float3 F = fresnelSchlick(max(dot(H,V),0),F0);

                float3 KS = F;
                float3 KD = 1 - KS;
                KD *= 1.0 - metallic;

                float3 nominator = NDF * G * F;
                float denominator = 4.0 * max(dot(N,V),0) * max(dot(N,L),0) + 0.001;
                float3 specular = nominator / denominator;

                float NdotL = max(dot(N,L),0);
                float3 final = (KD * albedo / PI + specular) * radiance * NdotL;

                float3 ambient = real3(0.03,0.03,0.03) * albedo * ao;
                float3 color = ambient + final;

                color = color / (color + float3(1.0,1.0,1.0));
                // color = pow(color,real3(1.0 / 2.2,1.0 / 2.2,1.0 / 2.2));
                




                
                return real4(color,1);


                
                

                
                

                
            }
            ENDHLSL
        }
    }
}
