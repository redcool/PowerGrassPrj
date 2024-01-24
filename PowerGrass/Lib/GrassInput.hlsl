#if !defined(POWER_GRASS_INPUT_CGINC)
#define POWER_GRASS_INPUT_CGINC
#include "../../../PowerShaderLib/Lib/UnityLib.hlsl"

sampler2D _MainTex;
sampler2D _SpecMaskMap;
// sampler2D _NormalMap;
sampler2D _MetallicMaskMap;

// ========================= vars for support instanced

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(half4 , _MainTex_ST)
    UNITY_DEFINE_INSTANCED_PROP(half , _Cutoff)
    UNITY_DEFINE_INSTANCED_PROP(half , _ColorScale)
    UNITY_DEFINE_INSTANCED_PROP(half4 , _Color)
    // UNITY_DEFINE_INSTANCED_PROP(half , _NormalScale)
    UNITY_DEFINE_INSTANCED_PROP(half , _Metallic)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Smoothness)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Occlusion)
    // wind
    UNITY_DEFINE_INSTANCED_PROP(half , _WaveIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half , _WaveSpeed)
    UNITY_DEFINE_INSTANCED_PROP(half , _WaveScale)

    UNITY_DEFINE_INSTANCED_PROP(half4 , _WaveColor1)
    UNITY_DEFINE_INSTANCED_PROP(half4 , _WaveColor2)
    // interactive
    UNITY_DEFINE_INSTANCED_PROP(half , _InteractiveOn)
    UNITY_DEFINE_INSTANCED_PROP(half , _PushRadius)
    UNITY_DEFINE_INSTANCED_PROP(half , _PushIntensity)

    // UNITY_DEFINE_INSTANCED_PROP(custom , UNITY_DEFINE_INSTANCED_PROP(shadow , bias
    UNITY_DEFINE_INSTANCED_PROP(half , _CustomShadowDepthBias)
    UNITY_DEFINE_INSTANCED_PROP(half , _CustomShadowNormalBias)

    UNITY_DEFINE_INSTANCED_PROP(half , _FogOn)
    UNITY_DEFINE_INSTANCED_PROP(half , _FogNoiseOn)
    UNITY_DEFINE_INSTANCED_PROP(half , _DepthFogOn)
    UNITY_DEFINE_INSTANCED_PROP(half , _HeightFogOn)

    UNITY_DEFINE_INSTANCED_PROP(half , _DistanceCullingOn)
    UNITY_DEFINE_INSTANCED_PROP(half3 , _CullPos)
    UNITY_DEFINE_INSTANCED_PROP(half , _CullDistance)
    UNITY_DEFINE_INSTANCED_PROP(half , _CullInvert)

    UNITY_DEFINE_INSTANCED_PROP(half4, _LightmapST)

UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

// ========================= shortcut vars
#define _MainTex_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTex_ST)
#define _Cutoff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Cutoff)
#define _ColorScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ColorScale)
#define _Color UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Color)
// #define _NormalScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_NormalScale)
#define _Metallic UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Metallic)
#define _Smoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Smoothness)
#define _Occlusion UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Occlusion)
// #define wind UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,wind)
#define _WaveIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WaveIntensity)
#define _WaveSpeed UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WaveSpeed)
#define _WaveScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WaveScale)

#define _WaveColor1 UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WaveColor1)
#define _WaveColor2 UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WaveColor2)
// #define interactive UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,interactive)
#define _InteractiveOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_InteractiveOn)
#define _PushRadius UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_PushRadius)
#define _PushIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_PushIntensity)

// #define bias UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,bias)
#define _CustomShadowDepthBias UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomShadowDepthBias)
#define _CustomShadowNormalBias UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomShadowNormalBias)

#define _FogOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FogOn)
#define _FogNoiseOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FogNoiseOn)
#define _DepthFogOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DepthFogOn)
#define _HeightFogOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_HeightFogOn)

#define _DistanceCullingOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistanceCullingOn)
#define _CullPos UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CullPos)
#define _CullDistance UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CullDistance)
#define _CullInvert UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CullInvert)

#define _LightmapST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_LightmapST)

// ========================= global vars

half3 _PlayerPos;

#endif //POWER_GRASS_INPUT_CGINC