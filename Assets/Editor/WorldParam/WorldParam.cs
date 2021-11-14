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
        dataIndex = GUILayout.SelectionGrid(dataIndex, new[] { "Water", "Fog", "Wind", "Cloud", "Interact" }, 5);
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线 
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);

        if (dataIndex == 1)
        {
            FogDataGUI();
        }
        if (dataIndex == 2)
        {
            WindDataGUI();
        }

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



    public bool _WindToggle;
    float _WindDensity = 15.0f;
    float _WindSpeedFloat = 0.35f;
    float _WindTurbulenceFloat = 0.5f;
    float _WindStrengthFloat = 0.1f;
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



    }
}