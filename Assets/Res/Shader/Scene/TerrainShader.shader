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
		
		

		CGINCLUDE
		#include "../ShaderFunction.hlsl"
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_fwdbase
		
		uniform sampler2D _Control;
		uniform float4 _Control_ST;


		uniform sampler2D _Splat0,_Mask0,_Normal0;
		uniform float4 _Splat0_ST;

		uniform sampler2D _Splat1,_Mask1,_Normal1;
		uniform float4 _Splat1_ST;

		uniform sampler2D _Splat2,_Mask2,_Normal2;
		uniform float4 _Splat2_ST;

		uniform sampler2D _Splat3,_Mask3,_Normal3;
		uniform float4 _Splat3_ST;


		ENDCG

		Pass
		{
			Tags {
				"RenderType"="Opaque"
				"LightMode"="ForwardBase"
				"Queue" = "Geometry"
			}

			Blend One Zero
			
			CGPROGRAM


			struct PBR
			{
				float4 baseColor;
				float3 normal;//A通道为高度图
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
				float4 normal :NORMAL;
				float4 tangent:TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 Control_UV : TEXCOORD0;
				float3 worldNormal :TEXCOORD2;
				float3 worldTangent :TEXCOORD3;
				float3 worldBitangent :TEXCOORD4;
				float3 worldView :TEXCOORD5;
				float3 worldPos:TEXCOORD6;
				LIGHTING_COORDS(7,8) 
				float2 splat0_UV:TEXCOORD10;
				float2 splat1_UV:TEXCOORD11;
				float2 splat2_UV:TEXCOORD12;
				float2 splat3_UV:TEXCOORD13;

			};

			v2f vert (appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);//初始化顶点着色器
				o.Control_UV = v.uv;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldTangent = UnityObjectToWorldDir(v.tangent).xyz;
				o.worldBitangent = cross(o.worldNormal,o.worldTangent.xyz) * v.tangent.w;
				o.worldView = _WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v.vertex);
				o.splat0_UV = TRANSFORM_TEX(v.uv,_Splat0);
				o.splat1_UV = TRANSFORM_TEX(v.uv,_Splat1);
				o.splat2_UV = TRANSFORM_TEX(v.uv,_Splat2);
				o.splat3_UV = TRANSFORM_TEX(v.uv,_Splat3);
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}

			fixed3 frag (v2f i) : SV_Target
			{

				//采样第一层贴图

				float4 var_Splat0 = tex2D(_Splat0,i.splat0_UV);
				float4 var_Mask0  = tex2D(_Mask0 ,i.splat0_UV);
				float4 var_Normal0= tex2D(_Normal0,i.splat0_UV);
				
				//采样第二层贴图
				float4 var_Splat1 = tex2D(_Splat1,i.splat1_UV);
				float4 var_Mask1  = tex2D(_Mask1 ,i.splat1_UV);
				float4 var_Normal1= tex2D(_Normal1,i.splat1_UV);
				//采样第三层贴图
				float4 var_Splat2 = tex2D(_Splat2,i.splat2_UV);
				float4 var_Mask2  = tex2D(_Mask2 ,i.splat2_UV);
				float4 var_Normal2= tex2D(_Normal2,i.splat2_UV);
				//采样第四层贴图
				float4 var_Splat3 = tex2D(_Splat3,i.splat3_UV);
				float4 var_Mask3  = tex2D(_Mask3 ,i.splat3_UV);
				float4 var_Normal3= tex2D(_Normal3,i.splat3_UV);
				//采样分层贴图
				float4 var_Control = tex2D(_Control,i.Control_UV);
				float4 blend = TerrainBlend(var_Splat0,var_Splat1,var_Splat2,var_Splat3,var_Control);
				//合成
				float4 finalAlbedo = var_Splat0*blend.r + var_Splat1*blend.g+ var_Splat2*blend.b+ var_Splat3*blend.a;
				float4 finalPbrParam =  var_Mask0*blend.r+ var_Mask1*blend.g + var_Mask2*blend.b + var_Mask3*blend.a;
				float4 finalNormal  = var_Normal0*blend.r+ var_Normal1*blend.g+ var_Normal2*blend.b+ var_Normal3*blend.a;

				//PBR
				PBR pbr;
				pbr.baseColor = finalAlbedo;
				pbr.emission  = 0;
				pbr.normal    = finalNormal;//A通道为高度图
				pbr.metallic  = finalPbrParam.r;
				pbr.roughness = finalPbrParam.g;
				pbr.occlusion = finalPbrParam.b;
				pbr.shadow    =  SHADOW_ATTENUATION(i) * CLOUD_SHADOW(i);


				float3 finalRGB = PBR_FUNCTION(i,pbr);
				BIGWORLD_FOG(i,finalRGB);//大世界雾效
				return finalRGB.rgb;
			}
			ENDCG
		}
		pass
		{
			Name "ShadowCaster"
			Tags{"LightMode" = "ShadowCaster"}	

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f 
			{
				V2F_SHADOW_CASTER;
			};

			v2f vert (appdata_base v)
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}
			float4 frag(v2f i ):SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
	}
}