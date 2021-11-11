using UnityEngine;
using UnityEditor;

public class DataCombineEditor : EditorWindow
{

    [MenuItem("Tools/DataCombine")]
    private static void ShowWindow()
    {
        var window = GetWindow<DataCombineEditor>();
        window.titleContent = new GUIContent("DataCombine");
        window.Show();
    }

    WaterData waterData;
    FogData fogData;
    private void OnGUI()
    {
        
    }
}