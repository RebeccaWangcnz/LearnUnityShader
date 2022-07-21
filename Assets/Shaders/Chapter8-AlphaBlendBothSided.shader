Shader "Unity Shaders Book/Chapter8/AlphaBlendBothSided"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _AlphaScale("Alpha Scale",Range(0,1))=0.5//͸���Ȳ��Ե��ж�����
    }
    SubShader
    {
        Tags { "Quene"="AlphaTest" "IgnoreProjector"="True" "RenderType"="Transparent"}
        pass
        {
        //first pass renders only back faces
             Tags{"LightMode"="ForwardBase"}
             Cull front

            ZWrite Off
            blend SrcAlpha OneMinusSrcAlpha //�������ģʽ ���û������

            CGPROGRAM
            #pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
            };
            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }
            fixed4 frag(v2f i):SV_TARGET0
            {
                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed4 texColor=tex2D(_MainTex,i.uv);
                fixed3 albedo=texColor.rgb*_Color.rgb;
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;//ʹ��Unity�ڲ�������ȡ��������
				//DIFFUSE
				fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLightDir));//���ñ�����ȡ��Դ��ǿ�Ⱥ���ɫ��Ϣ
                return fixed4(ambient+diffuse,texColor.a*_AlphaScale);
            }
            ENDCG
        }
        pass
        {
            Tags{"LightMode"="ForwardBase"}
            //second pass renders only front faces
            Cull back

            ZWrite Off
            blend SrcAlpha OneMinusSrcAlpha //�������ģʽ ���û������

            CGPROGRAM
            #pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
            };
            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }
            fixed4 frag(v2f i):SV_TARGET0
            {
                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed4 texColor=tex2D(_MainTex,i.uv);
                fixed3 albedo=texColor.rgb*_Color.rgb;
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;//ʹ��Unity�ڲ�������ȡ��������
				//DIFFUSE
				fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLightDir));//���ñ�����ȡ��Դ��ǿ�Ⱥ���ɫ��Ϣ
                return fixed4(ambient+diffuse,texColor.a*_AlphaScale);
            }
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}