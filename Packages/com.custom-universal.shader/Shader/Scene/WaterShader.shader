
Shader "Custom/Scene/WaterShader"
{
    Properties
    {
        _CubemapTexture("CubeMap",Cube) = "cube"{}
        _Normal("Normal",2D) = "bump"{}
        _NormalScale("NormalScale",Range(0.0,1.0)) = 0.5
    }
    
    SubShader
    {
        Tags
        { 
            "RenderPipeline"="UniversalRenderPipline"
            "LightMode" = "UniversalForward"
            "IgnoreProjector" = "True"
            "RenderType"="Opaque" 
            "Queue" = "Transparent"
        }
        LOD 100

        HLSLINCLUDE
        #pragma vertex vert
        #pragma fragment frag
        #include "../Water_Function.hlsl"
        struct appdata
        {
            float4 vertex : POSITION;
            float4 uv:TEXCOORD0;
            float3 normal:NORMAL;
        };
        struct v2f
        {
            float4 pos : SV_POSITION;
            float3 worldView : TEXCOORD1;
            float4 uv:TEXCOORD0;
            float3 worldPos:TEXCPPRD2;
            float3 worldNormal:NORMAL;
        };


        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);


        
        CBUFFER_START(UnityPerMaterial)
        uniform float _NormalScale;
        CBUFFER_END
        ENDHLSL


        Pass
        {
            Cull Back
            // Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha


            HLSLPROGRAM
            //Function

            
            v2f vert ( appdata v )
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.uv.zw = o.worldPos.xz * 0.1h + _Time.y * 0.05h;
                o.uv.xy = o.worldPos.xz * 0.4h - _Time.y * 0.1h;
                o.pos = TransformWorldToHClip(o.worldPos.xyz);
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldView = _WorldSpaceCameraPos.xyz - o.worldPos;

                return o;
            }
            


            float3 frag (v2f i ) : SV_Target
            {
                //采样Normal
                float2 normal01 = SAMPLE_TEXTURE2D(_Normal, sampler_Normal, i.uv.xy).xy * 2 - 1;
                float2 normal02 = SAMPLE_TEXTURE2D(_Normal, sampler_Normal, i.uv.zw).xy * 2 - 1;
                float2 normal = (normal01 * 0.5  + normal02);
                
                
                //准备向量
                Light light = GetMainLight();
                float3 normalDir = normalize(i.worldNormal);
                float3 viewDir   = normalize(i.worldView);
                float2 scrPos = i.pos.xy / _ScreenParams.xy;
                normalDir += float3(normal.x,0,normal.y) * _NormalScale;

                BRDFData brdfData;
                half alpha = 1;
                InitializeBRDFData(half3(0, 0, 0), 0, half3(1, 1, 1), 0.95, alpha, brdfData);
                half3 spec = DirectBDRF(brdfData, normalDir, light.direction, viewDir)  * light.color * 0.2;
                half3 reflection = SampleReflections(normalDir, viewDir);
                

                
                return spec + reflection;
            }
            ENDHLSL
        }
        
        
    }



}
