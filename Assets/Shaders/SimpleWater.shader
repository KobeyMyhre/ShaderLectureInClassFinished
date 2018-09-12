Shader "Custom/SimpleWater" {
	Properties {
		_Tess ("Tessellation", Range(1,32)) = 4
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0.3,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_NormalMap("Bump Map", 2D) = "white"{}
		_BumpMap("Bump Map", 2D) = "white"{}
		_WaveSpeed("Wave Speed", float) = 30
		_WaveAmp("Wave Amplitude", float) = 1
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_NoiseTex("Noise Tex",2D) = "white" {}
		_NoiseTex2("Noise Tex",2D) = "white"{}
		_ScrollDir("Scrol Dir", vector) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf BlinnPhong fullforwardshadows vertex:vert tessellate:tessFixed

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _NoiseTex;
		sampler2D _NoiseTex2;
		sampler2D _NormalMap;
		sampler2D _BumpMap;
		float _WaveAmp;
		float _WaveSpeed;
		float4 _ScrollDir;
		struct Input {
			float2 uv_MainTex;
			float2 uv_NormalMap;
			
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		uniform float _Tess;
		float4 tessFixed()
        {
            return _Tess;
        }

		void vert(inout appdata_full v)
		{
			float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
			float noiseSample = tex2Dlod(_NoiseTex, float4(v.texcoord.xy,0,0));
			float noiseSample2 = tex2Dlod(_NoiseTex2, float4(v.texcoord.xy,0,0));
			v.vertex.y += sin((_Time * _WaveSpeed) * noiseSample) * (_WaveAmp * noiseSample2);
			//v.normal.y += sin((_Time * _WaveSpeed) * noiseSample) * _WaveAmp;
		}


		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			float2 normalUV = IN.uv_NormalMap;
			float2 normalUV2 = IN.uv_NormalMap;
			normalUV += _ScrollDir.xy * (_WaveSpeed/ 500) * _Time;
			normalUV2 += _ScrollDir.zx * (_WaveSpeed /500) * _Time; 
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			float3 normal = UnpackNormal(tex2D(_NormalMap, normalUV));
			float3 normal2 = UnpackNormal(tex2D(_BumpMap, normalUV2));
			o.Normal = (normal + normal2)/2;
			// Metallic and smoothness come from slider variables
			o.Gloss = c.a;
			o.Specular = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
