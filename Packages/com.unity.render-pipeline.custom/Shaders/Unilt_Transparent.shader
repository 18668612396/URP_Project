Shader "Custom/Unlit/Unlit_Transparent"
{
    Properties
    {
        _BaseColor("Color",Color) = (1.0,1.0,1.0,1.0)
        _MainTex("MainTex",2D) = "white"
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
        }
        HLSLINCLUDE
        #pragma vertex vert
        #pragma fragment frag
        #include "../ShaderLibrary/Common.HLSL"
        
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv:TEXCOORD0;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float2 uv:TEXCOORD0;
        };

        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        sampler2D _MainTex;
        float4 _MainTex_ST;
        CBUFFER_END
        ENDHLSL
        Pass
        {
            Tags
            {
                
                "LightMode" = "CustomUnlit"
                
            }

            Blend SrcAlpha OneMinusSrcAlpha 
            ZWrite Off
            HLSLPROGRAM
            v2f vert (appdata i)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(i.vertex);
                o.uv = i.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 var_MainTex = tex2D(_MainTex,i.uv * _MainTex_ST.xy);
                return var_MainTex;
            }
            ENDHLSL
        }
    }
}
