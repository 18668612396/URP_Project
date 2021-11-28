
Shader "Custom/Scene/WaterShader"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _CubemapTexture("CubeMap",Cube) = "cube"{}
        _Normal("Normal",2D) = "bump"{}
        _DepthMulti("DepthMulti",Range(0.0,1.0)) = 0.5
        _NormalScale("NormalScale",Range(0.0,1.0)) = 0.5
        _RefractionRamp("RefractionRamp",2D) = "white"{}
        _ScatteringRamp("ScatteringRamp",2D) = "white"{}
        _WavaIntensity("_WavaIntensity",float) = 1.0
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
        #include "../ShaderLibrary/Water_Function.hlsl"
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

        TEXTURE2D(_ScatteringRamp);
        SAMPLER(sampler_ScatteringRamp);

        TEXTURE2D(_CameraOpaqueTexture); 
        SAMPLER(sampler_CameraOpaqueTexture_linear_clamp);

        


        
        CBUFFER_START(UnityPerMaterial)
        float4 _Normal_ST;
        uniform float _NormalScale;
        uniform float4 _Color;
        uniform float _DepthMulti;
        uniform float _WavaIntensity;
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
            


            float4 frag (v2f i ) : SV_Target
            {
                //采样贴图
                float4 var_Normal = SAMPLE_TEXTURE2D(_Normal, sampler_Normal, i.worldPos.xz * 0.1);
                //法线
                float4 normal01 = SAMPLE_TEXTURE2D(_Normal, sampler_Normal, i.uv.xy) * 2 - 1;
                float4 normal02 = SAMPLE_TEXTURE2D(_Normal, sampler_Normal, i.uv.zw) * 2 - 1;
                float2 normal = (normal01.xy * 0.5  + normal02.xy);
                //Ramp

                
                //准备向量
                Light light = GetMainLight();//获取主灯光
                float3 normalDir = normalize(i.worldNormal);//法线向量
                float3 viewDir   = normalize(i.worldView);//视线向量
                float2 scrPos = i.pos.xy / _ScreenParams.xy;//屏幕UV坐标
                normalDir += float3(normal.x,0,normal.y) * _NormalScale;
                //深度
                float WaterDepth = WaterDepth_Function(i.worldPos,scrPos,i.viewPos);
                //菲尼尔
                float Fresnel = saturate(pow(1 - dot(normalDir,viewDir),5));

                //折射
                float3 Refraction  = SAMPLE_TEXTURE2D(_RefractionRamp, sampler_RefractionRamp,float2(WaterDepth * _DepthMulti,0.0));
                half3 SceneColor = SAMPLE_TEXTURE2D_LOD(_CameraOpaqueTexture, sampler_CameraOpaqueTexture_linear_clamp, scrPos, WaterDepth * 0.25).rgb;
                Refraction *= SceneColor;

                //高光
                BRDFData brdfData;
                float alpha = 1.0;
                InitializeBRDFData(half3(0, 0, 0), 0, half3(1, 1, 1), 0.95, alpha, brdfData);
                half3 Specular = DirectBDRF(brdfData, normalDir, light.direction, viewDir)  * light.color * 0.01;

                //环境镜面反射
                float3 Reflection = SampleReflections(normalDir, viewDir);//采样环境反射  后续课添加切换
                //次表面散射
                float3 SubSurfaceScattering = SAMPLE_TEXTURE2D(_ScatteringRamp, sampler_ScatteringRamp,float2(WaterDepth * _DepthMulti,0.0)) * light.color * _Color;
                //WaterColor
                float3 Albedo = lerp(Refraction,Reflection,Fresnel);
                //边缘波浪
                float WarpNoise = WaterNoise(i.worldPos.xz * 0.2);
                float WavaFactor =1 - saturate(WaterDepth * 1);
                float WavaRadius = PerlinNoise(WavaFactor.xx * 3- _Time.y + (var_Normal.a * 2 - 1) * 0.5) * WavaFactor * 0.5  +0.5;
                
                float3 finalWava = smoothstep(0.5,0.6,WavaRadius) * saturate(WarpNoise) * _WavaIntensity * light.color;



                



                float WaterAlpha =  smoothstep(0.01,0.2,WaterDepth);

                return float4(Albedo + Specular + SubSurfaceScattering + finalWava,WaterAlpha);
            }
            ENDHLSL
        }
        
        
    }



}
