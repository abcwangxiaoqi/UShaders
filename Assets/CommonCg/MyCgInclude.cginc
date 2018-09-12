#ifndef MY_CG_INCLUDE
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles

#include "UnityCG.cginc"
#include "Lighting.cginc"  

#define MY_CG_INCLUDE

	/*
	获取深度值 
	为什么要1-d ？
	因为 深度越深，越接近黑色，就越趋近于0；深度越潜，越接近白色，就越趋近于1	
	*/
	inline float getDepth(sampler2D Tex,float2 uv)
	{
		return 1-Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(Tex, uv)));
	}

	//视角与法线夹角
	inline float DotViewAndNormal(in float3 worldNormal,in float3 worldPos)
	{
		float3 wNormal=normalize(worldNormal);
		float3 viewDir=normalize(UnityWorldSpaceViewDir(worldPos));
		return dot(wNormal,viewDir);
	}

	inline float3 normalToClip(in float3 normal)
	{
		
        float3 viewNormal= mul((float3x3)UNITY_MATRIX_IT_MV, normal);
		float3 clipNormal=mul((float3x3)UNITY_MATRIX_P, viewNormal);
		return clipNormal;
	}

	/*得到位移矩阵
	1	0	0	TX
	0	1	0	TY
	0	0	1	TZ
	0	0	0	1
	*/
	inline float4x4 MoveMatrix(in float4 trans)
	{
		return float4x4(1,0,0,trans.x,
						0,1,0,trans.y,
						0,0,1,trans.z,
						0,0,0,1
						);
	}

	/*缩放矩阵
		放大缩小矩阵
		SX   0    0    0
		0    SY	 0    0
		0     0   SZ   0
		0     0    0    1
	*/
	inline float4x4 ScaleMatrix(in float4 scale)
	{
		return float4x4(scale.x, 0, 0, 0,
						0, scale.y, 0, 0,
						0, 0, scale.z, 0,
						0, 0, 0, 1
						);
	}

	/*
	2d 旋转矩阵
	cosN -sinN
	sinN cosN
	*/
	inline float2x2 twoDRoundMatrix(in float angle)
	{
		float rady=radians(angle);
		float sinN=sin(rady);
		float cosN=cos(rady);

		return float2x2(cosN,-sinN,
						sinN,cosN);
	}

	//绕X轴旋转矩阵
	/*
	绕X旋转矩阵 X表示旋转角度
	1     0    	 0      0
	0	 cosX  -sinX    0
	0    sinX   cosX    0
	0	  0      0      1
	*/
	inline float4x4 roundXMatrix(in float angle)
	{
		float rady=radians(angle);
		float sinN=sin(rady);
		float cosN=cos(rady);


		return float4x4(1,0,0,0,
						0,cosN,-sinN,0,
						0,sinN,cosN,0,
						0,0,0,1);
	}	

	//绕Y轴旋转矩阵
	/*
	绕Y旋转矩阵 Y表示旋转角度
	cosY    0    sinY    0
	0       1      0     0
	-sinY   0    cosY    0
	0       0      0     1
	*/
	inline float4x4 roundYMatrix(in float angle)
	{
		float rady=radians(angle);
		float sinN=sin(rady);
		float cosN=cos(rady);


		return float4x4(cosN,0,sinN,0,
						0,1,0,0,
						-sinN,0,cosN,0,
						0,0,0,1);
	}

	//绕Z轴旋转矩阵
	/*
	绕Z旋转矩阵 Z表示旋转角度
	cosZ    -sinZ    0    0
	sinZ     cosZ    0    0
	0          0     1    0
	0          0     0    1
	*/
	inline float4x4 roundZMatrix(in float angle)
	{
		float rady=radians(angle);
		float sinN=sin(rady);
		float cosN=cos(rady);


		return float4x4(cosN,-sinN,0,0,
						sinN,cosN,0,0,
						0,0,1,0,
						0,0,0,1);
	}

	//旋转矩阵
	/*
	绕x,y,z旋转矩阵是上面三个矩阵的相乘得到
	cosYcosZ					-cosYcosZ					sinY				0
	cosXsinZ + sinXsinYcosZ		cosXcosZ - sinXsinYsinZ		-sinXcosY			0
	sinXsinZ - cosXsinYcosZ		sinXcosZ + cosXsinYsinZ		cosXcosY			0
	0							0							0					1
	*/
	inline float4x4 roundMatrix(in float3 rot)
	{
		float radx=radians(rot.x);
		float rady=radians(rot.y);
		float radz=radians(rot.z);

		float sinx=sin(radx);
		float cosx=cos(radx);
		float siny=sin(rady);
		float cosy=cos(rady);
		float sinz=sin(radz);
		float cosz=cos(radz);

		return float4x4(cosy*cosz,-cosy*sinz,siny,0,
						cosx*sinz+sinx*siny*cosz,cosx*cosz-sinx*siny*sinz,-sinx*cosy,0,
						sinx*sinz-cosx*siny*cosz,sinx*cosz+cosx*siny*sinz,cosx*cosy,0,
						0,0,0,1);
				
	}

	//lambert light model
	inline float Lambert(in float3 worldNormal,in float3 worldPos)
	{
		worldNormal=normalize(worldNormal);
		float3 worldLightDir=normalize(UnityWorldSpaceLightDir(worldPos));
		fixed lambert = max(0.0, dot(worldNormal, worldLightDir));  
		return lambert;
	}

	inline float3 Lambert_DiffLightAmbient(in float3 worldNormal,in float3 worldPos,in float3 diffuse,in float3 ambient)
	{
		float lambert=Lambert(worldNormal,worldPos);
		return lambert*diffuse+ambient;
	}

	inline float3 Lambert_DiffLight(in float3 worldNormal,in float3 worldPos,in float3 diffuse)
	{
		float lambert=Lambert(worldNormal,worldPos);
		return lambert*diffuse;
	}

	//half lambert light model
	inline float HalfLambert(in float3 worldNormal,in float3 worldPos)
	{
		worldNormal=normalize(worldNormal);
		float3 worldLightDir=normalize(UnityWorldSpaceLightDir(worldPos));
		fixed lambert =  0.5 * dot(worldNormal, worldLightDir) + 0.5;
		return lambert;
	}

	inline float3 HalfLambert_DiffLightAmbient(in float3 worldNormal,in float3 worldPos,in float3 diffuse,in float3 ambient)
	{
		float lambert=HalfLambert(worldNormal,worldPos);
		return lambert*diffuse;
		return lambert*diffuse*_LightColor0.xyz+ambient;
	}

	inline float3 HalfLambert_DiffLight(in float3 worldNormal,in float3 worldPos,in float3 diffuse)
	{
		float lambert=HalfLambert(worldNormal,worldPos);
		return lambert*diffuse*_LightColor0.xyz;
	}

	//unity 自带环境光
	inline float3 unityAmbient(in float3 diffuse)
	{
		return UNITY_LIGHTMODEL_AMBIENT.xyz * diffuse.xyz;
	}

	//菲涅尔系数 一种经验公式
	/*
	由于真实的菲尼尔公式计算量较多。在游戏里往往会用简化版的公式来提升效率达到近似的效果
	fresnel = fresnel基础值 + fresnel缩放量*pow( 1 - dot( N, V ), 5 )
	*/
	inline float getFresnel(in float fresnelBase,in float fresnelScale,in float3 worldNormal,in float3 worldPos,in float fresnelIndensity)
	{
		float f=fresnelBase+fresnelScale*pow(1-DotViewAndNormal(worldNormal,worldPos),fresnelIndensity);
		return f;
	}

	/*
	BPhong Spec 
	*/
	inline float3 BPhongSpecLight(in float3 worldLightDir,in float3 worldNormal,in float3 worldPos,in float3 _Color,in float _Gloss)
	{
		float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
		float3 halfDir = normalize(worldLightDir + viewDir);
		float3 specular = _Color.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
		return specular;
	}

	/*
	BPhong Spec 
	*/
	inline float3 BPhongSpec(in float3 worldNormal,in float3 worldPos,in float3 _Color,in float _Gloss)
	{
		float3 worldLightDir=normalize(UnityWorldSpaceLightDir(worldPos));
		return BPhongSpecLight(worldLightDir,worldNormal,worldPos,_Color,_Gloss);
	}

	inline float3 PhongSpecLight(in float3 worldLightDir,in float3 worldNormal,in float3 worldPos,in float3 _Color,in float _Gloss)
	{
		float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

		float diff = saturate(dot(worldLightDir, worldNormal));

		float3 reflection = normalize(2.0 * worldNormal * diff - worldLightDir);//反射向量
        float3 specular = _Color.rgb * pow(max(0, dot(reflection, viewDir)), _Gloss);

		return specular;
	}

	/*
	Phong Spec

	R = 2*N(dot(N, L)) - L
	Spec = pow( max(0 ,cos<R, V>), gloss)
	*/
	inline float3 PhongSpec(in float3 worldNormal,in float3 worldPos,in float3 _Color,in float _Gloss)
	{
		float3 worldLightDir=normalize(UnityWorldSpaceLightDir(worldPos));
		return PhongSpecLight(worldLightDir,worldNormal,worldPos,_Color,_Gloss);
	}

	/*
	get reflect vec
	used in texCUBE
	*/
	inline float3 getWorldReflect(in float3 worldNormal,in float3 worldPos)
	{
		float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
		return reflect(-viewDir,worldNormal);
	}


	/*self illumin*/
	inline float3 selfIllumin(in float3 tex)
	{
		return float3(0.299*tex.r,0.587*tex.g,0.114*tex.b);
	}

	/*get vertex light color*/
	inline float3 vertexLight(in float3 worldNormal)
	{
		return ShadeSH9(float4(normalize(worldNormal),1));
	}

	
	/*
	center 0表示(0,0)点在左下角 1表示(0,0)点在屏幕中心
	scale 0表示uv不根据屏幕分辨率缩放，1则相反
	*/
	inline float2 shaderToyUv(in float2 vertex , in int center ,in int scale)
	{
		float2 uv = lerp(vertex.xy/ _ScreenParams.xy,
						-1.0 + 2.0*vertex.xy/ _ScreenParams.xy,
						center);

		uv.x = lerp(uv.x,uv.x*(_ScreenParams.x/ _ScreenParams.y),scale);

		return uv;
	}
#endif