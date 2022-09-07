Shader "Unity Shaders Book/Chapter10/Mirror"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white"{}
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

			sampler2D _MainTex;
			float4 _MainTex_ST;

        	struct a2v
			{
				float4 vertex:POSITION;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 uv:TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//把坐标从模型空间转换到裁剪空间				  
				o.uv=v.texcoord;
				o.uv.x=1-o.uv.x;//mirror need to flip x

				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
                return tex2D(_MainTex,i. uv);
			}
			ENDCG
		}
       
    }
    FallBack "Diffuse"
}
