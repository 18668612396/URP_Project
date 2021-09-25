using System;
using UnityEngine;
using CustomURP_Runtime;
using Object = UnityEngine.Object;
using Random = UnityEngine.Random;

namespace CustomURP_Runtime
{ 
    [ExecuteAlways]
    public class PlayerPosition : MonoBehaviour
    {

        void Update()
        {
            Shader.SetGlobalVector("_PlayerPos", transform.position);

        }
    }
}
