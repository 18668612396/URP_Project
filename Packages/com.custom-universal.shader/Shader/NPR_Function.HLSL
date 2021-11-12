#ifndef NPR_FUNCTION_INCLUDE
    #define NPR_FUNCTION_INCLUDE
    
    #include "ShaderFunction.HLSL"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"



    uniform TEXTURE2D(_RampTex);
    uniform SAMPLER(sampler_RampTex);

    float3 NPR_Base_Ramp (float NdotL,float Night,float4 parameter)
    {
        float halfLambert = smoothstep(0.0,0.5,NdotL) * parameter.b * 2;
        /* 
        Skin = 255
        Silk = 160
        Metal = 128
        Soft = 78
        Hand = 0
        */
        if (Night > 0.0)
        {
            return SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, parameter.a * 0.45 + 0.55)).rgb;//因为分层材质贴图是一个从0-1的一张图 所以可以直接把他当作采样UV的Y轴来使用 
            //又因为白天需要只采样Ramp贴图的上半段，所以把他 * 0.45 + 0.55来限定范围 (范围 0.55 - 1.0)
        }
        else
        {
            return SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, parameter.a * 0.45)).rgb;//因为晚上需要只采样Ramp贴图的上半段，所以把他 * 0.45来限定范围(其中如果采样0.5的话 会被上面的像素所影响)
        }
    }
    //高光部分
    uniform float _HairSpecularIntensity;
    float3 NPR_Base_Specular(float NdotH ,float3 baseColor,float4 parameter)
    {
        float  SpecularRadius = pow(NdotH,parameter.r * 50);//将金属通道作为高光的范围控制  金属的部分高光集中  非金属的部分高光分散
        float3 SpecularColor  = parameter.g * baseColor;
        #if _SHADERENUM_HAIR
            return smoothstep(0.3,0.4,SpecularRadius) * SpecularColor * lerp(_HairSpecularIntensity,1,step(0.9,parameter.r));//如果是材质是头发的话  头发部分的高光强度自定
        #endif
        return smoothstep(0.3,0.4,SpecularRadius) * SpecularColor * parameter.r;//
    }
    //金属部分
    uniform TEXTURE2D(_Matcap);
    uniform SAMPLER(sampler_Matcap);
    float3 NPR_Base_Metal(float3 normalDir,float4 parameter,float3 baseColor)
    {
        float3 viewNormal = normalize(mul(UNITY_MATRIX_V,normalDir));//视空间法线向量，用于MatCap的UV采样
        float var_Matcap = SAMPLE_TEXTURE2D(_Matcap,sampler_Matcap,viewNormal * 0.5 + 0.5) * 2;
        float MetalColorMask = step(0.99,parameter.r);
        return var_Matcap * baseColor * parameter.r;
    }
    uniform float _RimIntensity;
    uniform float _RimRadius;
    
    //边缘光
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
        
        float3 RampColor = NPR_Base_Ramp (NdotL,Night,parameter);
        float3 Albedo = baseColor * RampColor;
        float3 Specular = NPR_Base_Specular(NdotH,baseColor,parameter);
        float3 Metal =  NPR_Base_Metal(normalDir,parameter,baseColor);
        float3 RimLight = NPR_Base_RimLight(NdotV,NdotL,baseColor) * parameter.b;
        float3 Emission = NPR_Emission(baseColor);
        float3 finalRGB = Albedo* (1 - parameter.r) + Specular + Metal + RimLight + Emission;
        return finalRGB;
    }
    

    //脸部
    float3 NPR_Function_face (float4 baseColor,float4 var_FaceShadow,Light light,float Night)
    {


        float3 Up = float3(0.0,1.0,0.0);
        float3 Front = unity_ObjectToWorld._12_22_32;
        float3 Right = cross(Up,Front);
        float switchShadow  = dot(normalize(Right.xz), normalize(light.direction.xz))*0.5+0.5 < 0.5;
        float FaceShadow = lerp(1 - var_FaceShadow.g,1 - var_FaceShadow.r,switchShadow.r);
        float FaceShadowRange = dot(normalize(Front.xz), normalize(light.direction.xz));
        float lightAttenuation = 1 - smoothstep(FaceShadowRange - 0.1,FaceShadowRange + 0.1,FaceShadow);
        float3 rampColor = NPR_Base_Ramp(lightAttenuation * var_FaceShadow.a,Night,1.0);

        return baseColor.rgb * rampColor ;
    }

    //头发
    float3 NPR_Function_Hair (float NdotL,float NdotH,float NdotV,float3 normalDir,float3 baseColor,float4 parameter,Light light,float Night)
    {
        
        float3 RampColor = NPR_Base_Ramp (NdotL,Night,float4(parameter.r,parameter.g,parameter.b,parameter.a));//头发的rampColor不应该把固定阴影的部分算进去，所以这里固定阴影给定0.5 到计算ramp的时候 *2 结果等于1  这个暂定
        float3 Albedo = baseColor * RampColor;
        float3 Specular = NPR_Base_Specular(NdotH,baseColor,parameter);
        float3 Metal =  NPR_Base_Metal(normalDir,parameter,baseColor);
        float3 RimLight = NPR_Base_RimLight(NdotV,NdotL,baseColor);
        float3 finalRGB = Albedo* (1 - parameter.r) + Specular + Metal + RimLight;
        return finalRGB;
    }

    //最终输出



#endif

