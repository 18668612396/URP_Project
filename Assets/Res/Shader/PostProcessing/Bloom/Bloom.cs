using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class Bloom : MonoBehaviour
{
    [Header("Bloom")]

    public Material material;


    [Tooltip("调整光晕的半径")] [Range(0, 4.99F)] public float _BloomRadius = 1.0f;

    [Tooltip("调整光晕的阈值")] [Range(0, 5)] public float _Threshold = 1.0f;

    void Start()
    {

    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        material.SetFloat("_Threshold", _Threshold);
        material.SetFloat("_BloomRadius", _BloomRadius);

        int width = source.width;
        int height = source.height;




        //准备升采样和降采样的RT
        RenderTexture RT1 = RenderTexture.GetTemporary(width / 2, height / 2, 0, source.format);
        RenderTexture RT2 = RenderTexture.GetTemporary(width / 4, height / 4, 0, source.format);
        RenderTexture RT3 = RenderTexture.GetTemporary(width / 8, height / 8, 0, source.format);
        RenderTexture RT4 = RenderTexture.GetTemporary(width / 16, height / 16, 0, source.format);
        RenderTexture RT5 = RenderTexture.GetTemporary(width / 32, height / 32, 0, source.format);

        RenderTexture RT4_UP = RenderTexture.GetTemporary(width / 16, height / 16, 0, source.format);
        RenderTexture RT3_UP = RenderTexture.GetTemporary(width / 8, height / 8, 0, source.format);
        RenderTexture RT2_UP = RenderTexture.GetTemporary(width / 4, height / 4, 0, source.format);
        RenderTexture RT1_UP = RenderTexture.GetTemporary(width / 2, height / 2, 0, source.format);
        RenderTexture BloomOver = RenderTexture.GetTemporary(width, height, 0, source.format);

        Graphics.Blit(source, RT1, material, 0);


        //模糊(降采样)
        Graphics.Blit(RT1, RT2, material, 1);
        Graphics.Blit(RT2, RT3, material, 1);
        Graphics.Blit(RT3, RT4, material, 1);
        Graphics.Blit(RT4, RT5, material, 1);
        //模糊(升采样)
        material.SetTexture("_BlendTex", RT5);
        Graphics.Blit(RT5, RT4_UP, material, 2);
        material.SetTexture("_BlendTex", RT4);
        Graphics.Blit(RT4_UP, RT3_UP, material, 2);
        material.SetTexture("_BlendTex", RT3);
        Graphics.Blit(RT3_UP, RT2_UP, material, 2);
        material.SetTexture("_BlendTex", RT2);
        Graphics.Blit(RT2_UP, RT1_UP, material, 2);
        material.SetTexture("_BlendTex", RT1);
        Graphics.Blit(RT1_UP, BloomOver, material, 2);
        //合并
        material.SetTexture("_BloomTex", BloomOver);
        Graphics.Blit(source, destination, material, 3);




        RenderTexture.ReleaseTemporary(RT1);
        RenderTexture.ReleaseTemporary(RT2);
        RenderTexture.ReleaseTemporary(RT3);
        RenderTexture.ReleaseTemporary(RT4);
        RenderTexture.ReleaseTemporary(RT5);
        RenderTexture.ReleaseTemporary(RT4_UP);
        RenderTexture.ReleaseTemporary(RT3_UP);
        RenderTexture.ReleaseTemporary(RT2_UP);
        RenderTexture.ReleaseTemporary(RT1_UP);
        RenderTexture.ReleaseTemporary(BloomOver);







    }

}
