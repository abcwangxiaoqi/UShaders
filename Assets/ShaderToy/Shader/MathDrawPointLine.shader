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
			#include "../../CommonCg/MyCgInclude.cginc"

			#define vec2 float2
    		#define vec3 float3
    		#define vec4 float4
			#define mat2 float2x2
			#define mat3 float3x3
			#define mat4 float4x4
			#define iGlobalTime _Time.y
			#define mod fmod
			#define mix lerp
			#define fract frac
			#define texture2D tex2D
			#define iResolution _ScreenParams
			#define gl_FragCoord ((_iParam.scrPos.xy/_iParam.scrPos.w) * _ScreenParams.xy)

			
			#define PI2 6.28318530718
			#define pi 3.14159265358979
			#define halfpi (pi * 0.5)
			#define oneoverpi (1.0 / pi)
			#define fragCoord

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
				float2 uv = shaderToyUv(i.vertex.xy,1,1);

				return circle(uv,float2(0,0),0.9,float4(1,0,0,0));
			}
			ENDCG
		}
	}
}
