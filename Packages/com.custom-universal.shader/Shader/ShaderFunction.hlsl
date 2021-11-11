#ifndef SHADER_FUNCTION_INCLUDE
    #define SHADER_FUNCTION_INCLUDE

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

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
    
    uniform float  _WindDensity;
    uniform float3 _WindDirection;
    uniform float  _WindSpeedFloat;
    uniform float  _WindTurbulenceFloat;
    uniform float  _WindStrengthFloat;
    void WindAnimation(inout float4 vertex, float4 vertexColor,float3 worldPos)
    {   

        #if _WINDANIM_ON
            vertex.xyz = vertex.xyz;
            float3 windDirection = float3(_WindDirection.xy,0.0);
            float2 panner = _Time.y * (windDirection * _WindSpeedFloat * 10).xy  + worldPos.xy; //这里的  Time.y 会造成浮点数误差的问题  后续想办法解决
            float SimplePerlinNoise = PerlinNoise(panner * _WindTurbulenceFloat / 10 * _WindDensity) * 0.5 + 0.5;
            
            vertex.xyz += mul(unity_WorldToObject,float4(_WindDirection * SimplePerlinNoise * _WindStrengthFloat,0.0)).xyz * vertexColor.a ;

            vertex.w = 1.0;
        #elif _WINDANIM_OFF
            vertex = vertex;
        #endif
        
    }
    #define WIND_ANIM(v,o)  WindAnimation(v.vertex,v.color,o.worldPos);

    //云阴影
    
    uniform float _CloudShadowSize;
    uniform vector _CloudShadowRadius;
    uniform float _CloudShadowSpeed;
    uniform float _CloudShadowIntensity;
    float CloudShadow(float3 worldPos)
    {
        float Shadow = 1.0;
        #if _CLOUDSHADOW_ON
            Shadow = PerlinNoise(worldPos.xz * _CloudShadowSize * _CloudShadowRadius.xy + _Time.y * _WindDirection.xz * _CloudShadowSpeed);
            Shadow = lerp(1.0,1.0 - saturate(Shadow),_CloudShadowIntensity);
        #elif _CLOUDSHADOW_OFF
            Shadow = 1.0;
        #endif
        return Shadow;
    }
    #define CLOUD_SHADOW(i)  CloudShadow(i.worldPos);

    ///植被交互
    
    uniform float _InteractRadius;
    uniform float _InteractIntensity;
    uniform float _InteractHeight;
    uniform float3 _PlayerPos;
    void GrassInteract(float2 uv,float4 vertexColor,inout float4 vertex,float3 worldPos)
    {
        #if _INTERACT_ON
            float interactDistance = distance(_PlayerPos.xyz + float3(0,_InteractHeight,0),worldPos);
            float interactDown = saturate((1 - interactDistance + _InteractRadius) * uv.y * _InteractIntensity);
            float3 interactDirection = normalize(worldPos.xyz - _PlayerPos.xyz);
            float3 incrementPos = interactDirection * interactDown * vertexColor.a;//计算增量的Position
            incrementPos.y*= 0.2;
            vertex.xyz += mul(unity_WorldToObject,float4(incrementPos,0.0)).xyz;
        #elif _INTERACT_OFF
            vertex = vertex;
        #endif
    }
    #define GRASS_INTERACT(v,o) GrassInteract(v.uv,v.color,v.vertex,o.worldPos);



    //大世界雾效
    //后续编辑脚本GUI时 控制宏开开关
    
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
            float inscatterFactor = pow(saturate(dot(-normalize(viewDir), _MainLightPosition.xyz - worldPos)), _FogInscatteringExp);
            inscatterFactor *= 1-saturate(exp2(falloff));
            inscatterFactor *= distanceFactor;
            float3 finalFogColor = lerp(_FogColor.rgb, _MainLightColor.rgb, saturate(inscatterFactor));
            finalRGB =lerp(finalRGB, finalFogColor, saturate(fog) * _FogColor.a);
        #endif
        finalRGB = finalRGB;
    }
    #define BIGWORLD_FOG(i,finalRGB) ExponentialHeightFog(i.worldPos,finalRGB);


    float3 _LightDirection;
    float3 _LightPosition;
    float4 GetShadowPositionHClip(float3 positionOS , float3 normal)
    {
        float3 positionWS = TransformObjectToWorld(positionOS.xyz);
        float3 normalWS = TransformObjectToWorldNormal(normal);

        #if _CASTING_PUNCTUAL_LIGHT_SHADOW
            float3 lightDirectionWS = normalize(_LightPosition - positionWS);
        #else
            float3 lightDirectionWS = _LightDirection;
        #endif

        float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

        #if UNITY_REVERSED_Z
            positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
        #else
            positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
        #endif

        return positionCS;
    }
#endif
