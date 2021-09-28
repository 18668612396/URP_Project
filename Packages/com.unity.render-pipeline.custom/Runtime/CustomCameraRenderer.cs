using UnityEngine;
using UnityEngine.Rendering;

public class CustomCameraRenderer
{
    ScriptableRenderContext context;

    Camera camera;

    public void Render(ScriptableRenderContext context, Camera camera)
    {
        this.context = context;
        this.camera = camera;

        SetupCamera();
        DrawVisibleGeomentry();
        Submit();//提交缓冲区命令
    }

    //设置缓冲区
    const string bufferName = "Render Camera";
    CommandBuffer buffer = new CommandBuffer { name = bufferName };

    void SetupCamera()
    {
        context.SetupCameraProperties(camera);
        buffer.ClearRenderTarget(true, true, Color.clear);
        buffer.BeginSample(bufferName);//开始采样
        ExecuteBuffer();


    }

    void DrawVisibleGeomentry()
    {
        context.DrawSkybox(camera);

    }

    void Submit()
    {
        buffer.EndSample(bufferName);//结束采样
        ExecuteBuffer();
        context.Submit();
    }

    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }






}