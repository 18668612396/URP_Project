#ifndef PBR_FALLDUST_INCLUDE
    #define PBR_FALLDUST_INCLUDE
    #pragma shader_feature _FALLDUST_ON
    float _HeightDepth;

    uniform TEXTURE2D (_FallDustMainTex);
    uniform	SAMPLER(sampler_FallDustMainTex);

    uniform TEXTURE2D (_FallDustPbrParam);
    uniform	SAMPLER(sampler_FallDustPbrParam);

    uniform TEXTURE2D (_FallDustNormal);
    uniform	SAMPLER(sampler_FallDustNormal);
    

    float4 _FallDustMainTex_ST;
    float4 _FallDustColor;
    float  _FallDustColorBlend;
    float  _FallDustMetallic;
    float  _FallDustRoughness;
    float _fallDustEmissionIntensity;
    float _FallDustNormalIntensity;
    void PBR_FallDust_Function(float2 blendUV ,float4 vertexColor,inout PBR pbr)
    {
        #ifdef _FALLDUST_ON
            //采样落灰贴图
            float2 uv = blendUV;
            float4 var_FallDustMainTex = SAMPLE_TEXTURE2D(_FallDustMainTex,sampler_FallDustMainTex,uv) * _FallDustColor;
            float4 var_FallDustPbrParam = SAMPLE_TEXTURE2D(_FallDustPbrParam,sampler_FallDustPbrParam,uv) ;
            float3 var_FallDustNormal = UnpackNormalScale(SAMPLE_TEXTURE2D(_FallDustNormal,sampler_FallDustNormal,uv),_FallDustNormalIntensity);
            //落灰PBR的通道
            float4 fallDustBaseColor = float4(lerp(pbr.baseColor.rgb,var_FallDustMainTex.rgb,_FallDustColorBlend),1);
            float3 fallDustNormal    = var_FallDustNormal;
            float3 fallDustEmission  = lerp(0,var_FallDustMainTex.rgb * _FallDustColor.rgb * max(0.0,_fallDustEmissionIntensity),var_FallDustPbrParam.a);
            float  fallDustMetallic  = min(_FallDustMetallic,var_FallDustPbrParam.r);
            float  fallDustRoughness = _FallDustRoughness*var_FallDustPbrParam.g;
            float  fallDustOcclustio = var_FallDustPbrParam.b;

            //高度融合mask
            float4 heightBlend = saturate(pow((((1 - pbr.baseColor.a * var_FallDustMainTex.a)*vertexColor)*4)+(vertexColor*2),_HeightDepth));//(1 - pbr.normal.a)比着原算法反向了一下高度图   此算法照搬的UE4的高度混合算法

            pbr.baseColor = lerp(pbr.baseColor,fallDustBaseColor,heightBlend.r);
            pbr.metallic      = lerp(pbr.metallic,fallDustMetallic,heightBlend.r);
            pbr.roughness = lerp(pbr.roughness,fallDustRoughness,heightBlend.r);
            pbr.normal.xyz    = lerp(pbr.normal.xyz,fallDustNormal,heightBlend.r);
            pbr.occlusion   = lerp(pbr.occlusion,fallDustOcclustio,heightBlend.r);
            pbr.emission    = lerp(pbr.emission,fallDustEmission,heightBlend.r);
        #else
            pbr.baseColor = pbr.baseColor;
            pbr.metallic      = pbr.metallic;
            pbr.roughness = pbr.roughness;
            pbr.normal.xyz    = pbr.normal.xyz;
            pbr.occlusion   = pbr.occlusion;
            pbr.emission    = pbr.emission;
        #endif

    }

    #define PBR_FALLDUST(i,pbr) PBR_FallDust_Function(i.blendUV,i.vertexColor,pbr);

#endif