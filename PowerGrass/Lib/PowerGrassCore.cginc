#if !defined(POWER_GRASS_CORE_CGINC)
#define POWER_GRASS_CORE_CGINC

#include "Lib/NodeLib.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float2 uv1:TEXCOORD1;
    float4 color:COLOR;
    float3 normal:NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
float _WaveIntensity;
float _WaveSpeed;
float _WaveScale;

float3 _PlayerPos;
float _PushRadius;
float _PushIntensity;

float3 _GlobalWindDir;
float _GlobalWindIntensity;
float _BaseAO;

float3 CalcForce(float3 pos,float2 uv,float3 color){
    //---interactive
    float3 dir = pos - _PlayerPos;
    
    float dist = length(dir);
    float circle = saturate(_PushRadius - dist);
    float atten = uv.y * circle * color * _PushIntensity;

    dir.xz = normalize(dir.xz)*0.5;
    dir.y = -0.5;
    return dir * saturate(atten);
}

float CalcNoise(float3 pos,float2 vertexUV,float3 vertexColor,float3 vertexPos){
    float2 timeOffset = _Time.y * _WaveSpeed;
    float2 noiseUV = pos.xz + timeOffset;

    float noise = 0;
    Unity_GradientNoise_float(noiseUV,_WaveScale*0.01,noise);
    noise -= 0.5;

    float yAtten = smoothstep(0.,0.5,vertexPos.y);
    float uvY = smoothstep(0,0.5,vertexUV.y);
    noise = noise * vertexColor.x * _WaveIntensity * uvY * yAtten;
    return noise;
}

float3 WaveVertex(float3 pos,float2 vertexUV,float3 vertexColor,float3 vertexPos){
    float noise = CalcNoise(pos,vertexUV,vertexColor,vertexPos);
    
    pos.x += noise;
    pos.xyz += CalcForce(pos.xyz,vertexUV,vertexColor);
    //apply weather
    float3 windDir = _GlobalWindDir * _GlobalWindIntensity;
    pos.xyz += noise * 0.4 * windDir;
    return pos;
}

float4 WaveVertex(appdata v,float waveSpeed,float waveIntensity){
    float4 pos = mul(unity_ObjectToWorld,v.vertex);

    float2 timeOffset = _Time.y * waveSpeed;
    float2 uv = pos.xz + timeOffset;

    float noise = 0;
    Unity_GradientNoise_float(uv,_WaveScale*0.01,noise);
    noise -= 0.5;
    float yAtten = smoothstep(0.,0.1,v.vertex.y);
    float uvY = smoothstep(0,0.5,v.uv.y);
    noise = noise * v.color.x * _WaveIntensity * uvY * 1;
    
    pos.x += noise;
    pos.xyz += CalcForce(pos.xyz,v.uv,v.color);
    //apply weather
    float3 windDir = _GlobalWindDir * _GlobalWindIntensity;
    pos.xyz += noise * 0.4 * windDir;

    //return mul(unity_WorldToObject,pos);
    return pos;
}

#endif //POWER_GRASS_CORE_CGINC