using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace XM.Editor
{
    public class AssetBundleCreator : EditorWindow
    {
        [MenuItem("Tools/Build Asset Bundle")]
        public static void BuildAssetBundle()
        {
            var win = GetWindow<AssetBundleCreator>("Build Asset Bundle");
            win.Show();
        }

        [SerializeField]//必须要加
        protected List<Gradient> _assetLst = new List<Gradient>();

        //序列化对象
        protected SerializedObject _serializedObject;
        //序列化属性
        protected SerializedProperty _assetLstProperty;


        protected void OnEnable()
        {
            //使用当前类初始化
            _serializedObject = new SerializedObject(this);
            //获取当前类中可序列话的属性
            _assetLstProperty = _serializedObject.FindProperty("_assetLst");
        }

        protected void OnGUI()
        {
            //更新
            _serializedObject.Update();

            //开始检查是否有修改
            EditorGUI.BeginChangeCheck();

            //显示属性
            //第二个参数必须为true，否则无法显示子节点即List内容
            EditorGUILayout.PropertyField(_assetLstProperty, true);

            //结束检查是否有修改
            if (EditorGUI.EndChangeCheck())
            {//提交修改
                _serializedObject.ApplyModifiedProperties();
            }
        }
    }
}