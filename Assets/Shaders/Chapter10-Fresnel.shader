Shader "Unity Shaders Book/Chapter10/Fresnel"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _FresnelScale("Fresnel Scale", Range(0,1)) = 0.5
        _Cubemap ("Reflection Cubemap", Cube) = "_Skybox"{}
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
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed _FresnelScale;
			samplerCUBE _Cubemap;

        	struct a2v
			{
				float4 vertex:POSITION;
				float4 normal:NORMAL;
			};

			struct v2f
			{
				fixed3 worldNormal:TEXCOORD0;
				float4 pos:SV_POSITION;
				float3 worldPos:TEXCOORD1;
				float3 worldViewDir:TEXCOORD2;
				float3 worldRefl:TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//把坐标从模型空间转换到裁剪空间				
				//获得世界空间中的法线和光源方向   
				o.worldNormal=UnityObjectToWorldNormal(v.normal);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldViewDir=UnityWorldSpaceViewDir(o.worldPos);

				o.worldRefl=reflect(-o.worldViewDir,o.worldNormal);

				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed3 worldNormal=normalize(i.worldNormal);
				fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir=normalize(i.worldViewDir);
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;//使用Unity内部变量获取环境光照

				//Reflection
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
				fixed3 reflection=texCUBE(_Cubemap,i.worldRefl).rgb;
				//Fresnel
				fixed fresnel=_FresnelScale+(1-_FresnelScale)*pow(1-dot(worldViewDir,worldNormal),5);
				//DIFFUSE
				fixed3 diffuse=_LightColor0.rgb*_Color.rgb*saturate(dot(i.worldNormal,worldLightDir));//内置变量获取光源的强度和颜色信息
				
                return fixed4(ambient+lerp(diffuse,reflection,saturate(fresnel))*atten, 1.0);
			}
			ENDCG
		}
       
    }
    FallBack "Diffuse"
}
