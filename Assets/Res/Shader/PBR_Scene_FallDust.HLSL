#ifndef PBR_FALLDUST_INCLUDE
    #define PBR_FALLDUST_INCLUDE
    float _HeightDepth;
    sampler2D _FallDustMainTex,_FallDustPbrParam,_FallDustNormal;
    float4 _FallDustMainTex_ST;
    float4 _FallDustColor;
    float  _FallDustColorBlend;
    float  _FallDustMetallic;
    float  _FallDustRoughness;
    float _fallDustEmissionIntensity;
    float _FallDustNormalIntensity;
    void PBR_FallDust_Function(float2 blendUV ,float4 vertexColor,inout PBR pbr)
    {
        //采样落灰贴图
        
        float4 var_FallDustMainTex = tex2D(_FallDustMainTex,blendUV) * _FallDustColor;
        float4 var_FallDustPbrParam = tex2D(_FallDustPbrParam,blendUV);
        float4 var_FallDustNormal = tex2D(_FallDustNormal,blendUV);
        //落灰PBR的通道
        float4 fallDustBaseColor = float4(lerp(pbr.baseColor.rgb,var_FallDustMainTex.rgb,_FallDustColorBlend),1);
        float3 fallDustNormal    = lerp(float4(0.5,0.5,1,1),var_FallDustNormal,_FallDustNormalIntensity).xyz;
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
    }

    #define PBR_FALLDUST(i,pbr) PBR_FallDust_Function(i.blendUV,i.vertexColor,pbr);

#endif