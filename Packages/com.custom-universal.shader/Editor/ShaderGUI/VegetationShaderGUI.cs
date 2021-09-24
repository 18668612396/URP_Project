using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class VegetationShaderGUI : ShaderGUI
{
    MaterialProperty _MainTexProp;
    MaterialProperty _CutOffProp;
    MaterialProperty _TopColorProp;
    MaterialProperty _DownColorProp;
    MaterialProperty _GradientVectorProp;

    Vector4 _Gradient = new Vector4(-10.0f, 10.0f, 0.0f, 0.0f);
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
        _TopColorProp = FindProperty("_TopColor", properties);
        _DownColorProp = FindProperty("_DownColor", properties);
        _GradientVectorProp = FindProperty("_GradientVector", properties);

    }

    private void DrawGUI(MaterialEditor materialEditor)
    {
        EditorGUILayout.LabelField("参数属性", EditorStyles.boldLabel);
        materialEditor.TexturePropertySingleLine(new GUIContent("MainTex                    CutOff"), _MainTexProp,_CutOffProp);//绘制主纹理GUI
       // materialEditor.RangeProperty(_CutOffProp, "CutOff");
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("渐变范围  ", EditorStyles.boldLabel, GUILayout.MaxWidth(70));
        // _Gradient.z = EditorGUILayout.FloatField(_Gradient.z, GUILayout.MaxWidth(50));//绘制渐变高度GUI
        _TopColorProp.colorValue = EditorGUILayout.ColorField(new GUIContent(""),_TopColorProp.colorValue,true,true,false, GUILayout.MaxWidth(50));//上半部分颜色
        EditorGUILayout.MinMaxSlider(ref _Gradient.x, ref _Gradient.y, -10.0f, 20.0f);
        _DownColorProp.colorValue = EditorGUILayout.ColorField(new GUIContent(""),_DownColorProp.colorValue,true,true,false, GUILayout.MaxWidth(50));//下半部分颜色
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.LabelField("AO范围  ", EditorStyles.boldLabel, GUILayout.MaxWidth(70));
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.FloatField(_Gradient.z,GUILayout.MaxWidth(50));
          EditorGUILayout.MinMaxSlider(ref _Gradient.z, ref _Gradient.w, 0.0f, 1.0f);
        EditorGUILayout.FloatField(_Gradient.w,GUILayout.MaxWidth(50));
        EditorGUILayout.EndHorizontal();

    }

    private void LoadParam()
    {
        _Gradient = _GradientVectorProp.vectorValue;

    }
    private void SaveParam()
    {
        _GradientVectorProp.vectorValue = _Gradient;
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
