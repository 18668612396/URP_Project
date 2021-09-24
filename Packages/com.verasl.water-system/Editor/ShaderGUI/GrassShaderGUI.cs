using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class GrassShaderGUI : ShaderGUI
{
    MaterialProperty _MainTexProp;
    MaterialProperty _CutOffProp;
    MaterialProperty _ColorProp;

    MaterialProperty _SpecularRadiusProp;

    MaterialProperty _SpecularIntensityProp;
    MaterialProperty _OcclusionIntensityPorp;
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)

    {

        MaterialParam(properties);
        LoadParam();
        DrawGUI(materialEditor);
        SaveParam();
        Other(materialEditor);//其他额外参数绘制
    }

    private void MaterialParam(MaterialProperty[] properties)
    {
        _MainTexProp = FindProperty("_MainTex", properties);
        _CutOffProp = FindProperty("_CutOff", properties);
        _ColorProp = FindProperty("_Color", properties);
        _SpecularRadiusProp = FindProperty("_SpecularRadius",properties);
        _SpecularIntensityProp = FindProperty("_SpecularIntensity",properties);
        _OcclusionIntensityPorp = FindProperty("_OcclusionIntensity",properties);
    }

    private void DrawGUI(MaterialEditor materialEditor)
    {
        EditorGUILayout.LabelField("参数属性", EditorStyles.boldLabel);
        materialEditor.TexturePropertySingleLine(new GUIContent("MainTex"), _MainTexProp,_ColorProp,_CutOffProp);//绘制主纹理GUI
        materialEditor.RangeProperty(_SpecularRadiusProp,"高光范围");
        materialEditor.RangeProperty(_SpecularIntensityProp,"高光强度");
        materialEditor.RangeProperty(_OcclusionIntensityPorp,"AO强度");
     }

    private void LoadParam()
    {
       // _Gradient = _GradientVectorProp.vectorValue;

    }
    private void SaveParam()
    {
       // _GradientVectorProp.vectorValue = _Gradient;
    }

    private void Other(MaterialEditor materialEditor)
    {
        EditorGUILayout.Space(10);
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        materialEditor.RenderQueueField();
        materialEditor.EnableInstancingField();
        materialEditor.DoubleSidedGIField();
        EditorGUILayout.EndVertical();
    }

}
