using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Blur : MonoBehaviour
{
    public Material material;
    [Range(0, 2.99f)] public float _BlurRadius;
    // Start is called before the first frame update
    void Start()
    {
        if (material == null)
        {
            enabled = false;
        }

    }


    void OnRenderImage(RenderTexture source, RenderTexture destination)

    {
        int width = source.width;
        int height = source.height;
        RenderTexture RT1 = RenderTexture.GetTemporary(width, height);
        RenderTexture RT2 = RenderTexture.GetTemporary(width, height);
        Graphics.Blit(source, RT1, material);

        material.SetFloat("_BlurRadius", _BlurRadius);
        for (int i = 0; i < _BlurRadius; i++)
        {
         RenderTexture.ReleaseTemporary(RT2);
         width = width / 2;
         height = height / 2;
         RT2 = RenderTexture.GetTemporary(width,height);
         Graphics.Blit(RT1,RT2,material);

         RenderTexture.ReleaseTemporary(RT1);
         width = width * 2;
         height = height * 2;
         RT1 = RenderTexture.GetTemporary(width,height);
         Graphics.Blit(RT2,RT1,material);
        }

        
        Graphics.Blit(RT1, destination);

        //------------------------------\

        RenderTexture.ReleaseTemporary(RT1);
        RenderTexture.ReleaseTemporary(RT2);

    }
}
