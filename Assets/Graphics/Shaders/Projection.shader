// http://www.rastertek.com/dx11tut43.html

Shader "Custom/Projection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ProjectionTexture  ("Projection Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 position : POSITION;
                float2 tex : TEXCOORD0;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 tex : TEXCOORD0;
                float4 viewPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _ProjectionTexture;
            float4 _MainTex_ST;
            float4 _ProjectionTexture_ST;
            uniform float4x4 _ProjectionMatrix;
            uniform float4x4 _ViewMatrix;

            // Custom implementation of UnityObjectToClipPos
            // Translates vertex to clip space.
            float4 ObjectToCLipPos(float4x4 objectMatrix, float4 vertex)
            {
                // view projection matrix
                float4x4 ViewProjection = mul(UNITY_MATRIX_P,UNITY_MATRIX_V);
                // object in world space
                float4 ObjectWorld = mul(objectMatrix, float4(vertex.xyz, 1.0));
                float4 pos = mul(ViewProjection, ObjectWorld);
                return pos;
            }


            v2f vert (appdata input)
            {
                v2f output;
                float4x4 viewMatrix = UNITY_MATRIX_V;
                float4x4 viewMatrix2 = _ViewMatrix;
                float4x4 projectionMatrix = UNITY_MATRIX_P;
                float4x4 projectionMatrix2 = _ProjectionMatrix;
                float4x4 worldMatrix = unity_ObjectToWorld;

                input.position.w = 1.0f;
                output.position = mul(worldMatrix, input.position);
                output.position = mul(viewMatrix, output.position);
                output.position = mul(projectionMatrix, output.position);

                output.viewPosition = mul(worldMatrix, input.position);
                output.viewPosition = mul(viewMatrix2, output.viewPosition);
                output.viewPosition = mul( projectionMatrix2, output.viewPosition);

                output.tex = input.tex;

                return output;
            }

            fixed4 frag (v2f input) : SV_Target
            {
                float4 color = tex2D(_MainTex, input.tex);
                float2 projectTexCoord;
                float4 projectionColor;

                projectTexCoord.x =  input.viewPosition.x / input.viewPosition.w * 0.5f + 0.5f;
                projectTexCoord.y = -input.viewPosition.y / input.viewPosition.w * 0.5f + 0.5f;

                projectionColor = tex2D(_ProjectionTexture, projectTexCoord);
                color =  color * projectionColor;
                return color;
            }
            ENDCG
        }
    }
}
