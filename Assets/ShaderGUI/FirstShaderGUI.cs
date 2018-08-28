using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

public class FirstShaderGUI : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {

        // render the default gui
        base.OnGUI(materialEditor, properties);

        Material targetMat = materialEditor.target as Material;

        // see if redify is set, and show a checkbox
        bool CS_BOOL = Array.IndexOf(targetMat.shaderKeywords, "CS_BOOL") != -1;

        EditorGUI.BeginChangeCheck();

        CS_BOOL = EditorGUILayout.Toggle("CS_BOOL", CS_BOOL);
        if (EditorGUI.EndChangeCheck())
        {
            // enable or disable the keyword based on checkbox
            if (CS_BOOL)
            {
                targetMat.EnableKeyword("CS_BOOL");
            }                
            else
            {
                targetMat.DisableKeyword("CS_BOOL");
            }                
        }
    }
}
