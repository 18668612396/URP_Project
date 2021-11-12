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


    int dataIndex;

    Color fogColor;
    private void OnGUI()
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

        }
        GUILayout.EndHorizontal();
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalslider"));//绘制分割线 
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);

        // GUILayout.BeginHorizontal();
        // {
        dataIndex = GUILayout.SelectionGrid(dataIndex, new[] { "Water", "Fog", "Wind", "Cloud", "Interact" }, 5);
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线 
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);



        fogColor = dataCombine.fogData._FogColor;
        dataCombine.fogData._FogColor = EditorGUILayout.ColorField(fogColor);
        Shader.SetGlobalColor("_FogColor", dataCombine.fogData._FogColor);


        // Debug.Log(dataCombineEditor.windowState);
        // waterData.DrawGUI(); 
        SceneView.RepaintAll();//需要重新绘制Scene视图才能实时更新数据
    }

    private void OnDisable()
    {
       dataCombineEditor.windowState = false;
       Debug.Log(dataCombineEditor.windowState);
    }

    private void Update()
    {

    }
}