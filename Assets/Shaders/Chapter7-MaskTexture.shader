Shader "Unity Shaders Book/Chapter7/MaskTexture"
{
    Properties
    {
        _DiffuseColor("DiffuseColor",Color)=(1,1,1,1)
         _MainTexture("Main Texture",2D)="white"{}
         _BumpMap("Bump Map",2D)="Bump"{}
         _BumpScale("Bump Scale",Float)=1.0
        _SpecularMask("Specular Mask",2D)="white"{}
        _SpecularScale("Specular Scale",Float)=1.0
		_SpecularColor("SpecularColor",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
    }
    SubShader
    {
    pass
    {
         Tags { "RenderType"="ForwardBase" }
         CGPROGRAM
         	#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

            fixed4 _DiffuseColor;
            sampler2D _MainTexture;
            float4 _MainTexture_ST;
            sampler2D _BumpMap;
            float _BumpScale;
            sampler2D _SpecularMask;
            float _SpecularScale;
            fixed4 _SpecularColor;
            float _Gloss;
            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 lightDir:TEXCOORD0;
                float3 viewDir:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.uv=TRANSFORM_TEX(v.texcoord,_MainTexture);

                TANGENT_SPACE_ROTATION;
                o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }
            fixed4 frag(v2f i):SV_TARGET0
            {
                fixed3 tangentLightDir=normalize(i.lightDir);
                fixed3 tangentNormal=UnpackNormal(tex2D(_BumpMap,i.uv));
                tangentNormal.xy*=_BumpScale;
                tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				//Ambient
                fixed3 albedo=tex2D(_MainTexture,i.uv)*_DiffuseColor.rgb;
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;//使用Unity内部变量获取环境光照
				//DIFFUSE
                //fixed3 diffuseColor=tex2D(_RampTexture,fixed2(halfLambert,halfLambert)).rgb*_DiffuseColor.rgb;
				fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(tangentNormal,tangentLightDir));//内置变量获取光源的强度和颜色信息
				//SPECULAR
                fixed3 tangentViewDir=normalize(i.viewDir);
                 
				fixed3 halfDir=normalize(tangentLightDir+tangentViewDir);
				fixed3 specular=_LightColor0.rgb*_SpecularColor.rgb*tex2D(_SpecularMask,i.uv).r*_SpecularScale*pow(max(0,dot(tangentNormal,halfDir)),_Gloss);
                return fixed4(diffuse+ambient+specular, 1.0);
            }
         ENDCG
    }
    }
  
    FallBack "Specular"
}
