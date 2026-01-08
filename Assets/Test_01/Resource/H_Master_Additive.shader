// Copyright (c) HualangFX. All rights reserved.
// Modification is permitted for personal use, but redistribution is strictly prohibited.

Shader "H_Master_Additive"
{
	Properties
	{
		[Header(Master_Additive)][Header(_Main_)] _Main_Tex( "Main_Tex", 2D ) = "white" {}
		[Toggle( _USECUSTOMMOVEZW_ON )] _UseCustomMoveZW( "Use Custom Move (Z & W)", Float ) = 0
		_PannerXY( "Panner(X,Y)", Vector ) = ( 0, 0, 0, 0 )
		[HDR] _Main_Color( "Main_Color", Color ) = ( 1, 1, 1, 0 )
		_Main_Ins( "Main_Ins", Float ) = 1
		[Toggle( _USECUSTOMINTENSITYX_ON )] _UseCustomIntensityX( "Use Custom Intensity (X)", Float ) = 0
		[Header(_Mask_)] _Mask_Tex( "Mask_Tex", 2D ) = "white" {}
		[Header(_Dissolve_)] _Dissolve_Texture( "Dissolve_Texture", 2D ) = "white" {}
		_Dissolve( "Dissolve", Range( -1, 1 ) ) = 2
		_Smooth( "Smooth", Range( 0, 1 ) ) = 1
		[Toggle( _USECUSTOMDISSOLVEY_ON )] _UseCustomDissolveY( "Use Custom Dissolve (Y)", Float ) = 0
		_Fade_Distance( "Fade_Distance", Float ) = 0
		[Header(Distort)] _Distort_Tex( "Distort_Tex", 2D ) = "white" {}
		_Distort_Power( "Distort_Power", Float ) = 0
		_Distort_PannerXY( "Distort_Panner(X,Y)", Vector ) = ( 0, 0, 0, 0 )
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent-5" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend SrcAlpha One
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.5
		#pragma shader_feature_local _USECUSTOMMOVEZW_ON
		#pragma shader_feature_local _USECUSTOMINTENSITYX_ON
		#pragma shader_feature_local _USECUSTOMDISSOLVEY_ON
		#define ASE_VERSION 19905
		#pragma surface surf Unlit keepalpha noshadow nofog 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
			float4 uv2_texcoord2;
			float4 screenPos;
		};

		uniform sampler2D _Main_Tex;
		uniform float2 _PannerXY;
		uniform sampler2D _Distort_Tex;
		uniform float2 _Distort_PannerXY;
		uniform float4 _Distort_Tex_ST;
		uniform float _Distort_Power;
		uniform float4 _Main_Tex_ST;
		uniform float _Main_Ins;
		uniform float4 _Main_Color;
		uniform sampler2D _Mask_Tex;
		uniform float4 _Mask_Tex_ST;
		uniform float _Dissolve;
		uniform float _Smooth;
		uniform sampler2D _Dissolve_Texture;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Fade_Distance;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 appendResult17 = (float2(_PannerXY.x , _PannerXY.y));
			float2 appendResult5 = (float2(_Distort_PannerXY.x , _Distort_PannerXY.y));
			float2 uv_Distort_Tex = i.uv_texcoord * _Distort_Tex_ST.xy + _Distort_Tex_ST.zw;
			float2 panner6 = ( 1.0 * _Time.y * appendResult5 + uv_Distort_Tex);
			float4 temp_cast_0 = (0.5).xxxx;
			float2 uv_Main_Tex = i.uv_texcoord * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
			float3 Distortion87 = ( ( (( tex2D( _Distort_Tex, panner6 ) - temp_cast_0 )).rga * _Distort_Power ) + float3( uv_Main_Tex ,  0.0 ) );
			float2 panner23 = ( 1.0 * _Time.y * appendResult17 + Distortion87.xy);
			float2 temp_cast_3 = (0.0).xx;
			float2 appendResult94 = (float2(i.uv2_texcoord2.z , i.uv2_texcoord2.w));
			#ifdef _USECUSTOMMOVEZW_ON
				float2 staticSwitch91 = appendResult94;
			#else
				float2 staticSwitch91 = temp_cast_3;
			#endif
			float4 tex2DNode28 = tex2D( _Main_Tex, (panner23*1.0 + staticSwitch91) );
			#ifdef _USECUSTOMINTENSITYX_ON
				float staticSwitch42 = i.uv2_texcoord2.x;
			#else
				float staticSwitch42 = _Main_Ins;
			#endif
			o.Emission = ( i.vertexColor * ( ( tex2DNode28 * staticSwitch42 ) * _Main_Color ) ).rgb;
			float2 uv_Mask_Tex = i.uv_texcoord * _Mask_Tex_ST.xy + _Mask_Tex_ST.zw;
			float2 panner70 = ( 1.0 * _Time.y * float2( 0,0 ) + uv_Mask_Tex);
			#ifdef _USECUSTOMDISSOLVEY_ON
				float staticSwitch24 = i.uv2_texcoord2.y;
			#else
				float staticSwitch24 =  (-2.0 + ( _Dissolve - -1.0 ) * ( 2.0 - -2.0 ) / ( 1.0 - -1.0 ) );
			#endif
			float temp_output_30_0 = ( 1.0 - staticSwitch24 );
			float smoothstepResult36 = smoothstep( temp_output_30_0 , ( temp_output_30_0 + _Smooth ) , tex2D( _Dissolve_Texture, i.uv_texcoord ).r);
			float clampResult103 = clamp( smoothstepResult36 , 0.0 , 1.0 );
			float4 ase_positionSS = float4( i.screenPos.xyz , i.screenPos.w + 1e-7 );
			float4 ase_positionSSNorm = ase_positionSS / ase_positionSS.w;
			ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
			float screenDepth43 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth43 = saturate( abs( ( screenDepth43 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( _Fade_Distance ) ) );
			o.Alpha = ( i.vertexColor.a * saturate( ( ( tex2D( _Mask_Tex, panner70 ).r * clampResult103 ) * distanceDepth43 ) ) * tex2DNode28.a );
		}

		ENDCG
	}
	Fallback Off

}

// Copyright (c) HualangFX. All rights reserved.
// Modification is permitted for personal use, but redistribution is strictly prohibited.