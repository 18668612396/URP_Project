﻿Shader "Custom/URP_BASE"
{
	Properties
	{
		_MainTex("主贴图", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		Pass
		{
			
			Tags
			{ 
				"RenderPipeline"="UniversalRenderPipline"
				"LightMode" = "UniversalForward"
				"IgnoreProjector" = "True"
				"RenderType"="Opaque" 
				"Queue" = "Opaque"
			}
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "ShaderFunction.HLSL"
			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};
			
			uniform TEXTURE2D (_MainTex);
			uniform	SAMPLER(sampler_MainTex);
			uniform float4 _MainTex_ST;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				return o;
			}
			
			float4 _Color;
			float _test;
			float4 frag(v2f i) : SV_Target
			{
				float4 SHADOW_COORDS = TransformWorldToShadowCoord(i.worldPos);
				Light light = GetMainLight(SHADOW_COORDS);
				float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
				return var_MainTex * light.shadowAttenuation;
			}
			ENDHLSL
		}
		pass 
		{
			Name "ShadowCast"
			
			Tags{ "LightMode" = "ShadowCaster" }
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			struct appdata
			{
				float4 vertex : POSITION;
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}
			float4 frag(v2f i) : SV_Target
			{
				float4 color;
				color.xyz = float3(0.0, 0.0, 0.0);
				return color;
			}
			ENDHLSL
		}
	}
}