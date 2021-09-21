Shader "Unlit/Blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _BlurRadius;

            fixed4 frag (v2f_img i) : SV_Target
            {
                float2 uv1 = i.uv + _BlurRadius * _MainTex_TexelSize.xy * float2(1,1);
                float2 uv2 = i.uv + _BlurRadius * _MainTex_TexelSize.xy * float2(-1,-1);
                float2 uv3 = i.uv;
                float2 uv4 = i.uv + _BlurRadius * _MainTex_TexelSize.xy * float2(-1,1);
                float2 uv5 = i.uv + _BlurRadius * _MainTex_TexelSize.xy * float2(1,-1);

                float4 finalRGBA = 0;
                finalRGBA += tex2D(_MainTex,uv1);
                finalRGBA += tex2D(_MainTex,uv2);
                finalRGBA += tex2D(_MainTex,uv3);
                finalRGBA += tex2D(_MainTex,uv4);
                finalRGBA += tex2D(_MainTex,uv5);
                finalRGBA *=0.2;
                
                
                return finalRGBA;
            }
            ENDCG
        }
    }
}
