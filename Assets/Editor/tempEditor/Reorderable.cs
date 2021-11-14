using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditorInternal;
using System;
 
[Serializable]
public class Element : ScriptableObject
{
    public Texture icon;
    public string name;
    public int hp;
    public Vector3 position;
}
 
public class Reorderable : EditorWindow
{
 
    ReorderableList reorderableList;
    List<Element> data = new List<Element>();
 
    [MenuItem("Tools/Reorderable")]
    static void Open()
    {
        EditorWindow.GetWindow<Reorderable>().Show();
    }
 
    void OnEnable()
    {
        reorderableList = new ReorderableList(data, typeof(Element));
 
        //设置单个元素的高度
        reorderableList.elementHeight = 85;
 
        //绘制单个元素
        reorderableList.drawElementCallback = OnElementCallback;
 
        //背景色
        reorderableList.drawElementBackgroundCallback = OnElementBackgroundCallback;
 
        //头部
        reorderableList.drawHeaderCallback = OnHeaderCallback;
 
    }
 
    private void OnHeaderCallback(Rect rect)
    {
        EditorGUI.LabelField(rect, "reorderableList");
    }
 
    private void OnElementBackgroundCallback(Rect rect, int index, bool isActive, bool isFocused)
    {
        GUI.color = Color.yellow;
    }
 
    private void OnElementCallback(Rect rect, int index, bool isActive, bool isFocused)
    {
        if (data.Count <= 0)
            return;
        data[index].icon = (Texture)EditorGUI.ObjectField(new Rect(rect.x, rect.y, 70, 70), data[index].icon, typeof(Texture),false);
        data[index].name = EditorGUI.TextField(new Rect(rect.x+80, rect.y , rect.width - 100, 20),"name", data[index].name);
        data[index].hp = EditorGUI.IntSlider(new Rect(rect.x + 80, rect.y+30, rect.width -100, 20), "hp" ,data[index].hp, 0, 100);
        EditorGUI.PrefixLabel(new Rect(rect.x + 80, rect.y + 60, rect.width - 100, 20), new GUIContent("pos"));
        data[index].position = EditorGUI.Vector3Field(new Rect(rect.x + 120, rect.y + 60, rect.width - 120, 20),"", data[index].position);
    }
 
    private void OnGUI()
    {
        reorderableList.DoLayoutList();
    }
}