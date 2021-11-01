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

        ShaderGUI(materialEditor, properties);
        Other(materialEditor);//其他额外参数绘制
    }

    //绘制入口
    //NPR公共材质参数
    MaterialProperty _ShaderEnumProp;
    MaterialProperty _MainTexProp;
    MaterialProperty _ParamTexProp;
    private void ShaderGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //NPR公共参数
        _ShaderEnumProp = FindProperty("_ShaderEnum", properties);
        _MainTexProp = FindProperty("_MainTex", properties);
        _ParamTexProp = FindProperty("_ParamTex", properties);

        materialEditor.ShaderProperty(_ShaderEnumProp, "材质类型");
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalslider"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);

        if (material.IsKeywordEnabled("_SHADERENUM_BODY"))
        {
            BodyParam(materialEditor, properties);//传递参数
        }
        if (material.IsKeywordEnabled("_SHADERENUM_FACE"))
        {
            EditorGUILayout.IntField(0);
        }
        if (material.IsKeywordEnabled("_SHADERENUM_HAIR"))
        {
            EditorGUILayout.IntField(1);
        }
    }
    //身体部分GUI
    bool _SkinToggle;
    MaterialProperty _SkinFactorProp;
    MaterialProperty _SkinFactorToleranceProp;
    //丝绸
    bool _SilkToggle;
    MaterialProperty _SilkFactorProp;
    MaterialProperty _SilkFactorToleranceProp;
    private void BodyParam(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //颜色贴图  且判断其是否被赋值
        Texture _MainTex = material.GetTexture("_MainTex");
        materialEditor.TexturePropertySingleLine(new GUIContent("颜色贴图"), _MainTexProp);//绘制主颜色纹理GUI
        materialEditor.TexturePropertySingleLine(new GUIContent("参数贴图"), _ParamTexProp);
        //皮肤部分
        _SkinFactorProp = FindProperty("_SkinFactor", properties);
        _SkinFactorToleranceProp = FindProperty("_SkinFactorTolerance", properties);

        _SkinToggle = material.IsKeywordEnabled("_SKINTOGGLE_ON") ? true : false; //读取Keywords数据
        _SkinToggle = EditorGUILayout.BeginToggleGroup(new GUIContent("SKIN_TOGGLE"), _SkinToggle);
        if (_SkinToggle)
        {

            material.EnableKeyword("_SKINTOGGLE_ON");
            materialEditor.RangeProperty(_SkinFactorProp, "皮肤遮罩阈值");
            materialEditor.RangeProperty(_SkinFactorToleranceProp, "遮罩容差");
        }
        else
        {

            material.DisableKeyword("_SKINTOGGLE_ON");
        }
        EditorGUILayout.EndToggleGroup();

        //丝绸部分
        _SilkFactorProp = FindProperty("_SilkFactor", properties);
        _SilkFactorToleranceProp = FindProperty("_SilkFactorTolerance", properties);

        _SilkToggle = material.IsKeywordEnabled("_SILKTOGGLE_ON") ? true : false; //读取Keywords数据
        _SilkToggle = EditorGUILayout.BeginToggleGroup(new GUIContent("SILK_TOGGLE"), _SilkToggle);
        if (_SilkToggle)
        {

            material.EnableKeyword("_SILKTOGGLE_ON");
            materialEditor.RangeProperty(_SilkFactorProp, "丝绸遮罩阈值");
            materialEditor.RangeProperty(_SilkFactorToleranceProp, "遮罩容差");
        }
        else
        {

            material.DisableKeyword("_SILKTOGGLE_ON");
        }
        EditorGUILayout.EndToggleGroup();

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
