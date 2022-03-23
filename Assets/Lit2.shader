Shader "Universal Render Pipeline/Lit2"
{
    Properties
    {
        // [HDR]_Color ("Color", Color) = (1,1,1,1)
        // _MainTex ("Albedo (RGB)", 2D) = "white" {}
        // _Glossiness ("Smoothness", Range(0,1)) = 0.5  
        // _Metallic ("Metallic", Range(0,1)) = 0.0
        // [NoScaleOffset][Normal]_Normal("_Normal", 2D) = "Bump" {}
        // _UVMoveSpeedX("_UVMoveSpeedX", Range(0, 3)) = 1
        // _UVMoveSpeedY("_UVMoveSpeedY", Range(0, 3)) = 1
        // _Cutoff("_CutOff", Range(0.001, 1)) = 1
        // _AlphaMap("_AlphaMap", 2D) = "white" {}
        // _AlphaHigh("_AlphaHigh", int) = 19.5
        // _AlphaLow("_AlphaLow", int) = 0


        // [Header(Specular)]
        // _SpecMul("_SpecMul", Range(0, 10)) = 1
        // [PowerSlider(3.0)]_SpecPow("_Spec", Range(0, 10000)) = 1
        // [HDR]_SpecColor("_SpecColor", Color) = (1, 1, 1, 1)

        // [Header(RimLight)]
        // _RimMul("_RimMul", int) = 1
        // _RimPow("RimPow", int) = 1
        // [HDR]_RimColor("_RimColor", Color) = (0, 0, 0, 0)

        // [Header(Vertex)]
        // _VertexAniTex("_VertexAniTex", 2D) = "white" {}
        // _VertAmount("_VertAmount", Range(0, 5)) = 1
        // _VertMoveSpeedX("_VertMoveSpeedX", int) = 1
        // _VertMoveSpeedY("_VertMoveSpeedY", int) = 1


        [HideInInspector] _WorkflowMode("WorkflowMode", Float) = 1.0

        [HDR][MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5

        //_GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
        //_SmoothnessTextureChannel("Smoothness texture channel", Float) = 0

        [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        //_MetallicGlossMap("Metallic", 2D) = "white" {}

        [HDR]_SpecColor("Specular", Color) = (0.2, 0.2, 0.2)
        //_SpecGlossMap("Specular", 2D) = "white" {}

        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0

        //_BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
        //_OcclusionMap("Occlusion", 2D) = "white" {}

        _EmissionColor("Color", Color) = (0,0,0)
        //_EmissionMap("Emission", 2D) = "white" {}

        //old waterDress properties
        [Header(Specular)]
        _SpecMul("_SpecMul", Range(0, 10)) = 1
        [PowerSlider(3.0)]_SpecPow("_Spec", Range(0, 10000)) = 1

        [Header(RimLight)]
        _RimMul("_RimMul", int) = 1
        _RimPow("RimPow", int) = 1
        [HDR]_RimColor("_RimColor", Color) = (0, 0, 0, 0)

        _UVMoveSpeedX("_UVMoveSpeedX", Range(0, 3)) = 1
        _UVMoveSpeedY("_UVMoveSpeedY", Range(0, 3)) = 1
        _VertexAniTex("_VertexAniTex", 2D) = "white" {}
        _VertAmount("_VertAmount", Range(0, 5)) = 1
        _VertMoveSpeedX("_VertMoveSpeedX", int) = 1
        _VertMoveSpeedY("_VertMoveSpeedY", int) = 1

        _AlphaMap("_AlphaMap", 2D) = "white" {}
        _AlphaHigh("_AlphaHigh", int) = 19.5
        _AlphaLow("_AlphaLow", int) = 0

        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 2.0

        _ReceiveShadows("Receive Shadows", Float) = 1.0
        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0
    }

    SubShader
    {
        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
        Tags{"RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        LOD 300

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard SRP library
            // All shaders must be compiled with HLSLcc and currently only gles is not using HLSLcc by default
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICSPECGLOSSMAP
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _OCCLUSIONMAP

            #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature _SPECULAR_SETUP
            #pragma shader_feature _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            //verterx & fragment
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Water_LitInput.hlsl"
            //float4 _BaseColor;
            //sampler2D _BaseMap;
            //float4 _BaseMap_ST;
            //sampler2D _Normal;
            //half _Metallic;
    
            sampler2D _AlphaMap;
            float4 _AlphaMap_ST;
            float _AlphaHigh;
            float _AlphaLow;

            float _UVMoveSpeedX;
            float _UVMoveSpeedY;

            float _SpecMul;
            float _SpecPow;

            float _RimMul;
            float _RimPow;
            float3 _RimColor;

            sampler2D _GrabTexture;
            sampler2D _VertexAniTex;

            float _VertAmount;
            float _VertMoveSpeedX;
            float _VertMoveSpeedY;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangentOS : TANGENT;
                float2 lightmapUV : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID //?
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD2;

                #ifdef _NORMALMAP
                    float4 normalWS                 : TEXCOORD3;    // xyz: normal, w: viewDir.x
                    float4 tangentWS                : TEXCOORD4;    // xyz: tangent, w: viewDir.y
                    float4 bitangentWS              : TEXCOORD5;    // xyz: bitangent, w: viewDir.z
                #else
                    float3 normalWS                 : TEXCOORD3;
                    float3 viewDirWS                : TEXCOORD4;
                #endif

                half4 fogFactorAndVertexLight   : TEXCOORD6; // x: fogFactor, yzw: vertex light

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    float4 shadowCoord              : TEXCOORD7;
                #endif

                float2 uvAlpha : TEXCOORD8;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            
            void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
            {
                inputData = (InputData)0; 

                #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
                    inputData.positionWS = input.positionWS;  
                #endif

                #ifdef _NORMALMAP
                    half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
                    inputData.normalWS = TransformTangentToWorld(normalTS,
                        half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
                #else
                    half3 viewDirWS = input.viewDirWS;
                    inputData.normalWS = input.normalWS;
                #endif

                    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                    viewDirWS = SafeNormalize(viewDirWS);
                    inputData.viewDirectionWS = viewDirWS;

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    inputData.shadowCoord = input.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                #else
                    inputData.shadowCoord = float4(0, 0, 0, 0);
                #endif

                inputData.fogCoord = input.fogFactorAndVertexLight.x;
                inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
                inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
            }


            Varyings LitPassVertex (Attributes v) {
                Varyings o;

                float3 disp = tex2Dlod(_VertexAniTex, float4(v.texcoord.x + _Time.y * _VertMoveSpeedX, v.texcoord.y + _Time.y * _VertMoveSpeedY, 0, 0));
                v.positionOS.xyz += v.normalOS * disp.r  * _VertAmount;
                o.positionCS = TransformObjectToHClip(v.positionOS);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normalOS, v.tangentOS);
                half3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
                half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                o.uv = TRANSFORM_TEX(v.texcoord, _BaseMap);
                o.uvAlpha = TRANSFORM_TEX(v.texcoord, _AlphaMap);

                o.positionWS = vertexInput.positionWS;

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    o.shadowCoord = GetShadowCoord(vertexInput);
                #endif

                #ifdef _NORMALMAP
                    o.normalWS = half4(normalInput.normalWS, viewDirWS.x);
                    o.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
                    o.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
                #else
                    o.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                    o.viewDirWS = viewDirWS;
                #endif

                OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, o.lightmapUV);
                OUTPUT_SH(o.normalWS.xyz, o.vertexSH);
                
                o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

                #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
                    o.positionWS = vertexInput.positionWS;
                #endif

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    o.shadowCoord = GetShadowCoord(vertexInput);
                #endif

                return o;
            }

            half4 LitPassFragment(Varyings i) : SV_Target
            {
                SurfaceData surfaceData;
                InitializeStandardLitSurfaceData(i.uv, surfaceData);

                InputData inputData;
                InitializeInputData(i, surfaceData.normalTS, inputData);

                
                float2 UVAnimation = float2(i.uv.x + _Time.y * _UVMoveSpeedX, i.uv.y + _Time.y * _UVMoveSpeedY);
                // float3 NormalFinal = UnpackNormal(tex2D(_BumpMap, UVAnimation)); 
                float3 NormalFinal = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, UVAnimation)); 
                
                //float4 BaseColor = tex2D(_BaseMap, UVAnimation) * _BaseColor;
                float4 BaseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, UVAnimation);
                
                float4 screenPos = ComputeScreenPos(i.positionCS);
            
                float2 cameraUV = screenPos.xy / screenPos.w;

                // float3 GrabRender = tex2D(_GrabTexture, cameraUV);
                // float3 GrabRenderDistort = tex2D(_GrabTexture, cameraUV + NormalFinal * 0.1);

                float NdotV = saturate(dot(i.viewDirWS, NormalFinal));
                float3 Specular = (pow((NdotV * _SpecMul), _SpecPow)) * _SpecColor; 
                float3 RimLight = (pow(((1 - NdotV) * _RimMul), _RimPow)) * _RimColor;

                float MaskHigh = saturate(-(i.positionWS.y - _AlphaHigh));
                float MaskLow = saturate(i.positionWS.y + _AlphaLow);
                
                float AlphaMap = tex2D(_AlphaMap, float2(i.uvAlpha.x + _Time.y * _UVMoveSpeedX, i.uvAlpha.y + _Time.y * _UVMoveSpeedY));

                float MaskWorld = MaskHigh * MaskLow;
                float MaskFinal = MaskWorld * AlphaMap;

                //float3 Albedo = lerp(0, BaseColor.rgb * GrabRenderDistort.rgb, MaskWorld);
                float3 Albedo = lerp(0, BaseColor.rgb , MaskWorld);
                //float3 Emission = lerp(GrabRender.rgb, RimLight + Specular, MaskWorld);
                float3 Emission =  (RimLight + Specular) * MaskWorld;

                float Alpha = MaskFinal;

                // o.Albedo = lerp(0, BaseColor.rgb * GrabRenderDistort.rgb, MaskWorld);
                // o.Emission = lerp(GrabRender.rgb, RimLight + Specular, MaskWorld);
                // o.Metallic = _Metallic;
                // o.Smoothness = _Glossiness;
                // o.Alpha = MaskFinal;   

                float Occlusion = 0.1;


                half4 color = UniversalFragmentPBR(inputData, Albedo, _Metallic, Specular,_Smoothness, Occlusion, Emission, Alpha);

                color.rgb = MixFog(color.rgb, inputData.fogCoord);

                return color;
            }

            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
        // Pass
        // {
        //     Name "DepthOnly"
        //     Tags{"LightMode" = "DepthOnly"}

        //     ZWrite On
        //     ColorMask 0
        //     Cull[_Cull]

        //     HLSLPROGRAM
        //     // Required to compile gles 2.0 with standard srp library
        //     #pragma prefer_hlslcc gles
        //     #pragma exclude_renderers d3d11_9x
        //     #pragma target 2.0

        //     #pragma vertex DepthOnlyVertex
        //     #pragma fragment DepthOnlyFragment

        //     // -------------------------------------
        //     // Material Keywords
        //     #pragma shader_feature _ALPHATEST_ON
        //     #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

        //     //--------------------------------------
        //     // GPU Instancing
        //     #pragma multi_compile_instancing

        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
        //     ENDHLSL
        // }
        // This pass it not used during regular rendering, only for lightmap baking.
        // Pass
        // {
        //     Name "Meta"
        //     Tags{"LightMode" = "Meta"}

        //     Cull Off

        //     HLSLPROGRAM
        //     // Required to compile gles 2.0 with standard srp library
        //     #pragma prefer_hlslcc gles
        //     #pragma exclude_renderers d3d11_9x

        //     #pragma vertex UniversalVertexMeta
        //     #pragma fragment UniversalFragmentMeta

        //     #pragma shader_feature _SPECULAR_SETUP
        //     #pragma shader_feature _EMISSION
        //     #pragma shader_feature _METALLICSPECGLOSSMAP
        //     #pragma shader_feature _ALPHATEST_ON
        //     #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

        //     #pragma shader_feature _SPECGLOSSMAP

        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"

        //     ENDHLSL
        // }
        // Pass
        // {
        //     Name "Universal2D"
        //     Tags{ "LightMode" = "Universal2D" }

        //     Blend[_SrcBlend][_DstBlend]
        //     ZWrite[_ZWrite]
        //     Cull[_Cull]

        //     HLSLPROGRAM
        //     // Required to compile gles 2.0 with standard srp library
        //     #pragma prefer_hlslcc gles
        //     #pragma exclude_renderers d3d11_9x

        //     #pragma vertex vert
        //     #pragma fragment frag
        //     #pragma shader_feature _ALPHATEST_ON
        //     #pragma shader_feature _ALPHAPREMULTIPLY_ON

        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
        //     ENDHLSL
        // }


    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    //CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.LitShader"
}
