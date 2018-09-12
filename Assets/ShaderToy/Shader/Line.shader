Shader "Hidden/Line"
{
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			//#pragma fragment fragStraightLine		
			//#pragma fragment fragCurveLine
			//#pragma fragment fragCurveLine1
			#pragma fragment fragSine
			//#pragma fragment fragCose


			#include "UnityCG.cginc"
			#include "../../CommonCg/MyCgInclude.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
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

			float plot(float2 st, float pct)
			{
				// 0.02 代表 线Y宽度的一半
  				return  smoothstep(pct-0.02, pct, st.y) - smoothstep( pct, pct+0.02, st.y);
			}


			fixed4 fragCose (v2f i) : SV_Target
			{				
				float2 st = shaderToyUv(i.vertex.xy,1,1);

				float y = cos(st.x+_Time.z);

				float3 color = float3(y,y,y);

				// Plot a line
				float pct = plot(st,y);

				color = lerp(color,float3(0.0,1.0,0.0),pct);

				return float4(color,1);
			}

			fixed4 fragSine (v2f i) : SV_Target
			{				
				float2 st = shaderToyUv(i.vertex.xy,1,1);

				float y = sin(st.x+_Time.z);

				float3 color = float3(y,y,y);

				// Plot a line
				float pct = plot(st,y);

				color = lerp(color,float3(0.0,1.0,0.0),pct);

				return float4(color,1);
			}

			fixed4 fragCurveLine1 (v2f i) : SV_Target
			{				
				float2 st = shaderToyUv(i.vertex.xy,0,0);
				
    			float y = smoothstep(0.1,0.9,st.x);// Smooth interpolation between 0.1 and 0.9

				float3 color = float3(y,y,y);

				// Plot a line
				float pct = plot(st,y);

				color = lerp(color,float3(0.0,1.0,0.0),pct);

				return float4(color,1);
			}

			fixed4 fragCurveLine (v2f i) : SV_Target
			{				
				float2 st = shaderToyUv(i.vertex.xy,0,0);

				float y=pow(st.x,5.0); // y = x^5 曲线

				float3 color = float3(y,y,y);

				// Plot a line
				float pct = plot(st,y);

				color = lerp(color,float3(0.0,1.0,0.0),pct);

				return float4(color,1);
			}

			fixed4 fragStraightLine (v2f i) : SV_Target
			{				
				float2 st = shaderToyUv(i.vertex.xy,0,0);

				float y = st.x;  // y=x 直线

				float3 color = float3(y,y,y);

				// Plot a line
				float pct = plot(st,y);

				color = lerp(color,float3(0.0,1.0,0.0),pct);

				return float4(color,1);
			}
			ENDCG
		}
	}
}
