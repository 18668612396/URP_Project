using UnityEngine;
using UnityEditor;

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
    private WaterData waterData;
    private FogData fogData;

    int waterDataIndex;

    private void OnGUI()
    {
        EditorGUILayout.Space(10);
        GUILayout.BeginHorizontal();

        dataCombine = EditorGUILayout.ObjectField("数据文件", dataCombine, typeof(DataCombine), false) as DataCombine;//水的Asset文件

        if (GUILayout.Button("Open", GUILayout.Width(80)))
        {
            GetWindow(typeof(DataCombineEditor)).Show();
        }



        GUILayout.EndHorizontal();


        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalslider"));//绘制分割线 
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);

        GUILayout.BeginHorizontal();
        {
            waterDataIndex = GUILayout.SelectionGrid(waterDataIndex, new[] { "Water", "Fog", "Wind", "Cloud", "Interact" }, 1, GUILayout.Width(150), GUILayout.Height(98));
            EditorGUILayout.BeginVertical();
            waterData = dataCombine.waterData;
            dataCombine.waterData = EditorGUILayout.ObjectField("", waterData, typeof(WaterData), false) as WaterData;//水的Asset文件

            fogData = dataCombine.fogData;
            dataCombine.fogData = EditorGUILayout.ObjectField("", fogData, typeof(FogData), false) as FogData;//水的Asset文件

            fogData = dataCombine.fogData;
            dataCombine.fogData = EditorGUILayout.ObjectField("", fogData, typeof(FogData), false) as FogData;//水的Asset文件

            fogData = dataCombine.fogData;
            dataCombine.fogData = EditorGUILayout.ObjectField("", fogData, typeof(FogData), false) as FogData;//水的Asset文件

            fogData = dataCombine.fogData;
            dataCombine.fogData = EditorGUILayout.ObjectField("", fogData, typeof(FogData), false) as FogData;//水的Asset文件
            EditorGUILayout.EndVertical();
        }
        GUILayout.EndHorizontal();






        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线 
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);

        // waterData.DrawGUI();

    }

}