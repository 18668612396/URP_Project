using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


namespace EditorExtension
{
    public class ShowCustomWindow : EditorWindow
    {

        [MenuItem("EditorExtension/02.EditorWindow/01.ShowCustomWindow")]
        static void ShowEditorWindow()
        {
            GetWindow<ShowCustomWindow>().Show();
        }
        enum toolsbar
        {
            water
        }

        int bar;
        private void OnGUI()
        {

            bar = GUILayout.Toolbar((int)bar, new[] { "water", "2" });
            GUILayout.Label("Hello GUI");

            if (bar == 0)
            {
                GUILayout.Label("hellow0");
            }


        }


    }

}