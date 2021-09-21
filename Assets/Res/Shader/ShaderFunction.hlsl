#ifndef SHADER_FUNCTION_INCLUDE
    #define SHADER_FUNCTION_INCLUDE

    
    #include "AutoLight.cginc"
    #include "Lighting.cginc"
    #include "UnityCG.cginc"
    //地表高度混合函数
    float _TerrainHeightDepth;
    inline half4 TerrainBlend(fixed4 _Splat0,fixed4 _Splat1,fixed4 _Splat2,fixed4 _Splat3,fixed4 var_Control)
    {
        half4 blend;
        //获取混合后的高度通道
        blend.r = _Splat0.a * var_Control.r;
        blend.g = _Splat1.a * var_Control.g;
        blend.b = _Splat2.a * var_Control.b;
        blend.a = _Splat3.a * var_Control.a;
        
        half max_Height = max(blend.a,max(blend.b,max(blend.r,blend.g)));
        blend = max( blend - max_Height + _TerrainHeightDepth,0.0) * var_Control;
        
        return blend / (blend.r + blend.g + blend.b + blend.a);
    }

    //Noise
    float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
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
    }
    //重映射
    float remap(float In ,float InMin ,float InMax ,float OutMin, float OutMax)
    {
        return OutMin + (In - InMin) * (OutMax - OutMin) / (InMax - InMin);
    }

    //风力动画
    #pragma multi_compile _WINDANIM_ON _WINDANIM_OFF
    uniform int   _WindAnimToggle;
    uniform float  _WindDensity;
    uniform float3 _WindDirection;
    uniform float  _WindSpeedFloat;
    uniform float  _WindTurbulenceFloat;
    uniform float  _WindStrengthFloat;
    void WindAnimation(inout float4 vertex, float4 vertexColor)
    {   
        #if _WINDANIM_ON
            vertex.xyz = vertex.xyz;
            float3 worldPos = mul(unity_ObjectToWorld,vertex);
            float3 windDirection = float3(_WindDirection.xy,0.0);
            float2 panner = (1.0 * _Time.y * (windDirection * _WindSpeedFloat * 10).xy + worldPos.xy);
            float SimplePerlinNoise = PerlinNoise(panner * _WindTurbulenceFloat / 10 * _WindDensity) * 0.5 + 0.5;
            if(_WindAnimToggle > 0)
            {
                vertex.xyz += mul(unity_WorldToObject,float4(_WindDirection * (SimplePerlinNoise * _WindStrengthFloat),0.0)) * vertexColor.a;
            }
            vertex.w = 1.0;
        #elif _WINDANIM_OFF
            vertex = vertex;
        #endif
        
        
    }
    #define WIND_ANIM(v)  WindAnimation(v.vertex,v.color);

    //云阴影
    #pragma multi_compile _CLOUDSHADOW_ON _CLOUDSHADOW_OFF
    uniform float _CloudShadowSize;
    uniform vector _CloudShadowRadius;
    uniform float _CloudShadowSpeed;
    uniform float _CloudShadowIntensity;
    float CloudShadow(float3 worldPos)
    {
        float Shadow = 1.0;
        #if _CLOUDSHADOW_ON
            Shadow = PerlinNoise(worldPos.xz * _CloudShadowSize * _CloudShadowRadius.xy + _Time.y * _WindDirection * _CloudShadowSpeed);
            Shadow = lerp(1.0,1.0 - saturate(Shadow),_CloudShadowIntensity);
        #elif _CLOUDSHADOW_OFF
            Shadow = 1.0;
        #endif
        return Shadow;
    }
    #define CLOUD_SHADOW(i)  CloudShadow(i.worldPos);

    ///植被交互
    #pragma multi_compile _INTERACT_ON _INTERACT_OFF
    uniform float _InteractRadius;
    uniform float _InteractIntensity;
    uniform float _InteractHeight;
    uniform float3 _PlayerPos;
    void GrassInteract(float2 uv,float4 vertexColor,inout float4 vertex)
    {
        #if _INTERACT_ON
            float3 worldPos = mul(unity_ObjectToWorld,vertex).xyz;
            float interactDistance = distance(_PlayerPos.xyz + float3(0,_InteractHeight,0),worldPos);
            float interactDown = saturate((1 - interactDistance + _InteractRadius) * uv.y * _InteractIntensity);
            float3 interactDirection = normalize(worldPos.xyz - _PlayerPos.xyz);
            worldPos.xyz = interactDirection * interactDown * vertexColor.a;
            worldPos.y*= 0.2;
            vertex.xyz += mul(unity_WorldToObject,worldPos);
        #elif _INTERACT_OFF
            vertex = vertex;
        #endif
    }
    #define GRASS_INTERACT(v) GrassInteract(v.uv,v.color,v.vertex);



    //大世界雾效
    //后续编辑脚本GUI时 控制宏开开关
    #pragma multi_compile _WORLDFOG_ON _WORLDFOG_OFF
    uniform float4 _FogColor;
    uniform float _FogGlobalDensity;
    // uniform float _FogFallOff;
    uniform float _FogHeight;
    uniform float _FogStartDis;
    uniform float _FogInscatteringExp;
    uniform float _FogGradientDis;

    void ExponentialHeightFog(float3 worldPos,inout float3 finalRGB)
    {
        #if _WORLDFOG_ON
            // float heightFallOff = _FogFallOff * 0.01;
            float falloff = 0.01 * ( worldPos.y -  _WorldSpaceCameraPos.y- _FogHeight); //这里节省了 _FogFallOff
            float fogDensity = _FogGlobalDensity * exp2(-falloff);
            float fogFactor = (1 - exp2(-falloff))/falloff;
            float3 viewDir = _WorldSpaceCameraPos - worldPos;
            float rayLength = length(viewDir);
            float distanceFactor = max((rayLength - _FogStartDis)/ _FogGradientDis, 0);
            float fog = fogFactor * fogDensity * distanceFactor;
            float inscatterFactor = pow(saturate(dot(-normalize(viewDir), WorldSpaceLightDir(float4(worldPos,1)))), _FogInscatteringExp);
            inscatterFactor *= 1-saturate(exp2(falloff));
            inscatterFactor *= distanceFactor;
            float3 finalFogColor = lerp(_FogColor, _LightColor0, saturate(inscatterFactor));
            finalRGB =lerp(finalRGB, finalFogColor, saturate(fog) * _FogColor.a);
        #endif
        finalRGB = finalRGB;
    }
    #define BIGWORLD_FOG(i,finalRGB) ExponentialHeightFog(i.worldPos,finalRGB);

    //深度计算
    UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );//声明深度纹理

    float DepthCompare(float4 scrPos, float radius)
    {
        float4 screenPos = scrPos / scrPos.w;
        screenPos = saturate(screenPos);
        float screenDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, screenPos.xy ));
        float distanceDepth = 1 - saturate(abs((screenDepth - LinearEyeDepth(screenPos.z )) * radius));
        return distanceDepth;
    }
    #define DEPTH_COMPARE(i,radius)  DepthCompare(i.scrPos,radius);
#endif
