
Shader "City/NormalDiffuse"
{
	Properties
	{
		[KeywordEnum(Day,Night)] _Type ("模式", int) = 0

		[Space(20)]
		_MainTex ("diffuse", 2D) = "white" {}
		_Color("Color",Color)=(1,1,1,1)		
		
		[Space(20)]
		_NightMaskTex ("night mask", 2D) = "white" {}

		[Space(20)]
		//_Emission("自发光颜色",Color)=(1,1,1,1)
		_EmInstity("自发光强度",Range(0,15))=1		

		[Space(20)]
		[KeywordEnum(on, off)] _SpcSwitch ("高光反射", int) = 0
		_EnvMap("环境贴图",Cube)="white"{}
		_SpecNoise("反射扰动图",2D)="white"{}
		_SpeColor("_SpecColor",Color)=(1,1,1,1)
		_Gloss("高光参数(越大高光面越大)",Range(0,1))=0.5
		_refracIntensity("反射强度",Range(0.1,1))=0.1
		_distributeIntensity("反射扰动强度",Range(0,1))=0.5

		[Space(20)]
		[Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Float) = 1	
	
		[HideInInspector]_MinAtten("_MinAtten",Range(0.1,1))=0.5		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Cull [_Cull]

		Pass
		{
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma multi_compile_fwdbase	  

			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag			
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "../../CommonCg/MyCgInclude.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 normal:NORMAL;				
				float2 lmuv : TEXCOORD1;//lightmap in uv1
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv:TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				#ifndef LIGHTMAP_OFF
				half2 lmUV : TEXCOORD3;
				#endif
				float3 vlight : TEXCOORD4;
				SHADOW_COORDS(5)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;

			sampler2D _NightMaskTex;
			float4 _NightMaskTex_ST;

			//float4 _Emission;
			float _EmInstity;

			int _SpcSwitch;
			sampler2D _SpecNoise;
			samplerCUBE _EnvMap;
			float4 _SpeColor;
			float _Gloss;
			float _refracIntensity;
			float _distributeIntensity;

			int _Type;
			float _MinAtten;


			v2f vert(appdata v) {

			 	v2f o;

			 	o.pos = UnityObjectToClipPos(v.vertex);
			 	
			 	o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.vlight=vertexLight(o.worldNormal);
			 	
			 	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.uv.xy=TRANSFORM_TEX(v.uv,_MainTex);

				o.uv.zw=TRANSFORM_TEX(v.uv,_NightMaskTex);

				#ifndef LIGHTMAP_OFF
				o.lmUV = v.lmuv.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
			 	
			 	TRANSFER_SHADOW(o);
			 	
			 	return o;
			}

			fixed4 frag(v2f i) : SV_Target {				

				float3 ablode=tex2D(_MainTex,i.uv.xy);
				float3 worldNormal = normalize(i.worldNormal);
				float3 finalCol;
				float3 emssion;

				int day= step(0.9,_Type);// 0 day 1 night

				//ambient
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//spec
				int specSwitch = step(_SpcSwitch, 0.9);
				float offset = tex2D(_SpecNoise,i.uv.xy).r*_distributeIntensity;//aculate spec disturbance
				float3 disturbanceOffset = float3(offset,offset,0);
				fixed3 worldRef = getWorldReflect(worldNormal, i.worldPos+disturbanceOffset);
				fixed4 refCol = texCUBE(_EnvMap, worldRef);
				_SpeColor.xyz *= refCol;
				float gloss = lerp(13, 5, _Gloss);
				float3 specular = BPhongSpec(worldNormal, i.worldPos, _SpeColor.xyz, gloss)*_refracIntensity;
				specular = lerp(float3(0, 0, 0), specular, specSwitch);

				#ifdef LIGHTMAP_OFF

				//diff
				float3 diffuse=HalfLambert_DiffLight(worldNormal,i.worldPos,_Color);

				//if non-light,default vertex light
				diffuse=max(i.vlight,diffuse);

				//shadow
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				atten=clamp(atten,_MinAtten,1);


				//blend
				//finalCol=ambient + (ablode*diffuse +specular);
				finalCol= ablode*diffuse+specular;

				#elif LIGHTMAP_ON
				float3 lm = DecodeLightmap (UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmUV.xy));

				ambient*=lerp(1,0.5,day);//night emssion weak

				//finalCol=ablode*lm*_Color+ambient+specular;
				finalCol=ablode*lm*_Color+specular;
				//finalCol = ablode * lm*_Color;
				
				#endif

				//bright windows emssion
				float3 mask=tex2D(_NightMaskTex,i.uv.zw);
				float m=step(0.0001,mask.r);//0y 1n
				emssion=mask*(1+_EmInstity);
				emssion=lerp(finalCol,emssion,0.5);//blend col
				finalCol=lerp(finalCol,emssion,day*m);

				
				return float4(finalCol, 1.0);
			}
			ENDCG
		}
	}
	FallBack "Standard"
}
