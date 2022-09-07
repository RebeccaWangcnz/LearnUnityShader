Shader "Unity Shaders Book/Chapter10/Reflection"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _ReflectionColor ("Reflection Color", Color) = (1,1,1,1)
        _ReflectionAmount ("Reflect Amount", Range(0,1)) = 0.5
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

			fixed4 _ReflectionColor;
			fixed4 _Color;
			fixed _ReflectionAmount;
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
				float3 worldRef1:TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//�������ģ�Ϳռ�ת�����ü��ռ�				
				//�������ռ��еķ��ߺ͹�Դ����   
				o.worldNormal=UnityObjectToWorldNormal(v.normal);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldViewDir=UnityWorldSpaceViewDir(o.worldPos);

				o.worldRef1=reflect(-o.worldViewDir,o.worldNormal);

				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed3 worldNormal=normalize(i.worldNormal);
				fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir=normalize(i.worldViewDir);
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;//ʹ��Unity�ڲ�������ȡ��������
				//DIFFUSE
				fixed3 diffuse=_LightColor0.rgb*_Color.rgb*saturate(dot(i.worldNormal,worldLightDir));//���ñ�����ȡ��Դ��ǿ�Ⱥ���ɫ��Ϣ
				//Reflection
				fixed3 reflection=texCUBE(_Cubemap,i.worldRef1).rgb*_ReflectionColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

                return fixed4(ambient+lerp(diffuse,reflection,_ReflectionAmount)*atten, 1.0);
			}
			ENDCG
		}
       
    }
    FallBack "Diffuse"
}
