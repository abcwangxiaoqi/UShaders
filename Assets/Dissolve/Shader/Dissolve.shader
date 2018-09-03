Shader "Unlit/Dissolve"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Noise("_Noise",2D)="white"{}
		_Progress("_Progress",Range(0,1))=0
		_DissolveColor("_DissolveColor",Color)=(1,1,1,1)
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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Noise; 
			float4 _Noise_ST;
			float4 _DissolveColor;
			float _Progress;
			float _Speed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed4 burn=tex2D(_Noise,i.uv);

				float clipV=burn.r-_Progress;

				clip(clipV);

				float t=smoothstep(0,0.2,clipV);

				col.xyz=lerp(col.xyz,_DissolveColor,1-t);

				return col;
			}
			ENDCG
		}
	}
}
