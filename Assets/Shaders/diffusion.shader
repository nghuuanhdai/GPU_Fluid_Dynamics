Shader "Hidden/diffusion"
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
            sampler2D _U;
            float _InterationCount;

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
                float dx = 1;

                float4 xL = sampleVelocity(i.uv - float2(1,0)*_MainTex_TexelSize.xy);
                float4 xR = sampleVelocity(i.uv + float2(1,0)*_MainTex_TexelSize.xy);
                float4 xB = sampleVelocity(i.uv - float2(0,1)*_MainTex_TexelSize.xy);
                float4 xT = sampleVelocity(i.uv + float2(0,1)*_MainTex_TexelSize.xy);

                float4 bC = (tex2D(_U, i.uv) - 0.5)*2;
                float alpha = dx*dx/(_InterationCount*unity_DeltaTime.x);
                float rBeta = 1/(4.0 + dx*dx/(_InterationCount*unity_DeltaTime.x));

                float4 newX = 1;
                newX.xy = ((xL + xR + xB + xT + alpha * bC)*rBeta).xy;
                newX.xy = (newX.xy + 1)/2;
                return newX; 
            }
            ENDCG
        }
    }
}
