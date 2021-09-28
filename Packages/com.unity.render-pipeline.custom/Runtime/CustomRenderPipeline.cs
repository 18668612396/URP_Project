using UnityEngine;
using UnityEngine.Rendering;


public class CustomRenderPipeline : RenderPipeline
{
    CustomCameraRenderer customRenderer = new CustomCameraRenderer();
    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        foreach (Camera camera in cameras)
        {
            customRenderer.Render(context, camera);
        }
    }
}