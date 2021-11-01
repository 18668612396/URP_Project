using UnityEngine;
using UnityEditor;

public class NPR_ShaderGUI : ShaderGUI
{

    //定义材质属性
    Material material;
    MaterialProperty _ShaderEnumProp;
    //基础PBR材质参数
    MaterialProperty _MainTexProp;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        _ShaderEnumProp = FindProperty("_ShaderEnum", properties);
        //获取当前材质球
        material = materialEditor.target as Material;
        ShaderGUI(materialEditor, properties);
        Other(materialEditor);//其他额外参数绘制
    }

    //绘制入口

    private void ShaderGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        materialEditor.ShaderProperty(_ShaderEnumProp, "材质类型");
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(10);

        if (material.IsKeywordEnabled("_SHADERENUM_BODY"))
        {
            BaseParam(materialEditor, properties);//传递参数
        }
        if (material.IsKeywordEnabled("_SHADERENUM_FACE"))
        {
            EditorGUILayout.IntField(0);
        }
        if (material.IsKeywordEnabled("_SHADERENUM_HARI"))
        {
            EditorGUILayout.IntField(1);
        }
    }

    //将定义好的材质属性传入Shader
    private void BaseParam(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //PBR材质参数
        _MainTexProp = FindProperty("_MainTex", properties);
        //颜色贴图  且判断其是否被赋值
        Texture _MainTex = material.GetTexture("_MainTex");
        materialEditor.TexturePropertySingleLine(new GUIContent("颜色贴图"), _MainTexProp);//绘制主颜色纹理GUI
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
