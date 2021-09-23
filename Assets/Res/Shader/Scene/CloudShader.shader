Shader "Custom/Scene/CloudShader"
{
    Properties
    {
        [Toggle] _test1("test",float) = 0
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1.0,1.0,1.0,1.0)
        _CloudAminSpeed("CloudAminSpeed",Range(0.0,0.5)) = 0.5
        _RimpIntensity("RimpIntensity",Range(0.0,2)) = 0.0
        _MaxLightRadius("_MaxLightRadius",float) = 0.0
        _MinLightRadius("_MinLightRadius",float) = 80
        _TranslucidusIntensity("_TranslucidusIntensity",Range(0,1)) = 0
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
        HLSLINCLUDE
        #include "../ShaderFunction.hlsl"
        #pragma vertex vert
        #pragma fragment frag


        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
            float3 normal:NORMAL;
            
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 pos : SV_POSITION;
            float3 worldPos:TEXCOORD1;
            float3 worldNormal:NORMAL;
            float3 randomPos:TEXCOORD3;
            
        };
        
        CBUFFER_START(UnityPreMaterial)
        uniform TEXTURE2D (_MainTex);
        uniform	SAMPLER(sampler_MainTex);
        uniform float4 _MainTex_ST;

        float _CloudAminSpeed;
        float4 _Color;
        float _RimpIntensity;
        float _MaxLightRadius;
        float _MinLightRadius;
        float _TranslucidusIntensity;
        CBUFFER_END
        ENDHLSL
        
        Pass
        {
           
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite Off
            HLSLPROGRAM
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器

                o.pos = TransformObjectToHClip(v.vertex.xyz);
                
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                float3 worldPivot =TransformObjectToWorld(float3(0.0,0.0,0.0));//将模型空间坐标转到世界空间
                float3 pivot = mul(unity_WorldToObject,float4(worldPivot,0.0)).xyz;//将世界空间坐标转到模型空间

                //随机数值
                float randomPivot = pivot.x + pivot.y + pivot.z;
                o.randomPos  = randomPivot;
                //随机UV坐标
                float randomPosIncrement = 0.0;
                
                o.uv = v.uv *  float2(0.5,0.25) + ceil(frac(ceil(o.randomPos.xy) / 10) * 10) * float2(0.5,0.25);
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {

                //return float4(randomTime.xxx,1);
                float randomTime =saturate(abs((frac((_Time.x + abs(i.randomPos.r)) * _CloudAminSpeed) - 0.5) * 3) - 0.5);
                // return float4(frac(randomPos).xxx,1);
                //采样贴图
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                
                //准备向量
                Light light = GetMainLight();
                float3 lightDir = normalize(light.direction);
                float3 viewDir  = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                float3 normalDir = normalize(i.worldNormal);
                //dot
                float VdotL = max(0,dot(viewDir,-lightDir)) * 0.5 + 0.5;
                //太阳光照范围
                float lightMaxRadiusFactor = pow(VdotL,_MaxLightRadius);
                float lightMinRadiusFactor = pow(VdotL,_MinLightRadius);
                //Cloud动画
                float aminRandomTime = randomTime;
                float cloudAlphaFactor = smoothstep(aminRandomTime,aminRandomTime + 0.1,var_MainTex.b);
                //基础颜色
                float3 Albedo = _Color.rgb;
                float Occlustion = 1;
                //边缘光
                float rimpLight = lerp(1.0,_RimpIntensity,var_MainTex.g * cloudAlphaFactor * lightMaxRadiusFactor);
                //主光源影响
                float shadow = var_MainTex.r;
                float translucidus = lerp(lightMaxRadiusFactor,lightMinRadiusFactor,abs(lightDir).x);
                float3 lightContribution =  Albedo * light.color * (shadow + translucidus * _TranslucidusIntensity) * rimpLight;
                //环境光源影响
                float3 Ambient = SampleSH(normalDir);
                float3 indirectionContribution = Ambient * Albedo * Occlustion * rimpLight;
                //最终颜色
                float3 finalRGB = lightContribution + indirectionContribution;
                
                // BIGWORLD_FOG(i,finalRGB);//大世界雾效
                return float4(finalRGB ,var_MainTex.a * cloudAlphaFactor);
            }
            ENDHLSL
        }
    }
}
