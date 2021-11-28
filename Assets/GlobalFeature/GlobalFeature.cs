using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteAlways]
public class GlobalFeature : MonoBehaviour
{
    [Range(0.0f, 1.0f)] public float test01;
    [Range(0.0f, 1.0f)] public float test02;
    [Range(0.0f, 1.0f)] public float test03;

    [Range(0.0f, 10.0f)] public float _RainSpeed;
    public Texture2D Rain;
    // Update is called once per frame

    private void Awake()
    {
        test01 = 1 - test02;
        Debug.Log(test02);
    }
    void Update()
    {
        Shader.SetGlobalFloat("_RainSpeed", _RainSpeed);
        Shader.SetGlobalTexture("_GlobalFeature_Param", Rain);
    }
}
