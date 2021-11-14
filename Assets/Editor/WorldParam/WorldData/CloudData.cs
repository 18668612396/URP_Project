
using UnityEngine;

[CreateAssetMenu(menuName = "WorldParam/CloudData")]
public class CloudData : ScriptableObject
{
    // public bool _CloudToggle;
    public bool _CloudShadowToggle;
    [Range(0.0f, 1.0f)] public float _CloudShadowSize;
    public Vector2 _CloudShadowRadius;
    [Range(0.0f, 1.0f)] public float _CloudShadowIntensity;
    [Range(0.0f, 5.0f)] public float _CloudShadowSpeed;

}
