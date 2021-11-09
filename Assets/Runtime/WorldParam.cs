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

    
    [SerializeField]
    private void OnGUI()
    {
        WaterDataGUI();
    }
    //水
    static WaterSettingsData WaterData = new WaterSettingsData(); 
    float WaterDepthRadiusProp;
    Cubemap Cubemap;
    private void WaterDataGUI()
    {
        WaterData = EditorGUILayout.ObjectField("水参数", WaterData, typeof(WaterSettingsData), false) as WaterSettingsData;//水的Asset文件

        WaterDepthRadiusProp = WaterData.WaterDepthRadius;
        WaterData.WaterDepthRadius = EditorGUILayout.Slider(WaterDepthRadiusProp, 0, 1);
        Shader.SetGlobalFloat("_Float01", WaterData.WaterDepthRadius);

        // Cubemap = WaterData.WaterCubemap;
        // WaterData.WaterCubemap = (Cubemap)EditorGUILayout.ObjectField("CUBE",Cubemap,typeof(Cubemap),false);

        WaterData.RefractionRamp = EditorGUILayout.GradientField("折射颜色渐变", WaterData.RefractionRamp);

        WaterData.ScatteringRamp = EditorGUILayout.GradientField("次表面散射颜色渐变", WaterData.ScatteringRamp);


       EditorGUILayout.FloatField("test",WaterDepthRadiusProp);
    }
}