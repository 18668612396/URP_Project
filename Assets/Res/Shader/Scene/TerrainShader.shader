// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Scene/TerrainShader"
{
	Properties
	{
		[NoScaleOffset]_Control("_Control",2D) = "white"

		_Splat0("_Splat0",2D) = "white"
		[NoScaleOffset]_Mask0("_PbrParam0",2D) = "white"
		[NoScaleOffset]_Normal0("_Normal0",2D) = "bump"
		_Splat1("_Splat1",2D) = "white"
		[NoScaleOffset]_Mask1("_PbrParam1",2D) = "white"
		[NoScaleOffset]_Normal1("_Normal1",2D) = "bump"
		_Splat2("_Splat2",2D) = "white"
		[NoScaleOffset]_Mask2("_PbrParam2",2D) = "white"
		[NoScaleOffset]_Normal2("_Normal2",2D) = "bump"
		_Splat3("_Splat3",2D) = "white"
		[NoScaleOffset]_Mask3("_PbrParam3",2D) = "white"
		[NoScaleOffset]_Normal3("_Normal3",2D) = "bump"

		_TerrainHeightDepth("_TerrainHeightDepth",float) = 0.2
	}

	SubShader
	{
		Tags { 
			"RenderType"="Opaque" 
			"SplatCount"="4" 
		}
		
		

		HLSLINCLUDE

		#include "../ShaderFunction.hlsl"
		#pragma vertex vert
		#pragma fragment frag

		struct PBR
		{
			float4 baseColor;//A通道为高度图
			float3 normal;
			float3 emission;
			float  roughness;
			float  metallic;
			float  occlusion;
			float  shadow;
			
		};
		#include "../PBR_Scene_Function.HLSL"
		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
			float2 lightmapUV:TEXCOORD1;
			float4 normal :NORMAL;
			float4 tangent:TANGENT;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			float2 Control_UV : TEXCOORD0;
			float2 lightmapUV:TEXCOORD1;
			float3 worldNormal :TEXCOORD2;
			float3 worldTangent :TEXCOORD3;
			float3 worldBitangent :TEXCOORD4;
			float3 worldView :TEXCOORD5;
			float3 worldPos:TEXCOORD6;
			float2 splat0_UV:TEXCOORD10;
			float2 splat1_UV:TEXCOORD11;
			float2 splat2_UV:TEXCOORD12;
			float2 splat3_UV:TEXCOORD13;
			float4 SHADOW_COORDS:TEXCOORD7;
		};

		uniform TEXTURE2D (_Control);
		uniform	SAMPLER(sampler_Control);
		
		uniform TEXTURE2D (_Splat0);
		uniform TEXTURE2D (_Mask0);
		uniform TEXTURE2D (_Normal0);
		uniform	SAMPLER(sampler_Splat0);
		uniform	SAMPLER(sampler_Mask0);
		uniform	SAMPLER(sampler_Normal0);
		uniform float4 _Splat0_ST;

		uniform TEXTURE2D (_Splat1);
		uniform TEXTURE2D (_Mask1);
		uniform TEXTURE2D (_Normal1);
		uniform	SAMPLER(sampler_Splat1);
		uniform	SAMPLER(sampler_Mask1);
		uniform	SAMPLER(sampler_Normal1);
		uniform float4 _Splat1_ST;

		uniform TEXTURE2D (_Splat2);
		uniform TEXTURE2D (_Mask2);
		uniform TEXTURE2D (_Normal2);
		uniform	SAMPLER(sampler_Splat2);
		uniform	SAMPLER(sampler_Mask2);
		uniform	SAMPLER(sampler_Normal2);
		uniform float4 _Splat2_ST;

		uniform TEXTURE2D (_Splat3);
		uniform TEXTURE2D (_Mask3);
		uniform TEXTURE2D (_Normal3);
		uniform	SAMPLER(sampler_Splat3);
		uniform	SAMPLER(sampler_Mask3);
		uniform	SAMPLER(sampler_Normal3);
		uniform float4 _Splat3_ST;

		ENDHLSL

		Pass
		{
			Tags
			{ 
				"RenderPipeline"="UniversalRenderPipline"
				"RenderType"="Opaque" 
				"Queue" = "Geometry"
			}

			Blend One Zero
			HLSLPROGRAM


			v2f vert (appdata v)
			{
				v2f o;
				ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
				o.Control_UV = v.uv;
				o.lightmapUV = v.lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;
				o.pos = TransformObjectToHClip(v.vertex.xyz);
				o.worldPos = TransformObjectToWorld(v.vertex.xyz);
				o.SHADOW_COORDS = TransformWorldToShadowCoord(o.worldPos.xyz);
				o.worldNormal = TransformObjectToWorldNormal(v.normal.xyz);
				o.worldTangent = TransformObjectToWorldDir(v.tangent.xyz);
				o.worldBitangent = cross(o.worldNormal,o.worldTangent.xyz) * v.tangent.w;
				o.worldView = _WorldSpaceCameraPos.xyz - o.worldPos;
				o.splat0_UV = TRANSFORM_TEX(v.uv,_Splat0);
				o.splat1_UV = TRANSFORM_TEX(v.uv,_Splat1);
				o.splat2_UV = TRANSFORM_TEX(v.uv,_Splat2);
				o.splat3_UV = TRANSFORM_TEX(v.uv,_Splat3);

				return o;
			}

			real3 frag (v2f i) : SV_Target
			{

				//采样第一层贴图

				float4 var_Splat0 = SAMPLE_TEXTURE2D(_Splat0,sampler_Splat0,i.splat0_UV);
				float4 var_Mask0  =  SAMPLE_TEXTURE2D(_Mask0,sampler_Mask0,i.splat0_UV);
				float3 var_Normal0= SAMPLE_TEXTURE2D(_Normal0,sampler_Normal0,i.splat0_UV).xyz;
				
				//采样第二层贴图
				float4 var_Splat1 = SAMPLE_TEXTURE2D(_Splat1,sampler_Splat1,i.splat1_UV);
				float4 var_Mask1  = SAMPLE_TEXTURE2D(_Mask1,sampler_Mask1,i.splat1_UV);
				float3 var_Normal1= SAMPLE_TEXTURE2D(_Normal1,sampler_Normal1,i.splat1_UV).xyz;
				//采样第三层贴图
				float4 var_Splat2 = SAMPLE_TEXTURE2D(_Splat2,sampler_Splat2,i.splat2_UV);
				float4 var_Mask2  = SAMPLE_TEXTURE2D(_Mask2,sampler_Mask2,i.splat2_UV);
				float3 var_Normal2= SAMPLE_TEXTURE2D(_Normal2,sampler_Normal2,i.splat2_UV).xyz;
				//采样第四层贴图
				float4 var_Splat3 = SAMPLE_TEXTURE2D(_Splat3,sampler_Splat3,i.splat3_UV);
				float4 var_Mask3  = SAMPLE_TEXTURE2D(_Mask3,sampler_Mask3,i.splat3_UV);
				float3 var_Normal3= SAMPLE_TEXTURE2D(_Normal3,sampler_Normal3,i.splat3_UV).xyz;
				// //采样分层贴图
				float4 var_Control = SAMPLE_TEXTURE2D(_Control,sampler_Control,i.Control_UV);
				float4 blend = TerrainBlend(var_Splat0,var_Splat1,var_Splat2,var_Splat3,var_Control);
				//合成
				float4 finalAlbedo = var_Splat0*blend.r + var_Splat1*blend.g+ var_Splat2*blend.b+ var_Splat3*blend.a;
				float4 finalPbrParam =  var_Mask0*blend.r+ var_Mask1*blend.g + var_Mask2*blend.b + var_Mask3*blend.a;
				float3 finalNormal  = var_Normal0*blend.r+ var_Normal1*blend.g+ var_Normal2*blend.b+ var_Normal3*blend.a;

				//PBR
				PBR pbr;
				ZERO_INITIALIZE(PBR,pbr);//初始化顶点着色器
				pbr.baseColor = finalAlbedo;
				pbr.emission  = float3(0.0,0.0,0.0);
				pbr.normal    = finalNormal;//A通道为高度图
				pbr.metallic  = finalPbrParam.r;
				pbr.roughness = finalPbrParam.g;
				pbr.occlusion = finalPbrParam.b;



				float3 finalRGB = PBR_FUNCTION(i,pbr);
				BIGWORLD_FOG(i,finalRGB);//大世界雾效
				return finalRGB;
			}
			ENDHLSL
		}
		pass 
		{
			Name "ShadowCast"
			
			Tags{ "LightMode" = "ShadowCaster" }
			HLSLPROGRAM
			v2f vert(appdata v)
			{
				v2f o;
				ZERO_INITIALIZE(v2f,o);
				o.pos = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}
			float4 frag(v2f i) : SV_Target
			{
				return float4(1.0,1.0,1.0,1.0);
			}
			ENDHLSL
		}
	}
}