Shader "Hidden/substract_pressure_gradient"
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
            sampler2D _P;
            float4 _P_TexelSize;

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
                float pL = (tex2D(_P, i.uv - float2(1,0)*_P_TexelSize.xy) - 0.5)*2;
                float pR = (tex2D(_P, i.uv + float2(1,0)*_P_TexelSize.xy) - 0.5)*2;
                float pB = (tex2D(_P, i.uv - float2(0,1)*_P_TexelSize.xy) - 0.5)*2;
                float pT = (tex2D(_P, i.uv + float2(0,1)*_P_TexelSize.xy) - 0.5)*2;

                float4 uNew = sampleVelocity(i.uv);
                uNew.xy -= 0.5*float2(pR - pL, pT - pB);
                uNew.xy = (uNew.xy + 1)/2;
                return uNew;
            }
            ENDCG
        }
    }
}
