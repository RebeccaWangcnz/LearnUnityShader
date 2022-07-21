Shader "Custom/Chapter9/ForwardRendering"
{
    Properties
    {
        _DiffuseColor("DiffuseColor",Color)=(1,1,1,1)
		 _SpecularColor("SpecularColor",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
	}
    SubShader
    {
		//base pass
		Pass
		{
			Tags{"LightMode"="ForwardBase"}
             CGPROGRAM
			 //��֤����˥���ȹ��ձ������Ա�������ֵ
			 #pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _DiffuseColor;
			fixed4 _SpecularColor;
			float _Gloss;

        	struct a2v
			{
				float4 vertex:POSITION;
				float4 normal:NORMAL;
			};

			struct v2f
			{
				fixed3 worldNormal:TEXCOORD0;
				fixed3 viewDir:TEXCOORD1;
				float4 pos:SV_POSITION;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//�������ģ�Ϳռ�ת�����ü��ռ�				
				//�������ռ��еķ��ߺ͹�Դ����   
				o.worldNormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				o.viewDir=normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex).xyz);
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;//ʹ��Unity�ڲ�������ȡ��������
				//DIFFUSE
				fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);//_WorldSpaceLightPos0��ȡ��Դ����
				fixed3 diffuse=_LightColor0.rgb*_DiffuseColor.rgb*saturate(dot(i.worldNormal,worldLight));//���ñ�����ȡ��Դ��ǿ�Ⱥ���ɫ��Ϣ
				//SPECULAR
				fixed3 halfDir=normalize(worldLight+i.viewDir);
				fixed3 specular=_LightColor0.rgb*_SpecularColor.rgb*pow(saturate(dot(i.worldNormal,halfDir)),_Gloss);
                return fixed4(diffuse+ambient+specular, 1.0);
			}
			ENDCG
		}
       
    }
    FallBack "Diffuse"
}
