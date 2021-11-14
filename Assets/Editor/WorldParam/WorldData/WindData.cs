
using UnityEngine;

[CreateAssetMenu(menuName = "WorldParam/WindData")]
public class WindData : ScriptableObject
{
    public bool _WindToggle;
    [Range(1.0f, 50.0f)] public float _WindDensity = 15.0f;
    [Range(0.0f, 1.0f)] public float _WindSpeedFloat = 0.35f;
    [Range(0.0f, 1.0f)] public float _WindTurbulenceFloat = 0.5f;
    [Range(0.0f, 1.0f)] public float _WindStrengthFloat = 0.1f;

}
