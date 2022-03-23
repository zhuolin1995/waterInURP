Shader "Custom/water tornado"
{
    Properties
    {
        [HDR]_Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5  
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [NoScaleOffset][Normal]_Normal("_Normal", 2D) = "Bump" {}
        _UVMoveSpeedX("_UVMoveSpeedX", Range(0, 3)) = 1
        _UVMoveSpeedY("_UVMoveSpeedY", Range(0, 3)) = 1
        _Cutoff("_CutOff", Range(0.001, 1)) = 1
        _AlphaMap("_AlphaMap", 2D) = "white" {}
        _AlphaHigh("_AlphaHigh", int) = 19.5
        _AlphaLow("_AlphaLow", int) = 0


        [Header(Specular)]
        _SpecMul("_SpecMul", Range(0, 10)) = 1
        [PowerSlider(3.0)]_SpecPow("_Spec", Range(0, 10000)) = 1
        [HDR]_SpecColor("_SpecColor", Color) = (1, 1, 1, 1)

        [Header(RimLight)]
        _RimMul("_RimMul", int) = 1
        _RimPow("RimPow", int) = 1
        [HDR]_RimColor("_RimColor", Color) = (0, 0, 0, 0)

        [Header(Vertex)]
        _VertexAniTex("_VertexAniTex", 2D) = "white" {}
        _VertAmount("_VertAmount", Range(0, 5)) = 1
        _VertMoveSpeedX("_VertMoveSpeedX", int) = 1
        _VertMoveSpeedY("_VertMoveSpeedY", int) = 1
    }
    SubShader
    {
        Tags {"RenderType"="Transparent"  "Quene" = "Transparent" }

        LOD 200
        Grabpass{}

        cull off

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:blend   

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        struct Input
        {
            float2 uv_MainTex;
            fixed3 viewDir;  //顶点到相机的向量
            fixed4 screenPos;  
            fixed3 worldPos;
            fixed2 uv_AlphaMap; 
        };

        fixed4 _Color;
        sampler2D _MainTex;
        sampler2D _Normal;
        half _Glossiness;
        half _Metallic;
 
        sampler2D _AlphaMap;
        fixed _AlphaHigh;
        fixed _AlphaLow;

        fixed _UVMoveSpeedX;
        fixed _UVMoveSpeedY;

        fixed _SpecMul;
        fixed _SpecPow;

        fixed _RimMul;
        fixed _RimPow;
        fixed3 _RimColor;

        sampler2D _GrabTexture;
        sampler2D _VertexAniTex;

        fixed _VertAmount;
        fixed _VertMoveSpeedX;
        fixed _VertMoveSpeedY;

        void vert(inout appdata_full v){
            fixed3 disp = tex2Dlod(_VertexAniTex, float4(v.texcoord.x + _Time.y * _VertMoveSpeedX, v.texcoord.y + _Time.y * _VertMoveSpeedY, 1, 1));
            v.vertex.xyz += v.normal * disp.r  * _VertAmount;
        }

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed2 UVAnimation = fixed2(IN.uv_MainTex.x + _Time.y * _UVMoveSpeedX, IN.uv_MainTex.y + _Time.y * _UVMoveSpeedY);

            fixed3 NormalFinal = UnpackNormal(tex2D(_Normal, UVAnimation));  //得到正确的法线方向
            o.Normal = NormalFinal;

            fixed4 BaseColor = tex2D(_MainTex, UVAnimation + o.Normal) *_Color;  //?

            fixed2 CameraUV = IN.screenPos.xy / IN.screenPos.w;  
            fixed3 GrabRender = tex2D(_GrabTexture, CameraUV);
            fixed3 GrabRenderDistort = tex2D(_GrabTexture, CameraUV + o.Normal * 0.1);

            fixed NdotV = saturate(dot(IN.viewDir, o.Normal));

            fixed3 Specular = (pow((NdotV * _SpecMul), _SpecPow)) * _SpecColor; 
            
            fixed3 RimLight = (pow(((1 - NdotV) * _RimMul), _RimPow)) * _RimColor;

            fixed MaskHigh = saturate(-(IN.worldPos.y - _AlphaHigh));
            fixed MaskLow = saturate(IN.worldPos.y + _AlphaLow);

            fixed AlphaMap = tex2D(_AlphaMap, fixed2(IN.uv_AlphaMap.x +  _Time.y * _UVMoveSpeedX, IN.uv_AlphaMap.y + _Time.y * _UVMoveSpeedY));

            fixed MaskWorld = MaskHigh * MaskLow;
            fixed MaskFinal = MaskWorld * AlphaMap;
           
            o.Albedo = lerp(0, BaseColor.rgb * GrabRenderDistort.rgb, MaskWorld);
            o.Emission = lerp(GrabRender.rgb, RimLight + Specular, MaskWorld);

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = MaskFinal;            
        }
        ENDCG
    }
    FallBack "Diffuse"
}