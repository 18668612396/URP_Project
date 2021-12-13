Shader "Custom/Scene/SceneLit"
{
    Properties
    {
        // [Header(Parallax)]

        // _MaxSample("MaxSample",int) = 4  //最高采样次数
        // _MinSample("MinSample",int) = 4  //最低采样次数
        // _SectionSteps("SectionSteps",int) = 4  //视差映射平滑次数
        // _PomScale("PomScale",Range(0,1)) = 0   //视差强度
        // _HeightScale("HeightScale",Range(-1,1)) = 0 //视差高度  多数用于和别的高度混合
        [Header(BBR Base)]
        _MainTex (" MainTex ", 2D) = "white" {}
        _Color("BaseColor",Color) = (1,1,1,1)
        _Cutoff("Cutoff",Range(0.0,1.0)) = 0.5
        [NoScaleOffset]_PbrParam("PbrParamTex",2D) = "white"{}
        _EmissionIntensity("EmissionIntensity",Range(0,25)) = 0
        [PowerSlider(1)]_Metallic ("Metallic",Range(0,1)) = 0
        [PowerSlider(1)]_Roughness("Roughness",Range(0,1)) = 1
        [Normal][NoScaleOffset]_Normal( "Normal" , 2D) = "bump" {}
        [PowerSlider(1)]_NormalIntensity("_NormalIntensity",Range(0,2)) = 1
        [Toggle]_HeightNormalUp("_HeightNormalUp",int) = 1
        [Toggle]_FallDustSwitchUV("_FallDustSwitchUV",int) = 1
        _HeightRadius("_HeightRadius",Range(0.0,10.0)) = 1
        _HeightDepth("heightDepth",Range(0.0,20.0)) = 0
        _BlendHeight("BlendHeight",Range(-5,5)) = 0
        _FallDustMainTex("FallDustMainTex",2D) = "white"{}
        _fallDustEmissionIntensity("fallDustEmissionIntensity",Range(0,25)) = 0
        _FallDustColor("FallDustColor",Color) = (1.0,1.0,1.0,1.0)
        _FallDustColorBlend("_FallDustColorBlend",Range(0,1)) = 1
        _FallDustPbrParam("FallDustPbrParam",2D) = "white"{}
        _FallDustMetallic("_FallDustMetallic",Range(0,1)) = 0
        _FallDustRoughness("FallDustRoughness",Range(0,1)) = 1
        _FallDustNormal("FallDustNormal",2D) = "bump"{}
        _FallDustNormalIntensity("FallDustNormalIntensity",Range(0,2)) = 0
        [Toggle]_FallDustNormalBlend("_FallDustNormalBlend",int) = 1
        [Toggle] _WindAnimToggle("WindAmin",int) = 0
    }
    SubShader
    {
        Name "CustomPBR"
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "LightMode" = "UniversalForward"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
            "ShaderModel"="4.5"
        }
        LOD 300

        HLSLINCLUDE
        #pragma vertex vert
        #pragma fragment frag
        #pragma target 4.5

        #include "../ShaderLibrary/ShaderFunction.hlsl"

        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
        ///////////////////////////////////////////////////////////
        //                ShaderFunction中的宏开关                //
        ///////////////////////////////////////////////////////////
        #pragma shader_feature _CLOUDSHADOW_ON _CLOUDSHADOW_OFF
        #pragma shader_feature _WORLDFOG_ON _WORLDFOG_OFF
        ///////////////////////////////////////////////////////////
        //                PBR_Scene_FallDust中的宏开关            //
        ///////////////////////////////////////////////////////////
        #pragma shader_feature _FALLDUST_ON
        #pragma shader_feature _FALLDUST_MAINTEX_ON
        #pragma shader_feature _FALLDUST_PBRPARAM_ON
        #pragma shader_feature _FALLDUST_NORMAL_ON
        ///////////////////////////////////////////////////////////
        //               光照相关的宏开关                          //
        ///////////////////////////////////////////////////////////
        //#pragma shader_feature LIGHTMAP_OFF LIGHTMAP_ON 
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT


        // #pragma shader_feature _WINDANIMTOGGLE_ON
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
            float2 lightmapUV:TEXCOORD1;
            float3 normal :NORMAL;
            float4 tangent:TANGENT;
            float4 color:COLOR;
        };

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float2 lightmapUV:TEXCOORD1;
            float2 blendUV:TEXCOORD9;
            float4 vertexColor:COLOR;
            float3 worldNormal :TEXCOORD2;
            float3 worldTangent :TEXCOORD3;
            float3 worldBitangent :TEXCOORD4;
            float3 worldView :TEXCOORD5;
            float3 worldPos:TEXCOORD6;
        };

        #include "../ShaderLibrary/LitFunction.hlsl"
        #include "../ShaderLibrary/PBR_Scene_FallDust.HLSL"
        #include "../ShaderLibrary/Scene_GlobalFeature.HLSL"

        //贴图采样器
        #pragma shader_feature _MAINTEX_ON
        uniform TEXTURE2D(_MainTex);
        uniform SAMPLER(sampler_MainTex);
        #pragma shader_feature _NORMAL_ON
        uniform TEXTURE2D(_Normal);
        uniform SAMPLER(sampler_Normal);
        #pragma shader_feature _PBRPARAM_ON

        uniform TEXTURE2D(_PbrParam);
        uniform SAMPLER(sampler_PbrParam);
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION

        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        float4 _Color;
        float _Metallic, _Roughness, _EmissionIntensity;
        float _NormalIntensity;
        float _Cutoff;
        // int _FallDust;
        // int _Parallax;
        int _HeightNormalUp;
        int _FallDustSwitchUV;
        float4 _FallDustMainTex_ST; //这个不能写在HLSL库里

        CBUFFER_END
        ENDHLSL


        Pass
        {


            // Blend One Zero

            HLSLPROGRAM
            v2f vert(appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f, o); //初始化顶点着色器
                // #if _WINDANIMTOGGLE_ON
                //     WIND_ANIM(v);
                // #endif
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);


                o.lightmapUV = v.lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                if (_FallDustSwitchUV > 0)
                {
                    o.blendUV = o.worldPos.xz / _FallDustMainTex_ST.xy; //混合贴图的UV
                }
                else
                {
                    o.blendUV = TRANSFORM_TEX(v.uv, _FallDustMainTex); //混合贴图的UV
                }
                // o.SHADOW_COORDS = TransformWorldToShadowCoord(o.worldPos);
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                #if _FALLDUST_ON
                    if (_HeightNormalUp > 0)
                    {
                        o.worldNormal = lerp(o.worldNormal,float3(0.0,1.0,0.0),v.color.r);
                    }
                #endif
                o.worldTangent = TransformObjectToWorldDir(v.tangent.xyz);
                o.worldBitangent = cross(o.worldNormal, o.worldTangent.xyz) * v.tangent.w * unity_WorldTransformParams.
                    w;
                o.worldView = GetWorldSpaceViewDir(o.worldPos);
                o.vertexColor = v.color;
                return o;
            }

            real3 frag(v2f i) : SV_Target
            {
                //视差映射UV
                #ifndef _FALLDUST_ON
                i.vertexColor = float4(0.0, 0.0, 0.0, 0.0);
                #endif
                float2 uv = i.uv;
                #ifdef _PARALLAX_ON
                // uv = PBR_PARALLAX(i,_MainTex,sampler_MainTex);
                #endif

                //贴图采样 并且利用宏来判断其是否被赋值
                #if _MAINTEX_ON
                    float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv) * _Color;//A通道为高度图
                #else
                float4 var_MainTex = _Color;
                #endif
                #if _PBRPARAM_ON
                    float4 var_PbrParam = SAMPLE_TEXTURE2D(_PbrParam,sampler_PbrParam,uv);
                #else
                float4 var_PbrParam = float4(_Metallic, _Roughness, 1.0, 0.0);
                #endif
                #if _NORMAL_ON
                    float3 var_Normal    = UnpackNormalScale(SAMPLE_TEXTURE2D(_Normal,sampler_Normal,uv),_NormalIntensity);
                #else
                float3 var_Normal = float3(0.0, 0.0, 1.0);
                #endif
                //屏幕空间AO
                float ScrOcclusion = 1.0;
                #if _SCREEN_SPACE_OCCLUSION
                    float2 scrPos = i.pos.xy / _ScreenParams.xy;
                    ScrOcclusion = SampleAmbientOcclusion(scrPos);
                #endif
                ShaderParam pbr;
                ZERO_INITIALIZE(ShaderParam, pbr); //初始化PBR结构体

                pbr.baseColor = var_MainTex;
                pbr.emission = pbr.baseColor.rgb * _EmissionIntensity * var_PbrParam.a; //A通道为高度图
                pbr.normal = var_Normal;
                pbr.metallic = var_PbrParam.r;
                pbr.roughness = var_PbrParam.g;
                pbr.occlusion = var_PbrParam.b * ScrOcclusion;


                //高度融合相关
                PBR_FALLDUST(i, pbr);
                // SceneGlobalFeature(i,pbr);

                float3 finalRGB = PBR_FUNCTION(i, pbr);
                BIGWORLD_FOG(i, finalRGB); //大世界雾效 

                // half3 attenuatedLightColor = addLight.color * addLight.distanceAttenuation;
                // finalRGB += LightingLambert(attenuatedLightColor, addLight.direction, i.worldNormal);

                clip(var_MainTex.a - _Cutoff);
                return finalRGB;
            }
            ENDHLSL
        }
        pass
        {
            Name "ShadowCast"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            HLSLPROGRAM
            //这个是用来区分定向光源和额外光源的宏 因为他们使用了不同的bise
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #include "../ShaderLibrary/ShadowCastPass.HLSL"
            ENDHLSL
        }

        Pass//这个PASS暂时不知道做什么  不过加上这个Pass会使得Scene视图的深度信息正确  //后续可以去除
        {

            Tags
            {
                "LightMode" = "DepthOnly"
            }

            HLSLPROGRAM
            v2f vert(appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f, o); //初始化顶点着色器
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }

            real3 frag(v2f i) : SV_Target
            {
                float3 color;
                color.xyz = float3(0.0, 0.0, 0.0);
                return color;
            }
            ENDHLSL
        }


    }

    CustomEditor "SceneLit"
}