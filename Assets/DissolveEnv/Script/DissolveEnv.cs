using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DissolveEnv : MonoBehaviour
{
    public Vector3 dissolveEndPoint;
    [Range(0, 1)]
    public float Progress = 0;
    [Range(0, 1)]
    public float distanceEffect = 0.6f;

    void Start()
    {
        //计算所有子物体到消融开始点的最大距离
        MeshFilter[] meshFilters = GetComponentsInChildren<MeshFilter>();
        float maxDistance = 0;
        for (int i = 0; i < meshFilters.Length; i++)
        {
            float distance = CalculateMaxDistance(meshFilters[i].mesh.vertices);
            if (distance > maxDistance)
                maxDistance = distance;
        }
        //传值到Shader
        MeshRenderer[] meshRenderers = GetComponentsInChildren<MeshRenderer>();
        for (int i = 0; i < meshRenderers.Length; i++)
        {
            meshRenderers[i].material.SetVector("_Start", dissolveEndPoint);
            meshRenderers[i].material.SetFloat("_MaxDistance", maxDistance);
        }
    }

    void Update()
    {
        //传值到Shader，为了方便控制所有子物体Material的值
        MeshRenderer[] meshRenderers = GetComponentsInChildren<MeshRenderer>();
        for (int i = 0; i < meshRenderers.Length; i++)
        {
            meshRenderers[i].material.SetFloat("_Progress", Progress);
            meshRenderers[i].material.SetFloat("_DistanceEffect", distanceEffect);
        }
    }

    //计算给定顶点集到消融开始点的最大距离
    float CalculateMaxDistance(Vector3[] vertices)
    {
        float maxDistance = 0;
        for (int i = 0; i < vertices.Length; i++)
        {
            Vector3 vert = vertices[i];
            float distance = (vert - dissolveEndPoint).magnitude;
            if (distance > maxDistance)
                maxDistance = distance;
        }
        return maxDistance;
    }
}
