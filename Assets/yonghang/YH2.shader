Shader "YH"
{
    Properties
    {
		
	    _MainTex ("固有色贴图", 2D) = "white" {}	
		_SkinOrClothes("mask0", 2D) = "white" {}
        _Mask("mask1)", 2D) = "black" {}
        _NormalMap("法线贴图",2D) = "bump"{}
[Space(10)]
        _DiffuseIntensity("固有色部分强度", float) = 1
		_SkinDiffuseIntensity("皮肤固有色部分强度", float) = 1
		
        _Color ("衣服颜色调节", Color) = (1, 1, 1, 1)		
        				
[Space(10)]
		_DarkSoft("阴影交界线软硬", Range(0,0.2)) = 0
		_FirstDarkWidth("一层阴影宽度(阴影系数B：29-100)", Range(0, 1)) = 0		
		_SecondDarkWidth("二层阴影宽度(阴影系数B：29-100)", Range(0, 1)) = 0		
	
		_FirstDarkColor("一层阴影颜色", color) = (1,1,1,1)		
		_SecondDarkColor("二层阴影颜色", color) = (1,1,1,1)		
        _LiangColor	("亮部颜色", color) = (1,1,1,1)		

		_SkinFirstDarkColor("皮肤一层阴影颜色", color) = (1,1,1,1)		
		_SkinSecondDarkColor("皮肤二层阴影颜色", color) = (1,1,1,1)   
		_SkinLiangColor ("皮肤亮部颜色", color) = (1,1,1,1)		

[Space(10)]
		_Gloss("金属高光power", float) = 10
		[HDR]_SpecFirstColor("金属高光颜色", Color) = (0,0,0,1)
[Space(10)]
		_ClearCoatGloss("清漆pow", float) = 0
     	_ClearCoatColor("皮革清漆颜色", color) = (1,1,1,1)
[Space(10)]
         [HDR]_baoshiCol("宝石颜色", color)= (1,1,1,1)
[Space(10)]
         [HDR]_KajiyaCol("头发高光颜色", color) = (1,1,1,1)
[Space(10)]
		_FackShadow("FackShadow", 2D) = "white" {}
[Space(10)]
		_AoCol("AO颜色", color) = (1,1,1,1)
[Space(10)]

		[HDR]_RimColor("边缘高光颜色", Color) = (0,0,0,1)
		_RimAmount("边缘高光范围", Range(0, 1)) = 1
        [HDR]_SkinRimColor("皮肤边缘高光颜色", Color) = (0,0,0,1)
		_SkinRimAmount("皮肤边缘高光范围", Range(0, 1)) = 1

[Space(10)]
		_OulineScale("描边宽度", float) = 0
		_OutlineColor("描边颜色", color)= (1,1,1,1)
[Space(10)]
        _EmissionIntensity("自发光强度",Range(0,4)) = 0				
        [HDR]_Emission("自发光颜色", Color) = (0,0,0,1)
	

    }

    SubShader
    {
		Tags { "Queue"="AlphaTest+51" "IgnoreProjector"="True" "RenderType"="AlphaTest" "RenderPipeline"="UniversalPipeline"}

			HLSLINCLUDE

			
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			TEXTURE2D(_NormalMap);
			SAMPLER(sampler_NormalMap);
			TEXTURE2D(_RampTex);

			TEXTURE2D(_Mask);
			SAMPLER(sampler_Mask);

			TEXTURE2D(_MaskJin);
			SAMPLER(sampler_MaskJin);
			TEXTURE2D(_SkinOrClothes);
			SAMPLER(sampler_SkinOrClothes);
			
			TEXTURE2D(_FackShadow);
			SAMPLER(sampler_FackShadow);

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;

            float4 _MainTex_ST;
			float _DiffuseIntensity;
			float _SkinDiffuseIntensity;
   
   			float4 _Emission;
            float _EmissionIntensity;

			float _DarkSoft;
			float _FirstDarkWidth;
			float4 _FirstDarkColor;
			float _SecondDarkWidth;
			float4 _SecondDarkColor;

		

			float4 _SkinFirstDarkColor;
			float4 _SkinSecondDarkColor;
			float4 _SkinThirdDarkColor;
			float4 _SkinFourDarkColor;
			float4 _SkinRimColor;
			float _SkinRimAmount;

			
			float3 _SpecFirstColor;
			float _Gloss;

			float4 _RimColor;
			float _RimAmount;
			float _RimThreshold;




           
			float4 _OutlineColor;




			float4 _LiangColor;
			float4 _SkinLiangColor;

			float _ClearCoatGloss;
     	    half3  _ClearCoatColor;
			 float3 _KajiyaCol;
			 float3 _AoCol;
			 float _OulineScale;
			 float4 _baoshiCol;


			CBUFFER_END

			ENDHLSL


        Pass
        {

            Tags { "LightMode" = "UniversalForward" }
			Cull Off 
			Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdbase  

           inline float3 UnityWorldSpaceLightDir( in float3 worldPos )
           {
          #ifndef USING_LIGHT_MULTI_COMPILE
          return _MainLightPosition.xyz - worldPos * _MainLightPosition.w;
          #else
          #ifndef USING_DIRECTIONAL_LIGHT    
          return _MainLightPosition.xyz - worldPos;
          #else
          return _MainLightPosition.xyz;   
          #endif
          #endif
        }

			struct a2v
			{
				float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
			};

            struct v2f
            {
                float4 pos		: SV_POSITION;
                float2 uv		: TEXCOORD0;
                float4 TW0		: TEXCOORD1;
                float4 TW1		: TEXCOORD2;
                float4 TW2		: TEXCOORD3;

            };

				float4 _CustomMainLightColor;

            v2f vert (a2v v)
            {
                v2f o = (v2f)0;
				float4 tempVer = v.vertex;
				v.vertex = tempVer;
                o.uv  = v.uv;			
				o.pos = TransformObjectToHClip(v.vertex);		
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);			
				float3 worldNormal = TransformObjectToWorldNormal(v.normal);	
				float3 worldTangent = TransformObjectToWorldDir(v.tangent.xyz); 
				float tangentSign = v.tangent.w * unity_WorldTransformParams.w; 
				float3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;

                o.TW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
	

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
			// 数据准备
				float3 normalTex = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,i.uv));
                float3 worldNormal = normalize(float3(dot(i.TW0, normalTex), dot(i.TW1, normalTex), dot(i.TW2, normalTex)));
				float3 worldPos = float3(i.TW0.w, i.TW1.w, i.TW2.w);
     
                float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));		
                float3 viewDir = normalize(_WorldSpaceCameraPos-worldPos);			
				float3 halfDir = normalize(lightDir + viewDir);						
				float3 worldRef = reflect(-viewDir, worldNormal);					
				
				float NdotV = abs(dot(worldNormal, viewDir));						
				float NdotL = saturate(dot(worldNormal, lightDir));					
				float NdotH = saturate(dot(worldNormal, halfDir));					
				
				float4 albedo = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
				float4 MaskTex = SAMPLE_TEXTURE2D(_Mask,sampler_Mask,i.uv);				
				float4 maskSoC = SAMPLE_TEXTURE2D(_SkinOrClothes,sampler_SkinOrClothes,i.uv);
				float4 AO =SAMPLE_TEXTURE2D(_FackShadow,sampler_FackShadow,i.uv); 
				float specularMask = MaskTex.r;
				float pigeMask = MaskTex.g;	//阴影遮罩图
				float toufa = maskSoC.a;
				float skinOrClothes = maskSoC.g;
				float emission = 1;
			

			//////////////////////////////////////////////////////////////////////
