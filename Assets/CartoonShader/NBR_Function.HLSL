#ifndef NBR_FUNCTION_INCLUDE
    #define NBR_FUNCTION_INCLUDE
    


    uniform sampler2D _Matcap;
    //D项 法线微表面分布函数
    float D_Function (float NdotH,float roughness)
    {
        float a      = roughness*roughness;
        float a2     = a*a;
        float NdotH2 = NdotH*NdotH;
        float nom   = a2;
        float denom = (NdotH2 * (a2 - 1.0) + 1.0);
        denom = UNITY_PI * denom * denom;
        float D = nom / denom;
        return D;
    }
    //0.8560542170328335
    //G项 几何函数
    float G_SubFunction(float NdotW , float K)
    {
        return NdotW / lerp(NdotW,1.0,K);
    }
    float G_Function (float NdotL,float NdotV,float roughness,float lightMap)
    {
        float K = (1.0+roughness) * (1.0+roughness) / 8;
        return G_SubFunction(smoothstep(0.01,0.1,NdotL),K) * G_SubFunction(NdotV,K) * lightMap;
    }

    //直接光F项
    float3 F_Light_Function(float HdotL, float3 F0)
    {
        float fresnel = exp2((-5.55473 * HdotL - 6.98316) * HdotL);
        return lerp(fresnel,1.0,F0);
    }
    //间接光F项
    float3 F_Indir_Function(float NdotV,float roughness,float3 F0)
    {
        float fresnel = exp2((-5.55473 * NdotV - 6.98316) * NdotV);
        return F0 + fresnel * saturate(1 - roughness - F0);
    }
    //直接光镜面反射 
    float3 DGF_Function(float NdotH,float NdotL,float NdotV,float HdotL,float roughness,float lightMap,float3 F0)
    {
        float  D = D_Function(NdotH,roughness);
        float  G = G_Function(NdotL,NdotV,roughness,lightMap);
        float3 F = F_Light_Function(HdotL,F0);
        float3 light_BRDF = saturate(( D * G * F ) / (4 * NdotL * NdotV + 0.001));//这里我自行修改了一下 把他限制在0-1
        light_BRDF = saturate(light_BRDF  * NdotL * UNITY_PI);
        return light_BRDF * saturate(1 - pow(roughness,0.1)) *  5 * _LightColor0.rgb; ///////////NPR的硬阴影
        
    }
    //直接光照漫反射
    float3 lightDiffuse_Function(float HdotL,float NdotL , float3 baseColor,float metallic,float3 F0)
    {
        float3 KS = F_Light_Function(HdotL,F0);
        float3 KD = (1 - KS) * (1 - metallic);
        return KD * baseColor * _LightColor0.rgb * smoothstep(0.11,0.2,NdotL); 
    }

    

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////间接光部分
    //LUT拟合曲线
    float2 LUT_Approx(float roughness, float NoV )
    {
        // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
        // Adaptation to fit our G term.
        const float4 c0 = { -1, -0.0275, -0.572, 0.022 };
        const float4 c1 = { 1, 0.0425, 1.04, -0.04 };
        float4 r = roughness * c0 + c1;
        float a004 = min( r.x * r.x, exp2( -9.28 * NoV ) ) * r.x + r.y;
        float2 AB = float2( -1.04, 1.04 ) * a004 + r.zw;
        return saturate(AB);
    }
    //间接光漫反射
    float3 indirectionDiffuse_Function(float NdotV,float3 normalDir,float metallic,float3 baseColor,float roughness,float3 F0)
    {
        float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT;//和下面那个二选一
        float3 SHColor = ShadeSH9(float4(normalDir,1));

        float3 KS = F_Indir_Function(NdotV,roughness,F0);
        float3 KD = (1 - KS) * (1 - metallic);
        return SHColor * KD * baseColor;//这里可以乘以一个AO
    }

    //间接光镜面反射
    float3 indirectionSpec_Function(float3 normalDir,float3 baseColor,float roughness,float NdotV,float3 F0)
    {
        //采样环境贴图
        float mip = roughness * (1.7 - 0.7 * roughness) * UNITY_SPECCUBE_LOD_STEPS ;
        //float3 indirectionCube = texCUBElod(_cube, float4(normalDir, mip));
        float3 indirectionCube = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, normalDir, mip);
        //indirectionCube = DecodeHDR(indirectionCube, unity_SpecCube0_HDR);

        float2 matcapUV   = mul((float3x3)UNITY_MATRIX_V, normalDir).xy * 0.5 +0.5;
        float3 var_Matcap= tex2Dlod(_Matcap,float4(matcapUV,0,mip)).rgb;
        

        //拟合曲线
        float2 LUT = LUT_Approx(roughness,NdotV);
        float3 F_IndirectionLight = F_Indir_Function(NdotV,roughness,F0);//环境菲尼尔
        float3 indirectionSpecFactor = var_Matcap.rgb  * (F_IndirectionLight * LUT.r + LUT.g);
        return indirectionSpecFactor;
    }
    
    //计算直接光照的贡献
    float3 lightContribution(float NdotH,float NdotL,float NdotV,float HdotL,float roughness,float3 baseColor,float metallic,float lightMap,float3 F0)
    {
        return lightDiffuse_Function(HdotL,NdotL,baseColor,metallic,F0) + DGF_Function(NdotH,NdotL,NdotV,HdotL,roughness,lightMap,F0);
    }
    
    //计算环境光照的贡献
    float3 indirectionContribution(float3 normalDir,float NdotV,float3 baseColor,float roughness,float metallic,float3 F0)
    {
        float3 indirectionDiffuse = indirectionDiffuse_Function(NdotV,normalDir,metallic,baseColor,roughness,F0);
        float3 indirectionSpec    = indirectionSpec_Function(normalDir,baseColor,roughness,NdotV,F0);
        return indirectionDiffuse + indirectionSpec;
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //计算自发光
    float3 emission_Function(float3 emission)
    {
        return emission;
    }

    float3 PBR_Function (float3 worldTangent,float3 worldBitangent,float3 worldNormal,float3 worldView,PBR pbr)
    {
        
        //参数输入
        float3 baseColor = pbr.baseColor;
        float  roughness = pbr.roughness;
        float  metallic  = pbr.metallic;
        float  emission  = pbr.emission;
        float  lightMap  = pbr.lightMap;
        float3 F0 = lerp(0.04,baseColor,metallic);
        //向量准备
        float3 normalDir  = normalize(worldNormal);
        float3 viewDir    = normalize(worldView);
        float3 lightDir   = normalize(_WorldSpaceLightPos0.xyz);
        float3 halfDir    = normalize(lightDir + viewDir);

        
        //点乘结果
        float NdotH = max(0.00001,dot(normalDir,halfDir));
        float NdotL = max(0.00001,dot(normalDir,lightDir));
        float NdotV = max(0.00001,dot(normalDir,viewDir));
        float HdotL = max(0.00001,dot(halfDir,lightDir));
        

        float3 lighting = lightContribution(NdotH,NdotL,NdotV,HdotL,roughness,baseColor,metallic,lightMap,F0);
        float3 indirection = indirectionContribution(normalDir,NdotV,baseColor,roughness,metallic,F0);
        float3 emissionLight = emission_Function(emission);

        return lighting + indirection ;
    }


    #define PBR_FUNCTION(i,pbr) PBR_Function(i.worldTangent,i.worldBitangent,i.worldNormal,i.worldView,pbr);

#endif