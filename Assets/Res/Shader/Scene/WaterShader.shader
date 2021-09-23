
Shader "Custom/Scene/WaterShader"
{
    Properties
    {
        _WarpScaleOffset("_WarpScaleOffset",vector) = (1.0,1.0,0.0,0.0)
        _WarpIntensity("_WarpIntensity",Range(0.0,1.0)) = 0.5
        _LightFactor("_LightFactor",Range(0.0,1.0)) = 0.0
        _WaterDepth("WaterDepth",float) = 0.0
        [HDR]_WaterTopColor("WaterTopColor",Color) = (1.0,1.0,1.0,1.0)
        _TransparentRadius("_TransparentRadius",Range(0.0,1.0)) = 0.0
        _WaterDownColor("WaterDownColor",Color) = (0.0,0.0,0.0,0.0)
        [Space(50)]
        _WaveRadius("_WaveRadius",Range(0.0,1.0)) = 0.0
        _WaveTile("_WaveTile",float) = 1
        _WaveWidth("_WaveWidth",Range(0.0,0.9)) = 0.0
        _WaveIntensity("_WaveIntensity",Range(0.0,1.0)) = 0.5
        _WaveFactorRadius("_WaveFactorRadius",float) = 0.0
        _WaveFactorIntensity("_WaveFactorIntensity",Range(0.0,1.0)) = 0.0
        [Space(20)]
        _WaveWarpScale("_WaveWarpScale",Range(0.0,1.0)) = 0.0 
        _IndirectionFactor("_IndirectionFactor",float) = 0.0
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
        #include "../ShaderFunction.hlsl"
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv:TEXCOORD0;
            float3 normal:NORMAL;
        };
        struct v2f
        {
            float4 pos : SV_POSITION;
            float4 scrPos : TEXCOORD1;
            float2 uv:TEXCOORD0;
            float3 worldPos:TEXCPPRD2;
            float3 worldNormal:NORMAL;
        };
        TEXTURE2D(_CameraOpaqueTexture);
        SAMPLER(sampler_CameraOpaqueTexture);

        uniform float4 _WarpScaleOffset;
        uniform float _WarpIntensity;

        uniform float _LightFactor;

        uniform float _WaterDepth;
        uniform float4 _WaterTopColor;
        uniform float4 _WaterDownColor;
        uniform float _TransparentRadius;

        uniform float _WaveRadius;
        uniform float _WaveTile;
        uniform float _WaveWidth;
        uniform float _WaveIntensity;
        uniform float _WaveFactorIntensity;
        uniform float _WaveFactorRadius;

        uniform float _WaveWarpScale;

        uniform float _IndirectionFactor;
        ENDHLSL

        
        Pass
        {
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite Off
            HLSLPROGRAM
            v2f vert ( appdata v )
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                o.scrPos = ComputeScreenPos(o.pos);
                
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                return o;
            }
            
            float4 frag (v2f i ) : SV_Target
            {
                
                //准备向量
                Light light = GetMainLight();
                float3 lightDir = normalize(light.direction).xyz;
                float3 normalDir = normalize(i.worldNormal);
                float3 viewDir   =normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 reflectDir = reflect(-viewDir,normalDir);
                float3 cameraPos = _WorldSpaceCameraPos;
                float3 reflectCamera = reflect(cameraPos * 0.5 + i.worldPos,normalDir);
                float2 scrPos = i.scrPos.xy / i.scrPos.w;
                float fresnel = max(0.0,dot(normalDir,viewDir));
                float indirectionFactor =1 -  pow(fresnel,_IndirectionFactor);
                //计算扭曲
                float2 warp = float2(1.0,1.0);
                warp.x = PerlinNoise(reflectCamera.xz + float2(0.0,_Time.y));
                warp.y = PerlinNoise(reflectCamera.xz + float2(0.0,-_Time.y));
                warp *= _WarpIntensity;
                //计算主光源漫反射
                float3 Albedo = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, scrPos).rgb;
                float DepthFactor =  DepthCompare(i.pos,scrPos,_WaterDepth);
                float waterTopFactor = smoothstep(_TransparentRadius,1.0,DepthFactor);
                float3 lightDiffuse = lerp(_WaterDownColor.rgb,lerp(_WaterTopColor.rgb,1,waterTopFactor)* Albedo,DepthFactor);
                //计算主光源镜面反射
                float waveFactor = distance(cameraPos,i.worldPos);
                waveFactor = 1 - saturate((1 - waveFactor + _WaveFactorRadius) * i.uv.y * _WaveFactorIntensity);
                float waveRadius = smoothstep(_WaveRadius,1,DepthFactor);
                float waveWarp   = PerlinNoise(i.worldPos.xz * _WaveWarpScale);
                float2 waveCoord = float2(0.0,waveRadius) * _WaveTile + float2(0.0,-_Time.y) + waveWarp;
                float3 lightSpec = smoothstep(_WaveWidth,_WaveWidth+0.1,(PerlinNoise(waveCoord) * 0.5 + 0.5) * waveRadius) *light.color * _WaveIntensity * waveFactor;
                //计算主光源贡献
                float3 lightContribution = lightDiffuse  * (1 - _LightFactor) + lightSpec;

                //计算环境漫反射
                float3 indirectionDiffuse = 0.0;
                //采样环境反射
                
                float3 var_Cubemap =  SAMPLE_TEXTURECUBE(unity_SpecCube0,samplerunity_SpecCube0, reflectDir + float3(warp.y,warp.x,0.0)).rgb;;
                float3 indirectionSpec = var_Cubemap;
                float3 indirectionContribution = (indirectionDiffuse + indirectionSpec) * _LightFactor * indirectionFactor;
                
                float3 finalRGB = lightContribution + indirectionContribution;
                BIGWORLD_FOG(i,finalRGB);//大世界雾效
                
                float Alpha =1 - smoothstep(0.9,1,DepthFactor);
                return float4(finalRGB,Alpha);
            }
            ENDHLSL
        }
    }



}
