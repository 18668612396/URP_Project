using UnityEngine;

[ExecuteAlways]
public class UsingFloat : MonoBehaviour
{

    public testScript test;
    // Start is called before the first frame update
    public float Float01;
    public Gradient gradient;

    // void Awake()
    // {
    //    test.Float01 = Float01 ;
    //    test.gradient =  gradient ;
    // }
    private void Update()
    {
        Float01 = test.Float01 ;
        test.gradient = gradient;
    }
}
