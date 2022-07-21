Shader "Unity Shaders Book/Chapter7/NormalMapTangentSpace"
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
				fixed3 viewDir:TEXCOORD0;
				float4 pos:SV_POSITION;
				float3 lightDir:TEXCOORD1;
				float4 uv:TEXCOORD2;//改成float4为了存储两个纹理坐标
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//把坐标从模型空间转换到裁剪空间				
				//计算副切线（bonormal）
				float3 binormal=cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
				//计算从物体空间到切线空间矩阵
				float3x3 rotation=float3x3(v.tangent.xyz,binormal,v.normal);
				//也可以使用tangent_space_rotation来定义
				o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
				o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.uv.xy=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
				o.uv.zw=v.texcoord.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
				//o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);接受两个参数，第一个参数是顶点纹理坐标，第二个参数是纹理名，实现中，将利用纹理名_ST的方式来计算变换后的纹理坐标
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed3 tangentLightDir=normalize(i.lightDir);
				fixed3 tangentViewDir=normalize(i.viewDir);
				//进行法线纹理的反映射
				fixed4 packedNormal=tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal=UnpackNormal(packedNormal);
				//_BumpScale用于控制凹凸程度
				tangentNormal.xy*=_BumpScale;
				//tangentNormal是单位矢量因此可以获得
				tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				fixed3 albedo=tex2D(_MainTex,i.uv).rgb* _DiffuseColor.rgb;//tex2D 第一个参数是纹理，第二个参数是纹理坐标，返回纹素值
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;//使用Unity内部变量获取环境光照
				//DIFFUSE
				fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(tangentNormal,tangentLightDir));;//内置变量获取光源的强度和颜色信息
				//SPECULAR
				fixed3 halfDir=normalize(tangentLightDir+tangentViewDir);
				fixed3 specular=_LightColor0.rgb*_SpecularColor.rgb*pow(max(0,dot(tangentNormal,halfDir)),_Gloss);
                return fixed4(diffuse+ambient+specular, 1.0);
			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
