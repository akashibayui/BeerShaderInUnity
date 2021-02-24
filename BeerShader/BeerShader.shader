Shader "Unlit/BeerShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BeerThreshold ("BeerThreshold", range(0,1)) = 0.7
		_BeerColor ("BeerColor", color) = (0.965, 0.800, 0.298, 1)
		_AwaColor ("AwaColor", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _BeerThreshold;
			fixed4 _BeerColor;
			fixed4 _AwaColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = tex2D(_MainTex, i.uv);
                
                
			
				float2 uv = i.uv;

				float awaHight = 0.05f * sin(2.0f * uv.x * 3.1415f + _Time.y*1.5f) + _BeerThreshold;

				if (step(awaHight, uv.y) == 1) {
					return _AwaColor; //高さが閾値以上なら泡色を塗る
				}
				fixed4 beerColor = lerp(_BeerColor, _AwaColor, -i.uv.y*0.8f); //グラデーションを付ける
				float2 uvAwaTex = i.uv;
				uvAwaTex.y -= _Time.y * 0.04f;
				beerColor += tex2D(_MainTex, uvAwaTex) * _AwaColor;
				return beerColor; //グラデーションを付けたビール色を塗る




                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
