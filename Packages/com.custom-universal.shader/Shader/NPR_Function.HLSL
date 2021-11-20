#ifndef NPR_FUNCTION_INCLUDE
    #define NPR_FUNCTION_INCLUDE
    
    #include "ShaderFunction.HLSL"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


    
    uniform TEXTURE2D(_RampTex);
    uniform SAMPLER(sampler_RampTex);

    uniform TEXTURE2D(_DebugGradient);
    uniform SAMPLER(sampler_DebugGradient);

    float3 NPR_Base_Ramp (float NdotL,float Night,float4 parameter)
    {
        float halfLambert = smoothstep(0.0,0.5,NdotL) * parameter.b;
        
        /* 
        Skin = 255
        Silk = 160
        Metal = 128
        Soft = 78
        Hand = 0
        */
        #if _DEBUGGRADIENT_ON//调试渐变贴图
            if (Night > 0.0)
            {
                return SAMPLE_TEXTURE2D(_DebugGradient, sampler_DebugGradient, float2(halfLambert, parameter.a * 0.45 + 0.55)).rgb;//因为分层材质贴图是一个从0-1的一张图 所以可以直接把他当作采样UV的Y轴来使用 
                //又因为白天需要只采样Ramp贴图的上半段，所以把他 * 0.45 + 0.55来限定范围 (范围 0.55 - 1.0)
            }
            else
            {
                return SAMPLE_TEXTURE2D(_DebugGradient, sampler_DebugGradient, float2(halfLambert, parameter.a * 0.45)).rgb;//因为晚上需要只采样Ramp贴图的上半段，所以把他 * 0.45来限定范围(其中如果采样0.5的话 会被上面的像素所影响)
            }
        #else
            if (Night > 0.0)
            {
                return SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, parameter.a * 0.45 + 0.55)).rgb;//因为分层材质贴图是一个从0-1的一张图 所以可以直接把他当作采样UV的Y轴来使用 
                //又因为白天需要只采样Ramp贴图的上半段，所以把他 * 0.45 + 0.55来限定范围 (范围 0.55 - 1.0)
            }
            else
            {
                return SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, parameter.a * 0.45)).rgb;//因为晚上需要只采样Ramp贴图的上半段，所以把他 * 0.45来限定范围(其中如果采样0.5的话 会被上面的像素所影响)
            }
        #endif
    }
    //高光部分
    // uniform TEXTURE2D(_MetalMap);
    // uniform SAMPLER(sampler_MetalMap);

    uniform float _MetalIntensity;
    /* float3 NPR_Base_Specular(float NdotL,float NdotH ,float3 normalDir,float3 baseColor,float4 parameter)
    {
        float Ks = 0.04;
        float3 viewNormal = normalize(mul(UNITY_MATRIX_V,normalDir)) * 0.5 + 0.5;//视空间法线向量，用于MatCap的UV采样
        
        float  SpecularPow = exp2(0.5 * parameter.r * 11.0 + 2.0);//这里乘以0.5是为了扩大高光范围
        float  SpecularNorm = (SpecularPow+8.0) / 8.0;
        float3 SpecularColor = baseColor * parameter.g;
        float SpecularContrib = baseColor * (SpecularNorm * pow(NdotH, SpecularPow));
        float4 var_MetalMap = SAMPLE_TEXTURE2D(_MetalMap,sampler_MetalMap, viewNormal * 0.5 + 0.5) * lerp(_MetalIntensity * 5,_MetalIntensity * 10,parameter.b);
        float3 MetalColor = var_MetalMap * baseColor * step(0.95,parameter.r);

        return SpecularColor * (SpecularContrib  * NdotL* Ks * parameter.b + MetalColor);
    }*/ //原始的
    
    float3 NPR_Base_Specular(float NdotL,float NdotH ,float3 normalDir,float3 baseColor,float4 parameter)//优化掉了金属贴图
    {
        float Ks = 0.04;
        
        float  SpecularPow = exp2(0.5 * parameter.r * 11.0 + 2.0);//这里乘以0.5是为了扩大高光范围
        float  SpecularNorm = (SpecularPow+8.0) / 8.0;
        float3 SpecularColor = baseColor * parameter.g;
        float SpecularContrib = baseColor * (SpecularNorm * pow(NdotH, SpecularPow));

        //原神的金属贴图（这里我使用了一种拟合曲线来模拟）
        float MetalDir = normalize(mul(UNITY_MATRIX_V,normalDir));
        float MetalRadius = saturate(1 - MetalDir) * saturate(1 + MetalDir);
        float MetalFactor = saturate(step(0.5,MetalRadius)+0.25) * 0.5 * saturate(step(0.15,MetalRadius) + 0.25) * lerp(_MetalIntensity * 5,_MetalIntensity * 10,parameter.b);
        
        float3 MetalColor = MetalFactor * baseColor * step(0.95,parameter.r);
        return SpecularColor * (SpecularContrib  * NdotL* Ks * parameter.b + MetalColor);
    }


    //边缘光
    uniform float _RimIntensity;
    uniform float _RimRadius;
    float3 NPR_Base_RimLight(float NdotV,float NdotL,float3 baseColor)
    {
        return (1 - smoothstep(_RimRadius,_RimRadius + 0.03,NdotV)) * _RimIntensity * (1 - (NdotL * 0.5 + 0.5 )) * baseColor;
    }
    //自发光(带有呼吸效果)
    uniform float _EmissionIntensity;
    float3 NPR_Emission(float4 baseColor)
    {
        return baseColor.a * baseColor * _EmissionIntensity * abs((frac(_Time.y * 0.5) - 0.5) * 2);
    }
    
    //主体部分  需要用到多个材质融合

    float3 NPR_Function_Base (float NdotL,float NdotH,float NdotV,float3 normalDir,float4 baseColor,float4 parameter,Light light,float Night)
    {
        float3 LightFactor = lerp(1.0,light.color,smoothstep(0.0,0.5,NdotL) * parameter.b * 2);//为了增强亮部

        float3 RampColor = NPR_Base_Ramp (NdotL,Night,parameter);
        float3 Albedo = baseColor * RampColor;
        float3 Specular = NPR_Base_Specular(NdotL,NdotH,normalDir,baseColor,parameter);
        float3 RimLight = NPR_Base_RimLight(NdotV,NdotL,baseColor) * parameter.b;
        float3 Emission = NPR_Emission(baseColor);
        float3 finalRGB = Albedo* (1 - parameter.r) + Specular + RimLight + Emission;
        return finalRGB;
    }
    

    //脸部
    uniform float _HairSpecularIntensity;
    float3 NPR_Function_face (float NdotL,float4 baseColor,float4 parameter,Light light,float Night)
    {
        

        float3 Up = float3(0.0,1.0,0.0);
        float3 Front = unity_ObjectToWorld._12_22_32;
        float3 Right = cross(Up,Front);
        float switchShadow  = dot(normalize(Right.xz), normalize(light.direction.xz)) < 0;
        float FaceShadow = lerp(1 - parameter.g,1 - parameter.r,switchShadow.r); //这里必须使用双通道来反转阴影贴图 因为需要让苹果肌那里为亮的
        float FaceShadowRange = dot(normalize(Front.xz), normalize(light.direction.xz));
        float lightAttenuation = 1 - smoothstep(FaceShadowRange - 0.05,FaceShadowRange + 0.05,FaceShadow);

        float3 LightFactor = lerp(1.0,light.color,smoothstep(0.2,0.4,lightAttenuation) * parameter.b);//为了增强亮部
        
        float3 rampColor = NPR_Base_Ramp(lightAttenuation * light.shadowAttenuation,Night,parameter);//这里的脸部参数贴图的Alpha必须是1

        return baseColor.rgb * rampColor;
    }

    //头发
    float3 NPR_Function_Hair (float NdotL,float NdotH,float NdotV,float3 normalDir,float3 viewDir,float3 baseColor,float4 parameter,Light light,float Night)
    {
        float3 LightFactor = lerp(1.0,light.color,smoothstep(0.0,0.5,NdotL) * parameter.b * 2);//为了增强亮部
        
        float3 RampColor = NPR_Base_Ramp (NdotL,Night,parameter);//头发的rampColor不应该把固定阴影的部分算进去，所以这里固定阴影给定0.5 到计算ramp的时候 *2 结果等于1  这个暂定
        float3 Albedo = baseColor * RampColor;
        
        float HariSpecRadius = 0.25;//这里可以控制头发的反射范围
        float HariSpecDir = normalize(mul(UNITY_MATRIX_V,normalDir)) * 0.5 + 0.5;
        float3 HariSpecular = smoothstep(HariSpecRadius,HariSpecRadius + 0.1,1 - HariSpecDir) * smoothstep(HariSpecRadius,HariSpecRadius + 0.1,HariSpecDir) *NdotL;//利用屏幕空间法线 

        
        float3 Specular = NPR_Base_Specular(NdotL,NdotH,normalDir,baseColor,parameter) + HariSpecular * _HairSpecularIntensity * 10 * parameter.g * step(parameter.r,0.1);
        // float3 Metal =  NPR_Base_Metal(normalDir,parameter,baseColor);
        float3 RimLight = NPR_Base_RimLight(NdotV,NdotL,baseColor);
        float3 finalRGB = Albedo* (1 - parameter.r) + Specular  + RimLight;
        return finalRGB;
    }

    //最终输出



#endif

