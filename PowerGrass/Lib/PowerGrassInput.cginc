#if !defined(POWER_GRASS_INPUT_CGINC)
#define POWER_GRASS_INPUT_CGINC

sampler2D _MainTex;
sampler2D _SpecMaskMap;

float4 _MainTex_ST;
float _Cutoff;
float _ColorScale;
float _Gloss;
int _SpecMaskR;
float4 _ShadowColor;

UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
    //UNITY_DEFINE_INSTANCED_PROP(float4,_PlayerPos)
    UNITY_DEFINE_INSTANCED_PROP(float4, _LightmapST)
UNITY_INSTANCING_BUFFER_END(Props)

#define _Color UNITY_ACCESS_INSTANCED_PROP(Props,_Color)
#define _LightmapST UNITY_ACCESS_INSTANCED_PROP(Props,_LightmapST)

#endif //POWER_GRASS_INPUT_CGINC