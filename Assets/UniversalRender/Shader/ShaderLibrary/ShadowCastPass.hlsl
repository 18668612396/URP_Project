#ifndef SHADOWCAST_FUNCTION_INCLUDE
    #define SHADOWCAST_FUNCTION_INCLUDE
    

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

    float3 _LightDirection;
    float3 _LightPosition;
    float4 GetShadowPositionHClip(appdata i)
    {
        float3 positionWS = TransformObjectToWorld(i.vertex.xyz);
        float3 normalWS = TransformObjectToWorldNormal(i.normal);

        #if _CASTING_PUNCTUAL_LIGHT_SHADOW
            float3 lightDirectionWS = normalize(_LightPosition - positionWS);
        #else
            float3 lightDirectionWS = _LightDirection;
        #endif

        float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

        #if UNITY_REVERSED_Z
            positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
        #else
            positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
        #endif

        return positionCS;
    }

    v2f vert(appdata v)
    {
        v2f o;
        ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
        o.pos = GetShadowPositionHClip(v);
        // o.uv = v.uv;
        return o;
    }
    real3 frag(v2f i) : SV_Target
    {
        // Alpha(SampleAlbedoAlpha(i.uv, TEXTURE2D_ARGS(_MainTex, sampler_MainTex)).a, _Color, _Cutoff);
        // float MainTexAlpha = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv).a;
        // clip(MainTexAlpha - 0.2);
        return 0;
    }

#endif

