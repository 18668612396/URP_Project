using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "Rendering/CustomRenderPipeline/Pipeline Asset(Forward Render)")]

public class CustomRenderPineAsset : RenderPipelineAsset
{
    protected override RenderPipeline CreatePipeline()
    {
       return new CustomRenderPipeline();
    }
}