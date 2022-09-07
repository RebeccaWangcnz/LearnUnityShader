Shader "Unity Shaders Book/Chapter10/GlassReflection"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white"{}
		_BumpMap("Bump Map",2D)="bump"{}
		_Cubemap ("Environment Cubemap", Cube) = "_Skybox"{}
		_Distortion("Distortion",Range(0,100))=10//ģ������ʱͼ���Ť���̶�
        _RefractAmount ("Refract Amount", Range(0,1)) = 0.5//����̶ȣ�=0ֻ�������䣬=1ֻ��������
    }
    SubShader
    {
 		Pass
		{
			//we must be transparent, so other objects are drawn before this one
			Tags{"Queue"="Transparent" "RenderType"="Opaque"}
			//this pass grab the scene behind the obj into a texture
			//we can access the result in the next pass as _RefractionTex
			GrabPass{"_RefractionTex"}
            
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			fixed _Distortion;
			fixed _RefractAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;//���Եõ����ش�С
			
			

        	struct a2v
			{
				float4 vertex:POSITION;
				float4 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
				float4 tangent:TANGENT;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD1;
				float4 TtoW0:TEXCOORD2;
				float4 TtoW1:TEXCOORD3;
				float4 TtoW2:TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//�������ģ�Ϳռ�ת�����ü��ռ�	
				o.scrPos=ComputeGrabScreen(o.pos);//��ȡ��Ӧ��ץȡ����Ļͼ��Ĳ�������
				o.uv.xy=TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv.zw=TRANSFORM_TEX(v.texcoord,_BumpMap);

				float3 worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
				fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);//����ռ䷨������
				fixed3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);//����ռ���������
				fixed3 worldBinormal=cross(worldNormal,worldTangent)*v.tangent.w;//����ռ为��������
				
				//���߿ռ䵽����ռ�ı任����
				o.TtoW0=float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TtoW1=float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TtoW2=float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

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
				fixed3 refraction=texCUBE(_Cubemap,i.worldRefr).rgb*_RefractColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

                return fixed4(ambient+lerp(diffuse,refraction,_RefractAmount)*atten, 1.0);
			}
			ENDCG
		}
       
    }
    FallBack "Diffuse"
}
