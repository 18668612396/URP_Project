using UnityEditor;
using UnityEngine;

namespace EditorExtensions
{
    public class MenuItemExample
    {
        //创建菜单栏
        [MenuItem("EditorExtensions/01.Menu/01.HelloEditor")]
        static void helloEditor()
        {
            Debug.Log("hello");
        }
        //打开网络链接
        [MenuItem("EditorExtensions/01.Menu/02.OpenBlibili %e")]
        static void OpenBilibili()
        {
            Application.OpenURL("www.baidu.com");
        }
        //打开OpenPersistenDataPath目录
        [MenuItem("EditorExtensions/01.Menu/03.OpenPersistenDataPath")]
        static void OpenPersistenDataPath()
        {
            EditorUtility.RevealInFinder(Application.persistentDataPath);
        }
        //打开自定义目录
        [MenuItem("EditorExtensions/01.Menu/04.OpenCustomPath")]
        static void OpenCustomPath()
        {
            EditorUtility.RevealInFinder(Application.dataPath.Replace("Assets", "Assets/Editor/MenuItemExample")); //前者为上级目录 后者为目标目录
        }
        //带有开关属性的菜单栏
        private static bool OpenShotCut = false;
        [MenuItem("EditorExtensions/01.Menu/05.快捷键开关")]
        static void ToggleShotCut()
        {
            OpenShotCut = !OpenShotCut;
            Menu.SetChecked("EditorExtensions/01.Menu/05.快捷键开关", OpenShotCut);
            Debug.Log(OpenShotCut);
        }
        //创建菜单栏
        [MenuItem("EditorExtensions/01.Menu/06.HelloEditor  _c")]
        static void HelloEditorWithShotCut()
        {
            Debug.Log("HelloEditorWithShotCut");
        }

    }
}

