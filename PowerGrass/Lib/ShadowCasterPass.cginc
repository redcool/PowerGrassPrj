#if !defined(SHADOW_CASTER_PASS_CGINC)
#define SHADOW_CASTER_PASS_CGINC

#include "PowerGrassInput.cginc"
#include "URP_MainLightShadows.hlsl"

half3 _LightDirection;



struct shadowPass_v2f {
    V2F_SHADOW_CASTER;
    half2 uv : TEXCOORD1;
    half4 worldPosNoise:TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

shadowPass_v2f shadowPass_vert(appdata_full v)
{
    shadowPass_v2f o = (shadowPass_v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    
    half4 worldPos = mul(unity_ObjectToWorld,v.vertex);
    half4 worldPosNoise = WaveVertex(worldPos,v.vertex,v.texcoord,v.color);
    half3 worldNormal = UnityObjectToWorldNormal(v.normal);
    o.pos = UnityWorldToClipPos(ApplyShadowBias(worldPosNoise.xyz,worldNormal,_LightDirection));
    #if UNITY_REVERSED_Z
        o.pos.z = min(o.pos.z, o.pos.w * UNITY_NEAR_CLIP_VALUE);
    #else
        o.pos.z = max(o.pos.z, o.pos.w * UNITY_NEAR_CLIP_VALUE);
    #endif

    o.uv = v.texcoord;
    o.worldPosNoise = worldPosNoise;
    return o;
}

half4 shadowPass_frag(shadowPass_v2f i) : SV_Target
{
    #if defined(ALPHA_TEST)
        half4 col = tex2D(_MainTex, i.uv);
        half alphaCull = col.a - _Cutoff;
        half cullDistance = 0;
        if(_CullAnimOn)
            cullDistance = CalcCullDistance(i.worldPosNoise.xyz);
            
        clip( min(alphaCull,cullDistance));
    #endif

    SHADOW_CASTER_FRAGMENT(i)
}
#endif //SHADOW_CASTER_PASS_CGINC