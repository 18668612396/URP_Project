#ifndef NPR_FUNCTION_INCLUDE
    #define NPR_FUNCTION_INCLUDE
    
    #include "ShaderFunction.HLSL"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"



    uniform TEXTURE2D(_RampTex);
    uniform SAMPLER(sampler_RampTex);
    uniform float _MaskTolerate;
    uniform float _SkinMask;
    uniform float _SilkMask;
    uniform float _MetalMask;
    uniform float _SoftMask;
    uniform float _HandMask;

    
    float3 NPR_Base_Ramp (float NdotL,float4 parameter)
    {
        float maskFactor = parameter.a * 255;
        float halfLambert = smoothstep(0.0,0.5,NdotL) * parameter.g * 2;

        float SkinMask = 0.0;
        float3 SkinRamp = 0.0;
        if (_SkinMask)
        {
            SkinMask = maskFactor > 255 + _MaskTolerate||maskFactor < 255 - _MaskTolerate ? 0.0:1.0;
            SkinRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.95)).rgb;
        }

        float SilkMask = 0.0;
        float3 SilkRamp = 0.0;
        if (_SilkMask)
        {
            SilkMask = maskFactor > 160 + _MaskTolerate||maskFactor < 160 - _MaskTolerate ? 0.0:1.0;
            SilkRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.85)).rgb;
        }

        float MetalMask = 0.0;
        float3 MetalRamp = 0.0;
        if (_MetalMask)
        {
            MetalMask = maskFactor > 128 + _MaskTolerate||maskFactor < 128 - _MaskTolerate ? 0.0:1.0;
            MetalRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.75)).rgb;
        }

        float SoftMask = 0.0;
        float3 SoftRamp = 0.0;
        if (_SoftMask)
        {
            SoftMask = maskFactor > 78 + _MaskTolerate||maskFactor < 78 - _MaskTolerate ? 0.0:1.0;
            SoftRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.65)).rgb;
        }

        float HandMask = 0.0;
        float3 HandRamp = 0.0;
        if (_HandMask)
        {
            HandMask = maskFactor > 0 + _MaskTolerate||maskFactor < 0 - _MaskTolerate ? 0.0:1.0;
            HandRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.55)).rgb;
        }


        float3 Skin = SkinMask * SkinRamp;
        float3 Silk = SilkMask * SilkRamp;
        float3 Metal= MetalMask * MetalRamp ;
        float3 Soft = SoftMask * SoftRamp;
        float3 Hand = HandMask * HandRamp;
        return lerp(0.5,Skin + Silk + Metal + Soft + Hand,SkinMask + SilkMask + MetalMask + SoftMask + HandMask);//因为采样误差  会出现一些黑色的地方 这里使用lerp填充黑色的部分（以后要改）
    }
    //高光部分
    uniform float _HairSpecularIntensity;
    float3 NPR_Base_Specular(float NdotH ,float3 baseColor,float4 parameter)
    {
        float  SpecularRadius = pow(NdotH,parameter.r * 50);//将金属通道作为高光的范围控制  金属的部分高光集中  非金属的部分高光分散
        float3 SpecularColor  = parameter.b * baseColor;
        #if _SHADERENUM_HAIR
            return smoothstep(0.3,0.4,SpecularRadius) * SpecularColor * lerp(_HairSpecularIntensity,1,step(0.9,parameter.r));//如果是材质是头发的话  头发部分的高光强度自定
        #endif
        return smoothstep(0.3,0.4,SpecularRadius) * SpecularColor * parameter.r;//
    }
    //金属部分
    uniform TEXTURE2D(_Matcap);
    uniform SAMPLER(sampler_Matcap);
    uniform float3 _MetalColor;
    float3 NPR_Base_Metal(float3 normalDir,float4 parameter,float3 baseColor)
    {
        float3 viewNormal = normalize(mul(UNITY_MATRIX_V,normalDir));//视空间法线向量，用于MatCap的UV采样
        float var_Matcap = SAMPLE_TEXTURE2D(_Matcap,sampler_Matcap,viewNormal * 0.5 + 0.5) * 2;
        float MetalColorMask = step(0.9,parameter.r);
        return var_Matcap * baseColor * lerp(0,_MetalColor,MetalColorMask);
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
    uniform float3 _ShadowColor;
    float3 NPR_Function_Base (float NdotL,float NdotH,float NdotV,float3 normalDir,float4 baseColor,float4 parameter,Light light)
    {
        
        float3 RampColor = NPR_Base_Ramp (NdotL,parameter);
        float3 Albedo = baseColor * RampColor * lerp(_ShadowColor,1,parameter.g * 2) ;
        float3 Specular = NPR_Base_Specular(NdotH,baseColor,parameter);
        float3 Metal =  NPR_Base_Metal(normalDir,parameter,baseColor);
        float3 RimLight = NPR_Base_RimLight(NdotV,NdotL,baseColor) * parameter.g;
        float3 Emission = NPR_Emission(baseColor);
        float3 finalRGB = Albedo* (1 - parameter.r) + Specular + Metal + RimLight + Emission;
        return finalRGB;
    }
    

    //脸部
    float3 NPR_Function_face (float3 lightDir,float4 baseColor,float4 var_FaceShadow,Light light)
    {

        float3 Up = float3(0.0,1.0,0.0);
        float3 Front = unity_ObjectToWorld._12_22_32;
        float3 Right = cross(Up,Front);
        float switchShadow  = dot(normalize(Right.xz), normalize(lightDir.xz))*0.5+0.5 < 0.5;
        float FaceShadow = lerp(1 - var_FaceShadow.g,1 - var_FaceShadow.r,switchShadow.r);
        float FaceShadowRange = dot(normalize(Front.xz), normalize(lightDir.xz));
        float lightAttenuation = 1 - smoothstep(FaceShadowRange - 0.1,FaceShadowRange + 0.1,FaceShadow);
        float3 rampColor = NPR_Base_Ramp(lightAttenuation * var_FaceShadow.a,1.0);

        return baseColor.rgb * rampColor ;
    }

    //头发
    float3 NPR_Function_Hair (float NdotL,float NdotH,float NdotV,float3 normalDir,float3 baseColor,float4 parameter,Light light)
    {
        
        float3 RampColor = NPR_Base_Ramp (NdotL,float4(parameter.r,0.5,parameter.b,1));//头发的rampColor不应该把固定阴影的部分算进去，所以这里固定阴影给定0.5 到计算ramp的时候 *2 结果等于1
        float3 Albedo = baseColor * RampColor * lerp(_ShadowColor,1,parameter.g * 2) ;
        float3 Specular = NPR_Base_Specular(NdotH,baseColor,parameter);
        float3 Metal =  NPR_Base_Metal(normalDir,parameter,baseColor);
        float3 RimLight = NPR_Base_RimLight(NdotV,NdotL,baseColor);
        float3 finalRGB = Albedo* (1 - step(0.9,parameter.r)) + Specular + Metal + RimLight;
        return finalRGB;
    }

    //最终输出



#endif

