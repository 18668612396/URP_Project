Shader "Unlit/ACES_Tonemapping"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    CGINCLUDE
    #include "UnityCG.cginc"
    #include "../Post_Function.hlsl"
    ENDCG
    SubShader
    {
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment ACES
            ENDCG
        }
    }
}
