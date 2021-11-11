
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
[CreateAssetMenu(menuName = "WorldConfig/WaterData")]
public class WaterData : ScriptableObject
{
    public float WaterDepthRadius;
    public Gradient RefractionRamp; 
    public Gradient ScatteringRamp;
    public Cubemap WaterCubemap;

#if UNITY_EDITOR
    //绘制GUI
    public WaterData waterData;

#endif

}
