
using UnityEditor;

public class EditorWindows : EditorWindow
{
    private Editor editor;
    [MenuItem("ExtendingEditor/ShowObject Window")]
    public static void ShowObjectWindow() 
    {
       var window =  EditorWindow.GetWindow<EditorWindows>(true, "ShowObject Window", true);
       window.editor = Editor.CreateEditor(ScriptableWizard.CreateInstance<ShowObject>());
    }
    public ShowObject showObject;
    private void OnGUI() 
    {
        showObject = new ShowObject(){};
        this.editor.OnInspectorGUI();
    }
}