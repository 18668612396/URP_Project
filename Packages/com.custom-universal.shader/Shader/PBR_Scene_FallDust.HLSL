#ifndef PBR_FALLDUST_INCLUDE
    #define PBR_FALLDUST_INCLUDE
    

    uniform TEXTURE2D (_FallDustMainTex);
    uniform	SAMPLER(sampler_FallDustMainTex);
    uniform TEXTURE2D (_FallDustPbrParam);
    uniform	SAMPLER(sampler_FallDustPbrParam);
    uniform TEXTURE2D (_FallDustNormal);
    uniform	SAMPLER(sampler_FallDustNormal);
    
    uniform float _HeightRadius;
    uniform float _HeightDepth;
    uniform float4 _FallDustColor;
    uniform float  _FallDustColorBlend;
    uniform float  _FallDustMetallic;
    uniform float  _FallDustRoughness;
    uniform float _fallDustEmissionIntensity;
    uniform float _FallDustNormalIntensity;
    uniform int _FallDustNormalBlend;
    void PBR_FallDust_Function(float2 blendUV ,float4 vertexColor,inout PBR pbr)
    {
        #ifdef _FALLDUST_ON
            //采样落灰贴图
            float2 uv = blendUV;
            #if _FALLDUST_MAINTEX_ON
                float4 var_FallDustMainTex = SAMPLE_TEXTURE2D(_FallDustMainTex,sampler_FallDustMainTex,uv) * _FallDustColor;
            #else
                float4 var_FallDustMainTex = _FallDustColor;
            #endif

            #if _FALLDUST_PBRPARAM_ON
                float4 var_FallDustPbrParam = SAMPLE_TEXTURE2D(_FallDustPbrParam,sampler_FallDustPbrParam,uv);
            #else
                float4 var_FallDustPbrParam = float4(_FallDustMetallic,_FallDustRoughness,1.0,0.0);
            #endif
            
            #if _FALLDUST_NORMAL_ON
                float3 var_FallDustNormal = UnpackNormalScale(SAMPLE_TEXTURE2D(_FallDustNormal,sampler_FallDustNormal,uv),_FallDustNormalIntensity);
            #else 
                float3 var_FallDustNormal = float3(0.0,0.0,1.0);
            #endif
            //落灰PBR的通道
            float4 fallDustBaseColor = float4(lerp(pbr.baseColor.rgb,var_FallDustMainTex.rgb,_FallDustColorBlend),1);
            float3 fallDustNormal    = var_FallDustNormal;
            float3 fallDustEmission  = var_FallDustMainTex.rgb * _fallDustEmissionIntensity * var_FallDustPbrParam.a;
            float  fallDustMetallic  = var_FallDustPbrParam.r;
            float  fallDustRoughness = var_FallDustPbrParam.g;
            float  fallDustOcclustio = var_FallDustPbrParam.b;
            
            //高度融合mask
            vertexColor.r = pow(vertexColor.r,_HeightRadius + 0.01);
            float heightBlend = saturate(pow(   max(0.0,(((1 - pbr.baseColor.a * var_FallDustMainTex.a)*vertexColor.r)*4)+(vertexColor.r*2)),_HeightDepth + 0.1));//(1 - pbr.normal.a)比着原算法反向了一下高度图   此算法照搬的UE4的高度混合算法
            pbr.baseColor = lerp(pbr.baseColor,fallDustBaseColor,heightBlend);
            pbr.metallic      = lerp(pbr.metallic,fallDustMetallic,heightBlend);
            pbr.roughness = lerp(pbr.roughness,fallDustRoughness,heightBlend);
            if (_FallDustNormalBlend > 0.0) 
            {
                pbr.normal.xyz    = normalize(pbr.normal.xyz + fallDustNormal * heightBlend);
            }
            else
            {
                pbr.normal.xyz    = lerp(pbr.normal.xyz,fallDustNormal,heightBlend);
            }
            pbr.occlusion   = lerp(pbr.occlusion,fallDustOcclustio,heightBlend);
            pbr.emission    = lerp(pbr.emission,fallDustEmission,heightBlend);
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