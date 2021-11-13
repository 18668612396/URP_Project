// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

Shader "Custom/Scene/GrassShader"
{
    Properties
    {

        
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)

        CBUFFER_END
        //结构体
        #pragma vertex vert
        #pragma fragment frag

        struct appdata
        {
            float4 vertex : POSITION;


        };
        struct v2f
        {
            float4 pos : SV_POSITION;

            
        };
        
        ENDHLSL
        Pass
        {
            

            Cull off
            HLSLPROGRAM
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器

                o.pos = TransformObjectToHClip(v.vertex.xyz);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
               
                return float4(1,1,1,1);

            }
            ENDHLSL
        }
        
      
    }

}
