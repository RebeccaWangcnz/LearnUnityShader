// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter7/NormalMapWorldSpace"
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
			float4 _MainTex_ST;//ƽ�ƺ����ţ�����xy��������tiling��zw����ƽ��offset
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _SpecularColor;
			float _Gloss;

        	struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;//tangent.w�������ĸ��������߷���������float4
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;//�ĳ�float4Ϊ�˴洢������������
				float4 TtoW0:TEXCOORD1;
				float4 TtoW1:TEXCOORD2;
				float4 TtoW2:TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//�������ģ�Ϳռ�ת�����ü��ռ�				

				o.uv.xy=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
				o.uv.zw=v.texcoord.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
				//o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);����������������һ�������Ƕ����������꣬�ڶ�����������������ʵ���У�������������_ST�ķ�ʽ������任�����������

				float3 worldPos=UnityObjectToClipPos(v.vertex).xyz;
				fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal=cross(worldNormal,worldTangent)*v.tangent.w;

				o.TtoW0=float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TtoW1=float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TtoW2=float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				float3 worldPos=float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				fixed3 lightDir=normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir=normalize(UnityWorldSpaceViewDir(worldPos));
				//���з�������ķ�ӳ��
				fixed4 packedNormal=tex2D(_BumpMap,i.uv.zw);
				fixed3 normal=UnpackNormal(packedNormal);
				//_BumpScale���ڿ��ư�͹�̶�
				normal.xy*=_BumpScale;
				//tangentNormal�ǵ�λʸ����˿��Ի��
				normal.z=sqrt(1.0-saturate(dot(normal.xy,normal.xy)));
				//�ѷ��߱任������������
				normal=normalize(half3(dot(i.TtoW0.xyz,normal),dot(i.TtoW1.xyz,normal),dot(i.TtoW2.xyz,normal)));

				fixed3 albedo=tex2D(_MainTex,i.uv).rgb* _DiffuseColor.rgb;//tex2D ��һ�������������ڶ����������������꣬��������ֵ
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;//ʹ��Unity�ڲ�������ȡ��������
				//DIFFUSE
				fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(normal,lightDir));;//���ñ�����ȡ��Դ��ǿ�Ⱥ���ɫ��Ϣ
				//SPECULAR
				fixed3 halfDir=normalize(lightDir+viewDir);
				fixed3 specular=_LightColor0.rgb*_SpecularColor.rgb*pow(max(0,dot(normal,halfDir)),_Gloss);
                return fixed4(diffuse+ambient+specular, 1.0);
			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
