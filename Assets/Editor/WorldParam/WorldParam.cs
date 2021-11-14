using UnityEngine;
using UnityEditor;
using System;


[InitializeOnLoad]
public class WorldParam : EditorWindow
{

    [MenuItem("Tools/WorldParam _1")]
    private static void ShowWindow()
    {
        var window = GetWindow<WorldParam>();
        window.titleContent = new GUIContent("WorldParam");
        window.Show();
    }
    int ToolsIndexID;

    private DataCombineEditor dataCombineEditor;
    public DataCombine dataCombine;


    int dataIndex;
    private void OnGUI()
    {
        Header();
        dataIndex = GUILayout.SelectionGrid(dataIndex, new[] { "Water", "Fog", "Wind", "Cloud" }, 4);
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线 
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);

        if (dataIndex == 1)
            FogDataGUI();
        if (dataIndex == 2)
            WindDataGUI();
        if (dataIndex == 3)
            CloudDataGUI();

        SceneView.RepaintAll();//需要重新绘制Scene视图才能实时更新数据
    }

    //抬头编辑

    private void Header()
    {
        EditorGUILayout.Space(10);
        GUILayout.BeginHorizontal();
        DataCombine curDataCombine = EditorGUILayout.ObjectField("数据文件", dataCombine, typeof(DataCombine), false) as DataCombine;//水的Asset文件
        if (dataCombine != curDataCombine)
        {
            dataCombineEditor.dataCombine = curDataCombine;
            dataCombine = curDataCombine;

        }

        if (GUILayout.Button("Open", GUILayout.Width(80)))
        {
            dataCombineEditor = GetWindow(typeof(DataCombineEditor)) as DataCombineEditor;
            dataCombineEditor.dataCombine = dataCombine;
            dataCombineEditor.Show();
            dataCombineEditor.windowState = true;
        }
        GUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalslider"));//绘制分割线 
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    }


    //雾效编辑-------------------------------------------
    Color _FogColor;
    float _FogGlobalDensity;
    float _FogHeight;
    float _FogStartDistance;
    float _FogInscatteringExp;
    float _FogGradientDistance;
    private void FogDataGUI()
    {
        //雾效颜色
        _FogColor = dataCombine.fogData._FogColor;
        dataCombine.fogData._FogColor = EditorGUILayout.ColorField("_FogColor", _FogColor);


        //雾效密度
        _FogGlobalDensity = dataCombine.fogData._FogGlobalDensity;
        dataCombine.fogData._FogGlobalDensity = EditorGUILayout.Slider("雾效密度", _FogGlobalDensity, 0.0f, 50.0f);


        //雾效高度
        _FogHeight = dataCombine.fogData._FogHeight;
        dataCombine.fogData._FogHeight = EditorGUILayout.Slider("雾效高度", _FogHeight, 0.0f, 50.0f);


        _FogStartDistance = dataCombine.fogData._FogStartDistance;
        dataCombine.fogData._FogStartDistance = EditorGUILayout.Slider("雾效起始距离", _FogStartDistance, 0.0f, 10.0f);


        _FogInscatteringExp = dataCombine.fogData._FogInscatteringExp;
        dataCombine.fogData._FogInscatteringExp = EditorGUILayout.Slider("雾效散射指数", _FogInscatteringExp, 1.0f, 10.0f);


        _FogGradientDistance = dataCombine.fogData._FogGradientDistance;
        dataCombine.fogData._FogGradientDistance = EditorGUILayout.Slider("雾效渐变距离", _FogGradientDistance, 1.0f, 300.0f);

    }


    //风力动画
    public bool _WindToggle;
    float _WindDensity = 15.0f;
    float _WindSpeedFloat = 0.35f;
    float _WindTurbulenceFloat = 0.5f;
    float _WindStrengthFloat = 0.1f;

    bool _InteractToggle;
    [Range(0.0f, 5.0f)] public float _InteractRadius = 0.2f;
    [Range(0.0f, 1.0f)] public float _InteractIntensity = 0.5f;
    [Range(0.0f, 10.0f)] public float _InteractHeight = 1.0f;

    private void WindDataGUI()
    {
        _WindDensity = dataCombine.windData._WindDensity;
        dataCombine.windData._WindDensity = EditorGUILayout.Slider("风力密度", _WindDensity, 1.0f, 50.0f);

        _WindSpeedFloat = dataCombine.windData._WindSpeedFloat;
        dataCombine.windData._WindSpeedFloat = EditorGUILayout.Slider("风力速度", _WindSpeedFloat, 0.0f, 1.0f);

        _WindTurbulenceFloat = dataCombine.windData._WindTurbulenceFloat;
        dataCombine.windData._WindTurbulenceFloat = EditorGUILayout.Slider("风力干涉", _WindTurbulenceFloat, 0.0f, 1.0f);

        _WindStrengthFloat = dataCombine.windData._WindStrengthFloat;
        dataCombine.windData._WindStrengthFloat = EditorGUILayout.Slider("风力强度", _WindStrengthFloat, 0.0f, 1.0f);

        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalslider"));//绘制分割线 
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);


        _InteractToggle = dataCombine.windData._InteractToggle;
        dataCombine.windData._InteractToggle = GUILayout.Toggle(_InteractToggle, "草地交互开关");
        EditorGUILayout.Space(2);
        _InteractRadius = dataCombine.windData._InteractRadius;
        dataCombine.windData._InteractRadius = EditorGUILayout.Slider("草地交互半径", _InteractRadius, 0.0f, 5.0f);

        _InteractIntensity = dataCombine.windData._InteractIntensity;
        dataCombine.windData._InteractIntensity = EditorGUILayout.Slider("草地交互强度", _InteractIntensity, 0.0f, 1.0f);

        _InteractHeight = dataCombine.windData._InteractHeight;
        dataCombine.windData._InteractHeight = EditorGUILayout.Slider("草地交互高度", _InteractHeight, 0.0f, 10.0f);

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

    }

    //云阴影
    // public bool _CloudShadowToggle;
    [Range(0.0f, 1.0f)] public float _CloudShadowSize = 0.1f;
    public Vector2 _CloudShadowRadius = new Vector2(0.8f, 0.5f);
    [Range(0.0f, 1.0f)] public float _CloudShadowIntensity = 0.75f;
    [Range(0.0f, 5.0f)] public float _CloudShadowSpeed = 0.65f;

    private void CloudDataGUI()
    {
        _CloudShadowSize = dataCombine.cloudData._CloudShadowSize;
        dataCombine.cloudData._CloudShadowSize = EditorGUILayout.Slider("阴影密度", _CloudShadowSize, 0.0f, 1.0f);

        _CloudShadowRadius = dataCombine.cloudData._CloudShadowRadius;
        dataCombine.cloudData._CloudShadowRadius = EditorGUILayout.Vector2Field("阴影大小", _CloudShadowRadius);

        _CloudShadowIntensity = dataCombine.cloudData._CloudShadowIntensity;
        dataCombine.cloudData._CloudShadowIntensity = EditorGUILayout.Slider("阴影强度", _CloudShadowIntensity, 0.0f, 1.0f);

        _CloudShadowSpeed = dataCombine.cloudData._CloudShadowSpeed;
        dataCombine.cloudData._CloudShadowSpeed = EditorGUILayout.Slider("阴影速度", _CloudShadowSpeed, 0.0f, 1.0f);

    }






















    public bool windowState = false;
    private void OnDisable()
    {
        // dataCombineEditor.windowState = false;

    }

    //全局变量传参 
    private void Update()
    {
        Shader.SetGlobalColor("_FogColor", dataCombine.fogData._FogColor);
        Shader.SetGlobalFloat("_FogGlobalDensity", dataCombine.fogData._FogGlobalDensity);
        Shader.SetGlobalFloat("_FogHeight", dataCombine.fogData._FogHeight);
        Shader.SetGlobalFloat("_FogStartDis", dataCombine.fogData._FogStartDistance);
        Shader.SetGlobalFloat("_FogInscatteringExp", dataCombine.fogData._FogInscatteringExp);
        Shader.SetGlobalFloat("_FogGradientDis", dataCombine.fogData._FogGradientDistance);

        // Shader.SetGlobalVector("_WindDirection", transform.rotation * Vector3.back);
        Shader.SetGlobalFloat("_WindDensity", _WindDensity);
        Shader.SetGlobalFloat("_WindSpeedFloat", _WindSpeedFloat);
        Shader.SetGlobalFloat("_WindTurbulenceFloat", _WindTurbulenceFloat);
        Shader.SetGlobalFloat("_WindStrengthFloat", _WindStrengthFloat);
        Shader.SetGlobalFloat("_InteractRadius", _InteractRadius);
        Shader.SetGlobalFloat("_InteractIntensity", _InteractIntensity);
        Shader.SetGlobalFloat("_InteractHeight", _InteractHeight);

        Shader.SetGlobalFloat("_CloudShadowSize", _CloudShadowSize);
        Shader.SetGlobalVector("_CloudShadowRadius", _CloudShadowRadius);
        Shader.SetGlobalFloat("_CloudShadowSpeed", _CloudShadowSpeed);
        Shader.SetGlobalFloat("_CloudShadowIntensity", _CloudShadowIntensity);

    }
}