using System;
using UnityEngine;
using Object = UnityEngine.Object;
using Random = UnityEngine.Random;


[ExecuteAlways]
public class SceneParam : MonoBehaviour
{


    private void Update()
    {
        GrassParam();
    }
   
    //草的参数
    public bool _GrassParam;
    public Texture2D _BaseTex; 
    public Texture2D _ColorTex0;
    public float _Color0_ST;
    public Texture2D _ColorTex1;
    public float _Color1_ST;
    public Texture2D _ColorTex2;
    public float _Color2_ST;
    public Texture2D _ColorTex3;
    public float _Color3_ST;
    private void GrassParam()
    {
        Shader.SetGlobalTexture("_BaseTex", _BaseTex);
        Shader.SetGlobalTexture("_ColorTex0", _ColorTex0);
        Shader.SetGlobalFloat("_Color0_ST",_Color0_ST);
        Shader.SetGlobalTexture("_ColorTex1", _ColorTex1);
        Shader.SetGlobalFloat("_Color1_ST",_Color1_ST);
        Shader.SetGlobalTexture("_ColorTex2", _ColorTex2);
        Shader.SetGlobalFloat("_Color2_ST",_Color2_ST);
        Shader.SetGlobalTexture("_ColorTex3", _ColorTex3);
        Shader.SetGlobalFloat("_Color3_ST",_Color3_ST);
    }

}
