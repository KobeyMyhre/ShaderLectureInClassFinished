Shader "Custom/Water_Shader_WithProperties" {
	Properties {
		_Tess ("Tessellation", Range(1,32)) = 4
		_Color ("Color", Color) = (1,1,1,1)
		_SecondColor ("Second Color", Color) = (0,0,0,0)
		//_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Bump1 ("Bump Map 1",2D) = "white"{}
		_Bump2 ("Bump Map 2",2D) = "white"{}
		_UVScroll("UV Scroll speed", float) = 1
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		//_Steepness("Steepness", Range(0,1)) = 0.0
		//_WaveLength("Wave Length", float) = 0.0
		_Amplitude("Amplitude",float) = 0.0
		_WaveNumber("Wave Number", float) = 1.0
		//_Direction("Direction", vector) = (1,1,1,1)
		_Speed("Wave Speed",float) = 0.0
		_WaveA("Wave A (dirX, dirY, steepness, waveLength)",vector)= (1,0,0.5,10)
		_WaveB("Wave B",vector)= (1,0,0.5,10)
		_WaveC("Wave C",vector)= (1,0,0.5,10)
		_WaveD("Wave D",vector)= (1,0,0.5,10)

		_EdgeColor("Edge Color", Color) = (1,1,1,1)
		_DepthFactor("Depth Factor", float) = 1.0
	}
	SubShader {
		Tags { "Queue" = "Transparent" "RenderType"="Transparent"}
		//Tags{ "Queue" = "Geometry" "RenderType" = "Opaque" }
		LOD 100
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard vertex:vert tessellate:tessFixed alpha

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		sampler2D _CameraDepthTexture;
		sampler2D _MainTex;
		sampler2D _Bump1;
		sampler2D _Bump2;
		float4 _Bump1_ST;
		float4 _Bump2_ST;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _SecondColor;
		float _UVScroll;
		float _Amplitude;
		float _Speed;
		float _DepthFactor;
		float4 _EdgeColor;
		//float _Steepness;
		//float _WaveLength;
		//float4 _Direction;
		float _WaveNumber;
		float4 _WaveA;
		float4 _WaveB;
		float4 _WaveC;
		float4 _WaveD;
		struct Input {
			float2 uv_MainTex;
			float4 screenPos;
		};

		uniform float _Tess;
		float4 tessFixed()
        {
            return _Tess;
        }

		
		float3 waveDisplacement(float3 pos, float time, float _Amp, float _S, float4 _WaveNum, float4 wave)
		{
			float3 retval = pos;
			float _WL = wave.w;
			float2 _Dir = wave.xy;
			float _Steepness = wave.z;
			float q = _Steepness / (_WL * _Amp);
			float p = (_S * ((2 * 3.14) / _WL)) * time;
			float toBeCosA = (_WaveNum * (dot(normalize(_Dir), retval.xz))) + p;
			float QA = ((_Amp * _WL) * (_WaveNum * (2 * 3.14))) / q;
			retval.x += (q * _Amp) * _Dir.x * cos(toBeCosA);
			float toBeCosB = (_WaveNum * (dot(normalize(_Dir), retval.xz))) + p;
			retval.z += (q * _Amp) * _Dir.y * cos(toBeCosB);
			float toBeCosC = (_WaveNum * (dot(normalize(_Dir), retval.xz))) + p;
			retval.y += _Amp * sin(toBeCosC);
			
			return retval;
		}


		float3 waveNormal(float3 pos, float time, float _Amp, float _S, float4 wave)
		{
			//float3 retval = pos;
			float _WL = wave.w;
			float2 _Dir = wave.xy;
			float _Steepness = wave.z;
			float3 retval = pos;
			float p = (_S * ((2 * 3.14) / _WL)) * time;
			float q = _Steepness / (_WL * _Amp);
			float CO = _WaveNumber * dot(normalize(_Dir), pos.xz) + p;

			retval.x += - (_Dir.x * (_WL * _Amp) * cos(CO));
			retval.z += -(_Dir.y * (_WL * _Amp) * cos(CO));
			retval.y += 1 - (q * (_WL * _Amp)) * sin(CO);
			return retval;
		}

		void vert(inout appdata_full v)
		{
			
			v.vertex.xyz += waveDisplacement(v.vertex.xyz, _Time, _Amplitude,_Speed, _WaveNumber, _WaveA);
			v.vertex.xyz += waveDisplacement(v.vertex.xyz, _Time, _Amplitude,_Speed, _WaveNumber, _WaveB);
			v.vertex.xyz += waveDisplacement(v.vertex.xyz, _Time, _Amplitude,_Speed, _WaveNumber, _WaveC);
			v.vertex.xyz += waveDisplacement(v.vertex.xyz, _Time, _Amplitude,_Speed, _WaveNumber, _WaveD);
			v.vertex.xyz /= 4;
			//v.vertex = UnityObjectToClipPos(v.vertex);

			v.normal += waveNormal(v.normal, _Time, _Amplitude, _Speed, _WaveA);
			v.normal += waveNormal(v.normal, _Time, _Amplitude, _Speed, _WaveB);
			v.normal += waveNormal(v.normal, _Time, _Amplitude, _Speed, _WaveC);
			v.normal += waveNormal(v.normal, _Time, _Amplitude, _Speed, _WaveD);
			v.normal /= 4;
			//v.vertex.xyz += waveDisplacement(v.vertex.xyz, _Time, _Amplitude, _Speed, _WaveLength , _Direction.xy, _WaveNumber);
			//v.vertex.xyz += waveDisplacement(v.vertex.xyz, _Time, _Amplitude * .2, _Speed * .7, _WaveLength * 6, float2(_Direction.x * .5, _Direction.y * .8), _WaveNumber * 6);
			//v.vertex.xyz += waveDisplacement(v.vertex.xyz, _Time, _Amplitude * .1, _Speed * 1.1, _WaveLength * 4, float2(_Direction.x * 0.4, _Direction.y * 0.4) , _WaveNumber * 7);
			//v.vertex.xyz += waveDisplacement(v.vertex.xyz, _Time, _Amplitude * .4, _Speed * 3, _WaveLength * 9, float2(_Direction.x + 0.8, _Direction.y * .2), _WaveNumber * 12);
			//v.vertex.xyz += waveDisplacement(v.vertex.xyz, _Time, _Amplitude * .3, _Speed * .2, _WaveLength *5, float2(-_Direction.x, -_Direction.y), _WaveNumber * 4);
			//v.normal += waveNormal(v.vertex.xyz, _Time, _Amplitude, _Speed, _WaveLength, _Direction.xy);
			//v.normal += waveNormal(v.vertex.xyz, _Time, _Amplitude * .2, _Speed * .7, _WaveLength * 4.7, float2(_Direction.x * .5, _Direction.y * .8));
			//v.normal += waveNormal(v.vertex.xyz, _Time, _Amplitude * .1, _Speed * 1.1, _WaveLength * .2, float2(_Direction.x * 0.4, _Direction.y * 0.4) );
			//v.normal += waveNormal(v.vertex.xyz, _Time, _Amplitude * .4, _Speed * 3, _WaveLength * 1.6, float2(_Direction.x * 0.8, _Direction.y * .2));
			//v.normal += waveNormal(v.vertex.xyz, _Time, _Amplitude * .7, _Speed * .2, _WaveLength *5, float2(-_Direction.x, -_Direction.y));
		}
		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			float2 uv = IN.uv_MainTex;
			float2 uv2 = uv;
			float2 dir = (_WaveA.xy, _WaveB.xy) /2;
			float2 dir2 = (_WaveC.xy, _WaveD.xy) /2;
			uv += dir * (_UVScroll / 100) * _Time;
			uv2 += dir2 * (_UVScroll /100) * _Time;
			fixed4 c = tex2D (_MainTex, uv) * _Color;
			o.Albedo = c.rgb;
			half2 uv_BumpMap1 = TRANSFORM_TEX(uv, _Bump1);
			half2 uv_BumpMap2 = TRANSFORM_TEX(uv2, _Bump2);
			half3 normal1 = UnpackNormal(tex2D(_Bump1, uv_BumpMap1));
			half3 normal2 = UnpackNormal(tex2D(_Bump2, uv_BumpMap2));
			half3 normal = (normal1 + normal2) /2;

			float4 s = UNITY_PROJ_COORD(IN.screenPos) ;
			float4 depthSample =
				SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, s);
			float depth = LinearEyeDepth(depthSample).r ;

			float4 foamLine = 1 - saturate(_DepthFactor * (depth - IN.screenPos.w));

			o.Normal = normal;
			//o.Albedo = lerp(_Color, _SecondColor, _Glossiness);
			o.Albedo = _Color + (foamLine * _EdgeColor);
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = _Color.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}