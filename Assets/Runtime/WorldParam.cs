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
    WaterData WaterData = null;
    static FogData fogData = new FogData();

    private void OnEnable()
    {

        if (!EditorPrefs.HasKey("shuishuju"))
        {
            WaterData = null;
        }
        else
        {
            
            WaterData = AssetDatabase.LoadAssetAtPath<WaterData>(EditorPrefs.GetString("shuishuju", ""));
        }
    }

    private void OnGUI()
    {
        EditorGUILayout.Space(10);

        ToolsIndexID = GUILayout.SelectionGrid(ToolsIndexID, new[] { "Water", "Fog", "Wind", "Cloud", "LALALA" }, 3);

        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线 
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);
        if (ToolsIndexID == 0)
        {
            DrawGUI();

            Shader.SetGlobalFloat("_Float01",WaterData.WaterDepthRadius);
        }
        // if (ToolsIndexID == 1)
        // {
        //     fogData.DrawGUI();
        // }
    }

    public void DrawGUI()
    {
        WaterData curWaterData = EditorGUILayout.ObjectField("数据文件", WaterData, typeof(WaterData), false) as WaterData;//水的Ass 

        if (curWaterData != WaterData)
        {
            EditorPrefs.SetString("shuishuju", curWaterData ? AssetDatabase.GetAssetPath(curWaterData) : "");
            WaterData = curWaterData;
        }
        // WaterData = EditorGUILayout.ObjectField("数据文件", WaterData, typeof(WaterData), false) as WaterData;//水的Asset文件


        // WaterDepthRadius = waterData.WaterDepthRadius;
        // waterData.WaterDepthRadius = EditorGUILayout.Slider(WaterDepthRadius, 0, 1);
        // Debug.Log(WaterDepthRadius);
    }
}