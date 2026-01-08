// Copyright (c) HualangFX. All rights reserved.
// Modification is permitted for personal use, but redistribution is strictly prohibited.

Shader "H_Simple_Alphablend"
{
	Properties
	{
		[Header(Simple_Alphablend)] _Main_Tex( "Main_Tex", 2D ) = "white" {}
		[HDR] _Main_Color( "Main_Color", Color ) = ( 1, 1, 1, 0 )
		_Main_Ins( "Main_Ins", Float ) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent-5" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.5
		#define ASE_VERSION 19905
		#pragma surface surf Unlit keepalpha noshadow nofog 
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
		};

		uniform sampler2D _Main_Tex;
		uniform float _Main_Ins;
		uniform float4 _Main_Color;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 panner23 = ( 1.0 * _Time.y * float2( 0,0 ) + i.uv_texcoord);
			float4 tex2DNode28 = tex2D( _Main_Tex, panner23 );
			o.Emission = ( i.vertexColor * ( ( tex2DNode28 * _Main_Ins ) * _Main_Color ) ).rgb;
			o.Alpha = ( i.vertexColor.a * tex2DNode28.a );
		}

		ENDCG
	}
	Fallback Off

}

// Copyright (c) HualangFX. All rights reserved.
// Modification is permitted for personal use, but redistribution is strictly prohibited.