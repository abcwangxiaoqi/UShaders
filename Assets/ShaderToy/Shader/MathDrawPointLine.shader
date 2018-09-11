Shader "Unlit/MathDrawPointLine"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			float4 circle(float2 pos, float2 center, float radius, float4 color) 
			{
				if (length(pos-center) < radius)
				 {
					// In the circle
					return float4(1, 1, 1, 1) * color;
				} 
				else 
				{
					return float4(0, 0, 0, 1);
				}
        }


			fixed4 frag (v2f i) : SV_Target
			{				
				float2 uv = -1.0 + 2.0*i.vertex.xy/ _ScreenParams.xy;
				uv.x *= _ScreenParams.x/ _ScreenParams.y ;

				return circle(uv,float2(0,0),0.9,float4(1,0,0,0));

				return 1;
			}
			ENDCG
		}
	}
}
