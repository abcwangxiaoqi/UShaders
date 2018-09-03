Shader "Unlit/Billboard"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// Need to disable batching because of the vertex animation
		Tags { "RenderType"="Opaque"  "DisableBatching"="True"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			float3 bill(float3 right,float3 up,float3 normal,float3 offset,float3 local)
			{
				float4x4 matix=(right.x,up.x,normal.x,offset.x,
								right.y,up.y,normal.y,offset.y,
								right.z,up.z,normal.z,offset.z,
								0,0,0,1);

				return mul(matix,float4(local,1));
			}

			v2f vert (appdata v)
			{
				v2f o;

				// Suppose the center in object space is fixed
				float3 center = float3(0, 0, 0);
				float3 viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos, 1));
				
				float3 normalDir = normalize(viewer - center);//得到N向量
				float3 upDir = float3(0, 1, 0);
				float3 rightDir = normalize(cross(upDir, normalDir));//得到R向量
				upDir = normalize(cross(normalDir, rightDir));//得到up向量
				
				float3 centerOffs = v.vertex.xyz - center;//得到偏移值

				//位移后的本地坐标
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;
				//float3 localPos =bill(rightDir,upDir,normalDir,centerOffs,center);
              
				o.vertex = UnityObjectToClipPos(float4(localPos, 1));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
