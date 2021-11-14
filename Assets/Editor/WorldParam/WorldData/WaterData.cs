
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
[CreateAssetMenu(menuName = "WorldParam/WaterData")]
public class WaterData : ScriptableObject
{
    public float WaterDepthRadius;
    public Gradient RefractionRamp; 
    public Gradient ScatteringRamp;
    public Cubemap WaterCubemap;

#if UNITY_EDITOR 
    //绘制GUI
    public WaterData waterData; 
    private WorldParam worldParam;
    public void DrawGUI()
    {
        waterData = EditorGUILayout.ObjectField("数据文件", waterData, typeof(WaterData), false) as WaterData;//水的Asset文件

        WaterDepthRadius = waterData.WaterDepthRadius;
        waterData.WaterDepthRadius = EditorGUILayout.Slider(WaterDepthRadius, 0, 1);
        Debug.Log(WaterDepthRadius);
    }
#endif

}
