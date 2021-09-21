Shader "Unlit/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlendTex("BlendTex", 2D) = "black" {}
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    #include "../Post_Function.hlsl"
    // sampler2D _MainTex;
    // sampler2D _BlendTex; 
    // float _Threshold;
    // float4 _MainTex_TexelSize;
    // float _BloomRadius;
    
    ENDCG
    //--------------------------------------------------------------------------------------

    
    SubShader
    {
        
        
        
        Pass//高动态颜色滤波PASS
        {
            CGPROGRAM
            
            #pragma vertex vert_img
            #pragma fragment Color_Filtration
            ENDCG
        }

        pass //用于bloom的降采样
        {
            CGPROGRAM
            
            #pragma vertex vert_img
            #pragma fragment DownBlur
            
            ENDCG
            
        }
        pass//用于bloom的升采样
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment UpBlur
            ENDCG
        }
        pass//合并
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment Bloom_Combine
            ENDCG
        }
    }
}
