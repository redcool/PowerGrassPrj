#if !defined(POWER_GRASS_PASS_CGINC)
#define POWER_GRASS_PASS_CGINC

struct appdata
{
    half4 vertex : POSITION;
    half2 uv : TEXCOORD0;
    half2 uv1:TEXCOORD1;
    half4 color:COLOR;
    half3 normal:NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    half2 uv : TEXCOORD0;
    UNITY_FOG_COORDS(1)
    half4 pos : SV_POSITION;
    half4 lmap:TEXCOORD2;
    SHADOW_COORDS(3)
    half3 diff:TEXCOORD4;
    half3 normal:TEXCOORD5;
    half4 worldPosNoise:TEXCOORD6;
    half3 ambient:TEXCOORD7;
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
};


v2f vert (appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);

    
    half4 worldPos = mul(unity_ObjectToWorld,v.vertex);
    half4 worldPosNoise = WaveVertex(worldPos,v.vertex,v.uv,v.color);

    o.pos = mul(UNITY_MATRIX_VP,half4(worldPosNoise.xyz,1));
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);

    #if defined(LIGHTMAP_ON)
        // half4 lightmapST = UNITY_ACCESS_INSTANCED_PROP(Props,_LightmapST);
        // lightmapST = length(lightmapST) ==0? unity_LightmapST : lightmapST;
        o.lmap.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
    #endif

    TRANSFER_SHADOW(o)
    UNITY_TRANSFER_FOG(o,o.pos);

    half3 lightDir = length(_WorldSpaceLightPos0.xyz) > 0 ? _WorldSpaceLightPos0.xyz : half3(0.1,.35,0.02);
    half3 normal = UnityObjectToWorldNormal(v.normal);
    half nl = dot(normal,lightDir) * 0.5 + 0.5;
    o.diff = nl * _LightColor0.rgb;//smoothstep(0,.32,nl);

    // ambient light
    o.ambient = 0;
    #if defined(VERTEXLIGHT_ON)
        o.ambient +=  Shade4PointLights (
        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
        unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
        unity_4LightAtten0, worldPos.xyz, normal);
    #else
        o.ambient += ShadeSH9(half4(normal,1));
    #endif

    o.normal = normal;
    o.worldPosNoise = worldPosNoise;
    return o;
}

half4 frag (v2f i) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);
    // sample the texture
    half4 col = tex2D(_MainTex, i.uv);

    half3 worldPos = i.worldPosNoise.xyz;
    half noise = i.worldPosNoise.w;

    #if defined(ALPHA_TEST)
        clip(col.a - _Cutoff);
        half cullDistance = CalcCullDistance(worldPos);
        clip(cullDistance);

    #endif
    col *= _Color * _ColorScale * lerp(_WaveColor1,_WaveColor2,noise);
    
    // ao 
    half atten = SHADOW_ATTENUATION(i);
//return atten;
    //half diff = max(_BaseAO,smoothstep(0.2,0.4,i.diff));
    half4 attenColor = lerp(UNITY_LIGHTMODEL_AMBIENT * _BaseAO,1,atten);
    col.rgb *= i.diff * attenColor + i.ambient;

    #if defined(LIGHTMAP_ON)
        half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmap.xy);
        half3 bakedColor = DecodeLightmap(bakedColorTex);
//return half4(bakedColor,1);
        col.rgb *= bakedColor;
    #endif
    
    //Specular
    #if defined(SPEC_ON)
        half4 specMaskMap = tex2D(_SpecMaskMap,i.uv);
        half specMask = _SpecMaskR? specMaskMap.r : specMaskMap.a;

        half3 n = normalize(i.normal);
        half3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
        half3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
        half3 h = normalize(l+v);
        half spec = pow(dot(n,h),_Gloss * 128);
        col += spec * specMask;
    #endif

    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, col);
    
    return col;
}

#endif //POWER_GRASS_PASS_CGINC