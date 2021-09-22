// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

Shader "Custom/Scene/GrassShader"
{
    Properties
    {
        
        _MainTex ("Texture", 2D) = "white" {}
        _Color("TopColor",Color) = (1.0,1.0,1.0,1.0)
        
        _GradientVector("_GradientVector",vector) = (0.0,1.0,0.0,0.0)
        _CutOff("Cutoff",Range(0.0,1.0)) = 0.0
        _WindAnimToggle("_WindAnimToggle",int) = 1
        _SpecularRadius("_SpecularRadius",Range(1.0,100.0)) = 50.0
        _SpecularIntensity("_SpecularIntensity",Range(0.0,1.0)) = 0.5
        _OcclusionIntensity("_OccIntensity",Range(0.0,1.0)) = 0.5
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        HLSLINCLUDE
        #include "../ShaderFunction.hlsl"
        //变量声明
        CBUFFER_START(UnityPreMaterial)
        //贴图采样器
        uniform TEXTURE2D (_MainTex);
        uniform	SAMPLER(sampler_MainTex);
        uniform float4 _MainTex_ST;

        uniform float _CutOff;
        uniform float4 _Color;
        uniform float4 _GradientVector;
        uniform float _OcclusionIntensity;
        uniform float _SpecularRadius;
        uniform float _SpecularIntensity;
        CBUFFER_END
        //结构体
        #pragma vertex vert
        #pragma fragment frag
        #pragma multi_compile_instancing    
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
            float4 color:COLOR;
            float3 normal:NORMAL;

        };
        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 vertexColor:COLOR;
            float3 worldNormal :TEXCOORD2;
            float3 worldView :TEXCOORD5;
            float3 worldPos:TEXCOORD6;
            
        };
        
        ENDHLSL
        Pass
        {
            Tags
            { 
                "RenderPipeline"="UniversalRenderPipline"
                "RenderType"="Opaque" 
                "Queue" = "Geometry"
            }

            Cull off
            HLSLPROGRAM
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                WIND_ANIM(v);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldView = _WorldSpaceCameraPos.xyz - o.worldPos;
                o.vertexColor = v.color;
                return o;
            }


            real3 frag (v2f i) : SV_Target
            {
                //采样贴图
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                //AlphaTest
                clip(var_MainTex.g - _CutOff);
                //准备向量
                float4 SHADOW_COORDS = TransformWorldToShadowCoord(i.worldPos);
                Light light = GetMainLight(SHADOW_COORDS);
                float3 lightDir = normalize(light.direction).xyz;
                float3 viewDir  = normalize(i.worldView);
                float3 normalDir = normalize(i.worldNormal);
                float3 halfDir   = normalize(lightDir + viewDir);
                //点乘计算
                float NdotL = max(0.0,dot(normalDir,lightDir));
                float NdotH = max(0.0,dot(float3(0.0,1.0,0.0),halfDir));//这里假设所有法线朝上
                
                //基础颜色Albedo
                float3 Albedo  = _Color.rgb;
                //Occlusion
                float Occlustion = lerp(1,i.vertexColor.a,_OcclusionIntensity);//把顶点色A通道当作别的草和自己的环境闭塞
                //主光源影响
                float specular = pow(NdotH,_SpecularRadius) * _SpecularIntensity * i.vertexColor.a;
                float shadow = light.shadowAttenuation * i.vertexColor.a * CLOUD_SHADOW(i);//把顶点色A通道当作自投影
                float3 lightContribution = (specular +  Albedo * light.color * NdotL) * shadow;
                //环境光源影响
                float3 Ambient = SampleSH(normalDir);
                float3 indirectionContribution = Ambient * Albedo * Occlustion;
                
                //光照合成
                float3 finalRGB = lightContribution + indirectionContribution;
                BIGWORLD_FOG(i,finalRGB);//大世界雾效
                //输出

                return finalRGB;

            }
            ENDHLSL
        }
        
        pass 
        {
            Name "ShadowCast"
            
            Tags{ "LightMode" = "ShadowCaster" }
            HLSLPROGRAM
            v2f vert(appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }
            float4 frag(v2f i) : SV_Target
            {
                return float4(1.0,1.0,1.0,1.0);
            }
            ENDHLSL
        }
        
    }

    CustomEditor "GrassShaderGUI"
}
