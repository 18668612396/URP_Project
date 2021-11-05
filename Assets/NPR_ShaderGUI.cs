using UnityEngine;
using UnityEditor;

public class NPR_ShaderGUI : ShaderGUI
{

    //定义材质属性
    Material material;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {

        //获取当前材质球
        material = materialEditor.target as Material;

        PublicGUI(materialEditor, properties);
        Other(materialEditor);//其他额外参数绘制
    }

    //绘制入口
    //NPR公共材质参数
    MaterialProperty _ShaderEnumProp;
    MaterialProperty _MainTexProp;
    MaterialProperty _ColorProp;
    MaterialProperty _ParamTexProp;
    MaterialProperty _RampTexProp;
    private void PublicGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //NPR公共参数
        _ShaderEnumProp = FindProperty("_ShaderEnum", properties);
        _MainTexProp = FindProperty("_MainTex", properties);
        _ColorProp = FindProperty("_Color", properties);
        _ParamTexProp = FindProperty("_ParamTex", properties);
        _RampTexProp = FindProperty("_RampTex", properties);

        materialEditor.ShaderProperty(_ShaderEnumProp, "材质类型");
        EditorGUILayout.Space(20);
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);

        materialEditor.TexturePropertySingleLine(new GUIContent("颜色贴图"), _MainTexProp, _ColorProp);
        if (material.IsKeywordEnabled("_SHADERENUM_FACE"))
        {
            materialEditor.TexturePropertySingleLine(new GUIContent("面部阴影"), _ParamTexProp);
        }
        else
        {
            materialEditor.TexturePropertySingleLine(new GUIContent("参数贴图"), _ParamTexProp);
        }
        materialEditor.TexturePropertySingleLine(new GUIContent("查找贴图"), _RampTexProp);
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalslider"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);

        if (material.IsKeywordEnabled("_SHADERENUM_BASE"))
        {
            BaseParam(materialEditor, properties);//传递参数
        }

        if (material.IsKeywordEnabled("_SHADERENUM_HAIR"))
        {
            HariParam(materialEditor, properties);//传递参数
        }

        if (material.IsKeywordEnabled("_SHADERENUM_FACE"))
        {
            FaceParam(materialEditor, properties);//传递参数
        }
    }
    //身体部分GUI
    MaterialProperty _MaskTolerateProp;//遮罩容差
    MaterialProperty _SkinMaskProp;//皮肤遮罩
    MaterialProperty _SilkMaskProp;//丝绸遮罩
    MaterialProperty _MetalMaskProp;//金属遮罩
    MaterialProperty _SoftMaskProp;//软体遮罩
    MaterialProperty _HandMaskProp;//硬体遮罩

    MaterialProperty _MatcapProp;
    MaterialProperty _MetalColorProp;

    MaterialProperty _EmissionIntensityProp;
    MaterialProperty _ShadowColorProp;

    MaterialProperty _RimIntensityProp;
    MaterialProperty _RimRadiusProp;

    MaterialProperty _OutlineColorProp;
    MaterialProperty _OutlineOffsetProp;
    private void BaseParam(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        _MatcapProp = FindProperty("_Matcap", properties);
        _MetalColorProp = FindProperty("_MetalColor", properties);

        _MaskTolerateProp = FindProperty("_MaskTolerate", properties);
        _SkinMaskProp = FindProperty("_SkinMask", properties);
        _SilkMaskProp = FindProperty("_SilkMask", properties);
        _MetalMaskProp = FindProperty("_MetalMask", properties);
        _SoftMaskProp = FindProperty("_SoftMask", properties);
        _HandMaskProp = FindProperty("_HandMask", properties);
        _EmissionIntensityProp = FindProperty("_EmissionIntensity", properties);
        _ShadowColorProp = FindProperty("_ShadowColor", properties);

        _RimIntensityProp = FindProperty("_RimIntensity", properties);
        _RimRadiusProp = FindProperty("_RimRadius", properties);

        _OutlineColorProp = FindProperty("_OutlineColor", properties);
        _OutlineOffsetProp = FindProperty("_OutlineOffset", properties);
        //绘制GUI
        materialEditor.TexturePropertySingleLine(new GUIContent("金属贴图"), _MatcapProp, _MetalColorProp);
        materialEditor.ShaderProperty(_MaskTolerateProp, "遮罩容差");
        materialEditor.ShaderProperty(_SkinMaskProp, "皮肤遮罩(255)");
        materialEditor.ShaderProperty(_SilkMaskProp, "丝绸遮罩(160)");
        materialEditor.ShaderProperty(_MetalMaskProp, "金属遮罩(128)");
        materialEditor.ShaderProperty(_SoftMaskProp, "软体遮罩(78)");
        materialEditor.ShaderProperty(_HandMaskProp, "硬体遮罩(0)");
        materialEditor.ShaderProperty(_EmissionIntensityProp, "自发光强度");
        materialEditor.ShaderProperty(_ShadowColorProp, "阴影颜色");

        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalslider"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);
        materialEditor.ShaderProperty(_RimIntensityProp, "边缘光强度");
        materialEditor.ShaderProperty(_RimRadiusProp, "边缘光范围");
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalslider"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);
        materialEditor.ShaderProperty(_OutlineColorProp, "描边颜色");
        materialEditor.ShaderProperty(_OutlineOffsetProp, "描边宽度");

    }
    MaterialProperty _HairSpecularIntensityProp;
    private void HariParam(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        _MatcapProp = FindProperty("_Matcap", properties);
        _MetalColorProp = FindProperty("_MetalColor", properties);

        _MaskTolerateProp = FindProperty("_MaskTolerate", properties);
        _SkinMaskProp = FindProperty("_SkinMask", properties);
        _SilkMaskProp = FindProperty("_SilkMask", properties);
        _MetalMaskProp = FindProperty("_MetalMask", properties);
        _SoftMaskProp = FindProperty("_SoftMask", properties);
        _HandMaskProp = FindProperty("_HandMask", properties);
        _HairSpecularIntensityProp = FindProperty("_HairSpecularIntensity", properties);
        _EmissionIntensityProp = FindProperty("_EmissionIntensity", properties);
        _ShadowColorProp = FindProperty("_ShadowColor", properties);

        _RimIntensityProp = FindProperty("_RimIntensity", properties);
        _RimRadiusProp = FindProperty("_RimRadius", properties);

        _OutlineColorProp = FindProperty("_OutlineColor", properties);
        _OutlineOffsetProp = FindProperty("_OutlineOffset", properties);
        //绘制GUI
        materialEditor.TexturePropertySingleLine(new GUIContent("金属贴图"), _MatcapProp, _MetalColorProp);
        materialEditor.ShaderProperty(_MaskTolerateProp, "遮罩容差");
        materialEditor.ShaderProperty(_SkinMaskProp, "头发遮罩(255)");
        materialEditor.ShaderProperty(_SilkMaskProp, "丝绸遮罩(160)");
        materialEditor.ShaderProperty(_MetalMaskProp, "金属遮罩(128)");
        materialEditor.ShaderProperty(_SoftMaskProp, "软体遮罩(78)");
        materialEditor.ShaderProperty(_HandMaskProp, "硬体遮罩(0)");
        materialEditor.ShaderProperty(_HairSpecularIntensityProp, "头发高光强度");
        materialEditor.ShaderProperty(_EmissionIntensityProp, "自发光强度");
        materialEditor.ShaderProperty(_ShadowColorProp, "阴影颜色");

        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalslider"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);
        materialEditor.ShaderProperty(_RimIntensityProp, "边缘光强度");
        materialEditor.ShaderProperty(_RimRadiusProp, "边缘光范围");
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalslider"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);
        materialEditor.ShaderProperty(_OutlineColorProp, "描边颜色");
        materialEditor.ShaderProperty(_OutlineOffsetProp, "描边宽度");
    }


    private void FaceParam(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        _ShadowColorProp = FindProperty("_ShadowColor", properties);
        _OutlineColorProp = FindProperty("_OutlineColor", properties);
        _OutlineOffsetProp = FindProperty("_OutlineOffset", properties);

        materialEditor.ShaderProperty(_ShadowColorProp, "阴影颜色");

        materialEditor.ShaderProperty(_OutlineColorProp, "描边颜色");
        materialEditor.ShaderProperty(_OutlineOffsetProp, "描边宽度");

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
