// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

Shader "Custom/Character/CartoonShader"
{
    Properties
    {
        //基础
        [KeywordEnum(Base,Face,Hair)] _ShaderEnum("ShaderEnum",int) = 0
        _MainTex ("MainTex", 2D) = "white" {}
        _EmissionIntensity("_EmissionIntensity",Range(0.0,25.0)) = 0.0
        _ParamTex("_ParamTex",2D) = "white"{}
        _RampTex("RampTex",2D) = "white"{}
        _Matcap("_Matcap",2D) = "white"{}
        _SpecularRadius("SpecularRadius",Range(1.0,100.0)) = 1.0
        [HDR]_MetalColor("_MetalColor",Color)= (1,1,1,1)
        _ShadowColor("ShadowColor",Color) = (0.0,0.0,0.0)
        _RimIntensity("_RimIntensity",float) = 0
        _RimRadius("_RimRadius",Range(0.0,1.0)) = 0.1
        _MaskTolerate("MaskTolerate",Range(0.0,50)) = 10.0
        _SkinMask("SkinMask",Range(0.0,255.0)) = 255.0
        _SilkMask("SilkMask",Range(0.0,255.0)) = 160.0
        _MetalMask("MetalMask",Range(0.0,255.0)) = 128.0
        _SoftMask("SoftMask",Range(0.0,255.0)) = 78
        _HandMask("HandMask",Range(0.0,255.0)) = 0

        _OutlineColor("Color",Color) = (0.0,0.0,0.0,0.0)
        _OutlineOffset("Offset",Range(0.0,0.01)) = 0.0 
        // _ShadowMultColor("一级阴影颜色(实时光照)",Color) = (1.0,1.0,1.0,1.0)
        // _DarkShadowMultColor   ("二级阴影颜色(静态光照)",Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {



        HLSLINCLUDE
        #include "../ShaderFunction.hlsl" 
        ///////////////////////////////////////////////////////////
        //                ShaderFunction中的宏开关                //
        ///////////////////////////////////////////////////////////
        #pragma shader_feature _WINDANIM_ON _WINDANIM_OFF
        #pragma shader_feature _CLOUDSHADOW_ON _CLOUDSHADOW_OFF
        #pragma shader_feature _WORLDFOG_ON _WORLDFOG_OFF
        #pragma shader_feature _SHADERENUM_BASE _SHADERENUM_FACE _SHADERENUM_HAIR

        #pragma shader_feature _SKINTOGGLE_ON 
        #pragma shader_feature _SILKTOGGLE_ON 
        uniform TEXTURE2D (_MainTex);
        uniform	SAMPLER(sampler_MainTex);

        uniform TEXTURE2D(_ParamTex);
        uniform SAMPLER(sampler_ParamTex);

        //变量声明
        CBUFFER_START(UnityPerMaterial)
        uniform float _EmissionIntensity;
        float _OutlineOffset;
        float4 _OutlineColor;


        CBUFFER_END
        //结构体
        #pragma vertex vert
        #pragma fragment frag
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        struct NPR
        {
            float3 baseColor;
            float3 emission;
            float4 parameter;
        };



        #include "../NPR_Function.hlsl" 
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
            float4 color:COLOR;
            float3 normal:NORMAL;

        };
        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 vertexColor:COLOR;
            float3 worldNormal :TEXCOORD2;
            float3 viewNormal :TEXCOORD3;
            float3 worldView :TEXCOORD5;
            float3 worldPos:TEXCOORD6;
            
        };
        
        ENDHLSL

        Pass
        {


            Tags
            { 

                "LightMode" = "UniversalForward"
                "RenderType"="Opaque" 
            }
            Cull off
            HLSLPROGRAM
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                o.uv = v.uv;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);//这个一定要放在下面两个顶点相关的方法之上 这样他们才能调用到
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.viewNormal = TransformWorldToView(o.worldNormal);
                o.worldView = _WorldSpaceCameraPos.xyz - o.worldPos;
                o.vertexColor = v.color;
                return o;
            }


            real3 frag (v2f i) : SV_Target
            {
                //采样贴图
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                float4 var_ParamTex = SAMPLE_TEXTURE2D(_ParamTex,sampler_ParamTex,i.uv);


                NPR npr;
                ZERO_INITIALIZE(NPR,npr);//初始化顶点着色器
                npr.baseColor = var_MainTex;
                npr.emission  = var_MainTex.a * var_MainTex * _EmissionIntensity;
                npr.parameter  = var_ParamTex;
                // return npr.rampMask;
                // NPR_FUNCTION(i,npr);
                float3 finalRGB = NPR_FUNCTION(i,npr);
                return finalRGB;
            }
            ENDHLSL
        }
        Pass
        {
            Tags{ "LightMode" = "SRPDefaultUnlit" }
            Cull off
            ZWrite on
            Cull front
            HLSLPROGRAM
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                v.vertex.xyz += v.normal * _OutlineOffset;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.worldNormal = v.normal;
                return o;
            }


            real3 frag (v2f i) : SV_Target
            {
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                float3 finalRGB = var_MainTex * _OutlineColor.rgb;
                
                return finalRGB;

            }
            ENDHLSL
        }
        pass 
        {
            Name "ShadowCast"
            
            Tags{ "LightMode" = "ShadowCaster" }
            HLSLPROGRAM
            v2f vert(appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }
            float4 frag(v2f i) : SV_Target
            {
                return float4(1.0,1.0,1.0,1.0);
            }
            ENDHLSL
        }
        
    }

    // CustomEditor "NPR_ShaderGUI"  
}
