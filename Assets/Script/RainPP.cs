using System.Collections;
using System.Collections.Generic;
using UnityEngine.Rendering.PostProcessing;


[PostProcess(typeof(RainPPRenderer), PostProcessEvent.BeforeStack, "Effect/PP Rain FX")]

public class RainPP : PostProcessEffectSettings
{
    public override bool IsEnabledAndSupported(PostProcessRenderContext context)
    {
        return base.IsEnabledAndSupported(context) && RainEffect.Instance; // Ensure the prefab of RainEffect in the scene
    }
}

public class RainPPRenderer : PostProcessEffectRenderer<RainPP>
{
    public override void Render(PostProcessRenderContext context)
    {
        RainEffect.Instance.Render(context.camera, context.source, context.destination, context.command);
    }
}