#ifndef WATER_FUNCTION_INCLUDE
    #define WATER_FUNCTION_INCLUDE
    
    #include "ShaderFunction.HLSL"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    
    //noise
    float2 random(float2 st){
        st = float2( dot(st,float2(127.1,311.7)), dot(st,float2(269.5,183.3)) );
        return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
    }

    float waterNoise (float2 st) 
    {
        float2 i = floor(st);
        float2 f = frac(st);

        float2 u = f*f*(3.0-2.0*f);

        return lerp( lerp( dot( random(i), f),
        dot( random(i + float2(1.0,0.0) ), f - float2(1.0,0.0) ), u.x),
        lerp( dot( random(i + float2(0.0,1.0) ), f - float2(0.0,1.0) ),
        dot( random(i + float2(1.0,1.0) ), f - float2(1.0,1.0) ), u.x), u.y);
    }

    //深度计算
    TEXTURE2D_X_FLOAT(_CameraDepthTexture);
    SAMPLER(sampler_CameraDepthTexture);
    uniform float _Offset;
    float DepthCompare(float2 scrPos,float3 viewPos,float _Radius)
    {
        float scrDepth = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, scrPos).r, _ZBufferParams);
        float disDepth  = (scrDepth + viewPos.z) * _Radius;
        return 1 - saturate(disDepth);
    }
    
    
    half2 DistortionUVs(half depth, float3 worldNormal)
    {
        half3 viewNormal = mul((float3x3)GetWorldToHClipMatrix(), -worldNormal).xyz;

        return viewNormal.xz * saturate((depth) * 0.005);
    }

    TEXTURECUBE(_CubemapTexture);
    SAMPLER(sampler_CubemapTexture);
    half3 SampleReflections(half3 normalDir, half3 viewDirectionWS)
    {
        half3 reflection = 0;

        half3 reflectDir = reflect(-viewDirectionWS, normalDir);
        // reflection = GlossyEnvironmentReflection(CubeMap, 0, 1);
        reflection = SAMPLE_TEXTURECUBE(_CubemapTexture,sampler_CubemapTexture, reflectDir).rgb;

        return reflection;
    }
    




#endif

