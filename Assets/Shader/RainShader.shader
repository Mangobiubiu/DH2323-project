Shader "Effect/RainShader"
{
    SubShader
    {
		Cull Off
		Zwrite Off
		ZTest Always
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float4 uvSP : TEXCOORD1; //position of uv in screen
                float4 vertex : SV_POSITION;
				float4 vertexP : TEXCOORD2;
            };
			
			//parameters
			float4 _UVChange;
			float2 _LayerLength;
			float4 _RainColor;

			//texture
			sampler2D _MainTex;
			sampler2D _RainTexture;
			sampler2D _CameraDepthTexture;

			//lighting
			float _LightExponent;
			float _LightIntensity1;
			float _LightIntensity2;
			sampler3D _VolumeScatter;
			float _CameraFarOverMaxFar;
			float _NearOverFarClip;


			half3 InjectedLight(half linear01Depth, half2 screenuv)
			{
				half z = linear01Depth * _CameraFarOverMaxFar;
				z = (z - _NearOverFarClip) / (1 - _NearOverFarClip);
				if (z < 0.0)
					return half4(0, 0, 0, 1);

				half3 uvw = half3(screenuv.x, screenuv.y, z);
				return tex3D(_VolumeScatter, uvw).rgb;

			}

			float4 RainDistance(float2 uvScreen, float uvdepth, float2 LayerUV, float2 LayerLength)
			{
				float3 RainDepth = tex2D(_RainTexture, LayerUV).rgb;
				float2 LayerDistance = RainDepth.g * LayerLength.y + LayerLength.x;
				float depthratio = saturate(uvScreen - LayerDistance);

				float3 lightAtDepth = InjectedLight(saturate(LayerDistance * _ProjectionParams.w), uvScreen);
				lightAtDepth = pow(lightAtDepth * _LightIntensity1, _LightExponent) * _LightIntensity2;

				float4 output;
				output.a = depthratio * RainDepth.r; // calculate the alpha value
				output.rgb = lightAtDepth * output.a;
				return output;
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertexP = v.vertex;
                o.uv = v.uv;
				o.uvSP = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float2 uv = i.uv;
				float2 uv_d = uv * _UVChange.xy + _UVChange.zw * _Time.x; // uv change according to the time

				float2 uvScreen = i.uvSP.xy / i.uvSP.w;
				float depth0 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uvScreen); //_CameraDepth is non-linear
				float depthLinear = Linear01Depth(depth0); //depth valued from 0 ~ 1;
				float depth = _ProjectionParams.z * depthLinear; //_ProjectionParams.z is the distance of the far plane

				//color
				float4 rainAhlpha = RainDistance(uvScreen, depth, uv_d, _LayerLength);

				float3 RainColor = _RainColor * rainAhlpha.a;
				RainColor = RainColor + rainAhlpha.rgb;
				float3 baseColor = tex2D(_MainTex, uvScreen).rgb;
				return float4(baseColor + RainColor, 1.f);
            }
            ENDCG
        }
    }
}
