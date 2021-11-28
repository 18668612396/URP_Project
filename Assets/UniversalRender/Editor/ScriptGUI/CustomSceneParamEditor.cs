using UnityEditor;
using UnityEngine;
using CustomURP_Runtime;



namespace CustomURP_Runtime
{

    [CustomEditor(typeof(SceneParam))]
    public class CustomSceneParamEditor : Editor
    {


        private void OnEnable()
        {

            GrassParam();
        }
        public override void OnInspectorGUI()
        {
            //base.OnInspectorGUI();
            serializedObject.Update();//更新

            GrassParamGUI();//绘制草的参数
            serializedObject.ApplyModifiedProperties();//存储
        }


     

        ///<吸色草参数>
        SerializedProperty _BaseTexProp;
        SerializedProperty _ColorTex0Prop;//雾的颜色
        SerializedProperty _Color0_STProp;//雾的密度
        SerializedProperty _ColorTex1Prop;//雾的颜色
        SerializedProperty _Color1_STProp;//雾的密度
        SerializedProperty _ColorTex2Prop;//雾的颜色
        SerializedProperty _Color2_STProp;//雾的密度
        SerializedProperty _ColorTex3Prop;//雾的颜色
        SerializedProperty _Color3_STProp;//雾的密度
        SerializedProperty _GrassParamProp;
        private void GrassParam()
        {
            _BaseTexProp = serializedObject.FindProperty("_BaseTex");
            _ColorTex0Prop = serializedObject.FindProperty("_ColorTex0");
            _Color0_STProp = serializedObject.FindProperty("_Color0_ST");
            _ColorTex1Prop = serializedObject.FindProperty("_ColorTex1");
            _Color1_STProp = serializedObject.FindProperty("_Color1_ST");
            _ColorTex2Prop = serializedObject.FindProperty("_ColorTex2");
            _Color2_STProp = serializedObject.FindProperty("_Color2_ST");
            _ColorTex3Prop = serializedObject.FindProperty("_ColorTex3");
            _Color3_STProp = serializedObject.FindProperty("_Color3_ST");
            _GrassParamProp = serializedObject.FindProperty("_GrassParam");
        }
        private void GrassParamGUI()
        {
            
            EditorGUILayout.PropertyField(_GrassParamProp, new GUIContent("GRASS_PARAM"));
            if (_GrassParamProp.boolValue == true)
            {
                EditorGUILayout.PropertyField(_BaseTexProp, new GUIContent("地表分层贴图"));
                EditorGUILayout.PropertyField(_ColorTex0Prop, new GUIContent("地表贴图01"));
                EditorGUILayout.PropertyField(_Color0_STProp, new GUIContent("地表贴图01重复率,跟地表保持一致"));
                EditorGUILayout.PropertyField(_ColorTex1Prop, new GUIContent("地表贴图02"));
                EditorGUILayout.PropertyField(_Color1_STProp, new GUIContent("地表贴图02重复率,跟地表保持一致"));
                EditorGUILayout.PropertyField(_ColorTex2Prop, new GUIContent("地表贴图03"));
                EditorGUILayout.PropertyField(_Color2_STProp, new GUIContent("地表贴图03重复率,跟地表保持一致"));
                EditorGUILayout.PropertyField(_ColorTex3Prop, new GUIContent("地表贴图04"));
                EditorGUILayout.PropertyField(_Color3_STProp, new GUIContent("地表贴图04重复率,跟地表保持一致"));
            }
            EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线
            EditorGUILayout.EndVertical();
            EditorGUILayout.Space(10);
        }
        ///<-------------------------------------------------------------->


    }
}




