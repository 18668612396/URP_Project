Shader "Unlit/algebra"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _test("test",Range(0.0,6)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _test;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                _test = _test / UNITY_PI;
                float3x3 RotatorM = float3x3(float3(cos(_test),-sin(_test),0)
                                            ,float3(sin(_test),cos(_test),0)
                                            ,float3( 0.5   ,   0.5 ,1)
                                            );
                float3 uv = mul(RotatorM,float3(i.uv,1));
                return tex2D(_MainTex,uv.xy);   
                
            }
            ENDCG
        }
    }
}
