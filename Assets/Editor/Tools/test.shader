Shader "Custom/test"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BaseColor ("BaseColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { 
            "RenderPipeline"="UniversalRenderPipline"
            "RenderType"="Opaque" 
        }
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //      #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
        
        CBUFFER_START(UnityMaterial)
        half4 _MainTex_ST;
        half4 _BaseColor;
        CBUFFER_END

        TEXTURE2D (_MainTex);
        SAMPLER(sampler_MainTex);
        
        uniform TEXTURE2D (_RampTex);
        uniform SAMPLER(sampler_RampTex);




        struct appdata
        {
            float4 vertex:POSITION;
            float4 normal:NORMAL;
            float4 uv : TEXCOORD0;
        };

        struct v2f
        {
            float4 vertex:SV_POSITION;
            float4 normal:NORMAL;
            float2 uv:TEXCOORD0;
        };


        ENDHLSL
        pass{

            HLSLPROGRAM
            #pragma vertex VERT
            #pragma fragment FRAG

            v2f VERT( appdata i)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(i.vertex.xyz);
                o.uv = TRANSFORM_TEX(i.uv, _MainTex);
                return o;
            }

            half4 FRAG(v2f i):SV_TARGET
            {
                half4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv)*_BaseColor;

                return tex;

            }

            ENDHLSL 
        }
    }
    //    FallBack "Diffuse"
}
