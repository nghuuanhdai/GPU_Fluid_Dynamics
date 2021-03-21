Shader "Hidden/pressure_divergence"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            float4 sampleVelocity(float2 uv)
            {
                float2 bound_check = abs(uv - 0.5);
                if(bound_check.x > 0.4) return float4(0,0,1,1);
                if(bound_check.y > 0.4) return float4(0,0,1,1);
                float4 v = tex2D(_MainTex, uv);
                v.xy = (v.xy - 0.5)*2;
                return v;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 wL = sampleVelocity(i.uv - float2(1,0)*_MainTex_TexelSize.xy);
                float4 wR = sampleVelocity(i.uv + float2(1,0)*_MainTex_TexelSize.xy);
                float4 wB = sampleVelocity(i.uv - float2(0,1)*_MainTex_TexelSize.xy);
                float4 wT = sampleVelocity(i.uv + float2(0,1)*_MainTex_TexelSize.xy);

                float4 div = 1;
                div.xyz = 0.5*((wR.x - wL.x) + (wT.y - wB.y));
                div.xyz = (div.xyz + 1)/2;
                return div;
            }
            ENDCG
        }
    }
}
