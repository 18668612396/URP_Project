using UnityEngine;
using UnityEditor;


public class DataCombineEditor : EditorWindow
{


    private static void ShowWindow()
    {
        var window = GetWindow<DataCombineEditor>();
        window.titleContent = new GUIContent("DataCombine");

        window.Show();


    }

    public WorldParam worldParam;
    public bool windowState = true;
    //WorldParam worldParam;
    public DataCombine dataCombine;
    private WaterData waterData;
    private FogData fogData;


    private void OnEnable()
    {
        windowState = true;
    }

    private void OnDisable()
    {

    }
    private void OnGUI()
    {
        if (dataCombine != null)
        {
            // Debug.Log(dataCombine.fogData._FogColor);
        }


        // waterData = dataCombine.waterData;
        // dataCombine.waterData = EditorGUILayout.ObjectField("数据文件", waterData, typeof(WaterData), false) as WaterData;//水的Asset文件


        FogGUI();//绘制雾效
        WindGUI();//风力动画
        CloudGUI();
        if (windowState == false)
        {
            Close();
        }
        SceneView.RepaintAll();

    }




    //Fog
    bool fogToggle;
    private void FogGUI()
    {
        GUILayout.BeginHorizontal();
        fogToggle = dataCombine.fogData._FogToggle;                                                                 // EditorGUILayout.BeginHorizontal();
        dataCombine.fogData._FogToggle = GUILayout.Toggle(fogToggle, "");

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
    }

    //风力动画
    private WindData windData;
    private bool _WindToggle = true;
    private void WindGUI()
    {
        GUILayout.BeginHorizontal();
        // _WindToggle = windData._WindToggle;
        // dataCombine.windData._WindToggle = GUILayout.Toggle(_WindToggle, "");
        GUILayout.Toggle(_WindToggle, ""); //临时
        windData = dataCombine.windData;
        dataCombine.windData = EditorGUILayout.ObjectField("", windData, typeof(WindData), false) as WindData;//水的Asset文件
        GUILayout.EndHorizontal();

        // Shader.EnableKeyword("_WINDANIM_ON");
        if (_WindToggle == true)
        {
            Shader.EnableKeyword("_WINDANIM_ON");
            Shader.DisableKeyword("_WINDANIM_OFF");
        }
        else
        {
            Shader.EnableKeyword("_WINDANIM_OFF");
            Shader.DisableKeyword("_WINDANIM_ON");
        }

    }


    //云阴影
    private CloudData cloudData;
    private bool _CloudShadowToggle;
    private void CloudGUI()
    {
        GUILayout.BeginHorizontal();
        _CloudShadowToggle = dataCombine.cloudData._CloudShadowToggle;
        dataCombine.cloudData._CloudShadowToggle = GUILayout.Toggle(_CloudShadowToggle, "");


        cloudData = dataCombine.cloudData;
        dataCombine.cloudData = EditorGUILayout.ObjectField("", cloudData, typeof(CloudData), false) as CloudData;//水的Asset文件
        GUILayout.EndHorizontal();

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
    }








    private void Update()
    {
        if (windowState == false)
        {
            Close();
        }
    }
}