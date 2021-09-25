using UnityEngine;
using UnityEditor;

public class PBR_ShaderGUI : ShaderGUI
{

    //定义材质属性
    Material material;
    //基础PBR材质参数
    MaterialProperty _MainTexProp;
    MaterialProperty _ColorProp;
    MaterialProperty _EmissionIntensityProp;
    MaterialProperty _PbrParamProp;
    MaterialProperty _MetallicProp;
    MaterialProperty _RoughnessProp;
    MaterialProperty _NormalProp;
    MaterialProperty _NormalIntensityProp;

    // //视差映射材质属性
    // bool _ParallaxToggle;
    // MaterialProperty _MaxSampleProp;//最高采样次数
    // float _MaxSample = 2;
    // MaterialProperty _MinSampleProp;//最低采样次数
    // float _MinSample = 1;
    // MaterialProperty _SectionStepsProp;//视差映射平滑次数
    // MaterialProperty _PomScaleProp;//视差强度
    // MaterialProperty _HeightScaleProp;//视差高度  多数用于和别的高度混合
    //高度融合材质属性

    bool _FallDustToggle;
    MaterialProperty _FallDustMainTexProp;
    MaterialProperty _FallDustColorProp;
    MaterialProperty _fallDustEmissionIntensityProp;
    MaterialProperty _FallDustColorBlendProp;
    MaterialProperty _FallDustPbrParamProp;
    MaterialProperty _FallDustMetallicProp;
    MaterialProperty _FallDustRoughnessProp;
    MaterialProperty _FallDustNormalProp;
    MaterialProperty _FallDustNormalIntensityProp;
    MaterialProperty _HeightDepthProp;
    MaterialProperty _BlendHeightProp;
    MaterialProperty _FallDustNormalBlendProp;

    //风力动画
    bool _WindAnimToggle;
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //获取当前材质球
        material = materialEditor.target as Material;

        BaseParam(properties);//传递参数
        LoadParam();//读取GUILayout数据
        BaseParamGUI(materialEditor);//PBR基础参数绘制
        // ParallaxGUI(materialEditor);//视察映射参数绘制
        HeightBlendGUI(materialEditor);//高度融合参数绘制

        // WindAnimTGUI(materialEditor);//风力动画
        SaveParam();//保存GUILayout数据

