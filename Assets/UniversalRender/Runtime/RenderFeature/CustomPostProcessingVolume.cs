using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[System.Serializable,VolumeComponentMenu("CustomPostProcessing/Bloom")]
public class Bloom : VolumeComponent
{
    [Range(0, 4.99F)] public FloatParameter _BloomRadius = new FloatParameter(1.0f);
    public FloatParameter _BloomThreshold = new FloatParameter(1.0f);
}


[System.Serializable,VolumeComponentMenu("CustomPostProcessing/AcesTonemapping")]
public class AcesTonemapping : VolumeComponent
{
    public FloatParameter BloomT = new FloatParameter(0.0f);
}