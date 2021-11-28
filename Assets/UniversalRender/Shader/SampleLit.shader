Shader "Custom/Scene/SampleLit"
{
    Properties
    {   
        _MainTex (" MainTex ", 2D) = "white" {}
        _Color("Color",Color) = (1.0,1.0,1.0,1.0)
        _Metallic("Metallic",Range(0.0,1.0)) = 0.0
        _Roughness("Roughness",Range(0.0,1.0)) = 1.0

    }
    SubShader
    {
        Name "CustomPBR"
        Tags{
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
            "LightMode" = "UniversalForward"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
            "ShaderModel"="4.5"
        }
        LOD 300
        
        HLSLINCLUDE

        #pragma vertex vert
        #pragma fragment frag
        #pragma target 4.5

        #include "ShaderLibrary/ShaderFunction.hlsl"

        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
        ///////////////////////////////////////////////////////////
        //                ShaderFunction中的宏开关                //
        ///////////////////////////////////////////////////////////
        #pragma shader_feature _CLOUDSHADOW_ON _CLOUDSHADOW_OFF
        #pragma shader_feature _WORLDFOG_ON _WORLDFOG_OFF
        ///////////////////////////////////////////////////////////
        //                PBR_Scene_FallDust中的宏开关            //
        ///////////////////////////////////////////////////////////
        #pragma shader_feature _FALLDUST_ON
        #pragma shader_feature _FALLDUST_MAINTEX_ON
        #pragma shader_feature _FALLDUST_PBRPARAM_ON
        #pragma shader_feature _FALLDUST_NORMAL_ON
        ///////////////////////////////////////////////////////////
        //               光照相关的宏开关                          //
        ///////////////////////////////////////////////////////////
        //#pragma shader_feature LIGHTMAP_OFF LIGHTMAP_ON 
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT

        
        // #pragma shader_feature _WINDANIMTOGGLE_ON
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
            float2 lightmapUV:TEXCOORD1;
            float3 normal :NORMAL;
            float4 tangent:TANGENT;
            float4 color:COLOR;
            
        };

        struct v2f
        {
            float4 pos : SV_POSITION;
            float4 vertexColor:COLOR;
            float2 uv : TEXCOORD0;
            float2 lightmapUV:TEXCOORD1;
            float3 worldNormal :TEXCOORD2;
            float3 worldTangent :TEXCOORD3;
            float3 worldBitangent :TEXCOORD4;
            float3 worldView :TEXCOORD5;
            float3 worldPos:TEXCOORD6;
            float2 blendUV:TEXCOORD7;
        };
        #include "ShaderLibrary/LitFunction.hlsl"

        //贴图采样器
        uniform TEXTURE2D (_MainTex);
        uniform	SAMPLER(sampler_MainTex);
        CBUFFER_START(UnityPerMaterial)

        
        CBUFFER_END
        half4 _Color;
        half _Metallic;
        half _Roughness;
        half4 _MainTex_ST;
        ENDHLSL
        

        Pass
        {
            

            // Blend One Zero
            
            HLSLPROGRAM
            
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldTangent = TransformObjectToWorldDir(v.tangent.xyz);
                o.worldBitangent = cross(o.worldNormal,o.worldTangent.xyz) * v.tangent.w * unity_WorldTransformParams.w;
                o.worldView = _WorldSpaceCameraPos.xyz - o.worldPos;
                o.vertexColor = v.color;
                return o;
            }

            real3 frag (v2f i) : SV_Target
            {
                
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);//A通道为高度图
                float3 _BaseColor  = var_MainTex * _Color;
                float3 F0 = lerp(0.04,_BaseColor,_Metallic);

                float3 normalDir  = normalize(i.worldNormal);
                float3 viewDir    = normalize(i.worldView);
                float3 reflectDir = normalize(reflect(-viewDir,normalDir));
                float NdotV = max(0.0,dot(normalDir,viewDir));


                float3 mainLightDiffuse = MainLightDiffuse(normalDir,viewDir,i.worldPos,_BaseColor,_Metallic,F0);
                float3 mainlightSpecular = MainLightSpecular(NdotV,normalDir,viewDir,i.worldPos,_Roughness,F0);
                float3 additionaLightDiffuse = AdditionaLightDiffuse(normalDir,viewDir,i.worldPos,_BaseColor,_Metallic,F0);
                float3 additionaLightSpecular = AdditionaLightSpecular(NdotV,normalDir,viewDir,i.worldPos,_Roughness,F0);
                
                float3 IndirectionDiffuse = indirectionDiffuse(NdotV,normalDir,_Metallic,_BaseColor,_Roughness,1.0,F0);
                float3 IndirectionSpecular = indirectionSpecular(reflectDir,_Roughness,NdotV,1.0,F0);
                

                return  mainLightDiffuse + mainlightSpecular + additionaLightDiffuse + additionaLightSpecular + IndirectionDiffuse + IndirectionSpecular;
            }
            ENDHLSL
        }
        pass 
        {
            Name "ShadowCast"
            Tags
            { 
                "LightMode" = "ShadowCaster" 
            }

            HLSLPROGRAM
            //这个是用来区分定向光源和额外光源的宏 因为他们使用了不同的bise
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #include "ShaderLibrary/ShadowCastPass.HLSL"
            ENDHLSL
        }

        Pass//这个PASS暂时不知道做什么  不过加上这个Pass会使得Scene视图的深度信息正确  //后续可以去除
        {

            Tags{"LightMode" = "DepthOnly"}

            HLSLPROGRAM
            
            v2f vert(appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }
            real3 frag(v2f i) : SV_Target
            {
                float3 color;
                color.xyz = float3(0.0, 0.0, 0.0);
                return color;
            }
            ENDHLSL
        }

        
    }

}