        Other(materialEditor);//其他额外参数绘制
    }
    //将定义好的材质属性传入Shader
    private void BaseParam(MaterialProperty[] properties)
    {
        //PBR材质参数
        _MainTexProp = FindProperty("_MainTex", properties);
        _ColorProp = FindProperty("_Color", properties);
        _EmissionIntensityProp = FindProperty("_EmissionIntensity", properties);
        _PbrParamProp = FindProperty("_PbrParam", properties);
        _MetallicProp = FindProperty("_Metallic", properties);
        _RoughnessProp = FindProperty("_Roughness", properties);
        _NormalProp = FindProperty("_Normal", properties);
        _NormalIntensityProp = FindProperty("_NormalIntensity", properties);
        // //视差映射材质参数
        // _MaxSampleProp = FindProperty("_MaxSample", properties);
        // _MinSampleProp = FindProperty("_MinSample", properties);
        // _SectionStepsProp = FindProperty("_SectionSteps", properties);
        // _PomScaleProp = FindProperty("_PomScale", properties);
        // _HeightScaleProp = FindProperty("_HeightScale", properties);
        //高度融合材质参数

        _FallDustMainTexProp = FindProperty("_FallDustMainTex", properties);
        _FallDustColorProp = FindProperty("_FallDustColor", properties);
        _fallDustEmissionIntensityProp = FindProperty("_fallDustEmissionIntensity", properties);
        _FallDustColorBlendProp = FindProperty("_FallDustColorBlend", properties);
        _FallDustPbrParamProp = FindProperty("_FallDustPbrParam", properties);
        _FallDustMetallicProp = FindProperty("_FallDustMetallic", properties);
        _FallDustRoughnessProp = FindProperty("_FallDustRoughness", properties);
        _FallDustNormalProp = FindProperty("_FallDustNormal", properties);
        _FallDustNormalIntensityProp = FindProperty("_FallDustNormalIntensity", properties);
        _HeightDepthProp = FindProperty("_HeightDepth", properties);
        _BlendHeightProp = FindProperty("_BlendHeight", properties);
        _FallDustNormalBlendProp = FindProperty("_FallDustNormalBlend", properties);

    }

    //保存GUILayout参数数据
    private void LoadParam()
    {
        // _MinSample = (int)_MinSampleProp.floatValue;
        // _MaxSample = (int)_MaxSampleProp.floatValue;

    }

    private void SaveParam()
    {
        // _MinSampleProp.floatValue = _MinSample;
        // _MaxSampleProp.floatValue = _MaxSample;

    }

    //绘制GUI
    private void BaseParamGUI(MaterialEditor materialEditor)
    {
        EditorGUILayout.LabelField("PBR BaseParam", EditorStyles.boldLabel);//头标题
        //颜色贴图  且判断其是否被赋值
        Texture _MainTex = material.GetTexture("_MainTex");
        Texture _PbrParam = material.GetTexture("_PbrParam");
        Texture _Normal = material.GetTexture("_Normal");


        if (_MainTex != null)
        {
            if (_PbrParam != null)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("颜色贴图"), _MainTexProp, _ColorProp, _EmissionIntensityProp);//绘制主颜色纹理GUI
            }
            else
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("颜色贴图"), _MainTexProp, _ColorProp);
                _EmissionIntensityProp.floatValue = 0.0f;
            }
            material.EnableKeyword("_MAINTEX_ON");
        }
        else
        {
            if (_PbrParam != null)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("颜色贴图"), _MainTexProp, _ColorProp, _EmissionIntensityProp);//绘制主颜色纹理GUI
            }
            else
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("颜色贴图"), _MainTexProp, _ColorProp);
                _EmissionIntensityProp.floatValue = 0.0f;
            }

            material.DisableKeyword("_MAINTEX_ON");

        }

        //Pbr参数贴图 且判断其是否被赋值
        if (_PbrParam != null)
        {
            materialEditor.TexturePropertySingleLine(new GUIContent("参数贴图"), _PbrParamProp);//绘制PBR参数纹理GUI
            material.EnableKeyword("_PBRPARAM_ON");
        }
        else
        {
            materialEditor.TexturePropertySingleLine(new GUIContent("参数贴图"), _PbrParamProp, _RoughnessProp, _MetallicProp);//绘制PBR参数纹理GUI
            material.DisableKeyword("_PBRPARAM_ON");
        }

        //法线贴图 且判断其是否被赋值

        if (_Normal != null)
        {
            materialEditor.TexturePropertySingleLine(new GUIContent("法线贴图"), _NormalProp, _NormalIntensityProp);//绘制法线纹理GUI
            material.EnableKeyword("_NORMAL_ON");
        }
        else
        {
            materialEditor.TexturePropertySingleLine(new GUIContent("法线贴图"), _NormalProp);//绘制法线纹理GUI
            material.DisableKeyword("_NORMAL_ON");
        }
        if (_MainTex || _PbrParam || _Normal != null)
        {
            materialEditor.TextureScaleOffsetProperty(_MainTexProp);//绘制主颜色纹理Tiling Offset
        }
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(10);
    }
    //视差映射
    /* private void ParallaxGUI(MaterialEditor materialEditor)
     {

         _ParallaxToggle = material.IsKeywordEnabled("_PARALLAX_ON") ? true : false; //读取Keywords数据
         _ParallaxToggle = EditorGUILayout.BeginToggleGroup("PARALLAX", _ParallaxToggle);
         if (_ParallaxToggle)
         {
             material.EnableKeyword("_PARALLAX_ON");
             EditorGUILayout.LabelField("Min Max Sample", EditorStyles.boldLabel);//头标题
             EditorGUILayout.MinMaxSlider(ref _MinSample, ref _MaxSample, 1.0f, 10.0f);//采样次数
             EditorGUILayout.BeginHorizontal();//开始布局，将布局内的内容横向排放
             materialEditor.FloatProperty(_MinSampleProp, "");//绘制_MinSample的参数，但是他不能调整，依靠上面的范围滑动条来调整参数，这里仅为了方便复制参数数值
             materialEditor.FloatProperty(_MaxSampleProp, "");//绘制_MaxSample的参数，但是他不能调整，依靠上面的范围滑动条来调整参数，这里仅为了方便复制参数数值
             EditorGUILayout.EndHorizontal();//结束布局

             materialEditor.RangeProperty(_PomScaleProp, "PomScale");
             materialEditor.FloatProperty(_SectionStepsProp, "SectionSteps");
             materialEditor.RangeProperty(_HeightScaleProp, "HeightScale");
         }
         else
         {
             material.DisableKeyword("_PARALLAX_ON");
         }
         EditorGUILayout.EndToggleGroup();
         EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线
         EditorGUILayout.EndVertical();
         EditorGUILayout.Space(10);
     }*/
    //高度融合
    private void HeightBlendGUI(MaterialEditor materialEditor)
    {
        _FallDustToggle = material.IsKeywordEnabled("_FALLDUST_ON") ? true : false; //读取Keywords数据
        _FallDustToggle = EditorGUILayout.BeginToggleGroup("FALLDUST", _FallDustToggle);
        if (_FallDustToggle)
        {
            material.EnableKeyword("_FALLDUST_ON");
            Texture _FallDustMainTex = material.GetTexture("_FallDustMainTex");
            if (_FallDustMainTex != null)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("高度颜色贴图"), _FallDustMainTexProp, _FallDustColorProp, _fallDustEmissionIntensityProp);
                material.EnableKeyword("_FALLDUST_MAINTEX_ON");
            }
            else
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("高度颜色贴图"), _FallDustMainTexProp, _FallDustColorProp);//绘制主颜色纹理GUI
                material.DisableKeyword("_FALLDUST_MAINTEX_ON");
                _fallDustEmissionIntensityProp.floatValue = 0.0f;
            }
            Texture _FallDustPbrParam = material.GetTexture("_FallDustPbrParam");
            if (_FallDustPbrParam != null)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("高度参数贴图"), _FallDustPbrParamProp);
                material.EnableKeyword("_FALLDUST_PBRPARAM_ON");
            }
            else
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("高度参数贴图"), _FallDustPbrParamProp, _FallDustRoughnessProp, _FallDustMetallicProp);
                material.DisableKeyword("_FALLDUST_PBRPARAM_ON");
            }

            Texture _FallDustNormal = material.GetTexture("_FallDustNormal");
            if (_FallDustNormal != null)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("高度法线贴图"), _FallDustNormalProp, _FallDustNormalIntensityProp,_FallDustNormalBlendProp);
                material.EnableKeyword("_FALLDUST_NORMAL_ON");
            }
            else
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("高度法线贴图"), _FallDustNormalProp);
                material.DisableKeyword("_FALLDUST_NORMAL_ON");
            }

            if (_FallDustMainTex || _FallDustPbrParam || _FallDustNormal != null)
            {
                materialEditor.TextureScaleOffsetProperty(_FallDustMainTexProp);//绘制主颜色纹理Tiling Offset
            }
            materialEditor.RangeProperty(_FallDustColorBlendProp, "高度融合透明度");
            materialEditor.RangeProperty(_HeightDepthProp, "高度融合软硬度");
            // if (_ParallaxToggle)
            // {
            //     materialEditor.RangeProperty(_BlendHeightProp, "ParallaxHeight");
            // }
        }
        else
        {

            material.DisableKeyword("_FALLDUST_ON");
        }

        EditorGUILayout.EndToggleGroup();
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(10);

    }
    //风力动画
    private void WindAnimTGUI(MaterialEditor materialEditor)
    {
        _WindAnimToggle = material.IsKeywordEnabled("_WINDANIMTOGGLE_ON") ? true : false;
        _WindAnimToggle = EditorGUILayout.BeginToggleGroup("WIND_ANIM", _WindAnimToggle);
        if (_WindAnimToggle)
        {
            material.EnableKeyword("_WINDANIMTOGGLE_ON");
        }
        else
        {
            material.DisableKeyword("_WINDANIMTOGGLE_ON");
        }
        EditorGUILayout.EndToggleGroup();
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(10);

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
