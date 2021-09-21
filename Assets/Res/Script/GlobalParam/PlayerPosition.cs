using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class PlayerPosition : MonoBehaviour
{
    
    void Update()
    {
        Shader.SetGlobalVector("_PlayerPos", transform.position);

    }
}
