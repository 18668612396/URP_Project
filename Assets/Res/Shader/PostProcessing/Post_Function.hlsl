
sampler2D _MainTex;
sampler2D _BlendTex; 
sampler2D _BloomTex;
float _Threshold;
float4 _MainTex_TexelSize;
float _BloomRadius;

//颜色滤波函数
half4 Color_Filtration (v2f_img i) : SV_Target
{
    //采样C#传入的颜色缓冲
    float3 InColor = tex2D(_MainTex,i.uv).rgb;
    //计算颜色RGB的最大值  使用max对三个通道进行对比 从而得到GRB的最大值
    float MaxColor = max(max(InColor.r,InColor.g),InColor.b);
    //用颜色最大值减去阈值，以得到超出阈值部分的数值(为防止出现负数，对他进行max对比)
    MaxColor = (max(0.0,MaxColor - _Threshold)) / max(MaxColor,0.0001);
    //用传入的颜色缓冲乘以进行过阈值对比的结果(小于阈值的颜色会呈现为黑色)
    InColor *= MaxColor;
    
    return float4(InColor,1);
}

//模糊函数(降采样)
half4 DownBlur (v2f_img i): SV_Target
{
    //采样周边四角的四个像素的UV
    float2 uv1 = i.uv + _BloomRadius * _MainTex_TexelSize.xy * float2(1.0,1.0);
    float2 uv2 = i.uv + _BloomRadius * _MainTex_TexelSize.xy * float2(-1.0,-1.0);
    float2 uv3 = i.uv;
    float2 uv4 = i.uv + _BloomRadius * _MainTex_TexelSize.xy * float2(-1.0,1.0);
    float2 uv5 = i.uv + _BloomRadius * _MainTex_TexelSize.xy * float2(1.0,-1.0);

    float4 finalRGBA  = 0.0;
    //采样周边四角的四个像素
    finalRGBA += tex2D(_MainTex,uv1);
    finalRGBA += tex2D(_MainTex,uv2);
    finalRGBA += tex2D(_MainTex,uv3);
    finalRGBA += tex2D(_MainTex,uv4);
    finalRGBA += tex2D(_MainTex,uv5);
    finalRGBA *= 0.2;
    
    return finalRGBA;
}

//Bloom模糊(升采样)
half4 UpBlur (v2f_img i): SV_Target
{
    //采样周边四角的四个像素的UV
    float2 uv1 = i.uv + _BloomRadius * _MainTex_TexelSize.xy * float2(1.0,1.0);
    float2 uv2 = i.uv + _BloomRadius * _MainTex_TexelSize.xy * float2(-1.0,-1.0);
    float2 uv3 = i.uv;
    float2 uv4 = i.uv + _BloomRadius * _MainTex_TexelSize.xy * float2(-1.0,1.0);
    float2 uv5 = i.uv + _BloomRadius * _MainTex_TexelSize.xy * float2(1.0,-1.0);

    float4 finalRGBA  = 0.0;
    //采样周边四角的四个像素
    finalRGBA += tex2D(_MainTex,uv1);
    finalRGBA += tex2D(_MainTex,uv2);
    finalRGBA += tex2D(_MainTex,uv3);
    finalRGBA += tex2D(_MainTex,uv4);
    finalRGBA += tex2D(_MainTex,uv5);
    finalRGBA *= 0.2;
    float4 BlendTex = tex2D(_BlendTex,i.uv);
    return finalRGBA + BlendTex;
}

//合并

half4 Bloom_Combine (v2f_img i): SV_Target
{
    float4 BaseColor = tex2D(_MainTex,i.uv);
    float4 BloomColor = tex2D(_BloomTex,i.uv);
    float4 finalColor = BaseColor+BloomColor;
    return finalColor;
}

//ACES_Tonemapping

float3 ACES_Tonemapping(float3 x)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;

    float3 finalRGB = saturate((x*(a*x + b)) / (x*(c*x + d) +e));
    return finalRGB;
}

half4 ACES (v2f_img i):SV_Target
{
    float4 ColorTex = tex2D(_MainTex,i.uv);
    float3 finalColor = pow(ColorTex.rgb,2.2);
    finalColor = ACES_Tonemapping(finalColor.rgb);

    finalColor = pow(finalColor.rgb,1 / 2.2);

    return float4(finalColor,ColorTex.a);

}