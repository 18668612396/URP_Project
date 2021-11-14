// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

Shader "Custom/Character/Outline"
{
    Properties
    {
        _OutlineColor("Color",Color) = (0.0,0.0,0.0,0.0)
        _OutlineOffset("Offset",Range(0.0,1.0)) = 0.0 
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


        //变量声明
        CBUFFER_START(UnityPerMaterial)
        //贴图采样器
        float _OutlineOffset;
        float4 _OutlineColor;
        CBUFFER_END
        //结构体
        #pragma vertex vert
        #pragma fragment frag
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
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
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.worldNormal = v.normal;
                return o;
            }


            real3 frag (v2f i) : SV_Target
            {
                float3 finalRGB =  _OutlineColor.rgb;
                BIGWORLD_FOG(i,finalRGB);//大世界雾效
                return finalRGB;

            }
            ENDHLSL
        }
        
        
    }

    
}
