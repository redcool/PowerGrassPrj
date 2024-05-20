#if !defined(POWER_GRASS_PASS_CGINC)
#define POWER_GRASS_PASS_CGINC

#include "GrassCore.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float2 uv1:TEXCOORD1;
    float4 color:COLOR;
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 pos : SV_POSITION;
    float4 uvLightmapUV : TEXCOORD0;
    float4 fogCoord:TEXCOORD1;
    float4 _ShadowCoord:TEXCOORD2;
    float3 diffColor:TEXCOORD3;
    float4 vertexLightNoise:TEXCOORD4;
    float4 worldPos:TEXCOORD5;
    // float4 tSpace0:TEXCOORD5;
    // float4 tSpace1:TEXCOORD6;
    // float4 tSpace2:TEXCOORD7;
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
};


v2f vert (appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);

    float4 worldPos = float4(TransformObjectToWorld(v.vertex.xyz),1);
    float4 worldPosNoise = WaveVertex(worldPos,v.vertex.xyz,v.uv,v.color.xyz);
    o.pos = mul(UNITY_MATRIX_VP,float4(worldPosNoise.xyz,1));
    o.uvLightmapUV.xy = TRANSFORM_TEX(v.uv, _MainTex);

    o.worldPos.xyz = worldPosNoise.xyz;
    o.vertexLightNoise.w = saturate(worldPosNoise.w);

    #if defined(LIGHTMAP_ON)
        o.uvLightmapUV.zw = v.uv1.xy * _LightmapST.xy + _LightmapST.zw;
    #endif
    
    #if !defined(_RECEIVE_SHADOWS_OFF)
    o._ShadowCoord = TransformWorldToShadowCoord(o.worldPos.xyz);
    #endif

    o.fogCoord.xy = CalcFogFactor(worldPos.xyz,o.pos.z,_HeightFogOn,_DepthFogOn);

    float4 pbrMaskTex = tex2Dlod(_MetallicMaskMap,float4(o.uvLightmapUV.xy,0,0));
    float metallic,smoothness,occlusion;
    SplitPbrMaskTexture(metallic/**/,smoothness/**/,occlusion/**/,pbrMaskTex,int3(0,1,2),half3(_Metallic,_Smoothness,_Occlusion));

    float3 normal = normalize(UnityObjectToWorldNormal(v.normal));
    // float3 tangent = 0;//UnityObjectToWorldDir(v.tangent.xyz);
    // float3 binormal = 0;//cross(normal,tangent) * v.tangent.w;
    // o.tSpace0 = float4(tangent.x,binormal.x,normal.x,worldPosNoise.x);
    // o.tSpace1 = float4(tangent.y,binormal.y,normal.y,worldPosNoise.y);
    // o.tSpace2 = float4(tangent.z,binormal.z,normal.z,worldPosNoise.z);

    // float3 lightDir = dot(_WorldSpaceLightPos0.xyz,_WorldSpaceLightPos0.xyz) > 0 ? _WorldSpaceLightPos0.xyz : float3(0.1,.35,0.02);
    float3 lightDir = (_MainLightPosition.xyz);
    float nl = saturate(dot(normal,lightDir) * 0.5 + 0.65) * occlusion;

    o.diffColor = (nl * _ColorScale) * _MainLightColor.xyz;
    o.diffColor *= _Color.xyz * lerp(_WaveColor1,_WaveColor2,worldPosNoise.w).xyz;

    o.vertexLightNoise.xyz = SampleSH(normal);
    return o;
}

half4 frag (v2f i) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);

    half2 uv = i.uvLightmapUV.xy;
    half4 col = tex2D(_MainTex, uv);

    half2 lightmapUV = i.uvLightmapUV.zw;
    half3 worldPos = i.worldPos.xyz;//half3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);
    half noise = i.vertexLightNoise.w;
    half3 sh = i.vertexLightNoise.xyz;

    #if defined(ALPHA_TEST)
        half alphaCull = col.a - _Cutoff;
        half cullDistance = 0;
        if(_DistanceCullingOn)
            cullDistance = CalcCullDistance(worldPos);

        clip( min(alphaCull,cullDistance));
    #endif

    // shadow atten
    half atten = 1;
    #if !defined(_RECEIVE_SHADOWS_OFF)
        atten = CalcShadow(i._ShadowCoord,worldPos);
    #endif
    col.rgb *= i.diffColor * atten + sh;


    #if defined(LIGHTMAP_ON)
        half3 bakedColor = SampleLightmap(i.uvLightmapUV.zw);
        col.rgb *= bakedColor;
    #endif

//------ fog
    BlendFogSphere(col.rgb/**/,worldPos,i.fogCoord.xy,_HeightFogOn,_FogNoiseOn,_DepthFogOn); // 2fps
    return col;
}

#endif //POWER_GRASS_PASS_CGINC