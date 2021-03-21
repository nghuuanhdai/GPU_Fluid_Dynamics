Shader "Hidden/pressure_compute"
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
            sampler2D _P_Divergence;
            float _InterationCount;

            float4 frag (v2f i) : SV_Target
            {
                float dx = 1;

                float4 xL = (tex2D(_MainTex,i.uv - float2(1,0)*_MainTex_TexelSize.xy) - 0.5)*2;
                float4 xR = (tex2D(_MainTex,i.uv + float2(1,0)*_MainTex_TexelSize.xy) - 0.5)*2;
                float4 xB = (tex2D(_MainTex,i.uv - float2(0,1)*_MainTex_TexelSize.xy) - 0.5)*2;
                float4 xT = (tex2D(_MainTex,i.uv + float2(0,1)*_MainTex_TexelSize.xy) - 0.5)*2;

                float4 bC = (tex2D(_P_Divergence, i.uv) - 0.5)*2;
                float alpha = -dx*dx;
                float rBeta = 1/4.0;

                float4 newX = 1;
                newX.xy = ((xL + xR + xB + xT + alpha * bC)*rBeta).xy;
                newX.xy = (newX.xy + 1)/2;
                return newX; 
            }
            ENDCG
        }
    }
}
