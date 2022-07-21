// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter6/Diffuse Pixel-Level"
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
				fixed3 worldNormal:TEXCOORD0;
				float4 pos:SV_POSITION;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//�������ģ�Ϳռ�ת�����ü��ռ�				
				//�������ռ��еķ��ߺ͹�Դ����   
				o.worldNormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;//ʹ��Unity�ڲ�������ȡ��������
				//DIFFUSE
				fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);//_WorldSpaceLightPos0��ȡ��Դ����
				fixed3 diffuse=_LightColor0.rgb*_DiffuseColor.rgb*saturate(dot(i.worldNormal,worldLight));//���ñ�����ȡ��Դ��ǿ�Ⱥ���ɫ��Ϣ
                return fixed4(diffuse+ambient, 1.0);
			}
        ENDCG
		}
       
    }
    FallBack "Diffuse"
}
