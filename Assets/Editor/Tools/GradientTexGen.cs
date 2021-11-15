using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

using System.IO;
using System.Collections;

namespace mattatz.Utils
{

    public class GradientTexGen
    {


        public static Texture2D Create(Gradient grad, int width = 128, int height = 16)
        {
            var gradTex = new Texture2D(width, height, TextureFormat.ARGB32, false);
            gradTex.filterMode = FilterMode.Bilinear;
            float inv = 1f / (width - 1);
            for (int y = 0; y < height; y++)
            {
                for (int x = 0; x < width; x++)
                {
                    var t = x * inv;
                    Color col = grad.Evaluate(t);
                    gradTex.SetPixel(x, y, col);
                }
            }
            gradTex.Apply();
            return gradTex;
        }
    }

#if UNITY_EDITOR
    public class GradientTexCreator : EditorWindow
    {

        [SerializeField] Gradient gradient;

        [SerializeField] string fileName = "Gradient";

        [MenuItem("Custom/GradientTex")]
        static void Init()
        {
            EditorWindow.GetWindow(typeof(GradientTexCreator));
        }

        void OnGUI()
        {
            EditorGUI.BeginChangeCheck();
            SerializedObject so = new SerializedObject(this);
            EditorGUILayout.PropertyField(so.FindProperty("gradient"), true, null);
            if (EditorGUI.EndChangeCheck())
            {
                so.ApplyModifiedProperties();
            }

            Texture2D GradientTex = new Texture2D(128, 16);
            if (GUILayout.Button("Save"))
            {
                // string path = EditorUtility.SaveFolderPanel("Select an output path", "", "");
                // if (path.Length > 0)
                // {
                GradientTex = GradientTexGen.Create(gradient, GradientTex.width, GradientTex.height);
                byte[] pngData = GradientTex.EncodeToPNG();
                File.WriteAllBytes("Assets/Editor/Tools/test.tga", pngData);
                AssetDatabase.Refresh();
                // }
            }

            Shader.SetGlobalTexture("_Gradient", GradientTex);
 
        }

        private void Update()
        {

        }
    }
#endif

}

