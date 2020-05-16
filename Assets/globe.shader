Shader "Custom/Globe"
{
    Properties
    {
        _MainTex ("Day", 2D) = "white" {}
        _NightTex ("Night", 2D) = "white" {}
        _CloudsTex ("Clouds", 2D) = "white" {}
        _Smoothness ("Smoothness (RGB)", 2D) = "white" {}
        _Metalness ("Metalness (RGB)", 2D) = "white" {}
        _NormalMap ("Normal (RGB)", 2D) = "Bump" {}   
        _CloudAmount ("Cloud Alpha", Range(0,2)) = 0     
        _CloudSpeed ("_CloudSpeed", Range(-1,1)) = 0.2
    }
    SubShader
    {
        Tags { "Queue"="Geometry" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard

        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NightTex;
        sampler2D _NormalMap;
        sampler2D _Smoothness;
        sampler2D _Metalness;
        sampler2D _CloudsTex;

        half _CloudAmount;
        half _CloudSpeed;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal; INTERNAL_DATA
        };
        
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        struct v2f {
            half3 worldNormal : TEXCOORD0;
            float4 pos : SV_POSITION;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {

          o.Normal = UnpackNormal (tex2D (_NormalMap, IN.uv_MainTex));

          float2 uvs = IN.uv_MainTex;

          fixed3 lightPos = _WorldSpaceLightPos0;
          fixed3 norm = WorldNormalVector (IN, o.Normal);

          fixed4 day = tex2D (_MainTex, uvs);
          fixed4 night = tex2D (_NightTex, uvs);
          fixed4 clouds = tex2D (_CloudsTex, uvs + fixed2(_Time.x * _CloudSpeed, 0));

          half dayValue = pow(clamp(dot(lightPos, norm) * 6.0, 0, 1), 1.0);
          half nightValue = 1.0 - dayValue;

          fixed4 c = day * dayValue + (night * nightValue * 0.5);
          c.a = 1.0;

          c += clouds.r * 2.0 * _CloudAmount;

          o.Albedo = c.rgb;
          o.Emission = night * nightValue;
          o.Smoothness = tex2D(_Smoothness, uvs).r;
          o.Metallic = tex2D(_Metalness, uvs).r;;
        
          o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
