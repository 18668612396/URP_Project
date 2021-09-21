using UnityEditor;
using UnityEngine;
[CustomEditor(typeof(SceneParam))]
public class CustomSceneParamEditor : Editor
{


    private void OnEnable()
    {
        WindParam();//风力动画参数
        CloudShadowParam();//云阴影参数
        InteractParam();//植被交互
        FogParam();//绘制雾效GUI
    }
    public override void OnInspectorGUI()
    {
        //base.OnInspectorGUI();
        serializedObject.Update();//更新
        CustomWindParamGUI();//绘制风力动画参数GUI
        CloudShadowParamGUI();//绘制云阴影参数GUI
        InteractParamGUI();//绘制植被交互GUI
        FogParamGUI();//绘制雾效GUI
        serializedObject.ApplyModifiedProperties();//存储
    }


    ///<风力系统参数>
    SerializedProperty _WindAnimToggleProp;
    SerializedProperty _WindDensityProp;
    SerializedProperty _WindSpeedFloatProp;
    SerializedProperty _WindTurbulenceFloatProp; 
    SerializedProperty _WindStrengthFloatProp;
    bool is_WindParam;
    private void WindParam()
    {
        _WindAnimToggleProp = serializedObject.FindProperty("_WindAnimToggle");
        _WindDensityProp = serializedObject.FindProperty("_WindDensity");
        _WindSpeedFloatProp = serializedObject.FindProperty("_WindSpeedFloat");
        _WindTurbulenceFloatProp = serializedObject.FindProperty("_WindTurbulenceFloat");
        _WindStrengthFloatProp = serializedObject.FindProperty("_WindStrengthFloat");
    }
    private void CustomWindParamGUI()
    {
        EditorGUILayout.PropertyField(_WindAnimToggleProp, new GUIContent("WIND_ANIM"));
        if (_WindAnimToggleProp.boolValue == true)
        {
            EditorGUILayout.PropertyField(_WindDensityProp, new GUIContent("风力密度", "风吹动时的抖动速率"));
            EditorGUILayout.PropertyField(_WindSpeedFloatProp, new GUIContent("风力速度", "风吹动时候的摇摆速度"));
            EditorGUILayout.PropertyField(_WindTurbulenceFloatProp, new GUIContent("风力干涉", "风吹动时的干涉强度"));
            EditorGUILayout.PropertyField(_WindStrengthFloatProp, new GUIContent("风力强度", "风吹动时的摇摆幅度"));
        }
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(10);
    }
    ///<-------------------------------------------------------------->

