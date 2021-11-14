using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class GrassShaderGUI : ShaderGUI
{
    MaterialProperty _MainTexProp;
    MaterialProperty _ColorProp;
    MaterialProperty _CutOffProp;
    MaterialProperty _SpecularRadiusProp;
    MaterialProperty _SpecularIntensityProp;
    MaterialProperty _HeightDepthPorp;
    MaterialProperty _UseMainColorProp;
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
        _ColorProp = FindProperty("_Color",properties);
        _CutOffProp = FindProperty("_CutOff", properties);
        _SpecularRadiusProp = FindProperty("_SpecularRadius", properties);
        _SpecularIntensityProp = FindProperty("_SpecularIntensity", properties);
        _HeightDepthPorp = FindProperty("_HeightDepth", properties);
        _UseMainColorProp = FindProperty("_UseMainColor",properties);
    }

    private void DrawGUI(MaterialEditor materialEditor)
    {
        EditorGUILayout.LabelField("参数属性", EditorStyles.boldLabel);
        materialEditor.ShaderProperty(_UseMainColorProp,"使用贴图颜色");
        materialEditor.TexturePropertySingleLine(new GUIContent("MainTex"), _MainTexProp,_ColorProp, _CutOffProp);//绘制主纹理GUI
        materialEditor.RangeProperty(_SpecularRadiusProp, "高光范围");
        materialEditor.RangeProperty(_SpecularIntensityProp, "高光强度");
        materialEditor.RangeProperty(_HeightDepthPorp, "AO强度");
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
