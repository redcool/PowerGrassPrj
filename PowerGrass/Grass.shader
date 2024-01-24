Shader "URP/Nature/Grass"
{
    Properties
    {
        [Group(Main)]
        [GroupItem(Main)] _MainTex ("Texture", 2D) = "white" {}
        [GroupItem(Main)] _Color("Color",color) = (1,1,1,1)
        [GroupItem(Main)] _ColorScale("ColorScale",range(0,5)) = 1

        // [GroupItem(Main)]_NormalMap("_NormalMap",2d)="bump"{}
        // [GroupItem(Main)]_NormalScale("_NormalScale",range(0,5)) = 1

        [Group(PBR Mask)]
        [GroupItem(PBR Mask)]_MetallicMaskMap("_PbrMask",2d)="white"{}

        [GroupItem(PBR Mask)]_Metallic("_Metallic",range(0,1)) = 0.5
        [GroupItem(PBR Mask)]_Smoothness("_Smoothness",range(0,1)) = 0.5
        [GroupItem(PBR Mask)]_Occlusion("_Occlusion",range(0,1)) = 0

        [GroupHeader(Main,Clip)]
        [GroupToggle(Main,ALPHA_TEST)]_CutoffOn("_CutoffOn",float) = 0
        [GroupItem(Main)] _Cutoff("Alpha cutoff", Range(0,1)) = 0.5

        [Group(Culling)]
        [GroupHeader(Culling,Distance Culling)]
        [GroupToggle(Culling,DISTANCE_CULLING)]_DistanceCullingOn("_DistanceCullingOn",float) = 0
        [GroupItem(Culling)] _CullPos("_CullPos",vector) = (0,0,0,0)
        [GroupItem(Culling)] _CullDistance("_CullDistance",float) = 5
        [GroupToggle(Culling)]_CullInvert("_CullInvert",float) = 0 
        
        [Group(Wind)]
        [GroupItem(Wind)] _WaveSpeed("WaveSpeed",float) = 4
        [GroupItem(Wind)] _WaveIntensity("WaveIntensity",float) = 2
        [GroupItem(Wind)] _WaveScale("_WaveScale",float) = 10

        [GroupHeader(Wind,WaveColor)]
        [GroupItem(Wind)] [hdr]_WaveColor1("_WaveColor1",color) = (1,1,1,1)
        [GroupItem(Wind)] [hdr]_WaveColor2("_WaveColor2",color) = (1,1,1,1)
        

        [Group(Interactive)]
        [GroupToggle(Interactive)]_InteractiveOn("_InteractiveOn",int) = 0
        [GroupItem(Interactive)] _PushRadius("Radius",float) = 0.5
        [GroupItem(Interactive)] _PushIntensity("Push Intensity",float) = 1
        //_PlayerPos("playerPos",vector) = (0,0,0,0)
        // _GlobalWindDir("Global WindDir",vector)=(1,0,0,0)
        // _GlobalWindIntensity("Global WindIntensity",float)=1
        // _LightmapST("_LightmapST",Vector)=(0,0,0,0)
        [Group(Fog)]
        [GroupToggle(Fog,FOG_LINEAR)]_FogOn("_FogOn",int) = 1
        [GroupToggle(Fog,SIMPLE_FOG,use simple linear depth height fog)]_SimpleFog("_SimpleFog",int) = 0
        [GroupToggle(Fog)]_FogNoiseOn("_FogNoiseOn",int) = 0
        [GroupToggle(Fog)]_DepthFogOn("_DepthFogOn",int) = 1
        [GroupToggle(Fog)]_HeightFogOn("_HeightFogOn",int) = 1

        [Group(Shadow)]
        //[LineHeader(Shadows)]
        [GroupToggle(Shadow,_RECEIVE_SHADOWS_OFF)]_ReceiveShadowOff("_ReceiveShadowOff",int) = 0
        [GroupItem(Shadow)]_MainLightShadowSoftScale("_MainLightShadowSoftScale",range(0,1)) = 0.1

        [GroupHeader(Shadow,custom bias)]
        [GroupSlider(Shadow)]_CustomShadowNormalBias("_CustomShadowNormalBias",range(-1,1)) = 0.5
        [GroupSlider(Shadow)]_CustomShadowDepthBias("_CustomShadowDepthBias",range(-1,1)) = 0.5

        [Header(Options)]
        [Toggle]_ZWriteMode("_ZWriteMode",int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",int) = 4
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("_SrcMode",int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstMode("_DstMode",int) = 0

    }

    SubShader
    {
        LOD 100
        cull off

        Pass
        {
            Tags {"Queue"="AlphaTest" }
            // zwrite[_ZWriteMode]
            // blend [_SrcMode][_DstMode]
            // ztest [_ZTestMode]
            // ztest equal
            // zwrite off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma shader_feature FOG_LINEAR SIMPLE_FOG
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_instancing
            #pragma shader_feature_local_fragment ALPHA_TEST
            #pragma shader_feature _RECEIVE_SHADOWS_OFF

            #include "Lib/GrassInput.hlsl"
            #include "Lib/GrassPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Tags {"LightMode"="ShadowCaster"}
            
            HLSLPROGRAM
            #pragma vertex shadowPass_vert
            #pragma fragment shadowPass_frag
            // #pragma multi_compile_instancing 
            
            #pragma shader_feature_local_fragment ALPHA_TEST

            #include "Lib/GrassInput.hlsl"

            #define USE_SAMPLER2D
            #define SHADOW_PASS
            #include "Lib/ShadowCasterPass.hlsl"
            
            ENDHLSL
        }

    }
}
