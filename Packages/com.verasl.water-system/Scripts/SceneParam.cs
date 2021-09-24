using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


[ExecuteInEditMode]
public class SceneParam : MonoBehaviour
{

    public bool _BigWind;
    bool _tempBigWind;

    private void Update()
    {
        WindParam();
        CloudShadow();
        GrassInteract();
        BigWorldFog();//大世界雾效

    }

    //风力动画参数
    public bool _WindAnimToggle;
    [Range(1.0f, 50.0f)] public float _WindDensity = 15.0f;
    [Range(0.0f, 1.0f)] public float _WindSpeedFloat = 0.35f;
    [Range(0.0f, 1.0f)] public float _WindTurbulenceFloat = 0.5f;
    [Range(0.0f, 1.0f)] public float _WindStrengthFloat = 0.1f;
    private void WindParam()
    {
        if (_WindAnimToggle == true)
        {
            Shader.EnableKeyword("_WINDANIM_ON");
            Shader.DisableKeyword("_WINDANIM_OFF");
        }
        else
        {
            Shader.EnableKeyword("_WINDANIM_OFF");
            Shader.DisableKeyword("_WINDANIM_ON");
        }
        Shader.SetGlobalVector("_WindDirection", transform.rotation * Vector3.back);
        Shader.SetGlobalFloat("_WindDensity", _WindDensity);
        Shader.SetGlobalFloat("_WindSpeedFloat", _WindSpeedFloat);
        Shader.SetGlobalFloat("_WindTurbulenceFloat", _WindTurbulenceFloat);
        Shader.SetGlobalFloat("_WindStrengthFloat", _WindStrengthFloat);

    }

    //云阴影参数
    public bool _CloudShadowToggle;
    [Range(0.0f, 1.0f)] public float _CloudShadowSize = 0.1f;
    public Vector2 _CloudShadowRadius = new Vector2(0.8f,0.5f);
    [Range(0.0f, 1.0f)] public float _CloudShadowIntensity = 0.75f;
    [Range(0.0f, 5.0f)] public float _CloudShadowSpeed = 0.65f;
    private void CloudShadow()
    {
        if (_CloudShadowToggle == true)
        {
            Shader.EnableKeyword("_CLOUDSHADOW_ON");
            Shader.DisableKeyword("_CLOUDSHADOW_OFF");
        }
        else
        {
            Shader.EnableKeyword("_CLOUDSHADOW_OFF");
            Shader.DisableKeyword("_CLOUDSHADOW_ON");
        }
        Shader.SetGlobalFloat("_CloudShadowSize", _CloudShadowSize);
        Shader.SetGlobalVector("_CloudShadowRadius", _CloudShadowRadius);
        Shader.SetGlobalFloat("_CloudShadowSpeed", _CloudShadowSpeed);
        Shader.SetGlobalFloat("_CloudShadowIntensity", _CloudShadowIntensity);

    }
    //草地交互参数
    public bool _InteractToggle;
    [Range(0.0f, 5.0f)] public float _InteractRadius = 0.2f;
    [Range(0.0f, 1.0f)] public float _InteractIntensity = 0.5f;
    [Range(0.0f, 10.0f)] public float _InteractHeight = 1.0f;
    private void GrassInteract()
    {
        if (_InteractToggle == true)
        {
            Shader.EnableKeyword("_INTERACT_ON");
            Shader.DisableKeyword("_INTERACT_OFF");
        }
        else
        {
            Shader.EnableKeyword("_INTERACT_OFF");
            Shader.DisableKeyword("_INTERACT_ON");
        }
        Shader.SetGlobalFloat("_InteractRadius", _InteractRadius);
        Shader.SetGlobalFloat("_InteractIntensity", _InteractIntensity);
        Shader.SetGlobalFloat("_InteractHeight", _InteractHeight);
    }

    //雾效

    public bool _FogToggle;
    public Color _FogColor = new Color(1.0f,1.0f,1.0f,1.0f);//雾的颜色
    public float _FogGlobalDensity = 1.0f;//雾的密度
    public float _FogHeight = 0.0f;//雾的高度
    public float _FogStartDistance = 10.0f;//雾的开始距离
    public float _FogInscatteringExp = 1.0f;//雾散射指数
    public float _FogGradientDistance = 50.0f;//雾的梯度距离

    private void BigWorldFog()
    {
        if (_FogToggle == true)
        {
            Shader.EnableKeyword("_WORLDFOG_ON");
            Shader.DisableKeyword("_WORLDFOG_OFF");

        }
        else
        {
            Shader.EnableKeyword("_WORLDFOG_OFF");
            Shader.DisableKeyword("_WORLDFOG_ON");
        }
        Shader.SetGlobalColor("_FogColor", _FogColor);
        Shader.SetGlobalFloat("_FogGlobalDensity", _FogGlobalDensity);
        Shader.SetGlobalFloat("_FogHeight", _FogHeight);
        Shader.SetGlobalFloat("_FogStartDis", _FogStartDistance);
        Shader.SetGlobalFloat("_FogInscatteringExp", _FogInscatteringExp);
        Shader.SetGlobalFloat("_FogGradientDis", _FogGradientDistance);
    }


}
