Shader "Unlit/test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
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
                float3 normal:NORMAL;
            };
    
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 objPos :TEXCOORD1;
                float3 normal:NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _test;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = v.vertex;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv =v.uv;
                o.objPos = v.vertex;

                return o;
            }

            fixed3 frag(v2f i) : SV_Target
            {

                float3 test = i.normal;

            }
            ENDCG
        }
    }
}