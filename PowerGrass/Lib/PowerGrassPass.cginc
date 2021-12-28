#if !defined(POWER_GRASS_PASS_CGINC)
#define POWER_GRASS_PASS_CGINC

#include "PowerGrassInput.cginc"


v2f vert (appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);

    //o.pos = UnityObjectToClipPos( WaveVertex(v,_WaveSpeed,_WaveIntensity) );
    float4 worldPos = WaveVertex(v,_WaveSpeed,_WaveIntensity);
    o.pos = mul(UNITY_MATRIX_VP,worldPos);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);

    #if defined(LIGHTMAP_ON)
        // float4 lightmapST = UNITY_ACCESS_INSTANCED_PROP(Props,_LightmapST);
        // lightmapST = length(lightmapST) ==0? unity_LightmapST : lightmapST;
        o.lmap.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
    #endif

    //UNITY_TRANSFER_LIGHTING(o,v.uv.xy);
    TRANSFER_SHADOW(o)
    UNITY_TRANSFER_FOG(o,o.pos);
    //float3 normal = UnityObjectToWorldNormal(v.normal);
    float3 lightDir = length(_WorldSpaceLightPos0.xyz) > 0 ? _WorldSpaceLightPos0.xyz : float3(0.1,.35,0.02);
    float3 normal = UnityObjectToWorldNormal(v.normal);
    float nl = dot(normal,lightDir) * 0.5 + 0.5;
    o.diff = nl * _LightColor0.rgb;//smoothstep(0,.32,nl);

    // ambient light
    o.ambient = 0;
    #if defined(VERTEXLIGHT_ON)
        o.ambient +=  Shade4PointLights (
        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
        unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
        unity_4LightAtten0, worldPos.xyz, normal);
    #else
        o.ambient += ShadeSH9(float4(normal,1));
    #endif

    o.normal = normal;
    o.worldPos = worldPos.xyz;
    return o;
}

half4 frag (v2f i) : SV_Target
{

    #if defined(DEBUG)
        float noise = 0;
        Unity_GradientNoise_float(i.worldPos.xz + _Time.y * _WaveSpeed,_WaveScale*0.01,noise);
        noise -= 0.5;
        return noise * _WaveIntensity;
    #endif

    UNITY_SETUP_INSTANCE_ID(i);
    // sample the texture
    half4 col = tex2D(_MainTex, i.uv);

    #if defined(ALPHA_TEST)
    clip(col.a - _Cutoff);
    #endif

    col *= _Color * _ColorScale;
    
    // ao 
    half atten = SHADOW_ATTENUATION(i);
//return atten;
    //float diff = max(_BaseAO,smoothstep(0.2,0.4,i.diff));
    float4 attenColor = lerp(UNITY_LIGHTMODEL_AMBIENT * _BaseAO,1,atten);
    col.rgb *= i.diff * attenColor + i.ambient;

    #if defined(LIGHTMAP_ON)
        half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmap.xy);
        half3 bakedColor = DecodeLightmap(bakedColorTex);
//return float4(bakedColor,1);
        col.rgb *= bakedColor;
    #endif
    
    //Specular
    #if defined(SPEC_ON)
        float4 specMaskMap = tex2D(_SpecMaskMap,i.uv);
        float specMask = _SpecMaskR? specMaskMap.r : specMaskMap.a;

        float3 n = normalize(i.normal);
        float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
        float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
        float3 h = normalize(l+v);
        float spec = pow(dot(n,h),_Gloss * 128);
        col += spec * specMask;
    #endif

    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, col);
    return col;
}


//========================================== shadow caster pass
struct shadowPass_v2f { 
    V2F_SHADOW_CASTER;
    float2 uv : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

v2f shadowPass_vert(appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    
    o.pos = UnityWorldToClipPos( WaveVertex(v,_WaveSpeed,_WaveIntensity) );
    o.uv = v.uv;
    return o;
}

float4 shadowPass_frag(v2f i) : SV_Target
{
    half4 col = tex2D(_MainTex, i.uv);

    #if defined(ALPHA_TEST)
    clip(col.a- _Cutoff);
    #endif

    SHADOW_CASTER_FRAGMENT(i)
    
}
#endif //POWER_GRASS_PASS_CGINC