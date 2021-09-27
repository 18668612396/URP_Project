// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

Shader "Custom/Character/CartoonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        
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

        uniform TEXTURE2D (_MainTex);
        uniform	SAMPLER(sampler_MainTex);
        //变量声明
        CBUFFER_START(UnityPerMaterial)
        //贴图采样器
        uniform float4 _MainTex_ST;

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
            Tags{ "LightMode" = "SRPDefaultUnlit" }

            Cull off
            HLSLPROGRAM
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);//这个一定要放在下面两个顶点相关的方法之上 这样他们才能调用到
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldView = _WorldSpaceCameraPos.xyz - o.worldPos;
                o.vertexColor = v.color;
                return o;
            }


            real3 frag (v2f i) : SV_Target
            {
                //采样贴图
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);

                //准备向量
                float4 SHADOW_COORDS = TransformWorldToShadowCoord(i.worldPos);
                Light light = GetMainLight(SHADOW_COORDS);
                float3 lightDir = normalize(light.direction).xyz;
                float3 viewDir  = normalize(i.worldView);
                float3 normalDir = normalize(i.worldNormal);
                float3 halfDir   = normalize(lightDir + viewDir);
                //点乘计算
                float NdotL = max(0.0,dot(normalDir,lightDir));

                //基础颜色Albedo
                float3 Albedo  = var_MainTex.rgb;
                //主光源影响
                float shadow = light.shadowAttenuation  * CLOUD_SHADOW(i);//把顶点色A通道当作自投影
                float3 lightContribution = Albedo * light.color * NdotL * shadow;

                //环境光源影响
                float3 Ambient = SampleSH(normalDir);
                float3 indirectionContribution = Ambient * Albedo;

                //光照合成
                float3 finalRGB = lightContribution + indirectionContribution;
                BIGWORLD_FOG(i,finalRGB);//大世界雾效
                //输出
                return finalRGB;

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
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }
            float4 frag(v2f i) : SV_Target
            {
                return float4(1.0,1.0,1.0,1.0);
            }
            ENDHLSL
        }
        
    }

    
}
