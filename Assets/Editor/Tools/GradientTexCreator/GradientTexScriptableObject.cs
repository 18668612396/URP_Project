using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[CreateAssetMenu(menuName = "Tools/GradientTexData")]
public class GradientTexScriptableObject : ScriptableObject
{
    public List<Gradient> gr;
}
