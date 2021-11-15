using UnityEngine;
using UnityEditor;
using System.IO;

public class Gradient_NPR_Ramp : EditorWindow
{
    //角色阴影
    public static Texture2D Create(
    Gradient night_Hand,
    Gradient night_Soft,
    Gradient night_Metal,
    Gradient night_Silk,
    Gradient night_Skin,
    Gradient day_Hand,
    Gradient day_Soft,
    Gradient day_Metal,
    Gradient day_Silk,
    Gradient day_Skin,
     int width = 128, int height = 30)
    {


        var RampTex = new Texture2D(width, height, TextureFormat.ARGB32, false);
        RampTex.filterMode = FilterMode.Bilinear;
        float inv = 1f / (width - 1);

        NPR_Gradient(RampTex, night_Hand, width, inv, 0, 1, 2);
        NPR_Gradient(RampTex, night_Soft, width, inv, 3, 4, 5);
        NPR_Gradient(RampTex, night_Metal, width, inv, 6, 7, 8);
        NPR_Gradient(RampTex, night_Silk, width, inv, 9, 10, 11);
        NPR_Gradient(RampTex, night_Skin, width, inv, 12, 13, 14);
        NPR_Gradient(RampTex, day_Hand, width, inv, 15, 16, 17);
        NPR_Gradient(RampTex, day_Soft, width, inv, 18, 19, 20);
        NPR_Gradient(RampTex, day_Metal, width, inv, 21, 22, 23);
        NPR_Gradient(RampTex, day_Silk, width, inv, 24, 25, 26);
        NPR_Gradient(RampTex, day_Skin, width, inv, 27, 28, 29);

        RampTex.Apply();
        return RampTex;
    }

    static void NPR_Gradient(Texture2D RampTex, Gradient gradient, int width, float inv, int index01, int index02, int index03)
    {

        for (int x = 0; x < width; x++)
        {

            var t = x * inv;
            Color col = gradient.Evaluate(t);
            RampTex.SetPixel(x, index01, col);
        }
        for (int x = 0; x < width; x++)
        {

            var t = x * inv;
            Color col = gradient.Evaluate(t);
            RampTex.SetPixel(x, index02, col);
        }
        for (int x = 0; x < width; x++)
        {

            var t = x * inv;
            Color col = gradient.Evaluate(t);
            RampTex.SetPixel(x, index03, col);
        }
    }


    [MenuItem("Custom/GradientTex")]
    private static void ShowWindow()
    {
        var window = GetWindow<Gradient_NPR_Ramp>();
        window.titleContent = new GUIContent("Gradient_NPR_Ramp");
        window.Show();

    }
    public NPR_RampData m_NPR_RampData;




    void OnGUI()
    {
        m_NPR_RampData = EditorGUILayout.ObjectField("", m_NPR_RampData, typeof(NPR_RampData), false) as NPR_RampData;//Ramp数据文件

        GradientDay_GUI();
        EditorGUILayout.Space(10);
        EditorGUILayout.BeginHorizontal(new GUIStyle("horizontalscrollbarthumb"));//绘制分割线 
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space(20);
        GradientNight_GUI();

        Texture2D GradientTex = new Texture2D(128, 30);
        if (GUILayout.Button("Save"))
        {
            // string path = EditorUtility.SaveFolderPanel("Select an output path", "", "");

            // if (path.Length > 0)
            // {
            GradientTex = Gradient_NPR_Ramp.Create(night_Hand, night_Soft, night_Metal, night_Silk, night_Skin, day_Hand, day_Soft, day_Metal, day_Silk, day_Skin, GradientTex.width, GradientTex.height);
            byte[] pngData = GradientTex.EncodeToPNG();
            File.WriteAllBytes("Assets/Editor/Tools/test.tga", pngData);
            AssetDatabase.Refresh();
            // }
        }
        GradientTex.Apply();
        Shader.SetGlobalTexture("_Gradient", GradientTex);


        SceneView.RepaintAll();
    }

    ///<白天GUI>
    [SerializeField] Gradient day_Skin;//白天皮肤
    [SerializeField] Gradient day_Silk;//白天丝绸
    [SerializeField] Gradient day_Metal;//白天金属
    [SerializeField] Gradient day_Soft;//白天软体
    [SerializeField] Gradient day_Hand;//白天硬体
    private void GradientDay_GUI()
    {
        day_Skin = m_NPR_RampData.day_Skin;
        m_NPR_RampData.day_Skin = EditorGUILayout.GradientField("白天皮肤", day_Skin);

        day_Silk = m_NPR_RampData.day_Silk;
        m_NPR_RampData.day_Silk = EditorGUILayout.GradientField("白天丝绸", day_Silk);

        day_Metal = m_NPR_RampData.day_Metal;
        m_NPR_RampData.day_Metal = EditorGUILayout.GradientField("白天金属", day_Metal);

        day_Soft = m_NPR_RampData.day_Soft;
        m_NPR_RampData.day_Soft = EditorGUILayout.GradientField("白天软体", day_Soft);

        day_Hand = m_NPR_RampData.day_Hand;
        m_NPR_RampData.day_Hand = EditorGUILayout.GradientField("白天硬体", day_Hand);
    }
    ///<晚上GUI>
    [SerializeField] Gradient night_Skin;//晚上皮肤
    [SerializeField] Gradient night_Silk;//晚上丝绸
    [SerializeField] Gradient night_Metal;//晚上金属
    [SerializeField] Gradient night_Soft;//晚上软体
    [SerializeField] Gradient night_Hand;//晚上硬体
    private void GradientNight_GUI()
    {
        night_Skin = m_NPR_RampData.night_Skin;
        m_NPR_RampData.night_Skin = EditorGUILayout.GradientField("晚上皮肤", night_Skin);

        night_Silk = m_NPR_RampData.night_Silk;
        m_NPR_RampData.night_Silk = EditorGUILayout.GradientField("晚上丝绸", night_Silk);

        night_Metal = m_NPR_RampData.night_Metal;
        m_NPR_RampData.night_Metal = EditorGUILayout.GradientField("晚上金属", night_Metal);

        night_Soft = m_NPR_RampData.night_Soft;
        m_NPR_RampData.night_Soft = EditorGUILayout.GradientField("晚上软体", night_Soft);

        night_Hand = m_NPR_RampData.night_Hand;
        m_NPR_RampData.night_Hand = EditorGUILayout.GradientField("晚上硬体", night_Hand);
    }
    private void Update()
    {

    }
}




