#ifndef NPR_FUNCTION_INCLUDE
    #define NPR_FUNCTION_INCLUDE
    
    #include "ShaderFunction.HLSL"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


    //皮肤
    int _SkinFactor;
    int _SkinFactorTolerance;
    float3 Skin_Function(float3 finalRGB,NPR npr)
    {
        float maskFactor = npr.paramMap.a*255;
        //丝绸
        float skinFactor = maskFactor > _SkinFactor + _SkinFactorTolerance||maskFactor < _SkinFactor - _SkinFactorTolerance ? 0.0:1.0;
        return finalRGB * skinFactor;
    }



    //丝绸
    int _SilkFactor;//丝绸遮罩
    float3 Silk_Function(float3 finalRGB,NPR npr)
    {
        float maskFactor = npr.paramMap.a*255;
        //丝绸
        float silkFactor = maskFactor > _SilkFactor + 20||maskFactor < _SilkFactor - 20 ? 0.0:1.0;
        return silkFactor * finalRGB;
    }


    //主体部分  需要用到多个材质融合
    float3 NPR_Function_Body (float NdotV,NPR npr)
    {
        float3 finalRGB = npr.baseMap;
        
        float3 Skin = 0.0;
        #if _SKINTOGGLE_ON
            Skin = Skin_Function(finalRGB,npr);
        #endif
        
        float3 Silk = 0.0;
        #if _SILKTOGGLE_ON
            Silk = Silk_Function(finalRGB,npr);
        #endif
        
        return Skin + Silk;
    }

    //脸部
    float3 NPR_Function_face (NPR npr)
    {
        return npr.baseMap;
    }

    //头发
    float3 NPR_Function_Hair (NPR npr)
    {
        
        return npr.baseMap;
    }
    //最终输出
    float3 NPR_Function(float3 worldPos,float3 worldNormal,float3 worldView,NPR npr)
    {
        float4 SHADOW_COORDS = TransformWorldToShadowCoord(worldPos);
        Light light = GetMainLight(SHADOW_COORDS);
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





        float3 finalRGB = float3(0.0,0.0,0.0);
        #if _SHADERENUM_BODY
            finalRGB = NPR_Function_Body(NdotV,npr);
        #elif _SHADERENUM_FACE
            finalRGB = NPR_Function_face(npr);
        #elif _SHADERENUM_HAIR
            finalRGB = NPR_Function_Hair(npr);
        #endif
        return finalRGB;
    }
    #define NPR_FUNCTION(i,npr) NPR_Function(i.worldPos,i.worldNormal,i.worldView,npr);


#endif

