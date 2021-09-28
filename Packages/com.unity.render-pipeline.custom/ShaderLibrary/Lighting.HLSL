#ifndef CUSTOM_LIGHTING_INCLUDE
    #define CUSTOM_LIGHTING_INCLUDE


    CBUFFER_START(_CustomLight)

    float3 _MainLightColor;
    float3 _MainLightDirection;

    CBUFFER_END

    struct Light
    {
        float3 color;
        float3 direction;
    };

    Light GetMainLight()
    {
        Light light;

        light.color = _MainLightColor;
        light.direction = _MainLightDirection;
        return light;
    }
    



#endif