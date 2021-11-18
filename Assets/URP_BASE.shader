Shader "Custom/cube"
{
	Properties
	{
		// _NormTex ("RGB:法线贴图", 2D) = "bump" {}
		
		
	}
	SubShader
	{
		Tags { 
			"RenderPipeline"="UniversalRenderPipline"
			"RenderType"="Opaque" 
			
		}

		//Cull front
		HLSLINCLUDE
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		//      #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
		
		CBUFFER_START(UnityMaterial)
		// half4 _MainTex_ST;
		// half4 _BaseColor;
		CBUFFER_END

		// TEXTURE2D(_NormTex);
		// SAMPLER(sampler_NormTex);


		struct appdata
		{
			float4 vertex : POSITION; 
			float2 uv0 : TEXCOORD0; 
			float4 normal : NORMAL; 
			float4 tangent : TANGENT; 
			
		};

		struct v2f
		{
			float4 pos : SV_POSITION; 
			float2 uv0 : TEXCOORD0; 
			float4 posWS : TEXCOORD1; 
			float3 nDirWS : TEXCOORD2; 
			float3 tDirWS : TEXCOORD3; 
			float3 bDirWS : TEXCOORD4; 
		};


		ENDHLSL
		pass
		{

			HLSLPROGRAM
			#pragma vertex VERT
			#pragma fragment FRAG

			v2f VERT( appdata v)
			{
				v2f o;
				o.pos = TransformObjectToHClip(v.vertex);
				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				o.nDirWS = TransformObjectToWorldNormal(v.normal); // 法线方向 OS>WS
				o.tDirWS = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz); // 切线方向 OS>WS
				o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w); // 副切线方向
				o.uv0 = v.uv0;
				return o;
			}

			float4 FRAG(v2f i) : SV_TARGET
			{
				// Light mylight = GetMainLight();
				
				// float3 lDirWS = normalize(mylight.direction);
				// float3 nDirTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormTex, sampler_NormTex, i.uv0));
				// float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
				// float3 nDirWS = normalize(mul(nDirTS, TBN));
				float3 normalDir = normalize(i.nDirWS);
				// float ndotl = dot(normalDir, lDirWS);

				float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
				
				float3 vrDirWS = reflect(-vDirWS, normalDir);
				half4 Cube = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0,vrDirWS,0);
				
				// float4 final = ndotl;//*Cube;

				return Cube;

			}

			ENDHLSL 
		}
	}

}
//FallBack "Diffuse"