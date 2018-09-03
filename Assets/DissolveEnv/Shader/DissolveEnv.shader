Shader "Unlit/DissolveEnv"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Noise("_Noise",2D)="white"{}
		_Progress("_Progress",Range(0,1))=0
		_Start("_Start",vector)=(0,0,0,0)
		_MaxDistance("_MaxDistance",float)=1
		_DissolveColor("_DissolveColor",Color)=(1,1,1,1)
		_DistanceEffect("_DistanceEffect",Range(0,1))=1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Cull off

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
				float4 worldPos:TEXCOORD1;
				float4 start:TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Noise; 
			float4 _Noise_ST;
			float4 _DissolveColor;
			float _Progress;
			float _Speed;
			float4 _Start;
			float _MaxDistance;
			float _DistanceEffect;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex);
				o.start=_Start;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture

				float len=length(i.start.xyz-i.worldPos.xyz);

				float yz=1-(len/_MaxDistance);//从外向内

				fixed4 col = tex2D(_MainTex, i.uv);

				fixed4 burn = tex2D(_Noise,i.uv);

				yz=lerp(burn.r,yz,_DistanceEffect);
				
				float clipV=yz-_Progress;

				clip(clipV);//剔除 确定没有的区域	

				//smoothstep方法映射范围(0~1) t==0 溶解边界 t==1正常渲染
				float t=smoothstep(0,0.1,clipV);

				col.xyz=lerp(col.xyz,_DissolveColor,1-t);

				return col;
			}
			ENDCG
		}
	}
}
