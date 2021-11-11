using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CreateAssetMenu(menuName = "WorldParam/FogData")]
public class FogData : ScriptableObject
{

    public bool _FogToggle;
    public Color _FogColor = new Color(1.0f, 1.0f, 1.0f, 1.0f);//雾的颜色
    public float _FogGlobalDensity = 1.0f;//雾的密度
    public float _FogHeight = 0.0f;//雾的高度
    public float _FogStartDistance = 10.0f;//雾的开始距离
    public float _FogInscatteringExp = 1.0f;//雾散射指数
    public float _FogGradientDistance = 50.0f;//雾的梯度距离
 
    //绘制GUI
    public FogData fogData;
    public void DrawGUI()
    {
        fogData = EditorGUILayout.ObjectField("数据文件", fogData, typeof(FogData), false) as FogData;//水的Asset文件

        _FogColor = fogData._FogColor;
        fogData._FogColor = EditorGUILayout.ColorField("雾效颜色", _FogColor);


    }
}
