using UnityEngine;

[ExecuteAlways]
public class UsingFloat : MonoBehaviour
{

    public ScriptObject test;
    // Start is called before the first frame update
    public float floatdd;
    // Update is called once per frame
    void Update()
    {
        test.test = floatdd;
        floatdd = test.test;
    }
}
