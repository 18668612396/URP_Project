using UnityEngine;
using System.Collections.Generic;

[CreateAssetMenu(fileName = "GradientCreatorData", menuName = "URP_Project/GradientCreatorData", order = 0)]
public class GradientCreatorData : ScriptableObject
{
    public string _GradientName = "Gradient";
    public string _ShaderPropName = "_Gradient";
    public string _KeywordName = "_DEBUGGRADIENT_ON";
    public int _GradientWidth = 128;//每一条渐变的宽度
    public int _GradientHeight = 4;//每一条渐变的高度
    public List<Gradient> _Gradient = new List<Gradient>();
    
}