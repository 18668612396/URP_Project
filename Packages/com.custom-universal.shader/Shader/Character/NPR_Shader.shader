// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

Shader "Custom/Character/CartoonShader"
{
    Properties
    {
        [KeywordEnum(Body,Face,Hari)] _ShaderEnum("ShaderEnum",int) = 0
        _MainTex ("MainTex", 2D) = "white" {}
        _ParamTex("_ParamTex",2D) = "white"{}
        
        [Header(Skin)]
        _SilkFactor("_SilkFactor",int) = 0
        
    }
    SubShader
    {
        Tags
        { 
            "RenderPipeline"="UniversalRenderPipline"
            "LightMode" = "UniversalForward"
            "RenderType"="Opaque" 
            "Queue" = "Geometry"
        }
        LOD 100

        HLSLINCLUDE
        #include "../ShaderFunction.hlsl" 
        ///////////////////////////////////////////////////////////
        //                ShaderFunction中的宏开关                //
        ///////////////////////////////////////////////////////////
        #pragma shader_feature _WINDANIM_ON _WINDANIM_OFF
        #pragma shader_feature _CLOUDSHADOW_ON _CLOUDSHADOW_OFF
        #pragma shader_feature _WORLDFOG_ON _WORLDFOG_OFF
        #pragma shader_feature _SHADERENUM_BODY _SHADERENUM_FACE _SHADERENUM_HARI
        uniform TEXTURE2D (_MainTex);
        uniform	SAMPLER(sampler_MainTex);

        uniform TEXTURE2D(_ParamTex);
        uniform SAMPLER(sampler_ParamTex);
        //变量声明
        CBUFFER_START(UnityPerMaterial)
        //贴图采样器
        uniform float4 _MainTex_ST;
        int _SilkFactor;
        CBUFFER_END
        //结构体
        #pragma vertex vert
        #pragma fragment frag
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        struct NPR
        {
            float3 baseColor;
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
            float3 worldView :TEXCOORD5;
            float3 worldPos:TEXCOORD6;
            
        };
        
        ENDHLSL

        Pass
        {
            Tags{ "LightMode" = "UniversalForward" }

            Cull off
            HLSLPROGRAM
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);//这个一定要放在下面两个顶点相关的方法之上 这样他们才能调用到
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldView = _WorldSpaceCameraPos.xyz - o.worldPos;
                o.vertexColor = v.color;
                return o;
            }


            real3 frag (v2f i) : SV_Target
            {
                //采样贴图
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                float4 var_ParamTex = SAMPLE_TEXTURE2D(_ParamTex,sampler_ParamTex,i.uv);
                float maskFactor = var_ParamTex.a*255;
                //丝绸
                // float silkFactor = maskFactor > _SilkFactor + 20||maskFactor < _SilkFactor - 20 ? 0.0:1.0;

                float silkFactor = min(step(maskFactor,_SilkFactor + 20),step(maskFactor,_SilkFactor - 20));

                NPR npr;
                // ZERO_INITIALIZE(NPR,npr);//初始化顶点着色器






                // NPR_FUNCTION(i,npr);

                #if _SHADERENUM_BODY
                return 0.0;
                #elif _SHADERENUM_FACE
                return 0.5;
                #elif _SHADERENUM_HARI
                return 1.0;
                #endif

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

  CustomEditor "NPR_ShaderGUI"  
}
