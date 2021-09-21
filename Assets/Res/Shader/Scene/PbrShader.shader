Shader "Custom/Scene/PbrShader"
{
    Properties
    {   
        [Header(Parallax)]

        _MaxSample("MaxSample",int) = 4  //最高采样次数
        _MinSample("MinSample",int) = 4  //最低采样次数
        _SectionSteps("SectionSteps",int) = 4  //视差映射平滑次数
        _PomScale("PomScale",Range(0,1)) = 0   //视差强度
        _HeightScale("HeightScale",Range(-1,1)) = 0 //视差高度  多数用于和别的高度混合


        [Header(BBR Base)]
        _MainTex (" MainTex ", 2D) = "white" {}
        _Color("BaseColor",Color) = (1,1,1,1)
        [NoScaleOffset]_PbrParam("PbrParamTex",2D) = "white"{}

        
        _EmissionIntensity("EmissionIntensity",Range(0,10)) = 0
        [PowerSlider(1)]_Metallic ("Metallic",Range(0,1)) = 0
        [PowerSlider(1)]_Roughness("Roughness",Range(0,1)) = 1
        [NoScaleOffset]_Normal(  "Normal" , 2D) = "bump" {}
        [PowerSlider(1)]_NormalIntensity("_NormalIntensity",Range(0,2)) = 1

        [Header(FallDust)]
        _HeightDepth("heightDepth",Range(1.0,20.0)) = 0
        _BlendHeight("BlendHeight",Range(-5,5)) = 0
        _FallDustMainTex("FallDustMainTex",2D) = "white"{}
        _fallDustEmissionIntensity("fallDustEmissionIntensity",Range(0,10)) = 0
        _FallDustColor("FallDustColor",Color) = (1.0,1.0,1.0,1.0)
        _FallDustColorBlend("_FallDustColorBlend",Range(0,1)) = 1
        _FallDustPbrParam("FallDustPbrParam",2D) = "white"{}
        _FallDustMetallic("_FallDustMetallic",Range(0,1)) = 0
        _FallDustRoughness("FallDustRoughness",Range(0,1)) = 1
        _FallDustNormal("FallDustNormal",2D) = "bump"{}
        _FallDustNormalIntensity("FallDustNormalIntensity",Range(0,2)) = 0

        [Toggle] _WindAnimToggle("WindAmin",int) = 0
    }
    SubShader
    {

        HLSLINCLUDE
        // #include "../ShaderFunction.HLSL"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityMaterial)
        uniform float4 _Color;
        uniform float _Metallic,_Roughness,_EmissionIntensity;
        uniform float _NormalIntensity;
        uniform int _FallDust;
        uniform int _Parallax;

        uniform float4 _MainTex_ST;
        CBUFFER_END

        //贴图采样器
        uniform TEXTURE2D (_MainTex);
        uniform	SAMPLER(sampler_MainTex);
        

        uniform TEXTURE2D (_Normal);
        uniform	SAMPLER(sampler_Normal);

        uniform TEXTURE2D (_PbrParam);
        uniform	SAMPLER(sampler_PbrParam);


        ENDHLSL
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags
            { 
                "RenderPipeline"="UniversalRenderPipline"
                "RenderType"="Opaque" 
            }

            Blend One Zero
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON 
            // #pragma shader_feature _PARALLAX_ON 
            // #pragma shader_feature _FALLDUST_ON
            // #pragma shader_feature _WINDANIMTOGGLE_ON
            struct PBR
            {
                float4 baseColor;
                float3 normal;//A通道为高度图
                float3 emission;
                float  roughness;
                float  metallic;
                float  occlusion;
                float  shadow;
                
            };
            // #include "../PBR_Scene_FallDust.HLSL"
            #include "../PBR_Scene_Function.HLSL"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 lightmapUV:TEXCOORD1;
                float4 normal :NORMAL;
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

            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                
                // #if _WINDANIMTOGGLE_ON
                //     WIND_ANIM(v);
                // #endif
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // o.blendUV = TRANSFORM_TEX(v.uv,_FallDustMainTex);//混合贴图的UV
                
                o.lightmapUV = v.lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;
                
                o.pos = TransformObjectToHClip(v.vertex);
                o.worldPos = TransformObjectToWorld(v.vertex);
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldTangent = TransformObjectToWorldDir(v.tangent).xyz;
                o.worldBitangent = cross(o.worldNormal,o.worldTangent.xyz) * v.tangent.w;
                o.worldView = _WorldSpaceCameraPos.xyz - o.worldPos;
                o.vertexColor = v.color;

                return o;
            }

            real3 frag (v2f i) : SV_Target
            {
                //视差映射UV
                // #ifndef _FALLDUST_ON
                //     i.vertexColor = float4(0.0,0.0,0.0,0.0);
                // #endif
                float2 uv = i.uv;
                // #ifdef _PARALLAX_ON
                //     uv = PBR_PARALLAX(i,_MainTex);
                // #endif


                
                //贴图采样
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv);//A通道为高度图
                float4 var_PbrParam = SAMPLE_TEXTURE2D(_PbrParam,sampler_PbrParam,uv);
                float3 var_Normal    = SAMPLE_TEXTURE2D(_Normal,sampler_Normal,uv);
                
                PBR pbr;
                ZERO_INITIALIZE(PBR,pbr);//初始化PBR结构体
                pbr.baseColor = var_MainTex * _Color;
                pbr.emission  = lerp(0,var_MainTex.rgb * max(0.0,_EmissionIntensity),var_PbrParam.a);//A通道为高度图
                pbr.normal    = lerp(float3(0.5,0.5,1),var_Normal,_NormalIntensity);
                pbr.metallic  = min(_Metallic,var_PbrParam.r);
                pbr.roughness = _Roughness*var_PbrParam.g;
                pbr.occlusion = var_PbrParam.b;

                // //高度融合相关
                // #ifdef _FALLDUST_ON
                //     PBR_FALLDUST(i,pbr);
                // #endif
                
                float3 finalRGB = PBR_FUNCTION(i,pbr);
                // float3 finalRGB = var_MainTex;
                // BIGWORLD_FOG(i,finalRGB);//大世界雾效
                return  finalRGB;
            }
            ENDHLSL
        }
        pass 
        {
            Name "ShadowCast"
            
            Tags{ "LightMode" = "ShadowCaster" }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex : POSITION;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
            };
            
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                return o;
            }
            float4 frag(v2f i) : SV_Target
            {
                float4 color;
                color.xyz = float3(0.0, 0.0, 0.0);
                return color;
            }
            ENDHLSL
        }
    }
    CustomEditor "PBR_ShaderGUI"
}
