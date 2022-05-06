#if !defined(POWER_GRASS_INPUT_CGINC)
#define POWER_GRASS_INPUT_CGINC
#include "Common.hlsl"

sampler2D _MainTex;
sampler2D _SpecMaskMap;
sampler2D _NormalMap;

CBUFFER_START(UnityPerMaterial)
half4 _MainTex_ST;
half _Cutoff;
half _ColorScale;
half _Metallic,_Smoothness;
// wind
half _WaveIntensity;
half _WaveSpeed;
half _WaveScale;

half4 _WaveColor1,_WaveColor2;
// interactive
half _InteractiveOn;
half _PushRadius;
half _PushIntensity;

// custom shadow bias
half2 _CustomShadowBias;
half _MainLightShadowSoftScale;

CBUFFER_END

// ========================= global vars

half3 _PlayerPos;
half3 _GlobalWindDir;
half _GlobalWindIntensity;

half _DistanceCullingOn;
half3 _CullPos;
half _CullDistance;
half _CullInvert;

UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(half4, _Color)
    //UNITY_DEFINE_INSTANCED_PROP(half4,_PlayerPos)
    UNITY_DEFINE_INSTANCED_PROP(half4, _LightmapST)
UNITY_INSTANCING_BUFFER_END(Props)

#define _Color UNITY_ACCESS_INSTANCED_PROP(Props,_Color)
#define _LightmapST UNITY_ACCESS_INSTANCED_PROP(Props,_LightmapST)

#endif //POWER_GRASS_INPUT_CGINC