

Shader "Unity Shaders Book/Chapter9/ForwardRendering"
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

				fixed atten=1.0;
                return fixed4(ambient+(diffuse+specular)*atten, 1.0);
			}
			ENDCG
		}

		//additional pass
		Pass
		{
			Tags{"LightMode"="ForwardAdd"}
			//ʹ�����basepass�е��ӣ������Ǹ���
			blend one One

			CGPROGRAM
			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

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
				float3 worldPosition:TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//�������ģ�Ϳռ�ת�����ü��ռ�				
				//�������ռ��еķ��ߺ͹�Դ����   
				o.worldNormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				o.viewDir=normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex).xyz);
				o.worldPosition=mul(unity_ObjectToWorld,v.vertex).xyz;
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);//_WorldSpaceLightPos0��ȡ��Դ����
				#else
					fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz-i.worldPosition.xyz);//_WorldSpaceLightPos0��ȡ��Դ����
				#endif
				//DIFFUSE		
				fixed3 diffuse=_LightColor0.rgb*_DiffuseColor.rgb*saturate(dot(i.worldNormal,worldLight));//���ñ�����ȡ��Դ��ǿ�Ⱥ���ɫ��Ϣ
				//SPECULAR
				fixed3 halfDir=normalize(worldLight+i.viewDir);
				fixed3 specular=_LightColor0.rgb*_SpecularColor.rgb*pow(saturate(dot(i.worldNormal,halfDir)),_Gloss);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten=1;
				#else
					#if defined (POINT)
				        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPosition, 1)).xyz;//����������任����Դ�ռ�
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
				        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPosition, 1));
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
				#endif
                return fixed4((diffuse+specular)*atten, 1.0);
			}
			ENDCG
		}
       
    }
    FallBack "Diffuse"
}
