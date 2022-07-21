Shader "Unity Shaders Book/Chapter7/SingleTexture"
{
    Properties
    {
        _DiffuseColor("DiffuseColor",Color)=(1,1,1,1)
        _MainTex("Main Tex",2D)="white"{}
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
			fixed4 _SpecularColor;
			float _Gloss;

        	struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				fixed3 worldNormal:TEXCOORD0;
				float4 pos:SV_POSITION;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//把坐标从模型空间转换到裁剪空间				
				//获得世界空间中的法线和光源方向   
				o.worldNormal=UnityObjectToWorldNormal(v.normal);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
				o.uv=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
				//o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);接受两个参数，第一个参数是顶点纹理坐标，第二个参数是纹理名，实现中，将利用纹理名_ST的方式来计算变换后的纹理坐标
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed3 albedo=tex2D(_MainTex,i.uv).rgb* _DiffuseColor.rgb;//tex2D 第一个参数是纹理，第二个参数是纹理坐标，返回纹素值
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;//使用Unity内部变量获取环境光照
				//DIFFUSE
				fixed3 worldLight=normalize(UnityWorldSpaceLightDir(i.worldPos));//_WorldSpaceLightPos0获取光源方向
				fixed3 diffuse=_LightColor0.rgb*albedo*saturate(dot(i.worldNormal,worldLight));//内置变量获取光源的强度和颜色信息
				//SPECULAR
				fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir=normalize(worldLight+viewDir);
				fixed3 specular=_LightColor0.rgb*_SpecularColor.rgb*pow(saturate(dot(i.worldNormal,halfDir)),_Gloss);
                return fixed4(diffuse+ambient+specular, 1.0);
			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
