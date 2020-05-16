Shader "Custom/GreenShadow" {  
	Properties {
		_MainTex ("Main", 2D) = "white" {}    
    _NoiseTex ("Noise", 2D) = "white" {}    
    _Color ("Color", Color) = (1,1,1,1)
		_Glossiness ("Smoothness", Range(0,1)) = 0.0
		_Metallic ("Metallic", Range(0,1)) = 0.0    
    _BallShadow1 ("Shadow 1", Vector) = (0,0,0)
    _BallShadow2 ("Shadow 2", Vector) = (0,0,0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" "ForceNoShadowCasting" = "True" }
		LOD 200
    Lighting Off

		// Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows addshadow
    // #pragma surface surf Standard

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;    
    sampler2D _NoiseTex;    

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
      float3 worldNormal;
		};

		half _Glossiness;
		half _Metallic;    
		fixed4 _Color;
		float3 _HolePosition;
    float3 _BallPosition;
    float3 _BallShadow1;
    float3 _BallShadow2;
    half _HoleDiameter;        

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)


		void surf (Input IN, inout SurfaceOutputStandard o) {
			
      float2 uv;
      uv.x = IN.worldPos.x;
      uv.y = IN.worldPos.z;

      float ballRadiusLarger = 0.03;

			fixed4 color = tex2D (_MainTex, uv) * _Color;
      
      float3 shadowDiff = _BallShadow1 - IN.worldPos.xyz;
      shadowDiff.y *= 0.05;
      float d = clamp(pow(length(shadowDiff) / ballRadiusLarger, 1.0), 0.5, 1);
      color = color * d;

      shadowDiff = _BallShadow2 - IN.worldPos.xyz;
      shadowDiff.y *= 0.05;
      d = clamp(pow(length(shadowDiff) / ballRadiusLarger, 1.0), 0.5, 1);
      color = color * d;

      float noiseValue = tex2D(_NoiseTex, uv / 32);
      o.Albedo = color.rgb + (noiseValue - 0.5) * 0.07;

      // o.Albedo = color.rgb;
      o.Metallic = _Metallic;
      o.Smoothness = _Glossiness;      
			
		}
		ENDCG
	}
	FallBack "Diffuse"
}
