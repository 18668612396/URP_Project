using System.Collections;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

[System.Serializable,VolumeComponentMenu("Custom/ColorTint")]
public class ColorTint : VolumeComponent
{
 public ColorParameter _Color = new ColorParameter(UnityEngine.Color.white,true);
}