//基础光照模型
				float tempNdotL = NdotL;
				

				float firstShadowRadio =1- smoothstep(_FirstDarkWidth, _FirstDarkWidth+ _DarkSoft, tempNdotL);
				//阴影区域
				float secondShadowRadio = 1-smoothstep(_SecondDarkWidth, _SecondDarkWidth + _DarkSoft, tempNdotL);	
				//高光区域
				float highLight = (1-firstShadowRadio);			
			
				//NoL颜色输出
				float3 NoLColor = secondShadowRadio * lerp(_SecondDarkColor, _SkinSecondDarkColor, skinOrClothes) +                              //暗部颜色
								  (firstShadowRadio- secondShadowRadio) * lerp(_FirstDarkColor, _SkinFirstDarkColor, skinOrClothes)+             //亮部颜色
								  highLight*lerp(_LiangColor,_SkinLiangColor,skinOrClothes);   



				float3 albedoToon = albedo.rgb * pow(2, emission * _EmissionIntensity *  _Emission.rgb);
				//乘到albedo上
				float3 Toon = NoLColor * albedoToon.rgb;
				//Toon分区亮度调节
				Toon = Toon * _DiffuseIntensity * (1-(skinOrClothes+toufa))*_Color + Toon * _SkinDiffuseIntensity * skinOrClothes +Toon*toufa;  				  

//金属高光
				float3 spec = smoothstep(0.1, 0.2, pow(max(0,NdotH), _Gloss )) ;
				float3 specular = _SpecFirstColor.rgb * spec *specularMask;

//各向异性
				float3 kajiya = MaskTex.a * _KajiyaCol *highLight;

//_FackShadow
				_AoCol = abs (_AoCol-1);
				float3 fShadow = AO.a*_AoCol;		
				float3 ao =abs(fShadow-1);		

///皮革清漆
				 
     			 float ClearCoat = pow(NdotV,_ClearCoatGloss);
     			 float3 clearCoatColor = _ClearCoatColor * ClearCoat  *pigeMask;	
//宝石
				float3 baoshi = maskSoC.b*_baoshiCol;				  


//边缘光				  
				float rimDot = 1 - NdotV;
				float rimIntensity =  rimDot * abs(1-NdotL);  //背边缘光
				//float rimIntensity =  rimDot * NdotL;  //单边缘光

				// rimIntensity =  rimDot;  //双边边缘光
				_RimAmount = lerp(_RimAmount, _SkinRimAmount, skinOrClothes);
				rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
				float4 rim = rimIntensity * lerp(_RimColor, _SkinRimColor, skinOrClothes);
							
		
				return float4((Toon+specular+clearCoatColor+kajiya+rim+baoshi)*ao,1);



            }
            ENDHLSL
        }
		
	
		Pass
		{
		    Tags {"LightMode"="LightweightForward"}
			Cull Front
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

		

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				 float2 uv : TEXCOORD0;


			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
           

			v2f vert(a2v v)
			{
				 v2f o;
				 o.uv  = v.uv;
                 v.vertex.xyz += v.normal.xyz *_OulineScale*0.01;
                 o.pos = TransformObjectToHClip(v.vertex);
                
                return o;
			}

			float4 frag(v2f i) : SV_TARGET
			{
				float4 outLineCol = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);    
					   outLineCol *= _OutlineColor;

				return outLineCol;
			}

			ENDHLSL
		}
    }
		//FallBack "Transparent/Cutout/VertexLit"
}

