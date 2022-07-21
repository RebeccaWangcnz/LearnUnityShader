// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter7/NormalMapWorldSpace"
{
    Properties
    {
        _DiffuseColor("DiffuseColor",Color)=(1,1,1,1)
        _MainTex("Main Tex",2D)="white"{}
		_BumpMap("Normal Map",2D)="bump"{}
		_BumpScale("Bump Scale",Float)=1.0
		 _SpecularColor("SpecularColor",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
    }
    SubShader
    {
 		Pass
		{
			Tags{"LightMode"="ForwardBase"}
             CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			fixed4 _DiffuseColor;
			sampler2D _MainTex;
			float4 _MainTex_ST;//平移和缩放，其中xy关于缩放tiling，zw关于平移offset
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _SpecularColor;
			float _Gloss;

        	struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;//tangent.w决定第四个方向负切线方向，所以是float4
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;//改成float4为了存储两个纹理坐标
				float4 TtoW0:TEXCOORD1;
				float4 TtoW1:TEXCOORD2;
				float4 TtoW2:TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//把坐标从模型空间转换到裁剪空间				

				o.uv.xy=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
				o.uv.zw=v.texcoord.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
				//o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);接受两个参数，第一个参数是顶点纹理坐标，第二个参数是纹理名，实现中，将利用纹理名_ST的方式来计算变换后的纹理坐标

				float3 worldPos=UnityObjectToClipPos(v.vertex).xyz;
				fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal=cross(worldNormal,worldTangent)*v.tangent.w;

				o.TtoW0=float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TtoW1=float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TtoW2=float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				float3 worldPos=float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				fixed3 lightDir=normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir=normalize(UnityWorldSpaceViewDir(worldPos));
				//进行法线纹理的反映射
				fixed4 packedNormal=tex2D(_BumpMap,i.uv.zw);
				fixed3 normal=UnpackNormal(packedNormal);
				//_BumpScale用于控制凹凸程度
				normal.xy*=_BumpScale;
				//tangentNormal是单位矢量因此可以获得
				normal.z=sqrt(1.0-saturate(dot(normal.xy,normal.xy)));
				//把法线变换到世界坐标下
				normal=normalize(half3(dot(i.TtoW0.xyz,normal),dot(i.TtoW1.xyz,normal),dot(i.TtoW2.xyz,normal)));

				fixed3 albedo=tex2D(_MainTex,i.uv).rgb* _DiffuseColor.rgb;//tex2D 第一个参数是纹理，第二个参数是纹理坐标，返回纹素值
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;//使用Unity内部变量获取环境光照
				//DIFFUSE
				fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(normal,lightDir));;//内置变量获取光源的强度和颜色信息
				//SPECULAR
				fixed3 halfDir=normalize(lightDir+viewDir);
				fixed3 specular=_LightColor0.rgb*_SpecularColor.rgb*pow(max(0,dot(normal,halfDir)),_Gloss);
                return fixed4(diffuse+ambient+specular, 1.0);
			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
