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
        Tags {
            "RenderType"="Opaque"
            "LightMode"="ForwardBase"
            "Queue" = "Transparent"
        } 
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite off
            Cull off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //GPU Instancing 宏开关
            #pragma multi_compile_instancing    

            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityCG.cginc"  
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID //GPU Instancing顶点定义
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 worldPos:TEXCOORD1;
                float3 worldNormal:NORMAL;
                float3 pivot:TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID  //GPU Instancing 片元定义
            };
            float _test1;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _CloudAminSpeed;
            float4 _Color;
            uniform float _test;
            float _RimpIntensity;
            float _MaxLightRadius;
            float _MinLightRadius;
            float _TranslucidusIntensity;
            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);//初始化顶点着色器
                UNITY_SETUP_INSTANCE_ID(v);//GPU Instancing
                UNITY_TRANSFER_INSTANCE_ID(v, o);//GPU Instancing
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                float3 worldPivot = mul(unity_ObjectToWorld,float4(0.0,0.0,0.0,1.0));//将模型空间坐标转到世界空间
                o.pivot = mul(unity_WorldToObject,worldPivot);//将世界空间坐标转到模型空间

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);//GPU Instancing
                //随机数值
                float randomPivot = i.pivot.x + i.pivot.y + i.pivot.z;
                float randomTime =saturate(abs((frac((_Time.x + abs(randomPivot)) * _CloudAminSpeed) - 0.5) * 3) - 0.5);
                float randomPos  = randomPivot;
                //return float4(randomTime.xxx,1);
                //随机UV坐标
                float randomPosIncrement = 0.0;
            
                
                
                float2 uv = i.uv * float2(0.5,0.25) + ceil(frac(ceil(randomPos) / 10) * 10) * float2(0.5,0.25);
                // return float4(frac(randomPos).xxx,1);
                //采样贴图
                float4 var_MainTex = tex2D(_MainTex,uv);
                // clip(var_MainTex.a - _CutOff);
                //准备向量
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
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
                float translucidus = lerp(lightMaxRadiusFactor,lightMinRadiusFactor,abs(lightDir));
                float3 lightContribution =  Albedo * _LightColor0.rgb * (shadow + translucidus * _TranslucidusIntensity) * rimpLight;
                //环境光源影响
                float3 Ambient = ShadeSH9(float4(normalDir,1));
                float3 indirectionContribution = Ambient * Albedo * Occlustion * rimpLight;
                //最终颜色
                float3 finalRGB = lightContribution + indirectionContribution;
                // BIGWORLD_FOG(i,finalRGB);//大世界雾效
                return float4(finalRGB ,var_MainTex.a * cloudAlphaFactor);
            }
            ENDCG
        }
    }
}
