Shader "Nature/Grass 1Pass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)
        _ColorScale("ColorScale",range(0,5)) = 1

        [Header(Clip)]
        [Toggle(ALPHA_TEST)]_CutoffOn("_CutoffOn",float) = 0
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5

        [Header(Distance Culling)]
        [Toggle(DISTANCE_CULLING)]_DistanceCullingOn("_DistanceCullingOn",float) = 0
        _CullPos("_CullPos",vector) = (0,0,0,0)
        _CullDistance("_CullDistance",float) = 5
        [Toggle]_CullInvert("_CullInvert",float) = 0 

        [Header(Wind)]
        _WaveSpeed("WaveSpeed",float) = 4
        _WaveIntensity("WaveIntensity",float) = 2
        _WaveScale("_WaveScale",float) = 10

        [Header(WaveColor)]
        [hdr]_WaveColor1("_WaveColor1",color) = (1,1,1,1)
        [hdr]_WaveColor2("_WaveColor2",color) = (1,1,1,1)
        

        [Header(Interactive)]
        [Toggle]_InteractiveOn("_InteractiveOn",int) = 0
        _PushRadius("Radius",float) = 0.5
        _PushIntensity("Push Intensity",float) = 1
        //_PlayerPos("playerPos",vector) = (0,0,0,0)
        // _GlobalWindDir("Global WindDir",vector)=(1,0,0,0)
        // _GlobalWindIntensity("Global WindIntensity",float)=1
        // _LightmapST("_LightmapST",Vector)=(0,0,0,0)

        [Header(Shadow)]
        [Toggle(URP_SHADOW)]_URPShadow("_URPShadow",int) = 0
        _MainLightShadowSoftScale("_MainLightShadowSoftScale",range(0.01,3)) = 1
        [Header(Shadow Bias)]
        _CustomShadowBias("_CustomShadowBias(x: depth bias, y: normal bias)",vector) = (0,0,0,0)

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

        // Pass
        // {
        //     Tags {"Queue"="AlphaTest"}
        //     zwrite on
        //     colorMask 0

        //     CGPROGRAM
        //     #pragma vertex shadowPass_vert
        //     #pragma fragment shadowPass_frag
        //     #pragma multi_compile_instancing  
            
        //     #pragma shader_feature_local_fragment ALPHA_TEST

        //     #include "UnityCG.cginc"
        //     #include "Lighting.cginc"
        //     #include "AutoLight.cginc"
        //     #include "Lib/PowerGrassCore.cginc"
        //     #include "Lib/ShadowCasterPass.cginc"
            
        //     ENDCG
        // }

        Pass
        {
            Tags {"Queue"="AlphaTest" }
            // zwrite[_ZWriteMode]
            // blend [_SrcMode][_DstMode]
            // ztest [_ZTestMode]
            // ztest equal
            // zwrite off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fwdbase 
            #pragma multi_compile_instancing
            #pragma shader_feature_local_fragment ALPHA_TEST
            #pragma shader_feature_local URP_SHADOW

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "Lib/PowerGrassCore.cginc"
            #include "Lib/PowerGrassPass.cginc"
            ENDCG
        }

        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex shadowPass_vert
            #pragma fragment shadowPass_frag
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing  
            
            #pragma shader_feature_local_fragment ALPHA_TEST

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "Lib/PowerGrassCore.cginc"
            #include "Lib/ShadowCasterPass.cginc"
            
            ENDCG
        }

    }
}
