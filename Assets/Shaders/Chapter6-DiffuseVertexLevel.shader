// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter6/Diffuse Vertex-Level"
{
    Properties
    {
        _DiffuseColor("DiffuseColor",Color)=(1,1,1,1)
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

		fixed4 _DiffuseColor;

        	struct a2v
			{
				float4 vertex:POSITION;
				float4 normal:NORMAL;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				fixed3 color:COLOR0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//把坐标从模型空间转换到裁剪空间

				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;//使用Unity内部变量获取环境光照
				//获得世界空间中的法线和光源方向   
				fixed3 worldNormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);//_WorldSpaceLightPos0获取光源方向
				fixed3 diffuse=_LightColor0.rgb*_DiffuseColor.rgb*saturate(dot(worldNormal,worldLight));//内置变量获取光源的强度和颜色信息
				//saturate 小于0取0，大于1取1

				o.color=ambient+diffuse;
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
                return fixed4(i.color, 1.0);
			}
        ENDCG
		}
       
    }
    FallBack "Diffuse"
}
