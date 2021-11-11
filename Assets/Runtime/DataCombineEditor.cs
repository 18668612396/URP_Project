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



    private DataCombine dataCombine;
    private WaterData waterData;
    private FogData fogData;

    bool waterToggle;
    bool fogToggle;
    private void OnGUI()
    {

        // // worldParam.dataCombine.waterData = EditorGUILayout.ObjectField("数据文件", waterData, typeof(WaterData), false) as WaterData;//水的Asset文件
        EditorGUILayout.BeginHorizontal();

        waterToggle = GUILayout.RepeatButton("Water", GUILayout.Width(100));
        waterData = EditorGUILayout.ObjectField("", waterData, typeof(WaterData), false) as WaterData;//水的Asset文件
        EditorGUILayout.EndHorizontal();
        Debug.Log(waterToggle);
        EditorGUILayout.BeginHorizontal();
        fogToggle = GUILayout.Button("Fog", GUILayout.Width(100));
        fogData = EditorGUILayout.ObjectField("", fogData, typeof(FogData), false) as FogData;//水的Asset文件
        EditorGUILayout.EndHorizontal();

    }
}