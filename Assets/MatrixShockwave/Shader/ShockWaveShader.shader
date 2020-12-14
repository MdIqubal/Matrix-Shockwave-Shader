//Author : Mohammed Iqubal
//MIT license
//https://twitter.com/polyandcode
//https://polyandcode.com

Shader "ShockWaveShader" {
        Properties{
            _EdgeLength("Edge length", Range(2,50)) = 15
            _MainTex("Base (RGB)", 2D) = "white" {}
            _NormalMap("Normalmap", 2D) = "bump" {}
            _Color("Color", color) = (1,1,1,0)
            [Header(Shockwave)]
            _StartPos("Start Position", Vector) = (0,0,0,0)
            _Height("Height",Float) = 0.0
            _Thickness("Thickness",Float) = 0.0
            _FadeDistance("Fade distance", Float) = 1
            _Speed("Speed", Float) = 0
            [Toggle]_StartShockWave("Start ShockWave", Float) = 0
        }
            SubShader{
                Tags { "RenderType" = "Opaque" }
                LOD 300

                CGPROGRAM
                #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessEdge nolightmap
                #pragma target 4.6
                #include "Tessellation.cginc"

                struct appdata {
                    float4 vertex : POSITION;
                    float4 tangent : TANGENT;
                    float3 normal : NORMAL;
                    float2 texcoord : TEXCOORD0;
                };

                float _EdgeLength;
    
                float4 tessEdge(appdata v0, appdata v1, appdata v2)
                {
                    return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
                }

                float _Height;
                float4 _StartPos;
                float _Thickness;
                float _Speed;
                float _FadeDistance;
                float _StartShockWave;
                float _CurrTime;

                void disp(inout appdata v)
                {
                    if (_StartShockWave != 1) {
                        return;
                    }
                    //moving wave radius, _currTime is set from script
                    float waveRadius = (_Time.y - _CurrTime)* _Speed;
                    
                    //Get vertex pos in world and calculate current radius from start pos
                    float4 vertexWorldPos = mul(unity_ObjectToWorld, v.vertex);
                    float currRadius = distance(vertexWorldPos.xyz, _StartPos.xyz);

                    //if the vertex lies in the wave and within fade distance, pull it up
                    if (currRadius < _FadeDistance && currRadius > waveRadius && currRadius < (waveRadius + _Thickness)){
                        //Get a value from current radius in 0 - pi range
                        float theta = (currRadius - waveRadius) / _Thickness * 3.14;
                        //get height from sin for a sin like crest
                        float currHeight = sin(theta) * _Height;
                        //To fade the wave as it approaches the fade distance
                        float fadeFactor = 1 - currRadius / _FadeDistance;
                        vertexWorldPos.xyz += v.normal * currHeight * fadeFactor ;
                        //Assign back the vertex pos in object space
                        v.vertex = mul(unity_WorldToObject, vertexWorldPos);
                    } 
                }

                struct Input {
                    float2 uv_MainTex;
                };

                sampler2D _MainTex;
                sampler2D _NormalMap;
                fixed4 _Color;

                void surf(Input IN, inout SurfaceOutput o) {
                    half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
                    o.Albedo = c.rgb;
                    o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
                }
                ENDCG
            }
            FallBack "Diffuse"
    }