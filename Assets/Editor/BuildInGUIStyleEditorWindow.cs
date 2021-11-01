using UnityEngine;
using UnityEditor;

namespace taecg.tools
{
    public class EditorStyleViewer : EditorWindow
    {
        private Vector2 scrollPosition = Vector2.zero;

        [MenuItem("Window/内置GUI样式大全")]
        public static void Init()
        {
            EditorWindow.GetWindow(typeof(EditorStyleViewer), false, "内置GUI样式大全");
        }

        void OnGUI()
        {
            scrollPosition = GUILayout.BeginScrollView(scrollPosition);

            foreach (GUIStyle style in GUI.skin)
            {
                EditorGUILayout.Space();
                GUILayout.BeginHorizontal();

                if (GUILayout.Button(style.name, style))
                {
                    EditorGUIUtility.systemCopyBuffer = "\"" + style.name + "\"";
                }
                EditorGUILayout.TextField(style.name);
                EditorGUILayout.EndHorizontal();
            }

            GUILayout.EndScrollView();

            Repaint();
        }
    }
}