// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter7/RampTexture"
{
    Properties
    {
        _DiffuseColor("DiffuseColor",Color)=(1,1,1,1)
        _RampTexture("Ramp Texture",2D)="white"{}
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
            sampler2D _RampTexture;
            float4 _RampTexture_ST;
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
                o.uv=TRANSFORM_TEX(v.texcoord,_RampTexture);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET0
            {
                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
				//Ambient
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*_DiffuseColor.rgb;//使用Unity内部变量获取环境光照
				//DIFFUSE
                fixed halfLambert=0.5*dot(worldNormal,worldLightDir)+0.5;
                fixed3 diffuseColor=tex2D(_RampTexture,fixed2(halfLambert,halfLambert)).rgb*_DiffuseColor.rgb;
				fixed3 diffuse=_LightColor0.rgb*diffuseColor;//内置变量获取光源的强度和颜色信息
				//SPECULAR
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));
                 
				fixed3 halfDir=normalize(worldLightDir+viewDir);
				fixed3 specular=_LightColor0.rgb*_SpecularColor.rgb*pow(max(0,dot(worldNormal,halfDir)),_Gloss);
                return fixed4(diffuse+ambient+specular, 1.0);
            };
            ENDCG
         }
    }
    FallBack "Specular"
}
