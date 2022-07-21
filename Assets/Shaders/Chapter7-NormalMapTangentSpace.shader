Shader "Unity Shaders Book/Chapter7/NormalMapTangentSpace"
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
				fixed3 viewDir:TEXCOORD0;
				float4 pos:SV_POSITION;
				float3 lightDir:TEXCOORD1;
				float4 uv:TEXCOORD2;//�ĳ�float4Ϊ�˴洢������������
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);//�������ģ�Ϳռ�ת�����ü��ռ�				
				//���㸱���ߣ�bonormal��
				float3 binormal=cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
				//���������ռ䵽���߿ռ����
				float3x3 rotation=float3x3(v.tangent.xyz,binormal,v.normal);
				//Ҳ����ʹ��tangent_space_rotation������
				o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
				o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.uv.xy=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
				o.uv.zw=v.texcoord.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
				//o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);����������������һ�������Ƕ����������꣬�ڶ�����������������ʵ���У�������������_ST�ķ�ʽ������任�����������
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed3 tangentLightDir=normalize(i.lightDir);
				fixed3 tangentViewDir=normalize(i.viewDir);
				//���з�������ķ�ӳ��
				fixed4 packedNormal=tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal=UnpackNormal(packedNormal);
				//_BumpScale���ڿ��ư�͹�̶�
				tangentNormal.xy*=_BumpScale;
				//tangentNormal�ǵ�λʸ����˿��Ի��
				tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				fixed3 albedo=tex2D(_MainTex,i.uv).rgb* _DiffuseColor.rgb;//tex2D ��һ�������������ڶ����������������꣬��������ֵ
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;//ʹ��Unity�ڲ�������ȡ��������
				//DIFFUSE
				fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(tangentNormal,tangentLightDir));;//���ñ�����ȡ��Դ��ǿ�Ⱥ���ɫ��Ϣ
				//SPECULAR
				fixed3 halfDir=normalize(tangentLightDir+tangentViewDir);
				fixed3 specular=_LightColor0.rgb*_SpecularColor.rgb*pow(max(0,dot(tangentNormal,halfDir)),_Gloss);
                return fixed4(diffuse+ambient+specular, 1.0);
			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
