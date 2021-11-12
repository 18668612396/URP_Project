using UnityEngine;
using UnityEditor;


public class DataCombineEditor : EditorWindow
{

    [MenuItem("ddddd/dddd")]
    private static void ShowWindow()
    {
        var window = GetWindow<DataCombineEditor>();
        window.titleContent = new GUIContent("DataCombine");
        window.Show();
    }

    public bool windowState;
    //WorldParam worldParam;
    public DataCombine dataCombine;
    private WaterData waterData;
    private FogData fogData;

    bool waterToggle;
    bool fogToggle;


    private void OnEnable()
    {
        windowState = true;
    }

    private void OnDisable() {

    }
    private void OnGUI()
    {
        if (dataCombine != null)
        {
            // Debug.Log(dataCombine.fogData._FogColor);
        }

        Debug.Log(dataCombine.name);
        waterData = dataCombine.waterData;
        dataCombine.waterData = EditorGUILayout.ObjectField("数据文件", waterData, typeof(WaterData), false) as WaterData;//水的Asset文件

        GUILayout.BeginHorizontal();
        fogToggle = dataCombine.fogData._FogToggle;                                                                 // EditorGUILayout.BeginHorizontal();
        dataCombine.fogData._FogToggle = GUILayout.Button("Fog",GUILayout.Width(100));

        fogData = dataCombine.fogData;
        dataCombine.fogData = EditorGUILayout.ObjectField("", fogData, typeof(FogData), false) as FogData;//水的Asset文件


        GUILayout.EndHorizontal();
        if (dataCombine.fogData._FogToggle == true)
        {
            Shader.EnableKeyword("_WORLDFOG_ON");
            Shader.DisableKeyword("_WORLDFOG_OFF");

        }
        else
        {
            Shader.EnableKeyword("_WORLDFOG_OFF");
            Shader.DisableKeyword("_WORLDFOG_ON");
        }

        // Shader.SetGlobalInt("_FogToggle",(int)dataCombine.fogData._FogToggle);
        // waterToggle = GUILayout.RepeatButton("Water", GUILayout.Width(100));
        // waterData = EditorGUILayout.ObjectField("", waterData, typeof(WaterData), false) as WaterData;//水的Asset文件
        // EditorGUILayout.EndHorizontal();
        // Debug.Log(waterToggle);
        // EditorGUILayout.BeginHorizontal();
        // fogToggle = GUILayout.Button("Fog", GUILayout.Width(100));
        // fogData = EditorGUILayout.ObjectField("", fogData, typeof(FogData), false) as FogData;//水的Asset文件
        // EditorGUILayout.EndHorizontal();
             if(windowState == false)
        {
            Close();
        }
        SceneView.RepaintAll();
   
    }
    
}