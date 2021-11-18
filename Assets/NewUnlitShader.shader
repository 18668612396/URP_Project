Shader "Study /Anisotropic"
{
	Properties
	{
		_MainTex("MainTex",2D) = "white"{}
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
		_Tangent ("Tangent", Range(0, 1)) = 0
	}
	SubShader
	{
		Pass
		{
			// Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			float _Tangent;
			sampler2D _MainTex;
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldBinormal : TEXCOORD2;
			};

			//顶点着色器当中的计算
			v2f vert(a2v v)
			{
				v2f o;
				//转换顶点空间：模型=>投影
				o.pos = UnityObjectToClipPos(v.vertex);
				//转换顶点空间：模型=>世界
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				//转换法线空间：模型=>世界
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				o.worldBinormal = cross(worldTangent, worldNormal);
				return o;
			}

			//片元着色器中的计算
			fixed4 frag(v2f i) : SV_Target
			{

				float3 normalDir = i.worldNormal;
				float3 viewNormal = normalize(mul(UNITY_MATRIX_V,normalDir)) * 0.5 + 0.5;


				float3 lightDir  = _WorldSpaceLightPos0.xyz;
				float3 viewDir = _WorldSpaceCameraPos - i.worldPos;
				
				float ddd = saturate(dot(normalize(normalDir.xz),normalize(lightDir.xz + viewDir.xy)));

				// float MetalRadius = 1.5;
				float MetalDir = normalize(mul(UNITY_MATRIX_V,normalDir));
				float MetalRadius = saturate(1 - MetalDir) * saturate(1 + MetalDir);
				return saturate(step(0.5,MetalRadius)+0.25) * 0.5 * saturate(step(0.15,MetalRadius) + 0.25);


				float MetalFactor = saturate(1 - saturate(step(1.5,1 - MetalDir) + step(1.5 - 1,MetalDir)) + 0.25);//利用屏幕空间法线 

				
				// return MetalFactor; 
				return tex2D(_MainTex,viewNormal);


			}
			ENDCG
		}
	}
	FallBack "Specular"
}