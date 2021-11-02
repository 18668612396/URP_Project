#ifndef NPR_FUNCTION_INCLUDE
    #define NPR_FUNCTION_INCLUDE
    
    #include "ShaderFunction.HLSL"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"





    uniform TEXTURE2D(_RampTex);
    uniform SAMPLER(sampler_RampTex);

    float3 Ramp_Function(float NdotL,NPR npr)
    {
        float rampValue = NdotL * 0.5 + 0.5;
        float3 ramp01 = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(rampValue,0.75)).rgb;
        return ramp01;
    }

    //直接光F项
    float3 F_Light_Function (float HdotL, float3 F0)
    {
        float fresnel = exp2((-5.55473 * HdotL - 6.98316) * HdotL);
        return lerp(fresnel,1.0,F0);
    }
    //直接光镜面反射 
    float3 lightSpecular_Function(float NdotH,float NdotL,float NdotV,float HdotL,float roughness,float3 F0)
    {
        roughness = saturate(roughness + 0.02);
        float a    = roughness*roughness;
        float a2     = a*a;
        float NdotH2 = NdotH*NdotH;
        float nom   = a2;
        float denom = (NdotH2 * (a2 - 1.0) + 1);
        denom = denom * denom;

        float3 KS = F_Light_Function(HdotL,F0);
        return step(0.99,nom / denom) * (1 - roughness) * KS;
    }

    //直接光照漫反射
    float3 lightDiffuse_Function(float HdotL,float NdotL , float3 baseColor,float metallic,float3 F0)
    {
        float3 KS = F_Light_Function(HdotL,F0);
        float3 KD = (1 - KS) * (1 - metallic);
        return KD * baseColor * NdotL;
    }

    //计算直接光照的贡献
    float3 lightContribution(float NdotH,float NdotL,float NdotV,float HdotL,float roughness,float3 baseColor,float metallic,float shadow,Light light,float3 F0)
    {
        
        float3 lightDiffuse = lightDiffuse_Function(HdotL,NdotL,baseColor,metallic,F0);
        float3 lightSpec    = lightSpecular_Function(NdotH,NdotL,NdotV,HdotL,roughness,F0);
        return (lightDiffuse + lightSpec) * light.color * shadow;//灯光和阴影在这里-----------------------------
    }

    //主体部分  需要用到多个材质融合
    float3 NPR_Function_Body (float NdotL,NPR npr)
    {

        return Ramp_Function(NdotL,npr);
    }

    //脸部
    float3 NPR_Function_face (NPR npr)
    {
        return npr.baseColor;
    }

    //头发
    float3 NPR_Function_Hair (NPR npr)
    {
        
        return npr.baseColor;
    }
    //最终输出
    float3 NPR_Function(float3 worldPos,float3 worldNormal,float3 worldView,NPR npr)
    {
        float4 SHADOW_COORDS = TransformWorldToShadowCoord(worldPos);
        Light light = GetMainLight(SHADOW_COORDS);

        //参数输入
        float3 baseColor = npr.baseColor.rgb;
        float  roughness = npr.roughness;
        float  metallic  = npr.metallic;


        float  shadow = light.shadowAttenuation;
        //向量准备
        float3 normalDir  = normalize(worldNormal);//映射法线  *2-1的操作在这里执行
        float3 viewDir    = normalize(worldView);
        float3 lightDir   = normalize(light.direction);
        float3 halfDir    = normalize(lightDir + viewDir);
        float3 reflectDir = normalize(reflect(viewDir,normalDir));
        //点乘结果
        float NdotH = max(0.00001,dot(normalDir,halfDir));
        float NdotL = max(0.00001,dot(normalDir,lightDir));
        float NdotV = max(0.00001,dot(normalDir,viewDir));
        float HdotL = max(0.00001,dot(halfDir,lightDir));

        float3 F0 = lerp(0.04,baseColor,metallic);




        float3 finalRGB = float3(0.0,0.0,0.0);
        #if _SHADERENUM_BODY
            finalRGB = NPR_Function_Body(NdotL,npr);
        #elif _SHADERENUM_FACE
            finalRGB = NPR_Function_face(npr);
        #elif _SHADERENUM_HAIR
            finalRGB = NPR_Function_Hair(npr);
        #endif
        return lightSpecular_Function(NdotH,NdotL,NdotV,HdotL,roughness,F0);
        return finalRGB;
    }
    #define NPR_FUNCTION(i,npr) NPR_Function(i.worldPos,i.worldNormal,i.worldView,npr);


#endif

