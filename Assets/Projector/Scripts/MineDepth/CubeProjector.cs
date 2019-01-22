﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class CubeProjector : MonoBehaviour {

    private Mesh m_mineMesh;
    private Material m_mineMat;

    private float m_size;
    private float m_nearClip;
    private float m_farClip;
    private float m_aspect;

    private Matrix4x4 m_worldToProjector;

    // Use this for initialization
    void Start () {
        Camera.main.depthTextureMode |= DepthTextureMode.Depth;
    }
	
	// Update is called once per frame
	void Update () {

        //box 是个投影器
        //设置投射的矩阵的 近裁剪面和远裁剪面
        BoxCollider collider = this.GetComponent<BoxCollider>();
        this.m_size = collider.size.x / 2;
        this.m_nearClip = -collider.size.x / 2;
        this.m_farClip = collider.size.x / 2;
        this.m_aspect = 1;

        //计算投射矩阵
        Matrix4x4 projector = default(Matrix4x4);
        projector = Matrix4x4.Ortho(-m_aspect * m_size, m_aspect * m_size, -m_size, m_size, m_nearClip, m_farClip);
       
        //计算 齐次坐标空间 到 世界坐标空间的矩阵
        m_worldToProjector = projector * this.transform.worldToLocalMatrix;

        MeshRenderer mr = this.GetComponent<MeshRenderer>();
        mr.sharedMaterial.SetMatrix("_WorldToProjector", m_worldToProjector);
    }
}
