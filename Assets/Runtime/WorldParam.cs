using UnityEngine;
using UnityEditor;

public class WorldParam : EditorWindow
{

    [MenuItem("Tools/WorldParam")]
    private static void ShowWindow()
    {
        var window = GetWindow<WorldParam>();
        window.titleContent = new GUIContent("WorldParam");
        window.Show();
    }
     int ToolsIndexID;
    static WaterData waterData = new WaterData();
    static FogData fogData = new FogData();
    private void OnGUI()
    {
        EditorGUILayout.Space(10); 
 
        ToolsIndexID = GUILayout.SelectionGrid(ToolsIndexID, new[] { "Water", "Fog", "Wind", "Cloud", "LALALA" }, 3);

        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线 
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);
        if (ToolsIndexID == 0)
        {
            waterData.DrawGUI();

        }
        // if (ToolsIndexID == 1)
        // {
        //     fogData.DrawGUI();
        // }
    }

}