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
			float4 _MainTex_ST;//ƽ�ƺ����ţ�����xy��������tiling��zw����ƽ��offset
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
				o.pos=UnityObjectToClipPos(v.vertex);//�������ģ�Ϳռ�ת�����ü��ռ�				
				//�������ռ��еķ��ߺ͹�Դ����   
				o.worldNormal=UnityObjectToWorldNormal(v.normal);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
				o.uv=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
				//o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);����������������һ�������Ƕ����������꣬�ڶ�����������������ʵ���У�������������_ST�ķ�ʽ������任�����������
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed3 albedo=tex2D(_MainTex,i.uv).rgb* _DiffuseColor.rgb;//tex2D ��һ�������������ڶ����������������꣬��������ֵ
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;//ʹ��Unity�ڲ�������ȡ��������
				//DIFFUSE
				fixed3 worldLight=normalize(UnityWorldSpaceLightDir(i.worldPos));//_WorldSpaceLightPos0��ȡ��Դ����
				fixed3 diffuse=_LightColor0.rgb*albedo*saturate(dot(i.worldNormal,worldLight));//���ñ�����ȡ��Դ��ǿ�Ⱥ���ɫ��Ϣ
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
