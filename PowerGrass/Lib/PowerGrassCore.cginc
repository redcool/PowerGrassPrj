#if !defined(POWER_GRASS_CORE_CGINC)
#define POWER_GRASS_CORE_CGINC

#include "NodeLib.cginc"
#include "PowerGrassInput.cginc"


half3 CalcForce(half3 pos,half2 uv,half3 color){
    //---interactive
    half3 dir = pos - _PlayerPos;
    
    half dist = length(dir);
    half circle = saturate(_PushRadius - dist);
    half atten = uv.y * circle * color * _PushIntensity;

    dir.xz = normalize(dir.xz)*0.5;
    dir.y = -0.5;
    return dir * saturate(atten);
}

half CalcNoise(half3 pos,half2 vertexUV,half3 vertexColor,half3 vertexPos){
    half2 timeOffset = _Time.y * _WaveSpeed;
    half2 noiseUV = pos.xz + timeOffset;

    half noise = 0;
    Unity_GradientNoise_half(noiseUV,_WaveScale*0.01,noise);
    noise -= 0.5;

    half yAtten = smoothstep(0.,0.5,vertexPos.y);
    half uvY = smoothstep(0,0.5,vertexUV.y);
    noise = noise * vertexColor.x * _WaveIntensity * uvY * yAtten;
    return noise;
}

half4 WaveVertex(half4 pos,half3 vertexPos,half2 vertexUV,half3 vertexColor){
    half noise = CalcNoise(pos,vertexUV,vertexColor,vertexPos);
    pos.w = noise;

    pos.x += noise;
    pos.xyz += CalcForce(pos.xyz,vertexUV,vertexColor);
    //apply weather
    half3 windDir = _GlobalWindDir * _GlobalWindIntensity;
    pos.xyz += noise * 0.4 * windDir;
    return pos;
}

half CalcCullDistance(half3 worldPos){
    half3 cullDir = worldPos - _CullPos;
    half distance2 = dot(cullDir,cullDir);
    half cullDistance = _CullDistance * _CullDistance - distance2;
    cullDistance *=  lerp(-1,1,_CullInvert);
    return cullDistance;
}

#endif //POWER_GRASS_CORE_CGINC