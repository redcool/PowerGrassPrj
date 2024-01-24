#if !defined(POWER_GRASS_CORE_CGINC)
#define POWER_GRASS_CORE_CGINC

#include "../../../PowerShaderLib/Lib/NodeLib.hlsl"
#include "../../../PowerShaderLib/Lib/FogLib.hlsl"
#include "../../../PowerShaderLib/Lib/BSDF.hlsl"
#include "../../../PowerShaderLib/Lib/GILib.hlsl"
#include "../../../PowerShaderLib/Lib/NatureLib.hlsl"
#include "../../../PowerShaderLib/Lib/TangentLib.hlsl"
#include "../../../PowerShaderLib/Lib/MaterialLib.hlsl"
#include "../../../PowerShaderLib/URPLib/URP_MainLightShadows.hlsl"

float3 CalcForce(float3 pos,float2 uv,float3 color){
    //---interactive
    float3 dir = pos - _PlayerPos;
    dir.y = 0;
    // float dist2 = dot(dir,dir);
    // float distAtten = (_PushRadius * _PushRadius - dist2);
    float dist = length(dir);
    float distAtten = _PushRadius - dist;

    float atten = uv.y * distAtten * color.x * _PushIntensity;

    dir.xz = normalize(dir.xz);
    dir.y = -0.5;
    return dir * saturate(atten);
}

float CalcNoise(float3 pos,float2 vertexUV,float3 vertexColor,float3 vertexPos){
    float2 timeOffset = _Time.y * _WaveSpeed;
    float2 noiseUV = pos.xz + timeOffset;

    float noise = unity_gradientNoise(noiseUV * _WaveScale*0.01);

    float yAtten = smoothstep(0.,0.5,vertexPos.y);
    float uvY = smoothstep(0,0.5,vertexUV.y);
    noise = noise * vertexColor.x * _WaveIntensity * uvY * yAtten;
    return noise;
}

float4 WaveVertex(float4 pos,float3 vertexPos,float2 vertexUV,float3 vertexColor){
    float noise = CalcNoise(pos.xyz,vertexUV,vertexColor,vertexPos);
    pos.w = noise;

    pos.x += noise;

    if(_InteractiveOn)
        pos.xyz += CalcForce(pos.xyz,vertexUV,vertexColor);

    //apply weather
    float3 windDir = _GlobalWindDir.xyz * _GlobalWindDir.w;
    pos.xyz += noise * 0.4 * windDir;
    return pos;
}

float CalcCullDistance(float3 worldPos){
    float3 cullDir = worldPos - _CullPos;
    float distance2 = dot(cullDir,cullDir);
    float cullDistance = _CullDistance * _CullDistance - distance2;
    cullDistance *=  lerp(-1,1,_CullInvert);
    return cullDistance;
}

#endif //POWER_GRASS_CORE_CGINC