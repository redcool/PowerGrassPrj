#if !defined(POWER_GRASS_INPUT_CGINC)
#define POWER_GRASS_INPUT_CGINC

struct v2f
{
    float2 uv : TEXCOORD0;
    UNITY_FOG_COORDS(1)
    float4 pos : SV_POSITION;
    float4 lmap:TEXCOORD2;
    SHADOW_COORDS(3)
    float3 diff:TEXCOORD4;
    float3 normal:TEXCOORD5;
    float3 worldPos:TEXCOORD6;
    float3 ambient:TEXCOORD7;
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

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