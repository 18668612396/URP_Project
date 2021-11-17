Shader "Custom/BlinnPhong"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BaseColor ("BaseColor", Color) = (1,1,1,1)
		_GlossinessMap("_GlossinessMap",2D) = "white" {}
		_Glossiness("_Glossiness",Range(0.0,1.0)) = 1.0 
		_SpecularMap("_SpecularMap",2D) = "white" {}

	}
	SubShader
	{
		Tags { 
			"RenderPipeline"="UniversalRenderPipline"
			"RenderType"="Opaque" 
		}
		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		
		CBUFFER_START(UnityMaterial)
		half4 _MainTex_ST;
		half4 _BaseColor;
		float _Glossiness;
		CBUFFER_END

		TEXTURE2D (_MainTex);
		SAMPLER(sampler_MainTex);

		TEXTURE2D (_GlossinessMap);
		SAMPLER(sampler_GlossinessMap);

		TEXTURE2D (_SpecularMap);
		SAMPLER(sampler_SpecularMap);




		struct appdata
		{
			float4 vertex:POSITION;
			float4 normal:NORMAL;
			float4 uv : TEXCOORD0;
		};

		struct v2f
		{
			float4 vertex:SV_POSITION;
			float3 worldNormal:NORMAL;
			float3 worldPos :TEXCOORD1;
			float2 uv:TEXCOORD0;
		};


		ENDHLSL
		pass{

			HLSLPROGRAM
			#pragma vertex VERT
			#pragma fragment FRAG

			v2f VERT( appdata v)
			{
				v2f o;
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.worldNormal = TransformObjectToWorldNormal(v.normal.xyz);
				o.worldPos = TransformObjectToWorld(v.vertex.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			float3 FRAG(v2f i):SV_TARGET
			{
				//采样贴图
				half4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv)*_BaseColor;
				
				float4 var_SpecularMap = SAMPLE_TEXTURE2D(_SpecularMap,sampler_SpecularMap, i.uv);

				//准备向量
				Light light = GetMainLight();
				float3 normalDir = normalize(i.worldNormal);
				float3 lightDir  = normalize(light.direction);
				float3 viewDir   = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				float3 halfDir   = normalize(lightDir + viewDir);
				float3 viewNormal = normalize(mul(UNITY_MATRIX_V,normalDir));
				//点乘计算
				float NdotL = max(0.0,dot(normalDir,lightDir));
				float NdotH = max(0.0,dot(normalDir,halfDir));

				float specPow = exp2(var_SpecularMap.r * 11.0 + 2.0);
				float specNorm = (specPow+8.0) / 8.0;

				float3 specularColor = var_MainTex * var_SpecularMap.g;
				float3 SpecularContrib = var_MainTex * (specNorm * pow(NdotH, specPow) * 0.04 * NdotL);


				float4 var_GlossinessMap = SAMPLE_TEXTURE2D(_GlossinessMap,sampler_GlossinessMap, viewNormal * 0.5 + 0.5) * 2;
				float3 reflColor =  var_GlossinessMap * var_MainTex.rgb * step(0.95,var_SpecularMap.r);
				//头发
				float3 toufa = smoothstep(0.5,1,(specNorm * pow(NdotH, specPow)* (NdotL))) * specularColor * step(var_SpecularMap.r,0.1);
				

				float3 specular = specularColor * SpecularContrib;

				return SpecularContrib;
				return specular*10 + var_MainTex * saturate(NdotL + 0.5) * (1 - var_SpecularMap.r) + reflColor + toufa;

			}

			ENDHLSL 
		}
	}
	//    FallBack "Diffuse"
}
