#ifndef SCENE_GLOBALFEATURE_INCLUDE
    #define SCENE_GLOBALFEATURE_INCLUDE
    
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    
    //全局结构体(为了方便后面调用，所以做了个结构体)
    struct GlobalFeature
    {
        float3 baseColor;
        float3 normal;
        float3 emission; 
        float  roughness;
        float  metallic;
        float  occlusion;
    };
    //全局贴图参数
    uniform TEXTURE2D (_GlobalFeature_Main);
    uniform	SAMPLER(sampler_GlobalFeature_Main);
    uniform TEXTURE2D (_GlobalFeature_Param);
    uniform	SAMPLER(sampler_GlobalFeature_Param);
    uniform TEXTURE2D (_GlobalFeature_Normal);
    uniform	SAMPLER(sampler_GlobalFeature_Normal);

    //下雨
    uniform half _RainSpeed = 1;
    void RainFeature(float3 worldPos,inout GlobalFeature Global,inout ShaderParam param)
    {
        
        float4 var_Param = SAMPLE_TEXTURE2D(_GlobalFeature_Param,sampler_GlobalFeature_Param,worldPos.xz * 3);
        
        
        float3 emissive = 1-(frac((_Time *_RainSpeed)));
        float3 emissive2 = 1-(frac((_Time *_RainSpeed)+ 0.5));//偏移一点时间，让涟漪扩散时间错开
        float3 _Texture_var =SAMPLE_TEXTURE2D(_GlobalFeature_Param,sampler_GlobalFeature_Param,worldPos.xz * 3);
        //UV 也偏移一点，让两张图错开一些
        float3 _Texture_var2 = SAMPLE_TEXTURE2D(_GlobalFeature_Param,sampler_GlobalFeature_Param,worldPos.xz * 3 + float2(0.5,0.5));
        // _Texture_var2 = pow(_Texture_var2,1 / 2.2);
        // _Texture_var = pow(_Texture_var,1 / 2.2);


        float maskColor = saturate(1 - distance(      smoothstep(emissive.r,1,_Texture_var.r)        ,0.05)/0.05);
        float maskColor2 = saturate(1 - distance(smoothstep(emissive.r,1,_Texture_var2.r),0.05)/0.05);
        float maskSwitch = saturate(abs(sin((_Time * 0.5))));//两张图交替淡入
        float finalColor = lerp(maskColor , maskColor2 ,maskSwitch );
        // float raindrop01 = saturate(1 - distance(1-(frac((_Time.y *_RainSpeed))) - var_Param.r,0.05)/0.05);
        // float raindrop02 = saturate(1 - distance(1-(frac((_Time.y *_RainSpeed)+ 0.5)) - var_Param.g,0.05)/0.05);

        Global.roughness = 1 - maskColor;
    }
    
    //可切换性全局效果

    void SceneGlobalFeature(v2f i,inout ShaderParam param)
    {
        GlobalFeature Global;
        ZERO_INITIALIZE(GlobalFeature,Global);//初始化结构体
        //下雨
        RainFeature(i.worldPos,Global,param);




        // param.baseColor = Global.baseColor;
        param.emission = float3(0.0,0.0,0.0);
        param.roughness *= Global.roughness ;
    }


#endif
