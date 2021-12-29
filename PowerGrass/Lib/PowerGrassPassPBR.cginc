#if !defined(POWER_GRASS_PASS_CGINC)
#define POWER_GRASS_PASS_CGINC
#include "Lib/BSDF.hlsl"

struct appdata
{
    half4 vertex : POSITION;
    half2 uv : TEXCOORD0;
    half2 uv1:TEXCOORD1;
    half4 color:COLOR;
    half3 normal:NORMAL;
    half4 tangent:TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    half4 uvLightmapUV : TEXCOORD0;
    UNITY_FOG_COORDS(1)
    half4 pos : SV_POSITION;
    SHADOW_COORDS(2)
    half3 diff:TEXCOORD3;
    half4 vertexLightNoise:TEXCOORD4;
    half4 tSpace0:TEXCOORD5;
    half4 tSpace1:TEXCOORD6;
    half4 tSpace2:TEXCOORD7;
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
};


v2f vert (appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);

    
    half4 worldPos = mul(unity_ObjectToWorld,v.vertex);
    half4 worldPosNoise = WaveVertex(worldPos,v.vertex,v.uv,v.color);

    o.vertexLightNoise.w = worldPosNoise.w;
    o.pos = mul(UNITY_MATRIX_VP,half4(worldPosNoise.xyz,1));
    o.uvLightmapUV.xy = TRANSFORM_TEX(v.uv, _MainTex);

    #if defined(LIGHTMAP_ON)
        // half4 lightmapST = UNITY_ACCESS_INSTANCED_PROP(Props,_LightmapST);
        // lightmapST = length(lightmapST) ==0? unity_LightmapST : lightmapST;
        o.uvLightmapUV.zw = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
    #endif

    TRANSFER_SHADOW(o)
    UNITY_TRANSFER_FOG(o,o.pos);

    half3 normal = UnityObjectToWorldNormal(v.normal);
    half3 tangent = UnityObjectToWorldDir(v.tangent.xyz);
    half3 binormal = cross(normal,tangent) * v.tangent.w;
    o.tSpace0 = half4(tangent.x,binormal.x,normal.x,worldPosNoise.x);
    o.tSpace1 = half4(tangent.y,binormal.y,normal.y,worldPosNoise.y);
    o.tSpace2 = half4(tangent.z,binormal.z,normal.z,worldPosNoise.z);

    half3 lightDir = dot(_WorldSpaceLightPos0.xyz,_WorldSpaceLightPos0.xyz) > 0 ? _WorldSpaceLightPos0.xyz : half3(0.1,.35,0.02);
    half nl = dot(normal,lightDir) * 0.5 + 0.5;
    o.diff = nl * _LightColor0.rgb;//smoothstep(0,.32,nl);

    // ambient light
    o.vertexLightNoise = 0;
    // #if defined(VERTEXLIGHT_ON)
    //     o.vertexLightNoise.xyz +=  Shade4PointLights (
    //     unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
    //     unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
    //     unity_4LightAtten0, worldPos.xyz, normal);
    // #else
        o.vertexLightNoise.xyz += ShadeSH9(half4(normal,1));
    // #endif
    return o;
}

half4 frag (v2f i) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);

    half2 uv = i.uvLightmapUV.xy;
    half2 lightmapUV = i.uvLightmapUV.zw;
    half3 worldPos = half3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);
    half noise = i.vertexLightNoise.w;
    half3 sh = i.vertexLightNoise.xyz;

    half metallic = _Metallic;
    half roughness = 1 - _Smoothness;

    half3 normal = half3(i.tSpace0.z,i.tSpace1.z,i.tSpace2.z);
    // #if defined(NORMAL_MAP_ON)
        half3 normalTS = UnpackNormal(tex2D(_NormalMap,uv));
        normal = half3(
            dot(i.tSpace0.xyz,normalTS),
            dot(i.tSpace1.xyz,normalTS),
            dot(i.tSpace2.xyz,normalTS)
        );
        // return normal.xyzx;
    // #endif
    half3 lightDir = UnityWorldSpaceLightDir(worldPos);
    half nl = saturate(dot(lightDir,normal) * 0.5+0.5);

    // sample the texture
    half4 mainTex = tex2D(_MainTex, uv) * _Color ;
    half3 albedo = mainTex.xyz;
    half alpha = mainTex.w;

    #if defined(ALPHA_TEST)
        clip(alpha - _Cutoff);
        half cullDistance = CalcCullDistance(worldPos);
        clip(cullDistance);
    #endif

    half shadowAtten = SHADOW_ATTENUATION(i);


    half3 attenColor = lerp(UNITY_LIGHTMODEL_AMBIENT * _BaseAO,1,shadowAtten);
    
    half3 diffColor = albedo * ( 1- metallic) * _ColorScale * i.diff * attenColor * lerp(_WaveColor1,_WaveColor2,noise);
    half3 specColor = lerp(0.04,albedo,metallic);

    #if defined(LIGHTMAP_ON)
        half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, lightmapUV);
        half3 bakedColor = DecodeLightmap(bakedColorTex);
        diffColor *= bakedColor;
    #endif
    
    half4 col = 0;
    half3 giDiff = sh * diffColor;
    col.rgb += giDiff;

    half specTerm = 0;
    //Specular
    #if defined(SPEC_ON)
        half3 n = normalize(normal);
        half3 v = normalize(UnityWorldSpaceViewDir(worldPos));
        half3 h = normalize(lightDir+v);
        half nh = saturate(dot(n,h));
        half lh = saturate(dot(lightDir,h));

        half a = roughness * roughness;
        half a2 = max(0.00001,a*a);
        // half surfaceReduction = 1/(a2+1);
        // half grazingTerm = saturate(smoothness + metallic);
        specTerm = MinimalistCookTorrance(lh,nh,a,a2);
    #endif

    half radiance = shadowAtten * nl;
    col.rgb += (diffColor + specColor * specTerm) * radiance;

    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, col);
    
    return col;
}

#endif //POWER_GRASS_PASS_CGINC