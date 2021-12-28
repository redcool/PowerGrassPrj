#if !defined(SHADOW_CASTER_PASS_CGINC)
#define SHADOW_CASTER_PASS_CGINC

#include "PowerGrassInput.cginc"

struct appdata{
    half4 vertex:POSITION;
    half2 uv:TEXCOORD;
    half3 color:COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct shadowPass_v2f {
    V2F_SHADOW_CASTER;
    half2 uv : TEXCOORD1;
    half4 worldPosNoise:TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

shadowPass_v2f shadowPass_vert(appdata v)
{
    shadowPass_v2f o = (shadowPass_v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    
    half4 worldPos = mul(unity_ObjectToWorld,v.vertex);
    half4 worldPosNoise = WaveVertex(worldPos,v.vertex,v.uv,v.color);
    o.pos = UnityWorldToClipPos(half4(worldPosNoise.xyz,1));
    o.uv = v.uv;
    o.worldPosNoise = worldPosNoise;
    return o;
}

half4 shadowPass_frag(shadowPass_v2f i) : SV_Target
{
    half4 col = tex2D(_MainTex, i.uv);

    #if defined(ALPHA_TEST)
        clip(col.a- _Cutoff);
        half3 worldPos = i.worldPosNoise.xyz;
        half cullDistance = CalcCullDistance(worldPos);
        clip(cullDistance);
    #endif

    SHADOW_CASTER_FRAGMENT(i)
    
}
#endif //SHADOW_CASTER_PASS_CGINC