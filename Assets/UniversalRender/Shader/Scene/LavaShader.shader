// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

Shader "Custom/Scene/LavaShader"
{
    Properties
    {
        _VertexLight("VertexLight",float) = 0
        _LavaSpeed("LavaSpeed",float) = 0
        _LavaWarp("LavaWarp",float) = 0
        _LavaTex ("LavaTex", 2D) = "white" {}
        _LavaIntensity("LavaIntensity",float) = 0
        _RockTex ("RockTex", 2D) = "white" {}
        _RockColor("RockColor",Color) = (1.0,1.0,1.0,1.0)
        _RockRadius("_RockRadius",float) = 1
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
        #include "../ShaderLibrary/ShaderFunction.hlsl"  

        uniform TEXTURE2D (_LavaTex);
        uniform	SAMPLER(sampler_LavaTex);

        uniform TEXTURE2D (_RockTex); 
        uniform SAMPLER(sampler_RockTex);  
        //变量声明
        CBUFFER_START(UnityPerMaterial)
        //贴图采样器
        uniform float4 _LavaTex_ST;
        uniform float4 _RockTex_ST;
        uniform float4 _RockColor;
        uniform float _RockRadius;
        uniform float _LavaSpeed;
        uniform float _LavaIntensity;
        uniform float _LavaWarp;
        uniform float _VertexLight;
        CBUFFER_END
        //结构体
        #pragma vertex vert
        #pragma fragment frag

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
            float2 lavaUV : TEXCOORD0;
            float2 rockUV : TEXCOORD7;
            float4 vertexColor:COLOR;
            float3 worldNormal :TEXCOORD2;
            float3 worldTangent:TEXCOORD3;
            float3 worldBitangent:TEXCOORD4;
            float3 worldView :TEXCOORD5;
            float3 worldPos:TEXCOORD6;
            
        };
        
        ENDHLSL


        Pass
        {
            HLSLPROGRAM
            v2f vert (appdata v)
            {
                v2f o;
                ZERO_INITIALIZE(v2f,o);//初始化顶点着色器
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);//这个一定要放在下面两个顶点相关的方法之上 这样他们才能调用到
                o.lavaUV = TRANSFORM_TEX(v.uv + float2(frac(_Time.x)*_LavaSpeed,0), _LavaTex);
                o.rockUV = TRANSFORM_TEX(v.uv,_RockTex);
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldTangent = TransformObjectToWorldDir(v.tangent);
                o.worldBitangent = cross(o.worldNormal,o.worldTangent.xyz) * v.tangent.w * unity_WorldTransformParams.w;
                o.vertexColor = v.color;
                return o;
            }
            //Noise
            /* float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
            float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
            float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
            float PerlinNoise( float2 v )
            {
                const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
                float2 i = floor( v + dot( v, C.yy ) );
                float2 x0 = v - i + dot( i, C.xx );
                float2 i1;
                i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
                float4 x12 = x0.xyxy + C.xxzz;
                x12.xy -= i1;
                i = mod2D289( i );
                float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
                float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
                m = m * m;
                m = m * m;
                float3 x = 2.0 * frac( p * C.www ) - 1.0;
                float3 h = abs( x ) - 0.5;
                float3 ox = floor( x + 0.5 );
                float3 a0 = x - ox;
                m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
                float3 g;
                g.x = a0.x * x0.x + h.x * x0.y;
                g.yz = a0.yz * x12.xz + h.yz * x12.yw;
                return 130.0 * dot( m, g ); 
            }*/
            
            
            real3 frag (v2f i) : SV_Target
            {
                /////////////////////////////////////////////////////////////////////////////////////////////////
                //采样贴图
                float4 var_LavaTex = SAMPLE_TEXTURE2D(_LavaTex,sampler_LavaTex,i.lavaUV  + (PerlinNoise(i.rockUV * 5) * 0.5 + 0.5) *_LavaWarp.xx );
                float4 var_RockTex = SAMPLE_TEXTURE2D(_RockTex,sampler_RockTex,i.rockUV + var_LavaTex.a * 0.1);
                float3 localNormal = float3(var_RockTex.xy,sqrt(1 - var_RockTex.x * var_RockTex.x - var_RockTex.y * var_RockTex.y)) * 2 - 1;
                //准备向量
                float3 lightDir = GetMainLight().direction;
                float3x3 TBN = float3x3(normalize(i.worldTangent),normalize(i.worldBitangent),normalize(i.worldNormal));
                
                float3 normalDir = mul(localNormal.xyz,TBN);

                //光照计算
                float NdotL = max(0.0,dot(normalDir,lightDir)) * 0.5 + 0.5;

                //光照合成
                float blend = saturate(i.vertexColor.r * _RockRadius - var_RockTex.a);
                float3 lavaColor = ((var_LavaTex + var_LavaTex.rgb * _LavaIntensity)  + (_VertexLight *i.vertexColor.g * var_LavaTex))  * (1 - blend);
                float3 rockColor = _RockColor.rgb * NdotL * blend * var_RockTex.b;
                float3 finalRGB = lavaColor + rockColor;
                //输出
                return finalRGB;

            }
            ENDHLSL
        }
    }
}
