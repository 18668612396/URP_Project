using UnityEngine;


using System.Collections.Generic;
using UnityEditor;


using System.IO;


public class GradientTexCreator : EditorWindow
{
    public static Texture2D Create(List<Gradient> gr, int width = 32, int height = 1)
    {
        var gradTex = new Texture2D(width, height, TextureFormat.ARGB32, false);
        gradTex.filterMode = FilterMode.Bilinear;
        float inv = 1f / (width - 1);

        int eachHeight = height / 1;
        if (gr.Count != 0)
        {
            eachHeight = height / gr.Count;
        }

        int howMany = 0;
        while (howMany != gr.Count)
        {
            for (int y = eachHeight * howMany; y < eachHeight * howMany + eachHeight; y++)
            {
                for (int x = 0; x < width; x++)
                {
                    var t = x * inv;
                    Color col = gr[howMany].Evaluate(t);
                    gradTex.SetPixel(x, y, col);
                }
            }
            howMany++;
        }
        gradTex.Apply();
        return gradTex;
    }

    public List<Gradient> gr = new List<Gradient>();
    int width = 128;
    int height = 16;
    string fileName = "Gradient";

    [MenuItem("Custom/GradientTex")]
    static void Init()
    {
        EditorWindow.GetWindow(typeof(GradientTexCreator));
    }

    public GradientTexScriptableObject scriptableObject;
    void OnGUI()
    {
        scriptableObject = EditorGUILayout.ObjectField("", scriptableObject, typeof(GradientTexScriptableObject), false) as GradientTexScriptableObject;//Ramp数据文件

        using (new GUILayout.HorizontalScope())
        {
            EditorGUI.BeginChangeCheck();
            SerializedObject ser = new SerializedObject(this);
            EditorGUILayout.PropertyField(ser.FindProperty("gr"), true);
            if (scriptableObject != null)
            {
                this.gr = scriptableObject.gr;
            }
            if (EditorGUI.EndChangeCheck())
            {
                ser.ApplyModifiedProperties();
            }
        }

        using (new GUILayout.HorizontalScope())
        {
            GUILayout.Label("width", GUILayout.Width(80f));
            int.TryParse(GUILayout.TextField(width.ToString(), GUILayout.Width(120f)), out width);
        }

        using (new GUILayout.HorizontalScope())
        {
            GUILayout.Label("height", GUILayout.Width(80f));
            int.TryParse(GUILayout.TextField(height.ToString(), GUILayout.Width(120f)), out height);
        }

        using (new GUILayout.HorizontalScope())
        {
            GUILayout.Label("name", GUILayout.Width(80f));
            fileName = GUILayout.TextField(fileName, GUILayout.Width(120f));
            GUILayout.Label(".png");
        }

        Texture2D tex = Create(gr, width, gr.Count * width);
        Shader.SetGlobalTexture("_Gradient", tex);

        SceneView.RepaintAll();
        if (GUILayout.Button("Save"))
        {
            string path = EditorUtility.SaveFolderPanel("Select an output path", "", "");
            if (path.Length > 0)
            {
                if (scriptableObject != null)
                {
                    scriptableObject.gr = this.gr;
                }

                byte[] pngData = tex.EncodeToPNG();
                File.WriteAllBytes(path + "/" + fileName + ".png", pngData);
                AssetDatabase.Refresh();
            }
        }
    }
}

