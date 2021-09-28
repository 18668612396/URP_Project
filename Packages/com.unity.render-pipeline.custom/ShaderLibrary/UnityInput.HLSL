#ifndef CUSTOM_UNITY_INPUT_INCLUDE
    #define CUSTOM_UNITY_INPUT_INCLUDE

    CBUFFER_START(UnityPerDraw)
    //定义一个模型空间转世界空间的转换矩阵
    float4x4 unity_ObjectToWorld;
    float4x4 unity_WorldToObject;
    float4 unity_LODFade;
    float4 unity_WorldTransformParams;

    CBUFFER_END
    
    
    float4x4 unity_MatrixVP;//定义一个世界空间转投影空间的转换矩阵

    float4x4 unity_MatrixV;

    float4x4 glastate_matrix_projection;







#endif