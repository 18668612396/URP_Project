Shader "Custom/NBR_Shader"
{
    Properties
    {
        _Matcap("Matcap",2D) = "white"{}
        _MainTex (" MainTex ", 2D) = "white" {}
        _BaseColor("BaseColor",Color) = (1,1,1,1)
        _PbrParam("PbrParam",2D) = "white"{}
        _EmissionIntensity("EmissionIntensity",float) = 0
        _Metallic ("Metallic",Range(0,1)) = 0
        _Roughness("Roughness",Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" } 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct PBR
            {
                float3 baseColor;
                float3 emission;
                float  roughness;
                float  metallic;
                float lightMap;
                
            };
            #include "NBR_Function.HLSL"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal :NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 clipPos : SV_POSITION;
                float3 worldNormal :WORLD_NORMAL;
                float3 worldTangent :WORLD_TANGENT;
                float3 worldBitangent :WORLD_BITANGENT;
                float3 worldView :WORLD_VIEW;
            };
            
            //贴图采样器
            uniform sampler2D _MainTex,_PbrParam;
            uniform float4 _BaseColor;
            uniform float _Metallic,_Roughness,_EmissionIntensity;
            
            v2f vert (appdata i)
            {
                v2f o;
                o.uv = i.uv;
                o.clipPos = UnityObjectToClipPos(i.vertex);
                
                o.worldNormal = UnityObjectToWorldNormal(i.normal);
                o.worldTangent = UnityObjectToWorldDir(i.tangent).xyz;
                o.worldBitangent = cross(o.worldNormal,o.worldTangent.xyz) * i.tangent.w;
                o.worldView = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,i.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //贴图采样
                float4 var_MainTex = tex2D(_MainTex,i.uv);
                float4 var_PbrParam  = tex2D(_PbrParam,i.uv);
                
                //PBR
                PBR pbr;
                pbr.baseColor = var_MainTex.rgb * _BaseColor.rgb;
                pbr.emission  = lerp(0,var_MainTex.rgb * var_MainTex.rgb * max(0.0,_EmissionIntensity),var_MainTex.a);
                pbr.metallic  = var_PbrParam.r * _Metallic;
                pbr.roughness = var_PbrParam.g * _Roughness;
                pbr.lightMap  = var_PbrParam.b;
                
                
                
                float3 finalRGB = PBR_FUNCTION(i,pbr);
                return finalRGB.rgbb + pbr.emission.rgbb;
            }
            ENDCG
        }
    }
}
