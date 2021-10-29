#ifndef NPR_FUNCTION_INCLUDE
    #define NPR_FUNCTION_INCLUDE
    
    #include "ShaderFunction.HLSL"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

    float3 NPR_Function (float3 worldTangent,float3 worldBitangent,float3 worldNormal,float3 worldView,float3 worldPos,float2 lightmapUV,NPR npr)
    {
        
        Light light = GetMainLight(SHADOW_COORDS);
        //参数输入
        float3 baseColor = pbr.baseColor.rgb;
        float3 normal    = pbr.normal.xyz;
        float  roughness = pbr.roughness;
        float  metallic  = pbr.metallic;
        float3  emission  = pbr.emission;

        float  occlusion = pbr.occlusion;;
        float  shadow = light.shadowAttenuation * CloudShadow(worldPos);

        
        // #ifdef LIGHTMAP_ON
        //     float3 var_Lightmap = DecodeLightmap (UNITY_SAMPLE_TEX2D(unity_Lightmap,lightmapUV.xy));
        //     occlusion = pbr.occlusion * var_Lightmap.r;
        //     shadow    =  var_Lightmap.g;
        // #else
        //     occlusion = pbr.occlusion;
        //     shadow    = light.shadowAttenuation * CloudShadow(worldPos);;   //* CLOUD_SHADOW(i)
        // #endif

        float3 F0 = lerp(0.04,baseColor,metallic);
        //法线计算
        float3x3 TBN = float3x3(normalize(worldTangent),normalize(worldBitangent),normalize(worldNormal));
        //向量准备
        float3 normalDir  = mul(pbr.normal,TBN);//映射法线  *2-1的操作在这里执行
        float3 viewDir    = normalize(worldView);
        float3 lightDir   = normalize(light.direction);
        float3 halfDir    = normalize(lightDir + viewDir);
        float3 reflectDir = normalize(reflect(viewDir,normalDir));
        //点乘结果
        float NdotH = max(0.00001,dot(normalDir,halfDir));
        float NdotL = max(0.00001,dot(normalDir,lightDir));
        float NdotV = max(0.00001,dot(normalDir,viewDir));
        float HdotL = max(0.00001,dot(halfDir,lightDir));
        
        float3 lighting = lightContribution(NdotH,NdotL,NdotV,HdotL,roughness,baseColor,metallic,shadow,light,F0);
        float3 indirection = indirectionContribution(reflectDir,normalDir,NdotV,baseColor,roughness,metallic,occlusion,F0);
        float3 emissionLight = emission_Function(emission);
        
        return lighting +indirection + emissionLight;
    }

    #define NPR_FUNCTION(i,pbr) NPR_Function(i.worldTangent,i.worldBitangent,i.worldNormal,i.worldView,i.worldPos,i.lightmapUV,pbr);
    
#endif

