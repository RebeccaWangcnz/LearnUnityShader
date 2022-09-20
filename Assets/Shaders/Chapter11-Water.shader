// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter11/Water"
{
    Properties
    {        
		_MainTex("Main Tex",2D)="white"{}
		_Color("Color Tint",color)=(1,1,1,1)
		_Magnitude("Distortion Magnitude",float)=1
		_Frequency("Distortion Frequency",float)=1
		_InvWaveLength("Distortion Inverse Wave Length",float)=10
		_Speed("Speed",float)=0.5
    }
    SubShader
    {
		Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}//关闭批处理 因为批处理会合并所有的相关模型 这些模型各自的模型空间就会丢失
 		Pass
		{
			Tags{"LightMode"="ForwardBase"}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off //关闭剔除功能 防止被遮挡的部分被剔除

             CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;

        	struct a2v
			{
				float4 vertex:POSITION;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				float4 Offset;
				Offset.yzw=float3(0,0,0);
				Offset.x=sin(_Frequency*_Time.y+v.vertex.x*_InvWaveLength+v.vertex.y*_InvWaveLength+v.vertex.z*_InvWaveLength)*_Magnitude;
				o.pos=UnityObjectToClipPos(v.vertex+Offset);
				o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv+=float2(0.0,_Time.y*_Speed);
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed4 c=tex2D(_MainTex,i.uv);
				c.rgb*=_Color.rgb;

				return c;
			}
			ENDCG
		}
       
    }
    FallBack "Transparent/VertexLit"
}
