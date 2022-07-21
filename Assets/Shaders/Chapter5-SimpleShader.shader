// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter5/Simple Shader"
{
	Properties
	{
		//����Color���͵�����
		_Color("Color Tint",Color)=(1.0,1.0,1.0,1.0)
	}
	SubShader
	{
		pass
		{
			CGPROGRAM

			//����Unity�ĸ���������������ɫ���Ĵ��룬��һ������ƬԪ��ɫ���Ĵ���
			#pragma vertex vert
			#pragma fragment frag

			//����һ���������ͺ����ƾ�ƥ��ı��� Unity��uniform����ʡ��
			//Color,vector-----float4 half4 fixed4
			//range float----float half fixed
			//2D-----sampler2D
			//cube----samplerCUBE
			//3d -----sampler3D
			uniform fixed4 _Color;


			//ʹ�ýṹ�������嶥����ɫ��������,�Դ�����ȡ���������
			//POSITION,NORMAL�Ⱦ���Դ��MeshRender���
			struct a2v
			{
				float4 vertex:POSITION;
				float4 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			//ʹ�ýṹ�������嶥����ɫ���������ʵ�ֶ�����ɫ����Ƭ����ɫ��֮���ͨ��
			struct v2f
			{
				//pos���������ڲü��ռ��е�λ����Ϣ
				float4 pos:SV_POSITION;
				//COLOR0�洢��ɫ��Ϣ
				fixed3 color:COLOR0;
			};

			//������ɫ��
			//return һ��float4���͵ı��� �Ƕ����ڲü��ռ��λ��
			//POSITION����shader��ģ�͵Ķ���������䵽�������v�У�SV_POSITION���߶�����ɫ������ǲü��ռ��еĶ�������
			v2f vert(a2v v)
			{
				//��������ṹ
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				//���߷��������Χ�ڡ�-1��1��
				o.color=v.normal*0.5+fixed3(0.5,0.5,0.5);
				return o;//mul(UNITY_MATRIX_MVP,v);��ζ�����������ģ�Ϳռ�ת�����ü��ռ�
			}

			//ƬԪ��ɫ��
			//SV_TARGET0 ��ȾĿ�꣬�û��������ɫ�洢��һ����ȾĿ����
			fixed4 frag(v2f i):SV_Target
			{
            	fixed3 c = i.color;
            	c *= _Color.rgb;
                return fixed4(c, 1.0);
			}
			ENDCG
		}
	}	
}
