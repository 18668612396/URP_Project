// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "IL3DN/Fog"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_Density("Density", Range( 0 , 10000)) = 50
		_NearColor("Near Color", Color) = (1,0.2038271,0,0)
		_FarColor("Far Color", Color) = (0,0.2739539,1,0)
		_GlowColor("Glow Color", Color) = (1,0.2038271,0,0)
		[Toggle(_EXCLUDESKYBOX_ON)] _ExcludeSkybox("Exclude Skybox", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{ 
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			#pragma shader_feature _EXCLUDESKYBOX_ON


			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				float4 ase_texcoord4 : TEXCOORD4;
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float4 _GlowColor;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _Density;
			uniform float4 _NearColor;
			uniform float4 _FarColor;

			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.pos = UnityObjectToClipPos ( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float4 screenPos = i.ase_texcoord4;
				float clampDepth76 = Linear01Depth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD( screenPos )));
				float screenDepth94 = saturate( ( clampDepth76 * _Density ) );
				float4 midCol87 = ( _GlowColor * saturate( (0.0 + (screenDepth94 - 0.1) * (1.0 - 0.0) / (0.2 - 0.1)) ) );
				float4 lerpResult65 = lerp( _NearColor , _FarColor , screenDepth94);
				float4 fogCol89 = lerpResult65;
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 screenCol90 = tex2D( _MainTex, uv_MainTex );
				float lerpResult91 = lerp( ( 1.0 - _NearColor.a ) , ( 1.0 - _FarColor.a ) , screenDepth94);
				float fogAlpha92 = lerpResult91;
				float4 lerpResult73 = lerp( fogCol89 , screenCol90 , fogAlpha92);
				float4 blendOpSrc112 = midCol87;
				float4 blendOpDest112 = lerpResult73;
				float4 combinedColors130 = ( saturate( ( 1.0 - ( 1.0 - blendOpSrc112 ) * ( 1.0 - blendOpDest112 ) ) ));
				float clampDepth139 = Linear01Depth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD( screenPos )));
				float4 lerpResult128 = lerp( screenCol90 , combinedColors130 , step( clampDepth139 , 0.999998 ));
				#ifdef _EXCLUDESKYBOX_ON
				float4 staticSwitch114 = lerpResult128;
				#else
				float4 staticSwitch114 = combinedColors130;
				#endif
				

				finalColor = staticSwitch114;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16900
267;306;1228;890;-1003.166;-377.2123;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;141;-1532.979,-814.1492;Float;False;952.8044;332.3556;Screen Depth;5;94;107;78;76;31;;1,0,0.02020931,1;0;0
Node;AmplifyShaderEditor.ScreenDepthNode;76;-1425.261,-726.0521;Float;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1486.399,-592.7107;Float;False;Property;_Density;Density;0;0;Create;True;0;0;False;0;50;20;0;10000;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1155.785,-663.0411;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;107;-997.1508,-663.4609;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-832.1851,-663.8221;Float;False;screenDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;143;-531.2238,-313.1123;Float;False;1075.89;451.0441;Fog Colors;5;10;101;2;65;89;;0,0.8300319,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;142;-527.9166,-816.0754;Float;False;1075.89;451.0441;Glow Color;6;108;87;81;79;88;111;;1,0.5665205,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;144;-537.5551,186.1575;Float;False;1075.89;451.0441;Fog Colors Alpha;5;92;91;100;102;103;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;145;-537.1301,685.9793;Float;False;1075.89;451.0441;Screen;3;99;72;90;;0.7587526,1,0.3443396,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-477.8193,-545.855;Float;False;94;screenDepth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-491.7118,-252.2064;Float;False;Property;_NearColor;Near Color;1;0;Create;True;0;0;False;0;1,0.2038271,0,0;1,0.6754876,0.4198112,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;10;-487.9349,-60.67448;Float;False;Property;_FarColor;Far Color;2;0;Create;True;0;0;False;0;0,0.2739539,1,0;0.2122634,0.5812036,1,0.4;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;102;-174.4074,282.0202;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;103;-177.5052,370.3084;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-217.1882,483.4968;Float;False;94;screenDepth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;99;-341.4579,786.636;Float;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;111;-229.3741,-542.2637;Float;False;5;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0.2;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-208.8753,-54.92604;Float;False;94;screenDepth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;65;47.10435,-232.3525;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;72;-116.2883,783.7027;Float;True;Property;_orColor;orColor;4;1;[HideInInspector];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;91;40.90746,345.2759;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;79;-89.98221,-754.9459;Float;False;Property;_GlowColor;Glow Color;3;0;Create;True;0;0;False;0;1,0.2038271,0,0;0.2470584,0.1176342,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;88;-31.085,-542.2628;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;297.8219,783.8709;Float;False;screenCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;298.0711,353.9594;Float;False;fogAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;316.8073,-239.8058;Float;False;fogCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;146.6527,-676.2126;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;73;821.8856,101.0071;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;328.2986,-678.65;Float;False;midCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;112;1073.17,71.6834;Float;False;Screen;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;146;637.6789,685.136;Float;False;763.7814;441.6655;Exclude Skybox;6;123;124;131;129;128;139;;0,0.620383,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;124;755.3596,1040.622;Float;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;0.999998;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;139;705.1352,938.621;Float;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;130;1346.803,72.77291;Float;False;combinedColors;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;123;1009.185,951.4492;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;723.7603,736.7744;Float;False;90;screenCol;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;131;686.3743,838.0184;Float;False;130;combinedColors;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;128;1229.388,768.6309;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;114;1650.693,736.8821;Float;False;Property;_ExcludeSkybox;Exclude Skybox;4;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;51;1976.483,740.6938;Float;False;True;2;Float;ASEMaterialInspector;0;3;IL3DN/Fog;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;True;2;False;-1;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;1;0;FLOAT4;0,0,0,0;False;0
WireConnection;78;0;76;0
WireConnection;78;1;31;0
WireConnection;107;0;78;0
WireConnection;94;0;107;0
WireConnection;102;0;2;4
WireConnection;103;0;10;4
WireConnection;111;0;108;0
WireConnection;65;0;2;0
WireConnection;65;1;10;0
WireConnection;65;2;101;0
WireConnection;72;0;99;0
WireConnection;91;0;102;0
WireConnection;91;1;103;0
WireConnection;91;2;100;0
WireConnection;88;0;111;0
WireConnection;90;0;72;0
WireConnection;92;0;91;0
WireConnection;89;0;65;0
WireConnection;81;0;79;0
WireConnection;81;1;88;0
WireConnection;73;0;89;0
WireConnection;73;1;90;0
WireConnection;73;2;92;0
WireConnection;87;0;81;0
WireConnection;112;0;87;0
WireConnection;112;1;73;0
WireConnection;130;0;112;0
WireConnection;123;0;139;0
WireConnection;123;1;124;0
WireConnection;128;0;129;0
WireConnection;128;1;131;0
WireConnection;128;2;123;0
WireConnection;114;1;130;0
WireConnection;114;0;128;0
WireConnection;51;0;114;0
ASEEND*/
//CHKSM=79FA3AB093E606BD2DE0FED1A7DA805628F44B10