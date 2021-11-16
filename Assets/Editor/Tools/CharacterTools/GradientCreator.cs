using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
public class GradientCreator : EditorWindow
{
    [MenuItem("Tools/AssetsEditor/GradientCreator &_c")]
    private static void ShowWindow()
    {
        var window = GetWindow<GradientCreator>();
        window.titleContent = new GUIContent("GradientCreator");
        window.Show();
    }

    ///<绘制面板>
    private int _GradientWidth = 128;//每一条渐变的宽度
    private int _GradientHeight = 4;//每一条渐变的高度
    public GradientCreatorData _GradientData;
    private Texture2D _GradientMap;
    private string _ShaderPropName;
    private void OnGUI()
    {
        _GradientData = EditorGUILayout.ObjectField("GradientData", _GradientData, typeof(GradientCreatorData), false) as GradientCreatorData;
        _GradientWidth = _GradientData._GradientWidth;
        _ShaderPropName = _GradientData._ShaderPropName;
        _GradientData._ShaderPropName = EditorGUILayout.TextField("预览(Shader纹理变量名)", _ShaderPropName);
        KeyworldGUI();
        GradientListGUI();


        _GradientMap = Create(_Gradient, _GradientWidth, _Gradient.Count * _GradientHeight);
        _GradientMap.wrapMode = TextureWrapMode.Clamp;
        Shader.SetGlobalTexture(_ShaderPropName, _GradientMap);
        SceneView.RepaintAll();
        Save();
    }

    ///<绘制渐变控制列表>
    [SerializeField]//必须要加
    protected List<Gradient> _Gradient = new List<Gradient>();
    protected SerializedObject _serializedObject;    //序列化对象
    protected SerializedProperty _assetLstProperty;   //序列化属性
    private void GradientListGUI()//绘制列表
    {
        _Gradient = _GradientData._Gradient;
        _serializedObject.Update();
        //开始检查是否有修改
        EditorGUI.BeginChangeCheck();
        EditorGUILayout.PropertyField(_assetLstProperty, true);//显示属性 //第二个参数必须为true，否则无法显示子节点即List内容
        if (EditorGUI.EndChangeCheck())//结束检查是否有修改
        {
            _serializedObject.ApplyModifiedProperties();//提交修改
        }
    }
    ///<存储纹理>
    string _GradientName;

    string[] MapFormat = { "TGA", "PNG", "JPG" };
    int FormatIndex = 0;
    private void Save()
    {



        _GradientData._GradientWidth = EditorGUILayout.IntField("每条渐变宽度(像素)", _GradientWidth);
        _GradientHeight = _GradientData._GradientHeight;
        _GradientData._GradientHeight = EditorGUILayout.IntField("每条渐变高度(像素)", _GradientHeight);


        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("纹理名称", GUILayout.Width(100));
        _GradientName = _GradientData._GradientName;
        _GradientData._GradientName = EditorGUILayout.TextArea(_GradientName);
        FormatIndex = EditorGUILayout.Popup(FormatIndex, MapFormat, GUILayout.Width(100));
        string _Format = ".tga";
        if (FormatIndex == 0)
            _Format = ".tga";
        if (FormatIndex == 1)
            _Format = ".tga";
        if (FormatIndex == 2)
            _Format = ".jpg";
        EditorGUILayout.EndHorizontal();

        if (GUILayout.Button("Save"))
        {
            string path = EditorUtility.SaveFolderPanel("Select an output path", "", "");

            if (_GradientData != null)
            {
                _GradientData._Gradient = this._Gradient;
            }

            byte[] pngData = _GradientMap.EncodeToPNG();
            File.WriteAllBytes(path + "/" + _GradientName + _Format, pngData);
            AssetDatabase.Refresh();
        }
    }

    ///<Shader内的宏控制>
    string _KeywordName = "_DEBUGGRADIENT_ON";
    
    private void KeyworldGUI()
    {
        _KeywordName = _GradientData._KeywordName;
        _GradientData._KeywordName = EditorGUILayout.TextField("预览(Shader内宏开关名)",_KeywordName);
    }

    ///<序列化属性列表>
    private void OnEnable()
    {
        _serializedObject = new SerializedObject(this);//使用当前类初始化
        _assetLstProperty = _serializedObject.FindProperty("_Gradient");

        Shader.EnableKeyword(_KeywordName);
    }

    private void OnDisable()
    {
        Shader.DisableKeyword(_KeywordName);
    }

    ///<生成纹理函数>
    Texture2D Create(List<Gradient> Gradient, int width = 32, int height = 1)
    {
        var _GradientMap = new Texture2D(width, height, TextureFormat.ARGB32, false);
        _GradientMap.filterMode = FilterMode.Bilinear;
        float inv = 1f / (width - 1);

        int eachHeight = height / 1;
        if (Gradient.Count != 0)
        {
            eachHeight = height / Gradient.Count;
        }

        int howMany = 0;
        while (howMany != Gradient.Count)
        {
            int start = height - eachHeight * howMany - 1;
            int end = start - eachHeight;
            for (int y = start; y > end; y--)
            {
                for (int x = 0; x < width; x++)
                {
                    var t = x * inv;
                    Color col = Gradient[howMany].Evaluate(t);
                    _GradientMap.SetPixel(x, y, col);
                }
            }
            howMany++;
        }
        _GradientMap.Apply();
        return _GradientMap;
    }
}