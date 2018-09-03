Shader "Unlit/OcclusionDissolve"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseMap("Noise Map", 2D) = "white"{}
		_DissolveWidth("_DissolveWidth",Range(0.1,1))=0.5
		_ClipDistance("_ClipDistance",float)=20
		_DissolveColor("_DissolveColor",Color)=(1,1,1,1)
		_DissolveRadius("_DissolveRadius",Range(0.1,1))=0.3//消融半径 
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal:NORMAL; 
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldPos:TEXCOORD1;
				float4 screenPos:TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseMap;
			float _DissolveThreshold;
			float _DissolveRadius;
			float _ClipDistance;
			float3 _DissolveColor;
			float _DissolveWidth;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
				o.screenPos=ComputeGrabScreenPos(o.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				//透视除法 求得屏幕坐标
				float2 screenPos=i.screenPos.xy/i.screenPos.w;
				float3 worldPos=i.worldPos;

				//摄像机和当前像素的距离
				float dis=length(worldPos-_WorldSpaceCameraPos);

				//当前像素到屏幕中心点的距离
				float2 dir=float2(0.5,0.5)-screenPos;
				float distance=length(dir);// 0~0.5
				
				//大于剔除距离 则不进行溶解
				float DisFlag=step(dis,_ClipDistance);

				//大于溶解半径 则不进行溶解
				float RadiusFlag=step(distance,_DissolveRadius);

				//噪声图 采样
				fixed3 burn = tex2D(_NoiseMap, i.uv).rgb;	
				
				//根据 噪声r 和 距离范围 clip
				float clipV=burn.r - DisFlag*RadiusFlag*(1-distance/_DissolveRadius);		
				clip(clipV);

				fixed4 col = tex2D(_MainTex, i.uv);

				//smoothstep方法映射范围(0~1) t==0 溶解边界 t==1正常渲染
				float t=smoothstep(0,_DissolveWidth,clipV);

				col.xyz=lerp(col.xyz,_DissolveColor,1-t);
				return col;
			}
			ENDCG
		}
	}
}
