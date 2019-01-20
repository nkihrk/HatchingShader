Shader "Custom/HatchingShaderLerpTes"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _NormalTex ("Normal Texture", 2D) = "bump" { }
        _NoiseTex ("Noise Texture", 2D) = "black" { }
        _Hatch0 ("Hatch0", 2D) = "white" { }
        _Hatch1 ("Hatch1", 2D) = "white" { }
        _Hatch2 ("Hatch2", 2D) = "white" { }
        _Hatch3 ("Hatch3", 2D) = "white" { }
        _Hatch4 ("Hatch4", 2D) = "white" { }
        _Hatch5 ("Hatch5", 2D) = "white" { }
        _MinDist ("Min Distance", Range(0.1, 50)) = 10
        _MaxDist ("Max Distance", Range(0.1, 50)) = 25
        _TessFactor ("Tessellation", Range(1, 50)) = 10
        _NoiseSpeed ("Noise Speed", Range(0.0, 10)) = 0.0
        _NoisePower ("Noise Power", Range(1.0, 3.0)) = 1.0
        _NoiseFactor ("Noise Factor", Range(0.0, 10)) = 0.0
        [Enum(OFF, 0, ON, 1)] _Hoge2 ("Toggle Billboard", int) = 0
        _Angle ("Angle", Range(0.0, 360.0)) = 0.0
        _Xcomp ("_Xcomp", Range(0.0, 0.99)) = 0.0
        _Ycomp ("_Ycomp", Range(0.0, 0.99)) = 0.0
        _Zcomp ("_Zcomp", Range(0.0, 0.99)) = 0.0
        _RimPower ("Rim Power", Float) = 0.0
        _RimAmplitude ("Rim Amplitude", Float) = 0.0
        _Threshold ("Threshold", Range(0.0, 1.0)) = 0.5
        _Adjust ("NdotL or NdotV", Range(0.0, 1.0)) = 0.6
        _Density ("Density", Range(0.0, 1.0)) = 0.6
        _Roughness ("Roughness", Range(0.1, 30)) = 8.0
        [Enum(OFF, 0, ON, 1)] _Hoge ("Toggle Gray Scale", int) = 0
        [Enum(OFF, 0, FRONT, 1, BACK, 2)] _CullMode ("Cull Mode", int) = 0
    }
    
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull[_CullMode]
        LOD 100

        CGINCLUDE
        #pragma target 3.0
        #pragma vertex vert
        #pragma fragment frag
        #pragma multi_compile_fog
        
        #include "UnityCG.cginc"
        #include "AutoLight.cginc"
        #include "UnityPBSLighting.cginc"
        

        #define one fixed4(1, 1, 1, 1)

        uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
        uniform sampler2D _NormalTex; uniform float4 _NormalTex_ST;
        uniform sampler2D _NoiseTex; uniform float4 _NoiseTex_ST;
        uniform sampler2D _Hatch0;
        uniform sampler2D _Hatch1;
        uniform sampler2D _Hatch2;
        uniform sampler2D _Hatch3;
        uniform sampler2D _Hatch4;
        uniform sampler2D _Hatch5;
        uniform float _MinDist;
        uniform float _MaxDist;
        uniform float _TessFactor;
        uniform float _NoiseSpeed;
        uniform float _NoisePower;
        uniform float _NoiseFactor;
        uniform float _Xcomp;
        uniform float _Ycomp;
        uniform float _Zcomp;
        uniform float _RimPower;
        uniform float _RimAmplitude;
        uniform float _Threshold;
        uniform float _Adjust;
        uniform float _Density;
        uniform float _Roughness;
        uniform int _Hoge;
        uniform int _Hoge2;
        uniform float _Angle;

        float C2F(float3 Color)
        {
            int c1 = 255;
            int c2 = 255 * 255;
            int c3 = 255 * 255 * 255;
            return(Color.x * 255 + Color.y * 255 * c1 + Color.z * 255 * c2) / c3;
        }

        fixed2 rand(fixed2 st)
        {
            st = fixed2(dot(st, fixed2(127.1, 311.7)), dot(st, fixed2(269.5, 183.3)));
            return - 1.0 + 2.0 * frac(sin(st) * 43758.5453123);
        }
        
        float perlinNoise(fixed2 st)
        {
            fixed2 p = floor(st);
            fixed2 f = frac(st);
            fixed2 u = f * f * (3.0 - 2.0 * f);
            float v00 = rand(p + fixed2(0, 0));
            float v10 = rand(p + fixed2(1, 0));
            float v01 = rand(p + fixed2(0, 1));
            float v11 = rand(p + fixed2(1, 1));
            return lerp(lerp(dot(v00, f - fixed2(0, 0)), dot(v10, f - fixed2(1, 0)), u.x), lerp(dot(v01, f - fixed2(0, 1)), dot(v11, f - fixed2(1, 1)), u.x), u.y) + 0.5f;
        }
        
        float fBm(fixed2 st)
        {
            float f = 0;
            fixed2 q = st;
            f += 0.5000 * perlinNoise(q); q = q * 2.01;
            f += 0.2500 * perlinNoise(q); q = q * 2.02;
            f += 0.1250 * perlinNoise(q); q = q * 2.03;
            f += 0.0625 * perlinNoise(q); q = q * 2.01;
            return f;
        }
        
        float2x2 rotateFnc(float b)
        {
            float alpha = b * UNITY_PI / 180.0;
            float sina, cosa;
            sincos(alpha, sina, cosa);
            return float2x2(cosa, -sina, sina, cosa);
        }

        float4 Rotate(float4 a, float b)
        {
            float2x2 m = rotateFnc(b);
            return float4(mul(m, a.xz), a.yw).xzyw;
        }
        ENDCG
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            
            #pragma hull hull
            #pragma domain domain
            #pragma multi_compile_fwdbase
            #pragma multi_compile _ VERTEXLIGHT_ON

            #include "Tessellation.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float3 normal: NORMAL;
                float3 tangent: TANGENT;
            };

            struct v2h
            {
                float4 f4Position: TEXCOORD0;
                float3 f3Normal: TEXCOORD1;
                float2 f2TexCoord: TEXCOORD2;
                float3 f3Tangent: TEXCOORD3;
            };

            struct HsControlPointOutput
            {
                float3 f3Position: TEXCOORD0;
                float3 f3Normal: TEXCOORD1;
                float2 f2TexCoord: TEXCOORD2;
                float3 f3Tangent: TEXCOORD3;
            };

            struct HsConstantOutput
            {
                float fTessFactor[3]: SV_TESSFACTOR;
                float fInsideTessFactor: SV_INSIDETESSFACTOR;
            };

            struct h2f
            {
                float2 uv: TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
                float3 normal: TEXCOORD2;
                float2 huv: TEXCOORD3;
                float4 wpos: TEXCOORD4;
                LIGHTING_COORDS(5, 6)
                float3 tangent: TEXCOORD7;
                float3 binormal: TEXCOORD8;
                #if defined(VERTEXLIGHT_ON)
                    fixed3 vertexLightColor: TEXCOORD9;
                #endif
            };

            void ComputeVertexLightColor(inout h2f i)
            {
                #if defined(VERTEXLIGHT_ON)
                    i.vertexLightColor = Shade4PointLights(
                        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                        unity_LightColor[0].rgb, unity_LightColor[1].rgb,
                        unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                        unity_4LightAtten0, i.wpos, i.normal
                    );
                #endif
            }

            v2h vert(appdata i)
            {
                v2h o;
                o.f4Position = i.vertex;
                o.f3Normal = i.normal;
                o.f2TexCoord = i.uv;
                o.f3Tangent = i.tangent;
                return o;
            }

            [domain("tri")]
            [partitioning("integer")]
            [outputtopology("triangle_cw")]
            [patchconstantfunc("hullConst")]
            [outputcontrolpoints(3)]
            HsControlPointOutput hull(InputPatch < v2h, 3 > i, uint id: SV_OUTPUTCONTROLPOINTID)
            {
                HsControlPointOutput o = (HsControlPointOutput)0;
                o.f3Position = i[id].f4Position.xyz;
                o.f3Normal = i[id].f3Normal;
                o.f2TexCoord = i[id].f2TexCoord;
                o.f3Tangent = i[id].f3Tangent;
                return o;
            }

            HsConstantOutput hullConst(InputPatch < v2h, 3 > i)
            {
                HsConstantOutput o = (HsConstantOutput)0;
                float4 p0 = i[0].f4Position;
                float4 p1 = i[1].f4Position;
                float4 p2 = i[2].f4Position;
                float4 tessFactor = UnityDistanceBasedTess(p0, p1, p2, _MinDist, _MaxDist, _TessFactor);

                o.fTessFactor[0] = tessFactor.x;
                o.fTessFactor[1] = tessFactor.y;
                o.fTessFactor[2] = tessFactor.z;
                o.fInsideTessFactor = tessFactor.w;
                return o;
            }

            [domain("tri")]
            h2f domain(HsConstantOutput hsConst, const OutputPatch < HsControlPointOutput, 3 > i, float3 bary: SV_DOMAINLOCATION)
            {
                h2f o = (h2f)0;

                float3 f3Position = bary.x * i[0].f3Position + bary.y * i[1].f3Position + bary.z * i[2].f3Position;
                float3 f3Normal = bary.x * i[0].f3Normal + bary.y * i[1].f3Normal + bary.z * i[2].f3Normal;
                float3 f3Tangent = bary.x * i[0].f3Tangent + bary.y * i[1].f3Tangent + bary.z * i[2].f3Tangent;
                float2 f2TexCoord = bary.x * i[0].f2TexCoord + bary.y * i[1].f2TexCoord + bary.z * i[2].f2TexCoord;
                
                float2 uvNoise = TRANSFORM_TEX(f2TexCoord, _NoiseTex);
                float angle = 180 * UNITY_PI * (_Time.x / 100 * _NoiseSpeed);
                float pivot = 0.5;
                float x = (uvNoise.x - pivot) * cos(angle) - (uvNoise.y - pivot) * sin(angle) + pivot;
                float y = (uvNoise.x - pivot) * sin(angle) + (uvNoise.y - pivot) * cos(angle) + pivot;
                uvNoise = float2(x, y);
                fixed4 noiseTex = tex2Dlod(_NoiseTex, float4(uvNoise, 0, 0));
                float c2f = pow(pow(_NoisePower, _NoisePower), C2F(noiseTex.rgb));
                float c = fBm(f2TexCoord.xy * _Time.x * _NoiseSpeed);
                fixed4 prlNoise = lerp(fixed4(c, c, c, 1), fixed4(c2f, c2f, c2f, 1), saturate(noiseTex * 100));

                f3Position.xyz += f3Normal * prlNoise.xyz * _NoiseFactor;
                float4 f4Position = mul(unity_ObjectToWorld, float4(f3Position.xyz, 1.0));

                o.wpos = f4Position;
                float4 vertex = Rotate(float4(f3Position.xyz, 1.0), _Angle);
                vertex.xyz = vertex.xyz * (1 - float3(_Xcomp, _Ycomp, _Zcomp));
                float4 pos = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1)) + float4(vertex.x, vertex.y, vertex.z, 0));
                o.vertex = lerp(UnityObjectToClipPos(vertex), pos, _Hoge2);
                o.uv = TRANSFORM_TEX(f2TexCoord, _MainTex);
                o.huv = TRANSFORM_TEX(f2TexCoord, _MainTex) * _Roughness;
                o.normal = UnityObjectToWorldNormal(f3Normal);
                o.tangent = UnityObjectToWorldNormal(f3Tangent);
                o.binormal = normalize(cross(o.tangent, o.normal));
                ComputeVertexLightColor(o);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }
            
            fixed4 frag(h2f i): SV_Target
            {
                float3 tangentNormal = float4(UnpackNormal(tex2D(_NormalTex, i.uv)), 1);
                float3x3 TBN = float3x3(i.tangent, i.binormal, i.normal);
                TBN = transpose(TBN);
                float3 worldNormal = mul(TBN, tangentNormal);

                float3 N = lerp(i.normal, worldNormal, saturate(length(tangentNormal) * 100));

                float3 lightDir;
                #if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
                    lightDir = normalize(_WorldSpaceLightPos0.xyz - i.wpos.xyz);
                #else
                    lightDir = _WorldSpaceLightPos0.xyz;
                #endif

                fixed4 lightCol;
                #if defined(VERTEXLIGHT_ON)
                    lightCol = fixed4(i.vertexLightColor, 1);
                #else
                    lightCol = _LightColor0;
                #endif

                lightCol.rgb += max(0, ShadeSH9(float4(N, 1)));

                float3 L = lightDir;
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.wpos.xyz);

                float NdotV = max(0, dot(N, V));
                float NNdotV = 1 - dot(N, V);
                float rim = pow(NNdotV, _RimPower) * _RimAmplitude;

                float NdotL = max(0, dot(L, N));
                UNITY_LIGHT_ATTENUATION(attenuation, i, N)
                lightCol *= attenuation;

                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 hatch0 = tex2D(_Hatch0, i.huv);
                fixed4 hatch1 = tex2D(_Hatch1, i.huv);
                fixed4 hatch2 = tex2D(_Hatch2, i.huv);
                fixed4 hatch3 = tex2D(_Hatch3, i.huv);
                fixed4 hatch4 = tex2D(_Hatch4, i.huv);
                fixed4 hatch5 = tex2D(_Hatch5, i.huv);

                if (length(lightCol.rgb) < _Threshold)
                {
                    float3 diffuse = col.rgb * NdotV;
                    float intensity = lerp(saturate(length(diffuse)), 0.5 * saturate(dot(diffuse, half3(0.2326, 0.7152, 0.0722))), _Density);

                    col *= one;
                    col *= lerp(one, lerp(hatch0, hatch1, 1 - intensity), step(0.5, step(intensity, 0.6)));
                    col *= lerp(one, lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), step(0.4, step(intensity, 0.5)));
                    col *= lerp(one, lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), step(0.3, step(intensity, 0.4)));
                    col *= lerp(one, lerp(lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), hatch4, 1 - intensity), step(0.2, step(intensity, 0.3)));
                    col *= lerp(one, lerp(lerp(lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), hatch4, 1 - intensity), hatch4, 1 - intensity), step(0.1, step(intensity, 0.2)));
                    col *= lerp(one, lerp(lerp(lerp(lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), hatch4, 1 - intensity), hatch4, 1 - intensity), hatch5 * 0.5, NdotV * 1.5), step(intensity, 0.1));
                }
                else
                {
                    float manipulate = lerp(NdotL, NdotV, _Adjust);
                    float3 diffuse = lerp(col.rgb * manipulate, lightCol, 1.0 / pow(3, length(lightCol)));
                    float intensity = lerp(saturate(length(diffuse)), 0.5 * saturate(dot(diffuse, half3(0.2326, 0.7152, 0.0722))), _Density);

                    col *= one;
                    col *= lerp(one, lerp(hatch0, hatch1, 1 - intensity), step(0.5, step(intensity, 0.6)));
                    col *= lerp(one, lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), step(0.4, step(intensity, 0.5)));
                    col *= lerp(one, lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), step(0.3, step(intensity, 0.4)));
                    col *= lerp(one, lerp(lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), hatch4, 1 - intensity), step(0.2, step(intensity, 0.3)));
                    col *= lerp(one, lerp(lerp(lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), hatch4, 1 - intensity), hatch4, 1 - intensity), step(0.1, step(intensity, 0.2)));
                    col *= lerp(one, lerp(lerp(lerp(lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), hatch4, 1 - intensity), hatch4, 1 - intensity), hatch5 * 0.5, (1 - NdotL) * 1.5), step(intensity, 0.1));
                }

                col.rgb = lerp(col.rgb, dot(col.rgb, half3(0.2326, 0.7152, 0.0722)), _Hoge) * _LightColor0.rgb;

                fixed3 colRim = col.rgb * 1.0 + rim * fixed3(1.0, 1.0, 1.0);
                col.rgb = lerp(col.rgb, colRim, V);
                col.a = 1;

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
            
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            CGPROGRAM
            
            #pragma hull hull
            #pragma domain domain
            #pragma multi_compile_fwdadd

            #include "Tessellation.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float3 normal: NORMAL;
                float3 tangent: TANGENT;
            };

            struct v2h
            {
                float4 f4Position: TEXCOORD0;
                float3 f3Normal: TEXCOORD1;
                float2 f2TexCoord: TEXCOORD2;
                float3 f3Tangent: TEXCOORD3;
            };

            struct HsControlPointOutput
            {
                float3 f3Position: TEXCOORD0;
                float3 f3Normal: TEXCOORD1;
                float2 f2TexCoord: TEXCOORD2;
                float3 f3Tangent: TEXCOORD3;
            };

            struct HsConstantOutput
            {
                float fTessFactor[3]: SV_TESSFACTOR;
                float fInsideTessFactor: SV_INSIDETESSFACTOR;
            };

            struct h2f
            {
                float2 uv: TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex: SV_POSITION;
                float3 normal: TEXCOORD2;
                float2 huv: TEXCOORD3;
                float4 wpos: TEXCOORD4;
                LIGHTING_COORDS(5, 6)
                float3 tangent: TEXCOORD7;
                float3 binormal: TEXCOORD8;
            };

            v2h vert(appdata i)
            {
                v2h o;
                o.f4Position = i.vertex;
                o.f3Normal = i.normal;
                o.f2TexCoord = i.uv;
                o.f3Tangent = i.tangent;
                return o;
            }

            [domain("tri")]
            [partitioning("integer")]
            [outputtopology("triangle_cw")]
            [patchconstantfunc("hullConst")]
            [outputcontrolpoints(3)]
            HsControlPointOutput hull(InputPatch < v2h, 3 > i, uint id: SV_OUTPUTCONTROLPOINTID)
            {
                HsControlPointOutput o = (HsControlPointOutput)0;
                o.f3Position = i[id].f4Position.xyz;
                o.f3Normal = i[id].f3Normal;
                o.f2TexCoord = i[id].f2TexCoord;
                o.f3Tangent = i[id].f3Tangent;
                return o;
            }

            HsConstantOutput hullConst(InputPatch < v2h, 3 > i)
            {
                HsConstantOutput o = (HsConstantOutput)0;
                float4 p0 = i[0].f4Position;
                float4 p1 = i[1].f4Position;
                float4 p2 = i[2].f4Position;
                float4 tessFactor = UnityDistanceBasedTess(p0, p1, p2, _MinDist, _MaxDist, _TessFactor);
                
                o.fTessFactor[0] = tessFactor.x;
                o.fTessFactor[1] = tessFactor.y;
                o.fTessFactor[2] = tessFactor.z;
                o.fInsideTessFactor = tessFactor.w;
                return o;
            }

            [domain("tri")]
            h2f domain(HsConstantOutput hsConst, const OutputPatch < HsControlPointOutput, 3 > i, float3 bary: SV_DOMAINLOCATION)
            {
                h2f o = (h2f)0;

                float3 f3Position = bary.x * i[0].f3Position + bary.y * i[1].f3Position + bary.z * i[2].f3Position;
                float3 f3Normal = bary.x * i[0].f3Normal + bary.y * i[1].f3Normal + bary.z * i[2].f3Normal;
                float3 f3Tangent = bary.x * i[0].f3Tangent + bary.y * i[1].f3Tangent + bary.z * i[2].f3Tangent;
                float2 f2TexCoord = bary.x * i[0].f2TexCoord + bary.y * i[1].f2TexCoord + bary.z * i[2].f2TexCoord;
                
                float2 uvNoise = TRANSFORM_TEX(f2TexCoord, _NoiseTex);
                float angle = 180 * UNITY_PI * (_Time.x / 100 * _NoiseSpeed);
                float pivot = 0.5;
                float x = (uvNoise.x - pivot) * cos(angle) - (uvNoise.y - pivot) * sin(angle) + pivot;
                float y = (uvNoise.x - pivot) * sin(angle) + (uvNoise.y - pivot) * cos(angle) + pivot;
                uvNoise = float2(x, y);
                fixed4 noiseTex = tex2Dlod(_NoiseTex, float4(uvNoise, 0, 0));
                float c2f = pow(pow(_NoisePower, _NoisePower), C2F(noiseTex.rgb));
                float c = fBm(f2TexCoord.xy * _Time.x * _NoiseSpeed);
                fixed4 prlNoise = lerp(fixed4(c, c, c, 1), fixed4(c2f, c2f, c2f, 1), saturate(noiseTex * 100));
                
                f3Position.xyz += f3Normal * prlNoise.xyz * _NoiseFactor;
                float4 f4Position = mul(unity_ObjectToWorld, float4(f3Position.xyz, 1.0));

                o.wpos = f4Position;
                float4 vertex = Rotate(float4(f3Position.xyz, 1.0), _Angle);
                vertex.xyz = vertex.xyz * (1 - float3(_Xcomp, _Ycomp, _Zcomp));
                float4 pos = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1)) + float4(vertex.x, vertex.y, vertex.z, 0));
                o.vertex = lerp(UnityObjectToClipPos(vertex), pos, _Hoge2);
                o.uv = TRANSFORM_TEX(f2TexCoord, _MainTex);
                o.huv = TRANSFORM_TEX(f2TexCoord, _MainTex) * _Roughness;
                o.normal = UnityObjectToWorldNormal(f3Normal);
                o.tangent = UnityObjectToWorldNormal(f3Tangent);
                o.binormal = normalize(cross(o.tangent, o.normal));
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }
            
            fixed4 frag(h2f i): SV_Target
            {
                float3 tangentNormal = float4(UnpackNormal(tex2D(_NormalTex, i.uv)), 1);
                float3x3 TBN = float3x3(i.tangent, i.binormal, i.normal);
                TBN = transpose(TBN);
                float3 worldNormal = mul(TBN, tangentNormal);

                float3 N = lerp(i.normal, worldNormal, saturate(length(tangentNormal) * 100));
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.wpos.xyz);
                
                float3 lightDir;
                #if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
                    lightDir = normalize(_WorldSpaceLightPos0.xyz - i.wpos.xyz);
                #else
                    lightDir = _WorldSpaceLightPos0.xyz;
                #endif
                fixed4 lightCol = _LightColor0;
                lightCol.rgb += max(0, ShadeSH9(float4(N, 1)));
                float3 L = lightDir;

                float NdotV = max(0, dot(N, V));
                float NNdotV = 1 - dot(N, V);
                float rim = pow(NNdotV, _RimPower) * _RimAmplitude;

                float NdotL = max(0, dot(L, N));
                UNITY_LIGHT_ATTENUATION(attenuation, i, N)
                lightCol *= attenuation;

                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 hatch0 = tex2D(_Hatch0, i.huv);
                fixed4 hatch1 = tex2D(_Hatch1, i.huv);
                fixed4 hatch2 = tex2D(_Hatch2, i.huv);
                fixed4 hatch3 = tex2D(_Hatch3, i.huv);
                fixed4 hatch4 = tex2D(_Hatch4, i.huv);
                fixed4 hatch5 = tex2D(_Hatch5, i.huv);

                if(length(lightCol.rgb) < _Threshold)
                {
                    float3 diffuse = col.rgb * NdotV;
                    float intensity = lerp(saturate(length(diffuse)), 0.5 * saturate(dot(diffuse, half3(0.2326, 0.7152, 0.0722))), _Density);

                    col *= one;
                    col *= lerp(one, lerp(hatch0, hatch1, 1 - intensity), step(0.5, step(intensity, 0.6)));
                    col *= lerp(one, lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), step(0.4, step(intensity, 0.5)));
                    col *= lerp(one, lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), step(0.3, step(intensity, 0.4)));
                    col *= lerp(one, lerp(lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), hatch4, 1 - intensity), step(0.2, step(intensity, 0.3)));
                    col *= lerp(one, lerp(lerp(lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), hatch4, 1 - intensity), hatch4, 1 - intensity), step(0.1, step(intensity, 0.2)));
                    col *= lerp(one, lerp(lerp(lerp(lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), hatch4, 1 - intensity), hatch4, 1 - intensity), hatch5 * 0.5, NdotV * 1.5), step(intensity, 0.1));
                }
                else
                {
                    float manipulate = lerp(NdotL, NdotV, _Adjust);
                    float3 diffuse = lerp(col.rgb * manipulate, lightCol, 1.0 / pow(3, length(lightCol)));
                    float intensity = lerp(saturate(length(diffuse)), 0.5 * saturate(dot(diffuse, half3(0.2326, 0.7152, 0.0722))), _Density);

                    col *= one;
                    col *= lerp(one, lerp(hatch0, hatch1, 1 - intensity), step(0.5, step(intensity, 0.6)));
                    col *= lerp(one, lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), step(0.4, step(intensity, 0.5)));
                    col *= lerp(one, lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), step(0.3, step(intensity, 0.4)));
                    col *= lerp(one, lerp(lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), hatch4, 1 - intensity), step(0.2, step(intensity, 0.3)));
                    col *= lerp(one, lerp(lerp(lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), hatch4, 1 - intensity), hatch4, 1 - intensity), step(0.1, step(intensity, 0.2)));
                    col *= lerp(one, lerp(lerp(lerp(lerp(lerp(lerp(hatch0, hatch1, 1 - intensity), hatch2, 1 - intensity), hatch3, 1 - intensity), hatch4, 1 - intensity), hatch4, 1 - intensity), hatch5 * 0.5, (1 - NdotL) * 1.5), step(intensity, 0.1));
                }

                col.rgb = lerp(col.rgb, dot(col.rgb, half3(0.2326, 0.7152, 0.0722)), _Hoge) * _LightColor0.rgb;

                fixed3 colRim = col.rgb * 1.0 + rim * fixed3(1.0, 1.0, 1.0);
                col.rgb = lerp(col.rgb, colRim, V);
                col.a = 1;

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
            
        }
    }
    Fallback "Diffuse"
}
