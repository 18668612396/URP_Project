
Shader "Custom/Scene/WaterShader"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _CubemapTexture("CubeMap",Cube) = "cube"{}
        _Normal("Normal",2D) = "bump"{}
        _NormalScale("NormalScale",Range(0.0,1.0)) = 0.5
        _RefractionRamp("RefractionRamp",2D) = "white"{}
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
            float3 viewPos :TEXCOORD3;
        };


        TEXTURE2D(_Normal);
        SAMPLER(sampler_Normal);

        
        TEXTURE2D(_RefractionRamp);
        SAMPLER(sampler_RefractionRamp);

        


        
        CBUFFER_START(UnityPerMaterial)
        float4 _Normal_ST;
        uniform float _NormalScale;
        uniform float4 _Color;
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
                o.uv.zw = o.worldPos.xz * 0.1h * _Normal_ST.zw  + _Time.y * 0.05h;
                o.uv.xy = o.worldPos.xz * 0.4h * _Normal_ST.xy  - _Time.y * 0.1h;
                o.viewPos = TransformWorldToView(o.worldPos);
                o.pos = TransformWorldToHClip(o.worldPos.xyz);
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldView = _WorldSpaceCameraPos.xyz - o.worldPos;

                return o;
            }
            


            float3 frag (v2f i ) : SV_Target
            {
                //采样贴图

                //法线
                float2 normal01 = SAMPLE_TEXTURE2D(_Normal, sampler_Normal, i.uv.xy).xy * 2 - 1;
                float2 normal02 = SAMPLE_TEXTURE2D(_Normal, sampler_Normal, i.uv.zw).xy * 2 - 1;
                float2 normal = (normal01 * 0.5  + normal02);
                //Ramp

                
                //准备向量
                Light light = GetMainLight();//获取主灯光
                float3 normalDir = normalize(i.worldNormal);//法线向量
                float3 viewDir   = normalize(i.worldView);//视线向量
                float2 scrPos = i.pos.xy / _ScreenParams.xy;//屏幕UV坐标
                normalDir += float3(normal.x,0,normal.y) * _NormalScale;
                //深度
                float WaterDepth = DepthCompare(scrPos,i.viewPos,1);
                //菲尼尔
                float Fresnel = saturate(pow(1 - dot(normalDir,viewDir),5));
                //环境反射
                float3 Reflection = SampleReflections(normalDir, viewDir);//采样环境反射  后续课添加切换
                //折射
                float3 Refraction  = SAMPLE_TEXTURE2D(_RefractionRamp, sampler_RefractionRamp,float2(WaterDepth,0.5));
                //次表面散射
                return Refraction;
                //高光
                BRDFData brdfData;
                float alpha = 1.0;
                InitializeBRDFData(half3(0, 0, 0), 0, half3(1, 1, 1), 0.95, alpha, brdfData);
                half3 Specular = DirectBDRF(brdfData, normalDir, light.direction, viewDir)  * light.color * 0.2;



                
                float3 finalRGB = lerp(_Color,Reflection,Fresnel);

                // return Fresnel;
                return Specular + finalRGB;
            }
            ENDHLSL
        }
        
        
    }



}
