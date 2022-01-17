using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ColorTintRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;//在后处理前执行我们的颜色校正
        public Shader shader;//汇入shader
    }
    public Settings settings = new Settings();//开放设置
    ColorTintPass colorTintPass;//设置渲染pass
    public override void Create()//新建pass
    {
        this.name = "ColorTintPass";//名字
        colorTintPass = new ColorTintPass(RenderPassEvent.AfterRenderingPostProcessing,Shader.Find("PostProcess/ColorTint"));//初始化
    }
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)//Pass逻辑
    {
        colorTintPass.Setup(renderer.cameraColorTarget);//初始化
        renderer.EnqueuePass(colorTintPass);//汇入队列
    }
}

//【执行pass】
public class ColorTintPass :ScriptableRenderPass
{
    static readonly string k_RenderTag = "ColorTint Effects";//设置tags
    static readonly int MainTexId = Shader.PropertyToID("_MainTex");//设置主贴图
    static readonly int TempTargetId = Shader.PropertyToID("_TempTargetColorTint");//设置暂存贴图

    ColorTint colorTint;//提供一个Volume传递位置
    Material colorTintMaterial;//后处理使用材质
    RenderTargetIdentifier currentTarget;//设置当前渲染目标

    #region 设置渲染事件
    public ColorTintPass(RenderPassEvent evt,Shader ColorTintShader)
    {
        renderPassEvent = evt;//设置渲染事件位置
        var shader = ColorTintShader;//汇入shader
        //不存在则返回
        if (shader == null)
        {
            Debug.LogError("不存在ColorTint shader");
            return;
        }
        colorTintMaterial = CoreUtils.CreateEngineMaterial(ColorTintShader);//新建材质
    }
    #endregion

    #region 初始化
    public void Setup(in RenderTargetIdentifier currentTarget)
    {
        this.currentTarget = currentTarget;
    }
    #endregion

    #region 执行
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (colorTintMaterial == null)//材质是否存在
        {
            Debug.LogError("材质初始化失败");
            return;
        }
        //摄像机关闭后处理
        if (!renderingData.cameraData.postProcessEnabled)
        {
            return;
        }
        //【渲染设置】
        var stack = VolumeManager.instance.stack;//传入volume数据
        colorTint = stack.GetComponent<ColorTint>();//拿到我们的Volume
        if (colorTint == null)
        {
            Debug.LogError("Volume组件获取失败");
            return;
        }

        var cmd = CommandBufferPool.Get(k_RenderTag);//设置抬头
        Render(cmd, ref renderingData);//设置渲染函数
        context.ExecuteCommandBuffer(cmd);//执行函数
        CommandBufferPool.Release(cmd);//释放
    }
    #endregion

    #region 渲染
    void Render(CommandBuffer cmd,ref RenderingData renderingData)
    {
        ref var cameraData = ref renderingData.cameraData;//汇入摄像机数据 
        var camera = cameraData.camera;//传入摄像机数据
        var source = currentTarget;//当前渲染图片汇入
        int destination = TempTargetId;//渲染目的地

        colorTintMaterial.SetColor("_ColorTint", colorTint._Color.value);//汇入颜色校正
        cmd.SetGlobalTexture(MainTexId, source);//汇入当前渲染图片
        cmd.GetTemporaryRT(destination, cameraData.camera.scaledPixelWidth, cameraData.camera.scaledPixelHeight, 0, FilterMode.Trilinear, RenderTextureFormat.Default);//设置目标贴图
        cmd.Blit(source, destination);//设置后处理
        cmd.Blit(destination, source, colorTintMaterial, 0);//传入颜色校正
    }
    #endregion
}
