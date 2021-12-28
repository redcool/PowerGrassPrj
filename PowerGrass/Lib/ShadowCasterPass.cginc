#if !defined(SHADOW_CASTER_PASS_CGINC)
#define SHADOW_CASTER_PASS_CGINC

#include "PowerGrassInput.cginc"

struct appdata{
    float4 vertex:POSITION;
    float2 uv:TEXCOORD;
    float3 color:COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct shadowPass_v2f {
    V2F_SHADOW_CASTER;
    float2 uv : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

shadowPass_v2f shadowPass_vert(appdata v)
{
    shadowPass_v2f o = (shadowPass_v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    
    float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
    worldPos.xyz = WaveVertex(worldPos,v.vertex,v.uv,v.color);
    o.pos = UnityWorldToClipPos(worldPos);
    o.uv = v.uv;
    return o;
}

float4 shadowPass_frag(shadowPass_v2f i) : SV_Target
{
    half4 col = tex2D(_MainTex, i.uv);

    #if defined(ALPHA_TEST)
    clip(col.a- _Cutoff);
    #endif

    SHADOW_CASTER_FRAGMENT(i)
    
}
#endif //SHADOW_CASTER_PASS_CGINC