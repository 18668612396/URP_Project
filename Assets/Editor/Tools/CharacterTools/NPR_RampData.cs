
using UnityEngine;

[CreateAssetMenu(menuName = "Tools/NPR_RampData")]
public class NPR_RampData : ScriptableObject
{
    public Gradient day_Skin;//白天皮肤
    public Gradient day_Silk;//白天丝绸
    public Gradient day_Metal;//白天金属
    public Gradient day_Soft;//白天软体
    public Gradient day_Hand;//白天硬体
    [Space(50)]
    public Gradient night_Skin;//晚上皮肤
    public Gradient night_Silk;//晚上丝绸
    public Gradient night_Metal;//晚上金属
    public Gradient night_Soft;//晚上软体
    public Gradient night_Hand;//晚上硬体

}
