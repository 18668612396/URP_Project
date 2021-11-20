Shader "DepthRim"
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





        struct appdata
        {
            float4 vertex:POSITION;
            float3 normal:NORMAL;
            float4 uv : TEXCOORD0;
        };

        struct v2f
        {
            float4 pos:SV_POSITION;
            float normal:NORMAL;
            float2 uv:TEXCOORD0;
            float3 posOS : DD;
            float3 worldPos:TEXCOORD10;
        };


        ENDHLSL
        pass{

            HLSLPROGRAM
            #pragma vertex VERT
            #pragma fragment FRAG

            v2f VERT( appdata v)
            {
                v2f o;
       
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.posOS =  v.vertex.xyz - v.normal * 0.05;

                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float3 FRAG(v2f i):SV_TARGET
            {
                return i.pos.z - i.pos.z * 0.99;
                half4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv)*_BaseColor;

                return tex;

            }

            ENDHLSL 
        }
    }
    //    FallBack "Diffuse"
}
