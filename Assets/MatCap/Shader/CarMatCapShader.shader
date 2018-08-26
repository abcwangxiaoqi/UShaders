
Shader "Unlit/CarMatCapShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MatCap("MatCap", 2D) = "white" {}
        _metalChannel("金属反射度",Range(0,1))=1
        _glassChannel("玻璃反射度",Range(0,1))=0
        _MatCapFactor("MatCapFactor", Range(0,5)) = 1
        _EnvTex("环境(CubeMap)", Cube) = "_SkyBox" {}

        [KeywordEnum(normal,fixation)] _Type ("类型", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float2 maskuv:TEXCOORD2;//对mask采用的uv 存在第三套uv上
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;//主纹理uv存xy,matCapUv存在zw
                float4 vertex : SV_POSITION;
                float3 RefDir : TEXCOORD1;
                float2 maskUv:TEXCOORD2;
            };

            sampler2D _MainTex;
			sampler2D _EnvMcTex;
            float4 _MainTex_ST;
            sampler2D _MatCap;
            half _MatCapFactor;
            samplerCUBE _EnvTex;
            float _metalChannel;
            float _glassChannel;
            float _Type;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.maskUv.xy = TRANSFORM_TEX(v.maskuv, _MainTex);

                //transfer to view
                float2 fixTypeUV;
                fixTypeUV.x=dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), normalize(v.normal));
                fixTypeUV.y=dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), normalize(v.normal));

                //transfer to world
                float2 norTypeUV;
                norTypeUV.xy=UnityObjectToWorldNormal(v.normal).xy;

                //adjust type
                o.uv.zw=lerp(norTypeUV,fixTypeUV,_Type);

                //matcap uv must be 0~1
                o.uv.zw = o.uv.zw * 0.5 + 0.5;//(-1,1)->(0,1)

                float3 wolrdN = UnityObjectToWorldNormal(v.normal);
                o.RefDir = reflect(-WorldSpaceViewDir(v.vertex), wolrdN);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv.xy);

                fixed4 mapCapCol = tex2D(_MatCap, i.uv.zw);
				float4 ref =  tex2D(_EnvMcTex, i.uv.zw);
                fixed4 reflection = texCUBE(_EnvTex, i.RefDir);

                float3 mask = tex2D(_MainTex, i.maskUv.xy);

                float metal =step(0.1,mask.r);//red metal
                float glass =step(0.1,mask.g);//green glass

                reflection=reflection*metal*_metalChannel+reflection*glass*_glassChannel;

                col.rgb =col.rgb * mapCapCol.g * _MatCapFactor + reflection.rgb;

                return col;
            }
            ENDCG
        }
    }
}