// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter5/Simple Shader"
{
	Properties
	{
		//声明Color类型的属性
		_Color("Color Tint",Color)=(1.0,1.0,1.0,1.0)
	}
	SubShader
	{
		pass
		{
			CGPROGRAM

			//告诉Unity哪个函数包含顶点着色器的代码，哪一个包含片元着色器的代码
			#pragma vertex vert
			#pragma fragment frag

			//定义一个属性类型和名称均匹配的变量 Unity中uniform可以省略
			//Color,vector-----float4 half4 fixed4
			//range float----float half fixed
			//2D-----sampler2D
			//cube----samplerCUBE
			//3d -----sampler3D
			uniform fixed4 _Color;


			//使用结构体来定义顶点着色器的输入,以此来获取更多的输入
			//POSITION,NORMAL等均来源于MeshRender组件
			struct a2v
			{
				float4 vertex:POSITION;
				float4 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			//使用结构体来定义顶点着色器的输出，实现顶点着色器和片段着色器之间的通信
			struct v2f
			{
				//pos包含顶点在裁剪空间中的位置信息
				float4 pos:SV_POSITION;
				//COLOR0存储颜色信息
				fixed3 color:COLOR0;
			};

			//顶点着色器
			//return 一个float4类型的变量 是顶点在裁剪空间的位置
			//POSITION告诉shader将模型的顶点坐标填充到输入参数v中，SV_POSITION告诉顶点着色器输出是裁剪空间中的顶点坐标
			v2f vert(a2v v)
			{
				//声明输出结构
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				//法线方向分量范围在【-1，1】
				o.color=v.normal*0.5+fixed3(0.5,0.5,0.5);
				return o;//mul(UNITY_MATRIX_MVP,v);意味将顶点坐标从模型空间转换到裁剪空间
			}

			//片元着色器
			//SV_TARGET0 渲染目标，用户输出的颜色存储在一个渲染目标上
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
