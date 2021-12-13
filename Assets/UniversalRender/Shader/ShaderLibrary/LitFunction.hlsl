#ifndef PBR_FUNCTION_INCLUDE
    #define PBR_FUNCTION_INCLUDE
    
    #include "ShaderFunction.HLSL"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


    //D项 法线微表面分布函数
    float D_Function (float NdotH,float roughness)
    {
        float alpha = roughness * roughness;
        float tmp = alpha / max(1e-8,(NdotH*NdotH*(alpha*alpha-1.0)+1.0));
        return tmp * tmp * INV_PI;
    }

    //G项 几何函数
    float G_SubFunction(float NdotW , float K)
    {
        return NdotW / ( NdotW*(1.0 - K) + K );//这里跟Substance有区别 Substance是     1 / ( NdotW*(1.0 - K) + K )
    }
    float G_Function (float NdotL,float NdotV,float roughness)
    {
        float K = roughness * roughness * 0.5;
        return G_SubFunction(NdotL,K) * G_SubFunction(NdotV,K);
    }

    //F项 菲涅尔函数
    float3 F_Function (float NdotW, float3 F0)
    {
        float sphg = pow (2.0, (-5.55473 * NdotW - 6.98316) * NdotW);
        return F0 + (1.0 - F0) * sphg;
    }



    //直接光镜面反射 
    float3 lightSpecular_Function(float NdotH,float NdotL,float NdotV,float HdotL,float roughness,float3 lightColor,float3 F0)
    {
        float  D = D_Function(NdotH,roughness);
        float  G = G_Function(NdotL,NdotV,roughness);
        float3 F = F_Function(HdotL,F0);
        float3 light_BRDF = F * (D * G / 4.0);

        return light_BRDF * PI * lightColor;//为了分流BRDF 所以单独乘以lightColor
    }
    //直接光照漫反射
    float3 lightDiffuse_Function(float HdotL,float NdotL , float3 baseColor,float metallic,float3 lightColor,float3 F0)
    {
        float3 KS = F_Function(HdotL,F0);
        float3 KD = (1 - KS) * (1 - metallic);
        return KD * baseColor * NdotL * lightColor;//为了分流BRDF 所以单独乘以lightColor
    }

    //LUT拟合曲线
    float2 LUT_Approx(float roughness, float NdotV,float3 F0 )
    {
        float4 p0 = float4( 0.5745, 1.548, -0.02397, 1.301 );
        float4 p1 = float4( 0.5753, -0.2511, -0.02066, 0.4755 );
        float4 t = (1 - roughness) * p0 + p1;
        float bias = saturate( t.x * min( t.y, exp2( -7.672 * NdotV ) ) + t.z );
        float delta = saturate( t.w );
        float scale = delta - bias;
        bias *= saturate( 50.0 * F0.y );
        return F0 * scale + bias;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////间接光部分

    //间接光漫反射
    float3 indirectionDiffuse(float NdotV,float3 normalDir,float metallic,float3 baseColor,float roughness,float occlusion,float3 F0)
    {
        float3 SHColor = SampleSH(normalDir);
        float3 KS = F_Function(NdotV,F0);
        float3 KD = (1 - KS) * (1 - metallic);
        return SHColor * KD * baseColor * occlusion;//这里可以乘以一个AO
    }

    //间接光镜面反射
    float3 indirectionSpecular(float3 reflectDir,float roughness,float NdotV,float occlusion,float3 F0)
    {
        //采样环境贴图
        float mip = roughness * (1.7 - 0.7 * roughness) * UNITY_SPECCUBE_LOD_STEPS ;
        float3 indirectionCube = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0,samplerunity_SpecCube0, reflectDir, mip).rgb;
        #if !defined(UNITY_USE_NATIVE_HDR)//如果使用本地HDR
            indirectionCube = DecodeHDREnvironment(float4(indirectionCube,1), unity_SpecCube0_HDR);
        #else
            indirectionCube = indirectionCube;
        #endif
        //拟合曲线
        float2 LUT = LUT_Approx(roughness,NdotV,F0);
        float3 F_IndirectionLight = F_Function(NdotV,F0);
        float3 indirectionSpecFactor = indirectionCube.rgb  * (F_IndirectionLight * LUT.r + LUT.g);
        return indirectionSpecFactor  *  occlusion;
    }
    
    //主光源Diffuse计算
    float3 MainLightDiffuse(float3 normalDir,float3 viewDir,float3 worldPos,float3 baseColor,float metallic,float3 F0)
    {
        float4 SHADOW_COORDS = TransformWorldToShadowCoord(worldPos);
        Light light = GetMainLight(SHADOW_COORDS);
        //准备向量
        float3 lightDir   = normalize(light.direction);
        float3 halfDir    = normalize(lightDir + viewDir);
        //点乘结果
        float NdotL = max(0.00001,dot(normalDir,lightDir));
        float HdotL = max(0.00001,dot(halfDir,lightDir));
        light.color *= light.shadowAttenuation  * light.distanceAttenuation * CloudShadow(worldPos);
        return lightDiffuse_Function(HdotL,NdotL,baseColor,metallic,light.color,F0);
    }

    //主光源Specular计算
    float3 MainLightSpecular(float NdotV,float3 normalDir,float3 viewDir,float3 worldPos,float roughness,float3 F0)
    {
        float4 SHADOW_COORDS = TransformWorldToShadowCoord(worldPos);
        Light light = GetMainLight(SHADOW_COORDS);
        //准备向量
        float3 lightDir   = normalize(light.direction);
        float3 halfDir    = normalize(lightDir + viewDir);
        //点乘结果
        float NdotH = max(0.00001,dot(normalDir,halfDir));
        float NdotL = max(0.00001,dot(normalDir,lightDir));
        float HdotL = max(0.00001,dot(halfDir,lightDir));
        light.color *= light.shadowAttenuation  * light.distanceAttenuation * CloudShadow(worldPos);
        return lightSpecular_Function(NdotH,NdotL,NdotV,HdotL,roughness,light.color,F0);
    }
    
    
    //额外光源Diffuseii算
    float3 AdditionaLightDiffuse (float3 normalDir,float3 viewDir,float3 worldPos,float3 baseColor,float metallic,float3 F0)
    {
        float3 lighting = float3(0.0,0.0,0.0);
        InputData inputData; //貌似是unity的内部数据
        int addLightsCount = GetAdditionalLightsCount();
        for(int idx = 0; idx < addLightsCount; idx++)
        {
            Light light = GetAdditionalLight(idx, worldPos,inputData.shadowMask);
            //准备向量
            float3 lightDir   = normalize(light.direction);
            float3 halfDir    = normalize(lightDir + viewDir);
            //点乘结果
            float NdotL = max(0.00001,dot(normalDir,lightDir));
            float HdotL = max(0.00001,dot(halfDir,lightDir));

            light.color *= light.shadowAttenuation  * light.distanceAttenuation;
            // addlight.color *= addlight.distanceAttenuation  * addlight.shadowAttenuation;
            lighting += lightDiffuse_Function(HdotL,NdotL,baseColor,metallic,light.color,F0);
            // lighting += light.shadowAttenuation;
        }
        return lighting;
    }
    //额外光源Specular计算
    float3 AdditionaLightSpecular (float NdotV,float3 normalDir,float3 viewDir,float3 worldPos,float roughness,float3 F0)
    {
        float3 lighting = float3(0.0,0.0,0.0);
        InputData inputData; //貌似是unity的内部数据
        int addLightsCount = GetAdditionalLightsCount();
        for(int idx = 0; idx < addLightsCount; idx++)
        {
            Light light = GetAdditionalLight(idx, worldPos,inputData.shadowMask);
            //准备向量
            float3 lightDir   = normalize(light.direction);
            float3 halfDir    = normalize(lightDir + viewDir);
            //点乘结果
            float NdotH = max(0.00001,dot(normalDir,halfDir));
            float NdotL = max(0.00001,dot(normalDir,lightDir));
            float HdotL = max(0.00001,dot(halfDir,lightDir));

            light.color *= light.shadowAttenuation  * light.distanceAttenuation;
            // addlight.color *= addlight.distanceAttenuation  * addlight.shadowAttenuation;
            lighting += lightSpecular_Function(NdotH,NdotL,NdotV,HdotL,roughness,light.color,F0);
            // lighting += light.shadowAttenuation;
        }
        return lighting;
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //PBR计算   
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //计算直接光照的贡献
    float3 lightContribution(float NdotH,float NdotL,float NdotV,float HdotL,float roughness,float3 baseColor,float metallic,float3 lightColor,float3 F0)
    {
        
        float3 MainLightDiffuse = lightDiffuse_Function(HdotL,NdotL,baseColor,metallic,lightColor,F0);
        float3 MainLightSpecular    = lightSpecular_Function(NdotH,NdotL,NdotV,HdotL,roughness,lightColor,F0);
        return (MainLightDiffuse + MainLightSpecular);//灯光和阴影在这里-----------------------------
    }
    
    //计算环境光照的贡献
    float3 indirectionContribution(float3 reflectDir,float3 normalDir,float NdotV,float3 baseColor,float roughness,float metallic,float occlusion,float3 F0)
    {
        float3 indirectionDiff = indirectionDiffuse(NdotV,normalDir,metallic,baseColor,roughness,occlusion,F0);
        float3 IndirectionSpec    = indirectionSpecular(reflectDir,roughness,NdotV,occlusion,F0);
        return (indirectionDiff + IndirectionSpec);//环境遮蔽在这里---------------------------------------
    }
    
    //计算主光源贡献
    float3 MainLightContribution(float3 worldPos,float3 normalDir,float3 viewDir,float NdotV,float roughness,float3 baseColor,float metallic,float3 F0)
    {
        float4 SHADOW_COORDS = TransformWorldToShadowCoord(worldPos);
        Light light = GetMainLight(SHADOW_COORDS);
        //准备向量
        float3 lightDir   = normalize(light.direction);
        float3 halfDir    = normalize(lightDir + viewDir);
        //点乘结果
        float NdotH = max(0.00001,dot(normalDir,halfDir));
        float NdotL = max(0.00001,dot(normalDir,lightDir));
        float HdotL = max(0.00001,dot(halfDir,lightDir));
        float3  lightColor = light.color * light.shadowAttenuation  * light.distanceAttenuation * CloudShadow(worldPos);
        return lightContribution(NdotH,NdotL,NdotV,HdotL,roughness,baseColor,metallic,lightColor,F0);
    }
    //计算额外光源贡献
    float3 additionaLightContribution (float NdotV,float3 normalDir,float3 viewDir,float3 worldPos,float3 baseColor,float roughness,float metallic,float3 F0)
    {
        float3 lighting = float3(0.0,0.0,0.0);
        InputData inputData; //貌似是unity的内部数据
        int addLightsCount = GetAdditionalLightsCount();
        for(int idx = 0; idx < addLightsCount; idx++)
        {
            Light light = GetAdditionalLight(idx, worldPos,inputData.shadowMask);
            //准备向量
            float3 lightDir   = normalize(light.direction);
            float3 halfDir    = normalize(lightDir + viewDir);
            //点乘结果
            float NdotH = max(0.00001,dot(normalDir,halfDir));
            float NdotL = max(0.00001,dot(normalDir,lightDir));
            float HdotL = max(0.00001,dot(halfDir,lightDir));

            light.color *= light.shadowAttenuation  * light.distanceAttenuation;
            // addlight.color *= addlight.distanceAttenuation  * addlight.shadowAttenuation;
            lighting += lightContribution(NdotH,NdotL,NdotV,HdotL,roughness,baseColor,metallic,light.color,F0);
            // lighting += light.shadowAttenuation;
        }
        return lighting;
    }
    
    //计算自发光
    float3 emission_Function(float3 emission)
    {
        return emission;
    }
    
    float3 PBR_Function(float3 worldTangent,float3 worldBitangent,float3 worldNormal,float3 worldView,float3 worldPos,float3 baseColor,float3 normal,float roughness,float metallic,float3 emission,float occlusion)
    {
        //参数输入
        float3 F0 = lerp(0.04,baseColor,metallic);

        //法线计算
        float3x3 TBN = float3x3(normalize(worldTangent),normalize(worldBitangent),normalize((worldNormal)));
        //各种光公用向量准备
        float3 normalDir  = mul(normal,TBN);//映射法线  *2-1的操作在这里执行
        float3 viewDir    = normalize(worldView);
        float3 reflectDir = normalize(reflect(-viewDir,normalDir));

        float NdotV = max(0.00001,dot(normalDir,viewDir));
        // #ifdef LIGHTMAP_ON
        //     float3 var_Lightmap = DecodeLightmap (UNITY_SAMPLE_TEX2D(unity_Lightmap,i.lightmapUV.xy));
        //     occlusion = pbr.occlusion * var_Lightmap.r;
        //     shadow    =  var_Lightmap.g;
        // #else
        //     occlusion = pbr.occlusion;
        //     shadow    = light.shadowAttenuation * CloudShadow(worldPos);;   //* CLOUD_SHADOW(i)
        // #endif

        float3 Mainlighting = MainLightContribution(worldPos,normalDir,viewDir,NdotV,roughness,baseColor,metallic,F0);
        float3 AdditionaLighting = additionaLightContribution (NdotV,normalDir,viewDir,worldPos,baseColor,roughness,metallic,F0);
        float3 indirection = indirectionContribution(reflectDir,normalDir,NdotV,baseColor,roughness,metallic,occlusion,F0);
        float3 emissionLight = emission_Function(emission);
        float NdotL = max(0.0,dot(normalDir,_MainLightPosition));

        return Mainlighting + AdditionaLighting + indirection + emissionLight;
    }

    #define PBR_FUNCTION(i,pbr)  PBR_Function(i.worldTangent,i.worldBitangent,i.worldNormal,i.worldView,i.worldPos,pbr.baseColor.rgb,pbr.normal.xyz,pbr.roughness,pbr.metallic,pbr.emission,pbr.occlusion);
    




    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //补充项

    //视差映射UV计算
    // #pragma shader_feature _PARALLAX_ON 
    // inline float2 POM( TEXTURE2D_PARAM(_Texture, sampler_Texture), float2 uvs, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples,int sectionSteps, float parallax, float refPlane,float vertexColor,float _BlendHeight)
    // {
        //     int stepIndex = 0;
        //     int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, saturate( dot( normalWorld, viewWorld ) ) );
        //     float layerHeight = 1.0 / numSteps;
        //     float2 plane = parallax  * ( viewDirTan.xy / viewDirTan.z );
        //     uvs += lerp(refPlane,_BlendHeight,vertexColor.r) * plane;//这里增加了顶点色影响 后面要看有没有问题
        //     float2 deltaTex = -plane * layerHeight;
        //     float2 prevTexOffset = 0;
        //     float prevRayZ = 1.0f;
        //     float prevHeight = 0.0f;
        //     float2 currTexOffset = deltaTex;
        //     float currRayZ = 1.0f - layerHeight;
        //     float currHeight = 0.0f;
        //     float intersection = 0;
        //     float2 finalTexOffset = 0;
        //     float2 dx = ddx(uvs);
        //     float2 dy = ddy(uvs);
        //     while ( stepIndex < numSteps + 1 )
        //     {
            //         // currHeight = SAMPLE_TEXTURE2D(_Texture,sampler_Texture,uvs + currTexOffset, dx, dy ).a;
            //         currHeight = tex2D( _MainTex, uvs + currTexOffset, dx, dy ).a;
            //         currHeight = lerp(currHeight,1.0,vertexColor);
            //         if ( currHeight > currRayZ )
            //         {
                //             stepIndex = numSteps + 1;
            //         }
            //         else
            //         {
                //             stepIndex++;
                //             prevTexOffset = currTexOffset;
                //             prevRayZ = currRayZ;
                //             prevHeight = currHeight;
                //             currTexOffset += deltaTex;
                //             currRayZ -= layerHeight;
            //         }
        //     }
        //     int sectionIndex = 0;
        //     float newZ = 0;
        //     float newHeight = 0;
        //     while ( sectionIndex < sectionSteps )
        //     {
            //         intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
            //         finalTexOffset = prevTexOffset + intersection * deltaTex;
            //         newZ = prevRayZ - intersection * layerHeight;
            //         newHeight = tex2D( _MainTex, uvs + finalTexOffset, dx, dy ).a;
            //         newHeight = lerp(newHeight,1.0,vertexColor);
            //         if ( newHeight > newZ )
            //         {
                //             currTexOffset = finalTexOffset;
                //             currHeight = newHeight;
                //             currRayZ = newZ;
                //             deltaTex = intersection * deltaTex;
                //             layerHeight = intersection * layerHeight;
            //         }
            //         else
            //         {
                //             prevTexOffset = finalTexOffset;
                //             prevHeight = newHeight;
                //             prevRayZ = newZ;
                //             deltaTex = ( 1 - intersection ) * deltaTex;
                //             layerHeight = ( 1 - intersection ) * layerHeight;
            //         }
            //         sectionIndex++;
        //     }
        //     return uvs + finalTexOffset;
    // }

    // CBUFFER_START(UnityPreMaterial)
    // uniform int _SectionSteps,_MinSample,_MaxSample;
    // uniform float _PomScale,_HeightScale;
    // uniform float _BlendHeight;
    // CBUFFER_END
    //视差映射计算
    // void Parallax (float4 vertexColor,float3 worldTangent,float3 worldBitangent, float3 worldNormal,float3 worldPos,float3 worldView,TEXTURE2D_PARAM(_Texture, sampler_Texture),inout float2 uv)//这里是用的法线的A通道来作为高度
    // {
        
        
        //     worldNormal = normalize(worldNormal);
        //     float3 worldViewDir = normalize(worldView);
        //     float3 tangenWorld_X = float3(worldTangent.x,worldBitangent.x,worldNormal.x);
        //     float3 tangenWorld_Y = float3(worldTangent.y,worldBitangent.y,worldNormal.y);
        //     float3 tangenWorld_Z = float3(worldTangent.z,worldBitangent.z,worldNormal.z);
        //     float3 tangentViewDir = normalize(tangenWorld_X * worldViewDir.x + tangenWorld_Y * worldViewDir.y + tangenWorld_Z * worldViewDir.z);
        
        //     uv = POM(_Texture,sampler_Texture, uv, worldNormal, worldViewDir, tangentViewDir, _MinSample, _MaxSample,_SectionSteps, _PomScale * 0.1, _HeightScale,vertexColor.r,_BlendHeight);
        
    // }
    // #define PBR_PARALLAX(i,_MainTex)  Parallax(i.vertexColor,i.worldTangent,i.worldBitangent,i.worldNormal,i.worldPos,i.worldView,_MainTex,i.uv)  //不知道怎么在采样贴图的时候使用 dx,dy 故后面查阅资料后再弄

    
#endif

