Shader "Cartoon/Hair"
{
    Properties
    {
        _TheTimeRamp("TheTimeRamp",int) = 0.1
        _RampTex("Ramp",2D) = "white"{}
        _BoundaryPos("_BoundaryPos",Range(0,1)) = 0
        _BoundaryRadius("_BoundaryRadius",float) = 0
        
        _MainTex ("Texture", 2D) = "white" {}
        _Material("Material",2D) = "white" {}
        _SpecularRadius("SpecularRadius",float) = 1
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
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float3 color:COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal:NORMAL;
                float3 viewDir:VIEWDIR;
                float3 color:COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Material;
            sampler2D _RampTex;
            float _SpecularRadius;
            float _BoundaryPos;
            float _BoundaryRadius;
            float _TheTimeRamp;
            v2f vert (appdata i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.uv = TRANSFORM_TEX(i.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(i.normal);
                o.viewDir = _WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,i.vertex);
                o.color = i.color;
                return o;
            }

            float3 frag (v2f i) : SV_Target
            {
                
                //采样贴图
                fixed4 var_MainTex = tex2D(_MainTex, i.uv);
                fixed4 var_Material = tex2D(_Material,i.uv);
                //准备向量
                float3 Ambient = UNITY_LIGHTMODEL_AMBIENT;
                float3 lightDir = normalize(_WorldSpaceLightPos0).xyz;
                float3 normalDir = normalize(i.normal).xyz;
                float3 viewDir = normalize(i.viewDir).xyz;
                float3 halfDir = normalize(viewDir + lightDir);

                //Ramp数组
                //{
                    float rampUV = DotClamped(normalDir,lightDir) * 0.5 + 0.5;
                    float4 ramp = tex2D(_RampTex,float2(rampUV,_TheTimeRamp/10));
                    


                //}
                //DOT
                float Lambert = smoothstep(_BoundaryPos,_BoundaryPos + _BoundaryRadius,DotClamped(normalDir,lightDir));
                //阴影
                float3 shadowColor = lerp(unity_ShadowColor,1,saturate(var_Material.g * 2 * Lambert));
                return var_MainTex * shadowColor * Ambient * _LightColor0.rgb;
                
            }
            ENDCG
        }
    }
}
