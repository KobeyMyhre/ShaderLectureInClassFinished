Shader "Custom/FuckWater" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Speed("Wave Speed", float) = 20
		_WaveA("Dir.x, Dir.y, Amp, Length", vector) =(.5,.5,.3,10)
		_WaveB("Dir.x, Dir.y, Amp, Length", vector) =(.5,.5,.3,10)
		_WaveC("Dir.x, Dir.y, Amp, Length", vector) =(.5,.5,.3,10)
		_WaveD("Dir.x, Dir.y, Amp, Length", vector) =(.5,.5,.3,10)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _Speed;
		float4 _WaveA;
		float4 _WaveB;
		float4 _WaveC;
		float4 _WaveD;
		void vert(inout appdata_full v)
		{
			float2 pos = v.vertex.xy;
			float freq = _Speed * (2 * 3.14 / _WaveA.w);
			float phase = 2 * 3.14 / _WaveA.w;
			v.vertex.y += _WaveA.z * sin((dot(_WaveA.xy,pos.xy) * freq + (phase)) * _Time);
			v.vertex.y += _WaveB.z * sin((dot(_WaveB.xy,pos.xy) * freq + (phase)) * _Time);
			v.vertex.y += _WaveC.z * sin((dot(_WaveC.xy,pos.xy) * freq + (phase)) * _Time);
			v.vertex.y += _WaveD.z * sin((dot(_WaveD.xy,pos.xy) * freq + (phase)) * _Time);
			v.vertex.y /= 4;
			//v.vertex.y += pos.xy;
		}


		struct Input {
			float2 uv_MainTex;
		};

		
		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
