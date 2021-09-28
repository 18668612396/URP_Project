Shader "Custom/Lit/Lambert"
{
    Properties
    {
        _BaseColor("Color",Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        HLSLINCLUDE
        #pragma vertex vert
        #pragma fragment frag
        #include "../ShaderLibrary/Common.HLSL"
        #include "../ShaderLibrary/Lighting.HLSL"

        struct appdata
        {
            float4 vertex : POSITION;
            float3 normal:NORMAL;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float3 normal:NORMAL;
            
        };

        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        CBUFFER_END


        ENDHLSL
        Pass
        {
            Tags
            {
                "LightMode" = "CustomLightMode"
            }
            
            HLSLPROGRAM
            

            

            v2f vert (appdata i)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(i.vertex);
                o.normal = TransformObjectToWorldNormal(i.normal);
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                Light light = GetMainLight();
                
                //准备向量
                float3 normalDir = normalize(i.normal);
                float3 lightDir = normalize(light.direction);
                float3 lightColor = light.color;
                

                //计算Dot结果
                float NdotL = dot(normalDir,lightDir);
                
                //光照模型
                float Lambert = NdotL *0.5 +0.5;
                return Lambert;
            }
            ENDHLSL
        }
    }
}
