using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Projection : MonoBehaviour {

    public Camera cam;

    public RenderTexture depthRenderTexture;

    CommandBuffer cmd;

    public Transform target;

    private void Awake()
    {
        cam.depthTextureMode = DepthTextureMode.DepthNormals;

        cam.targetTexture = depthRenderTexture;
    }

    private void OnWillRenderObject()
    {         

        cmd = new CommandBuffer();
        cmd.name = "get depth tex";

        int depthID = Shader.PropertyToID("_GlobalDepthTex");

        cmd.GetTemporaryRT(depthID, -1, -1, 0, FilterMode.Bilinear);
        cmd.Blit(BuiltinRenderTextureType.CurrentActive, depthID);
        
        cmd.Blit(depthID, depthRenderTexture);

        cmd.ReleaseTemporaryRT(depthID);

    

        cmd.SetGlobalTexture("_GlobalDepthTex", depthID);
        cam.AddCommandBuffer(CameraEvent.AfterForwardOpaque, cmd);
    }

        // Use this for initialization
        void Start () {

        Camera.main.transform.LookAt(target);

    }
}
