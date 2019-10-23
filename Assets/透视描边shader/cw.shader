Shader "Unlit/cw"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeColor("Edge Color",Color) = (1,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

         Pass
        {
            Name "CROSSWALL"

            ZTest greater
            Blend OneMinusDstColor One
            ZWrite off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;

			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
            fixed4 _EdgeColor ;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                //没有颜色 设置默认色
                int f = step(0,_EdgeColor.r);  
                _EdgeColor = lerp(_EdgeColor,fixed4(1,0,0,1),f);
                    

                float NdotV = 1 - clamp(dot(i.normal, i.viewDir),0,1);
				return _EdgeColor*NdotV;
			}

            ENDCG
        }

    }
}
