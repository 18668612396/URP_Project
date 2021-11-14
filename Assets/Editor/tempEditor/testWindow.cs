
using UnityEditor;
using UnityEngine;

public class TestWindow:EditorWindow
{
    [MenuItem("Demos/ChildWindow")]
    static void OpenWindow()
    {
        GetWindow<TestWindow>();
    }

    Rect windowRect = new Rect(20, 20, 120, 50);

    private void OnGUI()
    {
        BeginWindows();
        windowRect = GUILayout.Window(0, windowRect, DoMyWindow, "My Window");
        EndWindows();
    }

    void DoMyWindow(int windowID)
    {
        if (GUILayout.Button("Hello World"))
        {
            Debug.Log("Got a click");
        }
    }
}
