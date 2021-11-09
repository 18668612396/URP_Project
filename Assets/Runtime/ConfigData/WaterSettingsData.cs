
using UnityEngine;


[CreateAssetMenu(menuName = "WorldConfig/WaterSettings")]
public class WaterSettingsData : ScriptableObject
{
    public float WaterDepthRadius;
    public Gradient RefractionRamp;
    public Gradient ScatteringRamp;
    public Cubemap  WaterCubemap;


}
