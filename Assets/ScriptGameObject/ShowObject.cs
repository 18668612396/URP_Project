using UnityEngine;
using System.Collections;

// 生成入口到Unity菜单Assets->Create下
[CreateAssetMenu(menuName = "Create ShowObject")]
public class ShowObject : ScriptableObject
{
    public Vector3 position;
    [Space(20)] // 注意，ShowObject需要单独一个文件，并且文件名与类名一致，[]属性才能有效。
    public string  label;
    [Range(0, 10)] // 注意，ShowObject需要单独一个文件，并且文件名与类名一致，[]属性才能有效。
    public int     intData;
    public bool    isCheck;
    public Options options;
    public Shader  defaultShader;

    public enum Options
    {
        Opt1,
        Opt2,
        Opt3,
    }
}