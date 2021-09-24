Shader "Custom/Scene/VegetationShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_TopColor("TopColor",Color) = (1.0,1.0,1.0,1.0)
        [HDR] _DownColor("DownColor",Color) = (0.0,0.0,0.0,0.0)
        _GradientVector("_GradientVector",vector) = (0.0,1.0,0.0,0.0)
        _CutOff("Cutoff",Range(0.0,1.0)) = 0.0
        _WindAnimToggle("_WindAnimToggle",int) = 1
        
        
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
        #pragma vertex vert
        #pragma fragment frag
        #include "../ShaderFunction.hlsl"
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
            float3 localPos:TEXCOORD3;
            
        };

        CBUFFER_START(UnityPreMaterial)
        //贴图采样器
        uniform TEXTURE2D (_MainTex);
        uniform	SAMPLER(sampler_MainTex);
        uniform float4 _MainTex_ST;

        uniform float _CutOff;
        uniform float4 _TopColor;
        uniform float4 _DownColor;
        uniform float4 _GradientVector;
        uniform float _OcclusionIntensity;
        CBUFFER_END
        ENDHLSL
        Pass
        {
            
            LOD 100
            Cull off
            HLSLPROGRAM

            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);//这个一定要放在下面两个顶点相关的方法之上 这样他们才能调用到
                WIND_ANIM(v,o);
                GRASS_INTERACT(v,o);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.localPos = v.vertex.xyz;
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldView = _WorldSpaceCameraPos.xyz - o.worldPos;
                o.vertexColor = v.color;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //采样贴图
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                //准备向量
                float4 SHADOW_COORDS = TransformWorldToShadowCoord(i.worldPos);
                Light light = GetMainLight(SHADOW_COORDS);
                float3 lightDir = normalize(light.direction).xyz;
                float3 localPos = i.localPos;
                float3 normalDir = normalize(i.worldNormal);

                //点乘计算
                float NdotL = saturate(dot(normalDir,lightDir));
                //基础颜色Albedo
                float Gradient = saturate(smoothstep(_GradientVector.x,_GradientVector.y,localPos.y  + _GradientVector.z));
                float3 Albedo  = lerp(_DownColor.rgb,_TopColor.rgb,Gradient) * var_MainTex.r;
                //Occlusion
                float Occlustion = lerp(_GradientVector.z,_GradientVector.w,i.vertexColor.b);//和PBR相同  使用B通道来作为AO的输入
                //主光源影响
                float shadow = light.shadowAttenuation * CLOUD_SHADOW(i);
                float3 lightContribution = Albedo * light.color * NdotL * shadow ;
                //环境光源影响
                float3 Ambient = SampleSH(normalDir);
                float3 indirectionContribution = Ambient * Albedo * Occlustion;
                //光照合成
                float3 finalRGB = lightContribution + indirectionContribution;
                BIGWORLD_FOG(i,finalRGB);//大世界雾效
                //AlphaTest
                clip(var_MainTex.g - _CutOff);
                //输出
                return finalRGB.rgbb;
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
                o.uv = v.uv;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }
            float4 frag(v2f i) : SV_Target
            {
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                clip(var_MainTex.g - _CutOff);
                return float4(1.0,1.0,1.0,1.0);
            }
            ENDHLSL
        }
    }
    CustomEditor "VegetationShaderGUI"
}