    ///<云阴影参数>
    SerializedProperty _CloudShadowToggleProp;
    SerializedProperty _CloudShadowSizeProp;
    SerializedProperty _CloudShadowRadiusProp;
    SerializedProperty _CloudShadowIntensityProp;
    SerializedProperty _CloudShadowSpeedProp;
    private void CloudShadowParam()
    {
        _CloudShadowToggleProp = serializedObject.FindProperty("_CloudShadowToggle");
        _CloudShadowSizeProp = serializedObject.FindProperty("_CloudShadowSize");
        _CloudShadowRadiusProp = serializedObject.FindProperty("_CloudShadowRadius");
        _CloudShadowIntensityProp = serializedObject.FindProperty("_CloudShadowIntensity");
        _CloudShadowSpeedProp = serializedObject.FindProperty("_CloudShadowSpeed");
    }
    private void CloudShadowParamGUI()
    {
        EditorGUILayout.PropertyField(_CloudShadowToggleProp, new GUIContent("CLOUD_SHADOW"));

        if (_CloudShadowToggleProp.boolValue == true)
        {
            EditorGUILayout.PropertyField(_CloudShadowSizeProp, new GUIContent("云阴影密度", "云阴影的Tile值"));
            EditorGUILayout.PropertyField(_CloudShadowSpeedProp, new GUIContent("云阴影速度", "云阴影的速度"));
            EditorGUILayout.PropertyField(_CloudShadowRadiusProp, new GUIContent("云阴影半径", "风吹动时候的摇摆速度"));
            EditorGUILayout.PropertyField(_CloudShadowIntensityProp, new GUIContent("云阴影强度", "风吹动时的干涉强度"));

        }
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(10);
    }
    ///<-------------------------------------------------------------->
    ///<植被交互参数>
    SerializedProperty _InteractToggleProp;
    SerializedProperty _InteractRadiusProp;
    SerializedProperty _InteractIntensityProp;
    SerializedProperty _InteractHeightProp;
    bool is_Interact;
    private void InteractParam()
    {
        _InteractToggleProp = serializedObject.FindProperty("_InteractToggle");
        _InteractRadiusProp = serializedObject.FindProperty("_InteractRadius");
        _InteractIntensityProp = serializedObject.FindProperty("_InteractIntensity");
        _InteractHeightProp = serializedObject.FindProperty("_InteractHeight");
    }
    private void InteractParamGUI()
    {

        EditorGUILayout.PropertyField(_InteractToggleProp, new GUIContent("INTERACT"));
        if (_InteractToggleProp.boolValue == true)
        {
            EditorGUILayout.PropertyField(_InteractRadiusProp, new GUIContent("植被交互半径", "云阴影的Tile值")); 
            EditorGUILayout.PropertyField(_InteractIntensityProp, new GUIContent("植被交互强度", "云阴影的速度"));
            EditorGUILayout.PropertyField(_InteractHeightProp, new GUIContent("植被交互高度偏移", "风吹动时候的摇摆速度"));
        }
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(10);

    }
    ///<-------------------------------------------------------------->

    ///<大世界雾效参数>
    SerializedProperty _FogToggleProp;//雾效开关
    SerializedProperty _FogColorProp;//雾的颜色
    SerializedProperty _FogGlobalDensityProp;//雾的密度
    SerializedProperty _FogHeightProp;//雾的高度
    SerializedProperty _FogStartDistanceProp;//雾的开始距离
    SerializedProperty _FogInscatteringExpProp;//雾散射指数
    SerializedProperty _FogGradientDistanceProp;//雾的梯度距离
    bool is_Fog;
    private void FogParam()
    {
        _FogColorProp = serializedObject.FindProperty("_FogColor");
        _FogGlobalDensityProp = serializedObject.FindProperty("_FogGlobalDensity");
        _FogHeightProp = serializedObject.FindProperty("_FogHeight");
        _FogToggleProp = serializedObject.FindProperty("_FogToggle");
        _FogStartDistanceProp = serializedObject.FindProperty("_FogStartDistance");
        _FogInscatteringExpProp = serializedObject.FindProperty("_FogInscatteringExp");
        _FogGradientDistanceProp = serializedObject.FindProperty("_FogGradientDistance");
    }
    private void FogParamGUI()
    {

        //  _FogToggleProp.boolValue = EditorGUILayout.BeginToggleGroup("PARALLAX", _FogToggleProp.boolValue);
        EditorGUILayout.PropertyField(_FogToggleProp, new GUIContent("BIGWORLD_FOG"));
        if (_FogToggleProp.boolValue == true)
        {
            EditorGUILayout.PropertyField(_FogColorProp, new GUIContent("雾的颜色"));
            EditorGUILayout.PropertyField(_FogGlobalDensityProp, new GUIContent("雾的密度"));
            EditorGUILayout.PropertyField(_FogHeightProp, new GUIContent("雾的高度"));
            EditorGUILayout.PropertyField(_FogStartDistanceProp, new GUIContent("雾的开始距离"));
            EditorGUILayout.PropertyField(_FogInscatteringExpProp, new GUIContent("雾散射指数"));
            EditorGUILayout.PropertyField(_FogGradientDistanceProp, new GUIContent("雾的渐变距离"));
        }
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(10);
    }
    ///<-------------------------------------------------------------->
}





