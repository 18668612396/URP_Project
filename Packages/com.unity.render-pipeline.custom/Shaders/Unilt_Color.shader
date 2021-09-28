Shader "Custom/Unlit/Unlit_Color"
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

        struct appdata
        {
            float4 vertex : POSITION;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
        };

        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        CBUFFER_END


        ENDHLSL
        Pass
        {
            Tags
            {
                "Queue" = "queue"
                "LightMode" = "CustomUnlit"
            }
            HLSLPROGRAM
            

            

            v2f vert (appdata i)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(i.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                
                return _BaseColor;
            }
            ENDHLSL
        }
    }
}
