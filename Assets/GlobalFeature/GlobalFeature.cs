using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteAlways]
public class GlobalFeature : MonoBehaviour
{
    [Range(0.0f,10.0f)] public float _RainSpeed;
    public Texture2D Rain;
    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalFloat("_RainSpeed",_RainSpeed);
        Shader.SetGlobalTexture("_GlobalFeature_Param",Rain);
    }
}
