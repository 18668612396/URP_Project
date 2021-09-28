using UnityEngine;
using UnityEngine.Rendering;

public class CustomCameraRenderer
{
    ScriptableRenderContext context;

    Camera camera;

    public void Render(ScriptableRenderContext context,Camera camera)
    {
        this.context = context;
        this.camera = camera;
    }
}