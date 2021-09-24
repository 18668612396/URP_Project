using System;
using UnityEngine;
using CustomURP_Shader;
using Object = UnityEngine.Object;
using Random = UnityEngine.Random;

namespace CustomURP_Shader
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
