using UnityEngine;
using UnityEditor;
public class EditorWindows : EditorWindow
{
    private Editor editor;

    [MenuItem("ExtendingEditor/ShowObject Window")]
    public static void ShowObjectWindow() 
    {
        var window = EditorWindow.GetWindow<EditorWindows>(true, "ShowObject Window", true);
        // 直接根据ScriptableObject构造一个Editor
        window.editor = Editor.CreateEditor(ScriptableObject.CreateInstance<EditorWindows>());
    }
        
    private void OnGUI() 
    {
        // 直接调用Inspector的绘制显示
        this.editor.OnInspectorGUI();
    }
}