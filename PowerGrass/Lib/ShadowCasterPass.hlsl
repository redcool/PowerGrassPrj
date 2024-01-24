#if !defined(SHADOW_CASTER_PASS_CGINC)
#define SHADOW_CASTER_PASS_CGINC

#include "GrassCore.hlsl"


#include "../../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"


struct shadowPass_v2f {
    float4 pos:SV_POSITION;
    half2 uv : TEXCOORD1;
    half4 worldPosNoise:TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

shadowPass_v2f shadowPass_vert(shadow_appdata input)
{
    shadowPass_v2f o = (shadowPass_v2f)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, o);

    float4 worldPos = TransformObjectToWorld(input.vertex.xyz).xyzx;
    worldPos = WaveVertex(worldPos,input.vertex.xyz,input.texcoord,input.color.xyz);
    o.worldPosNoise = worldPos;

    float3 worldNormal = TransformObjectToWorldNormal(input.normal);
    
    #if defined(SHADOW_PASS)
        o.pos = GetShadowPositionHClip(worldPos.xyz,worldNormal);
    #else
        o.pos = TransformWorldToHClip(worldPos.xyz);
    #endif
    
    o.uv = TRANSFORM_TEX(input.texcoord,_MainTex);

    return o;
}

half4 shadowPass_frag(shadowPass_v2f i) : SV_Target
{
    #if defined(ALPHA_TEST)
        half4 col = tex2D(_MainTex, i.uv);
        half alphaCull = col.a - _Cutoff;
        half cullDistance = 0;
        if(_DistanceCullingOn)
            cullDistance = CalcCullDistance(i.worldPosNoise.xyz);
            
        clip( min(alphaCull,cullDistance));
    #endif

    return 0;
}
#endif //SHADOW_CASTER_PASS_CGINC