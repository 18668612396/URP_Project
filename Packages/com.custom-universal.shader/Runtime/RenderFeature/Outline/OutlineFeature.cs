using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class OutlineFeature : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        public RenderTargetIdentifier source;
        private Material material;
        private RenderTargetHandle tempRenderTargetHandler;
        public CustomRenderPass(Material material)
        {
            this.material = material;
            tempRenderTargetHandler.Init("_TemporaryColorTexture");
        }
        //这个方法在执行渲染传递之前被调用。  
        //它可以被用来配置渲染目标和它们的清晰状态。 也创建临时渲染目标纹理。  
        //当此渲染通道为空时，将渲染到活动相机的渲染目标。  
        //你不应该调用CommandBuffer.SetRenderTarget。 而是调用<c>ConfigureTarget</c>和<c> configuclear </c>。  
        //渲染管道将确保目标设置和清除以一种性能方式发生。  
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
        }

        //在这里你可以实现渲染逻辑。  
        //使用<c>ScriptableRenderContext</c>发出绘图命令或执行命令缓冲区  
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html  
        //你不需要调用ScriptableRenderContext。 提交时，呈现管道将在管道中的特定点调用它。
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer commandBuffer = new CommandBuffer();

            commandBuffer.GetTemporaryRT(tempRenderTargetHandler.id, renderingData.cameraData.cameraTargetDescriptor);
            Blit(commandBuffer,source, tempRenderTargetHandler.Identifier(), material);
            Blit(commandBuffer, tempRenderTargetHandler.Identifier(), source);
            context.ExecuteCommandBuffer(commandBuffer);
            commandBuffer.Release();
        }

        //清除在执行渲染传递过程中创建的任何已分配资源。  
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }
    [System.Serializable]
    public class Setting 
    {
        public Material material = null;
    }
    public Setting setting = new Setting();
    CustomRenderPass m_ScriptablePass;

    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass(setting.material);

        //配置渲染通道的注入位置。  
        m_ScriptablePass.renderPassEvent = RenderPassEvent.BeforeRenderingPrePasses;
    }

    //这里你可以在渲染器中注入一个或多个渲染通道。  
    //这个方法在每个相机设置渲染器时被调用。  
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        m_ScriptablePass.source = renderer.cameraColorTarget;
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


