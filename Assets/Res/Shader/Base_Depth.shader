Shader "Custom/Base_Depth"
{
    Properties
    {
        _MainTex("主贴图", 2D) = "white" {}
        _Test("Test",float) = 0.0
    }
    SubShader
    {
        
        Tags
        { 
            "RenderPipeline"="UniversalRenderPipline"
            "LightMode" = "UniversalForward"
            "RenderType"="Opaque" 
            "Queue" = "Transparent"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        
        uniform TEXTURE2D (_CameraDepthTexture);uniform	SAMPLER(sampler_CameraDepthTexture);
        
        
        ENDHLSL
        
        Pass
        {
            
            
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            
            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 viewPos  : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                
                o.worldPos = TransformObjectToWorld(v.vertex);
                o.viewPos  = TransformWorldToView(o.worldPos);
                o.pos = TransformWViewToHClip(o.viewPos);
                o.uv =v.uv;

                return o;
            }
            float _Test;
            float3 frag(v2f i) : SV_Target
            {
                float2 scrPos = i.pos / _ScreenParams.xy;
                half4 depthMap = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, scrPos);
                half depth = LinearEyeDepth(depthMap, _ZBufferParams);
                
                float3 viewPos = i.viewPos;
                float disDepth = depth + viewPos.z;
                disDepth *= _Test;
                return  1 - disDepth;
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
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
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
}