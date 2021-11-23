// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

Shader "Custom/Character/CartoonShader"
{
    Properties
    {
        //基础
        [KeywordEnum(Base,Face,Hair)] _ShaderEnum("ShaderEnum",int) = 0//
        [Toggle]_DebugGradient("Debug",int) = 0
        [Toggle]_NightTime("DayOrNight",int) = 0
        _MainTex ("MainTex", 2D) = "white" {}//
        _Color("Color",Color) = (1.0,1.0,1.0,1.0)//
        _EmissionIntensity("_EmissionIntensity",Range(0.0,25.0)) = 0.0//
        _ParamTex("_ParamTex",2D) = "white"{}//
        _RampTex("RampTex",2D) = "white"{}//
        // _MetalMap("_Matcap",2D) = "white"{}//
        _MetalIntensity("_MetalIntensity",Range(0.5,1.0)) = 1.0
        _MetalColor("_MetalColor",Color)= (1,1,1,1)//
        _HairSpecularIntensity("_HairSpecularIntensity",Range(0.0,1.0)) = 0.5
        _RimIntensity("_RimIntensity",float) = 0
        _RimRadius("_RimRadius",Range(0.0,1.0)) = 0.1


        _OutlineColor("Color",Color) = (0.0,0.0,0.0,0.0)
        _OutlineOffset("Offset",Range(0.0,0.1)) = 0.0 

    }
    SubShader
    {



        HLSLINCLUDE
        #include "../NPR_Function.hlsl" 
        ///////////////////////////////////////////////////////////
        //                ShaderFunction中的宏开关                //
        ///////////////////////////////////////////////////////////
        #pragma shader_feature _CLOUDSHADOW_ON _CLOUDSHADOW_OFF
        #pragma shader_feature _WORLDFOG_ON _WORLDFOG_OFF
        #pragma shader_feature _SHADERENUM_BASE _SHADERENUM_FACE _SHADERENUM_HAIR
        #pragma shader_feature _DEBUGGRADIENT_ON
        uniform TEXTURE2D (_MainTex);
        uniform	SAMPLER(sampler_MainTex);

        uniform TEXTURE2D(_ParamTex);
        uniform SAMPLER(sampler_ParamTex);
        



        //变量声明
        CBUFFER_START(UnityPerMaterial) 
        
        float _OutlineOffset;
        float4 _OutlineColor;

        float4 _Color;

        CBUFFER_END
        //结构体
        #pragma vertex vert
        #pragma fragment frag
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile_fragment _ _SHADOWS_SOFT

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
            float4 color:COLOR;
            float3 normal:NORMAL;
            float4 tangent:TANGENT;

        };
        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 vertexColor:COLOR;
            float3 worldNormal :TEXCOORD2;
            float3 viewNormal :TEXCOORD3;
            float3 worldView :TEXCOORD5;
            float3 worldPos:TEXCOORD6;
            float3 worldTangent:TEXCOORD7;
            float3 worldBinormal:TEXCOORD8;
            
        };
        
        ENDHLSL

        Pass
        {


            Tags
            { 

                "LightMode" = "UniversalForward"
                "RenderType"="Opaque" 
            }
            Cull off
            HLSLPROGRAM
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                o.uv = v.uv;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);//这个一定要放在下面两个顶点相关的方法之上 这样他们才能调用到
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.viewNormal = TransformWorldToView(o.worldNormal);
                o.worldView = _WorldSpaceCameraPos.xyz - o.worldPos;
                float3 worldTangent = TransformObjectToWorldDir(v.tangent.xyz);
                o.worldBinormal = cross(worldTangent, o.worldNormal);
                o.vertexColor = v.color;
                return o;
            }


            real3 frag (v2f i) : SV_Target
            {
                //采样贴图                
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv) * _Color;
                float4 var_ParamTex = SAMPLE_TEXTURE2D(_ParamTex,sampler_ParamTex,i.uv);
                //灯光信息
                float4 SHADOW_COORDS = TransformWorldToShadowCoord(i.worldPos);
                Light light = GetMainLight(SHADOW_COORDS);

                //参数输入
                float4 baseColor = var_MainTex;
                float3 emission  = var_MainTex.a * var_MainTex * _EmissionIntensity;
                float4 parameter   = var_ParamTex;
                float  shadow = light.shadowAttenuation;
                parameter.b *= smoothstep(0.1,0.5,shadow) * 2; //硬化实时阴影 主要是为了去除软阴影的误差  这里乘以2是因为原始阴影贴图是0 - 0.5的值 这里把他映射到 0 -1

                //向量准备
                float3 normalDir  = normalize(i.worldNormal);
                float3 viewDir    = normalize(i.worldView);
                light.direction = normalize(light.direction);
                float Night = dot(light.direction,float3(0.0,1.0,0.0));
                if (Night < 0.0)
                {
                    light.direction = -light.direction;
                }
                float3 halfDir    = normalize(light.direction + viewDir);
                float3 reflectDir = normalize(reflect(viewDir,normalDir));
                //点乘结果
                float NdotH = max(0.00001,dot(normalDir,halfDir));
                float NdotL = max(0.00001,dot(normalDir,light.direction));
                float NdotV = max(0.00001,dot(normalDir,viewDir));
                float HdotL = max(0.00001,dot(halfDir,light.direction));
                

                float3 finalRGB = float3(0.0,0.0,0.0);
                
                // return parameter.b;
                #if _SHADERENUM_BASE
                    finalRGB = NPR_Function_Base(NdotL,NdotH,NdotV,normalDir,baseColor,parameter,light,Night) ;
                #elif _SHADERENUM_FACE
                    finalRGB = NPR_Function_face(NdotL,var_MainTex,parameter,light,Night);
                #elif _SHADERENUM_HAIR
                    finalRGB = NPR_Function_Hair(NdotL,NdotH,NdotV,normalDir,viewDir,baseColor,parameter,light,Night);
                #endif
                // clip(var_MainTex.a - 0.5);
                return finalRGB.xyz;

            }
            ENDHLSL
        }
        Pass
        {
            Tags{ "LightMode" = "SRPDefaultUnlit" }
            Cull off
            ZWrite on
            Cull front
            HLSLPROGRAM
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                
                v.vertex.xyz += v.normal * _OutlineOffset * v.color.a;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.worldNormal = v.normal;
                return o;
            }


            real3 frag (v2f i) : SV_Target
            {
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                float3 finalRGB = var_MainTex * _OutlineColor.rgb;
                
                return finalRGB;

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
            #include "../ShadowCastPass.HLSL"
            ENDHLSL
        }
        
    }

    CustomEditor "NPR_ShaderGUI"  
}
