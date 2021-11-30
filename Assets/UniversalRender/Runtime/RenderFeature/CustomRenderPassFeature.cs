using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomRenderPassFeature : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        //这个方法在执行渲染传递之前被调用。  
        //它可以用来配置渲染目标和它们的清除状态。 还可以创建临时渲染目标纹理。  
        //当这个渲染通道为空时，它将渲染到激活的相机渲染目标。  
        //你不应该调用CommandBuffer.SetRenderTarget。 相反调用<c>ConfigureTarget</c>和<c>ConfigureClear</c>。  
        //渲染管道将确保目标设置和清除以一种性能方式发生。  
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
        }

        //在这里你可以实现渲染逻辑。  
        //使用<c>ScriptableRenderContext</c>发出绘图命令或执行命令缓冲区  
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html  
        //你不必调用ScriptableRenderContext。 提交，渲染管道将在管道中的特定点调用它。 
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
        }

        //清除渲染传递执行过程中创建的所有已分配资源。  
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }

    CustomRenderPass m_ScriptablePass;

    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass();
        //设置渲染通道注入的位置  
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    //这里你可以在渲染器中注入一个或多个渲染通道。  
    //这个方法在设置渲染器时每相机调用一次。  
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


