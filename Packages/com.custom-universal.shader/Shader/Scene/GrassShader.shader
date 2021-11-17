// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

Shader "Custom/Scene/GrassShader"
{
    Properties
    {
        [Toggle]_UseMainColor("_UseMainColor",int) = 0
        [Toggle]_WindAnim("动画开关",int) = 1
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1.0,1.0,1.0,1.0)
        _Color01("TopColor1",Color) = (1.0,1.0,1.0,1.0)
        _Color02("TopColor2",Color) = (1.0,1.0,1.0,1.0)
        _Color03("TopColor3",Color) = (1.0,1.0,1.0,1.0)
        _Color04("TopColor4",Color) = (1.0,1.0,1.0,1.0)
        _GradientVector("_GradientVector",vector) = (0.0,1.0,0.0,0.0)
        _CutOff("Cutoff",Range(0.0,1.0)) = 0.5
        _WindAnimToggle("_WindAnimToggle",int) = 1
        _SpecularRadius("_SpecularRadius",Range(1.0,100.0)) = 50.0
        _SpecularIntensity("_SpecularIntensity",Range(0.0,1.0)) = 0.5
        _HeightDepth("_HeightDepth",Range(0.0,1.0)) = 0.5
        
    }
    SubShader
    {
        Tags
        { 
            "RenderPipeline"="UniversalRenderPipline"
            "LightMode" = "UniversalForward"
            "RenderType"="Opaque" 
            "Queue" = "Geometry"
        }
        LOD 100

        HLSLINCLUDE
        #include "../ShaderFunction.hlsl" 
        ///////////////////////////////////////////////////////////
        //                ShaderFunction中的宏开关                //
        ///////////////////////////////////////////////////////////  
        #pragma shader_feature _WINDANIM_ON _WINDANIM_OFF
        #pragma shader_feature _CLOUDSHADOW_ON _CLOUDSHADOW_OFF
        #pragma shader_feature _INTERACT_ON _INTERACT_OFF
        #pragma shader_feature _WORLDFOG_ON _WORLDFOG_OFF

        uniform TEXTURE2D (_MainTex);
        uniform	SAMPLER(sampler_MainTex);

        uniform TEXTURE2D (_BaseTex);
        uniform	SAMPLER(sampler_BaseTex);

        uniform TEXTURE2D (_ColorTex0);
        uniform	SAMPLER(sampler_ColorTex0);

        uniform TEXTURE2D (_ColorTex1);
        uniform	SAMPLER(sampler_ColorTex1);

        uniform TEXTURE2D (_ColorTex2);
        uniform	SAMPLER(sampler_ColorTex2);

        uniform TEXTURE2D (_ColorTex3);
        uniform	SAMPLER(sampler_ColorTex3);
        //变量声明
        CBUFFER_START(UnityPerMaterial)
        //贴图采样器
        uniform float4 _MainTex_ST;
        uniform float _CutOff;
        uniform float4 _Color;
        uniform float4 _GradientVector;
        uniform float _HeightDepth;
        uniform float _SpecularRadius;
        uniform float _SpecularIntensity;

        uniform float _Color0_ST;
        uniform float _Color1_ST;
        uniform float _Color2_ST;
        uniform float _Color3_ST;

        uniform int _UseMainColor;
        CBUFFER_END
        //结构体
        #pragma vertex vert
        #pragma fragment frag
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
            float4 color:COLOR;
            float3 normal:NORMAL;

        };
        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 vertexColor:COLOR;
            float3 worldNormal :TEXCOORD2;
            float3 worldView :TEXCOORD5;
            float3 worldPos:TEXCOORD6;
            
        };
        
        ENDHLSL
        Pass
        {
            

            Cull off
            HLSLPROGRAM
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);//这个一定要放在下面两个顶点相关的方法之上 这样他们才能调用到
                WIND_ANIM(v,o);
                GRASS_INTERACT(v,o);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldView = _WorldSpaceCameraPos.xyz - o.worldPos;
                o.vertexColor = v.color;
                return o;
            }

            //地表融合函数
            float4 TerrainBlend(real4 _Splat0,real4 _Splat1,real4 _Splat2,real4 _Splat3,real4 var_Control)
            {
                half4 blend;
                //获取混合后的高度通道
                blend.r = _Splat0.a * var_Control.r;
                blend.g = _Splat1.a * var_Control.g;
                blend.b = _Splat2.a * var_Control.b;
                blend.a = _Splat3.a * var_Control.a;
                
                half max_Height = max(blend.a,max(blend.b,max(blend.r,blend.g)));
                blend = max( blend - max_Height + _HeightDepth,0.0) * var_Control;
                
                return blend / (blend.r + blend.g + blend.b + blend.a);
            }

            real3 frag (v2f i) : SV_Target
            {
                //临时的颜色计算//////////////////////////////////////////////////////////////////////////////////
                
                float4 var_Splat0 = SAMPLE_TEXTURE2D(_ColorTex0,sampler_ColorTex0,i.worldPos.xz / _Color0_ST );
                //采样第二层贴图
                float4 var_Splat1 = SAMPLE_TEXTURE2D(_ColorTex1,sampler_ColorTex1,i.worldPos.xz / _Color1_ST );
                //采样第三层贴图
                float4 var_Splat2 = SAMPLE_TEXTURE2D(_ColorTex2,sampler_ColorTex2,i.worldPos.xz/ _Color2_ST );
                //采样第四层贴图
                float4 var_Splat3 = SAMPLE_TEXTURE2D(_ColorTex3,sampler_ColorTex3,i.worldPos.xz / _Color3_ST );
                // //采样分层贴图
                float4 var_Control = SAMPLE_TEXTURE2D(_BaseTex,sampler_BaseTex,i.worldPos.xz / 256);

                float4 blend = TerrainBlend(var_Splat0,var_Splat1,var_Splat2,var_Splat3,var_Control);
                //合成
                float4 finalAlbedo = var_Splat0*blend.r + var_Splat1*blend.g+ var_Splat2*blend.b+ var_Splat3*blend.a;





                /////////////////////////////////////////////////////////////////////////////////////////////////
                //采样贴图
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                //AlphaTest
                clip(var_MainTex.a - _CutOff);
                //准备向量
                float4 SHADOW_COORDS = TransformWorldToShadowCoord(i.worldPos);
                Light light = GetMainLight(SHADOW_COORDS);
                float3 lightDir = normalize(light.direction).xyz;
                float3 viewDir  = normalize(i.worldView);
                float3 normalDir = normalize(i.worldNormal);
                float3 halfDir   = normalize(lightDir + viewDir);
                //点乘计算
                float NdotL = max(0.0,dot(float3(0.0,1.0,0.0),lightDir));
                float NdotH = max(0.0,dot(float3(0.0,1.0,0.0),halfDir));//这里假设所有法线朝上
                
                
                //基础颜色Albedo
                float3 Albedo  = finalAlbedo.rgb;
                if (_UseMainColor > 0)
                {
                    Albedo  = lerp(finalAlbedo.rgb,var_MainTex.rgb * _Color,i.vertexColor.a);
                }

                //Occlusion
                // float Occlustion = lerp(1,i.vertexColor.a,_OcclusionIntensity);//把顶点色A通道当作别的草和自己的环境闭塞
                // float Occlustion = lerp(1,i.vertexColor.a,_OcclusionIntensity);//把顶点色A通道当作别的草和自己的环境闭塞
                //主光源影响
                float specular = pow(NdotH,_SpecularRadius) * _SpecularIntensity * i.vertexColor.a;
                float shadow = light.shadowAttenuation * CLOUD_SHADOW(i);//把顶点色A通道当作自投影
                float3 lightContribution = (specular * light.color +  Albedo * light.color * NdotL) * shadow;
                //环境光源影响
                float3 Ambient = SampleSH(normalDir);
                float3 indirectionContribution = Ambient * Albedo;
                
                //光照合成
                float3 finalRGB = lightContribution + indirectionContribution;
                BIGWORLD_FOG(i,finalRGB);//大世界雾效
                //输出

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

   CustomEditor "GrassShaderGUI"
}
