Shader "Hidden/advection"
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
            float _CarryF;

            float4 frag (v2f i) : SV_Target
            {
                float dx = _CarryF;
                float2 velocity = tex2D(_U, i.uv).xy;
                velocity = (velocity - 0.5)*2;
                float2 sample_pos = i.uv - unity_DeltaTime.x*velocity*dx;
                return tex2D(_MainTex, sample_pos);
            }
            ENDCG
        }
    }
}
