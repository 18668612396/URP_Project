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

    
    float3 NPR_Base_Ramp (float NdotL,float rampMask,float LightMap)
    {
        float maskFactor = rampMask * 255;
        float SkinMask = maskFactor > _SkinMask + _MaskTolerate||maskFactor < _SkinMask - _MaskTolerate ? 0.0:1.0;
        float SilkMask = maskFactor > _SilkMask + _MaskTolerate||maskFactor < _SilkMask - _MaskTolerate ? 0.0:1.0;
        float MetalMask = maskFactor > _MetalMask + _MaskTolerate||maskFactor < _MetalMask - _MaskTolerate ? 0.0:1.0;
        float SoftMask = maskFactor > _SoftMask + _MaskTolerate||maskFactor < _SoftMask - _MaskTolerate ? 0.0:1.0;
        float HandMask = maskFactor > _HandMask + _MaskTolerate||maskFactor < _HandMask - _MaskTolerate ? 0.0:1.0;
        float halfLambert = smoothstep(0.0,0.5,NdotL);
        #if _SHADERENUM_BASE
            halfLambert = smoothstep(0.0,0.5,NdotL) * LightMap;//映射到一个合适的位置  这里应当找到一个合适的值，我现在是猜的
        #endif
        float3 SkinRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.95)).rgb;
        float3 SilkRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.85)).rgb;
        float3 MetalRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.75)).rgb;
        float3 SoftRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.65)).rgb;
        float3 HandRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.55)).rgb;
        float3 Skin = SkinMask * SkinRamp;
        float3 Silk = SilkMask * SilkRamp;
        float3 Metal= MetalMask * MetalRamp ;
        float3 soft = SoftMask * SoftRamp;
        float3 hand = HandMask * HandRamp;
        return lerp(HandRamp,Skin + Silk + Metal + soft + hand,SkinMask + SilkMask + MetalMask + SoftMask + HandMask);//因为采样误差  会出现一些黑色的地方 这里使用lerp填充黑色的部分（以后要改）
    }
    //高光部分

    uniform float _SpecularRadius;
    float3 NPR_Base_Specular(float NdotH ,float3 baseColor,float SpecularAtten)
    {
        float  SpecularRadius = pow(NdotH,_SpecularRadius);
        float3 SpecularColor  = SpecularAtten * baseColor;
        return SpecularRadius * SpecularColor;
    }
    //金属部分
    uniform TEXTURE2D(_Matcap);
    uniform SAMPLER(sampler_Matcap);
    uniform float3 _MetalColor;
    float3 NPR_Base_Metal(float3 normalDir,float MetalMask,float3 baseColor)
    {
        float3 viewNormal = normalize(mul(UNITY_MATRIX_V,normalDir));//视空间法线向量，用于MatCap的UV采样
        float var_Matcap = SAMPLE_TEXTURE2D(_Matcap,sampler_Matcap,viewNormal * 0.5 + 0.5);
        float MetalColorMask = step(0.9,MetalMask);
        return var_Matcap * baseColor * MetalMask* lerp(1.0,_MetalColor,MetalColorMask);
    }
    uniform float _RimIntensity;
    uniform float _RimRadius;
    //边缘光
    float3 NPR_Base_RimLight(float NdotV,float NdotL,float3 baseColor)
    {
        return (1 - smoothstep(_RimRadius,_RimRadius + 0.1,NdotV)) * _RimIntensity * (1 - (NdotL * 0.5 + 0.5 )) * baseColor;
    }
    //主体部分  需要用到多个材质融合
    uniform float3 _ShadowColor;
    float3 NPR_Function_Base (float NdotL,float NdotH,float NdotV,float3 normalDir,float3 baseColor,float4 parameter,Light light)
    {
        
        float3 RampColor = NPR_Base_Ramp (NdotL,parameter.a,parameter.g * 2);
        float3 Albedo = baseColor * RampColor * lerp(_ShadowColor,1,parameter.g * 2) ;
        float3 Specular = NPR_Base_Specular(NdotH,baseColor,parameter.b);
        float3 Metal =  NPR_Base_Metal(normalDir,parameter.r,baseColor);
        float3 RimLight = NPR_Base_RimLight(NdotV,NdotL,baseColor);
        float3 finalRGB = Albedo* (1 - parameter.r) + Specular + Metal + RimLight;
        return finalRGB;
    }

    //脸部
    float3 NPR_Function_face (NPR npr)
    {
        return npr.baseColor;
    }

    //头发
    float3 NPR_Function_Hair (float NdotL,float NdotH,float NdotV,float3 normalDir,float3 baseColor,float4 parameter,Light light)
    {
        float3 RampColor = NPR_Base_Ramp (NdotL,parameter.a,parameter.g * 2);
        float3 Albedo = baseColor * RampColor * lerp(_ShadowColor,1,parameter.g * 2) ;
        float3 Specular = NPR_Base_Specular(NdotH,baseColor,parameter.b);
        float3 Metal =  NPR_Base_Metal(normalDir,parameter.r,baseColor);
        float3 RimLight = NPR_Base_RimLight(NdotV,NdotL,baseColor);
        float3 finalRGB = Albedo* (1 - parameter.r) + Specular + Metal + RimLight;
        return finalRGB;
    }

    //最终输出

    uniform float3 _ShadowMultColor;//一级阴影颜色
    uniform float3 _DarkShadowMultColor;//二级阴影颜色 
    
    float3 NPR_Function(float3 worldPos,float3 worldNormal,float3 worldView,NPR npr)
    {
        //灯光信息
        float4 SHADOW_COORDS = TransformWorldToShadowCoord(worldPos);
        Light light = GetMainLight(SHADOW_COORDS);
        //阴影
        float3 ShallowShadowColor = npr.baseColor * _ShadowMultColor;
        float3 DarkShadowColor = npr.baseColor * _DarkShadowMultColor;
        //参数输入
        float3 baseColor = npr.baseColor;
        float3 emission  = npr.emission;
        float4 parameter   = npr.parameter;
        float  shadow = light.shadowAttenuation;
        //向量准备
        float3 normalDir  = normalize(worldNormal);
        float3 viewDir    = normalize(worldView);
        float3 lightDir   = normalize(light.direction);
        float3 halfDir    = normalize(lightDir + viewDir);
        float3 reflectDir = normalize(reflect(viewDir,normalDir));
        //点乘结果
        float NdotH = max(0.00001,dot(normalDir,halfDir));
        float NdotL = max(0.00001,dot(normalDir,lightDir));
        float NdotV = max(0.00001,dot(normalDir,viewDir));
        float HdotL = max(0.00001,dot(halfDir,lightDir));


        float3 finalRGB = float3(0.0,0.0,0.0);
        #if _SHADERENUM_BASE
            finalRGB = NPR_Function_Base(NdotL,NdotH,NdotV,normalDir,baseColor,parameter,light) ;
        #elif _SHADERENUM_FACE
            finalRGB = NPR_Function_face(npr);
        #elif _SHADERENUM_HAIR
            finalRGB = NPR_Function_Hair(NdotL,NdotH,NdotV,normalDir,baseColor,parameter,light);
        #endif
        return finalRGB;
    }
    #define NPR_FUNCTION(i,npr) NPR_Function(i.worldPos,i.worldNormal,i.worldView,npr);


#endif

