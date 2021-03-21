Shader "Hidden/qty_paint_input"
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
            sampler2D _Input;

            fixed4 alphaBlend(fixed4 src, fixed4 dst)
            {
                fixed4 c = src;
                c.rgb = src.rgb*(1 - dst.a) + dst.rgb*dst.a;
                c.a = src.a + dst.a;
                return c;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 input = tex2D(_Input, i.uv);
                fixed4 reversedInput = 1 - input;
                reversedInput.a = input.a;
                return alphaBlend(col, lerp(input, reversedInput, (sin(_Time.z) + 1)/2));
            }
            ENDCG
        }
    }
}
