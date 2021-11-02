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
    float3 Ramp_Function (float NdotL,float rampMask)
    {
        float maskFactor = rampMask * 255;
        float SkinMask = maskFactor > _SkinMask + _MaskTolerate||maskFactor < _SkinMask - _MaskTolerate ? 0.0:1.0;
        float SilkMask = maskFactor > _SilkMask + _MaskTolerate||maskFactor < _SilkMask - _MaskTolerate ? 0.0:1.0;
        float MetalMask = maskFactor > _MetalMask + _MaskTolerate||maskFactor < _MetalMask - _MaskTolerate ? 0.0:1.0;
        float SoftMask = maskFactor > _SoftMask + _MaskTolerate||maskFactor < _SoftMask - _MaskTolerate ? 0.0:1.0;
        float HandMask = maskFactor > _HandMask + _MaskTolerate||maskFactor < _HandMask - _MaskTolerate ? 0.0:1.0;

        float halfLambert = (NdotL * 0.5 + 0.5) * 1.5;//映射到一个合适的位置  这里应当找到一个合适的值，我现在是猜的
        float3 SkinRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.95)).rgb;
        float3 SilkRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.85)).rgb;
        float3 MetalRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.75)).rgb;
        float3 SoftRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.65)).rgb;
        float3 HandRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 0.55)).rgb;
        float3 Skin = SkinRamp * SkinMask;
        float3 Silk = SilkMask * SilkRamp;
        float3 Metal= MetalRamp * MetalMask;
        float3 soft = SoftMask * SoftRamp;
        float3 hand = HandMask * HandRamp;
        return Skin + Silk + Metal + soft + hand;
    }
    //主体部分  需要用到多个材质融合
    float3 NPR_Function_Base (float NdotL,float3 baseColor,float4 parameter)
    {
        float3 Albedo = baseColor;


        float3 finalRGB = Albedo;
        return Ramp_Function (NdotL,parameter.a) * Albedo;
        return finalRGB;
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
        #if _SHADERENUM_BODY
            finalRGB = NPR_Function_Base(NdotL,baseColor,parameter);
        #elif _SHADERENUM_FACE
            finalRGB = NPR_Function_face(npr);
        #elif _SHADERENUM_HAIR
            finalRGB = NPR_Function_Hair(npr);
        #endif
        return finalRGB;
    }
    #define NPR_FUNCTION(i,npr) NPR_Function(i.worldPos,i.worldNormal,i.worldView,npr);


#endif

