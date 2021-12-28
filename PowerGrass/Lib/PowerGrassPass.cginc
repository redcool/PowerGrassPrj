#if !defined(POWER_GRASS_PASS_CGINC)
#define POWER_GRASS_PASS_CGINC

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float2 uv1:TEXCOORD1;
    float4 color:COLOR;
    float3 normal:NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

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


v2f vert (appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);

    
    float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
    worldPos.xyz = WaveVertex(worldPos,v.vertex,v.uv,v.color);
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

#endif //POWER_GRASS_PASS_CGINC