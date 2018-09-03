Shader "Unlit/FrameAnim"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Row("row",float)=4
		_Column("col",float)=4
		_Speed("speed",Range(1,100))=100
	}
	SubShader
	{
		Tags {"Queue"="Transparent" "RenderType"="Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
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
			uint _Row;
			uint _Column;
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
				float2 uv = i.uv;
				
				//得到每个小图的采样坐标
				//一张图的采样坐标范围是【0，1】，那么每个小图的采样坐标范围就是除以行数和列数
				float2 cell=float2(uv.x/_Column,uv.y/_Row);
 
                //总数
                int count = _Row * _Column;
 
                //取余数 得到当前索引位置
                int SpriteIndex = fmod(_Time.y*_Speed,count);
 
                //Y索引位置
                int SpriteRowIndx = (SpriteIndex / _Column);
 
                //X索引位置
                int SpriteColumnIndex = fmod(SpriteIndex,_Column);

                //因uv坐标左下角为（0,0），第一行为最底下一行，为了合乎我们常理，我们转换到最上面一行为第一行,eg:0,1,2-->2,1,0
				//索引从0开始 所以要-1
				SpriteRowIndx=_Row-SpriteRowIndx-1;
 
                //乘以1.0转为浮点数,不然加号右边，整数除以整数，还是整数（有误）
				//float2(SpriteColumnIndex*1.0 / _Column,SpriteRowIndx*1.0 / _Row) 确定是那张图 UV
				//cell 小图的UV
				//小图的UV偏移 + 整体的UV偏移=最终UV
				uv.xy=cell+float2(SpriteColumnIndex*1.0 / _Column,SpriteRowIndx*1.0 / _Row);
 
                half4 c = tex2D(_MainTex,uv);
                return c;
			}
			ENDCG
		}
	}
}
