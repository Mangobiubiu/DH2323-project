using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class RainEffect : MonoBehaviour
{
    [Header("RainSetting")]
    public Shader RainShader;
    public Mesh RainMesh;
    public Texture2D RainTexture;
    public Vector4 RainUV = new Vector4(1f,1f,0f,4f);

    [Range(0f, 2f)]
    public float rainColorScale = 0.5f;
    public Color RainColor = Color.grey;

    [Range(0f, 10f)]
    public float LayerLength0 = 2f;
    [Range(1f, 20f)]
    public float LayerLength1 = 6f;

    Material RainMaterial;
    public static RainEffect Instance { get; private set; }

    //lighting
    [Range(0.25f, 4f)]
    public float lightExponent = 1f;
    [Range(0.25f, 4f)]
    public float lightIntensity1 = 1f;
    [Range(0.25f, 4f)]
    public float lightIntensity2 = 1f;

    // Start is called before the first frame update
    private void OnEnable()
    {
        RainMaterial = new Material(RainShader ?? Shader.Find("Effect/RainShader"));
        RainMaterial.hideFlags = HideFlags.DontSave;
        Instance = this;
    }

    void OnDisable()
    {
        DestroyImmediate(RainMaterial);
        RainMaterial = null;
        Instance = null;
    }

    public void Render(Camera cam, RenderTargetIdentifier src, RenderTargetIdentifier dst, CommandBuffer deferredCmds)
    {
        deferredCmds.SetGlobalTexture("_MainTex", src);

        deferredCmds.SetGlobalTexture("_RainTexture", RainTexture);
        deferredCmds.SetGlobalVector("_UVChange", RainUV);

        deferredCmds.SetGlobalVector("_RainColor", RainColor * rainColorScale);

        deferredCmds.SetGlobalVector("_LayerDistances0", new Vector4(LayerLength0, LayerLength1 - LayerLength0, 0, 0));

        //lighting
        deferredCmds.SetGlobalFloat("_LightExponent", lightExponent);
        deferredCmds.SetGlobalFloat("_LightIntensity1", lightIntensity1);
        deferredCmds.SetGlobalFloat("_LightIntensity2", lightIntensity2);

        var obj_matrix = Matrix4x4.TRS(cam.transform.position, transform.rotation, new Vector3(1f, 1f, 1f));

        deferredCmds.SetRenderTarget(dst);
        deferredCmds.DrawMesh(RainMesh, obj_matrix, RainMaterial);
    }
}
