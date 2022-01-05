Shader "Nature/Grass 1Pass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)
        _ColorScale("ColorScale",range(0,3)) = 1
        _BaseAO("Base Ao",range(0,2)) = 1

        [Header(Clip)]
        [Toggle(ALPHA_TEST)]_CutoffOn("_CutoffOn",float) = 0
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5

        [Header(Clip Animation)]
        [Toggle(CULL_ANIM)]_CullAnimOn("_CullAnimOn",float) = 0
        _CullPos("_CullPos",vector) = (0,0,0,0)
        _CullDistance("_CullDistance",float) = 5
        [Toggle]_CullInvert("_CullInvert",float) = 0 

        [Header(Wind)]
        _WaveSpeed("WaveSpeed",float) = 1
        _WaveIntensity("WaveIntensity",float) = 1
        _WaveScale("_WaveScale",float) = 1

        [Header(WaveColor)]
        [hdr]_WaveColor1("_WaveColor1",color) = (1,1,1,1)
        [hdr]_WaveColor2("_WaveColor2",color) = (1,1,1,1)
        

        [Header(Interactive)]
        [Toggle]_InteractiveOn("_InteractiveOn",int) = 0
        _PushRadius("Radius",float) = 0.5
        _PushIntensity("Push Intensity",float) = 1
        //_PlayerPos("playerPos",vector) = (0,0,0,0)
        // _GlobalWindDir("Global WindDir",vector)=(1,0,0,0)
        // _GlobalWindIntensity("Global WindIntensity",float)=1
        // _LightmapST("_LightmapST",Vector)=(0,0,0,0)


        [Header(Options)]
        [Toggle]_ZWriteMode("_ZWriteMode",int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",int) = 4
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("_SrcMode",int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstMode("_DstMode",int) = 0

    }

    SubShader
    {
        LOD 100
        cull off

        // Pass
        // {
        //     Tags {"Queue"="AlphaTest"}
        //     zwrite on
        //     colorMask 0

        //     CGPROGRAM
        //     #pragma vertex shadowPass_vert
        //     #pragma fragment shadowPass_frag
        //     #pragma multi_compile_instancing  
            
        //     #pragma shader_feature_local_fragment ALPHA_TEST

        //     #include "UnityCG.cginc"
        //     #include "Lighting.cginc"
        //     #include "AutoLight.cginc"
        //     #include "Lib/PowerGrassCore.cginc"
        //     #include "Lib/ShadowCasterPass.cginc"
            
        //     ENDCG
        // }

        Pass
        {
            Tags {"Queue"="AlphaTest" "LightMode"="ForwardBase"}
            // zwrite[_ZWriteMode]
            // blend [_SrcMode][_DstMode]
            // ztest [_ZTestMode]
            // ztest equal
            // zwrite off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            //#pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fwdbase 
            #pragma multi_compile_instancing
            #pragma shader_feature_local_fragment ALPHA_TEST

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "Lib/PowerGrassCore.cginc"
            #include "Lib/PowerGrassPass.cginc"
            ENDCG
        }

        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex shadowPass_vert
            #pragma fragment shadowPass_frag
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing  
            
            #pragma shader_feature_local_fragment ALPHA_TEST

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "Lib/PowerGrassCore.cginc"
            #include "Lib/ShadowCasterPass.cginc"
            
            ENDCG
        }
        
/*
        Pass {
            Tags { "LightMode" = "ForwardAdd" }
            ZWrite Off Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            //#pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fwdadd 
            #pragma multi_compile_instancing
            #pragma shader_feature_local ALPHA_TEST

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
                float4 lmap:TEXCOORD2;
                // UNITY_SHADOW_COORDS(3)
                SHADOW_COORDS(3)
                float3 worldPos:TEXCOORD4;
                float3 normal:TEXCOORD5;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;
            float _ColorScale;
            //float4 _Color;
            float4 _LightColor0;

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
				//UNITY_DEFINE_INSTANCED_PROP(float4,_PlayerPos)
                UNITY_DEFINE_INSTANCED_PROP(float4, _LightmapST)
            UNITY_INSTANCING_BUFFER_END(Props)

            float CalcAtten(float3 worldPos,out float3 lightDir){
                if(_WorldSpaceLightPos0.w == 0){
                    lightDir = normalize(_WorldSpaceLightPos0);
                    return 1;
                }else{
                    lightDir = normalize(_WorldSpaceLightPos0.xyz - worldPos);
                    float dist = length(_WorldSpaceLightPos0.xyz - worldPos);
                    return 1/(dist*+dist);
                }
            }

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float3 worldPos = WaveVertex(v,_WaveSpeed,_WaveIntensity);
                o.pos = UnityWorldToClipPos(worldPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //UNITY_TRANSFER_LIGHTING(o,v.uv.xy);
                TRANSFER_SHADOW(o)
                UNITY_TRANSFER_FOG(o,o.pos);
                o.worldPos = worldPos;
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                // sample the texture
                half4 col = tex2D(_MainTex, i.uv);

                #if defined(ALPHA_TEST)
                clip(col.a - _Cutoff);
                #endif 

                col *= UNITY_ACCESS_INSTANCED_PROP(Props,_Color) * _ColorScale;
                
                float3 n = normalize(i.normal);
                float3 l = (float3)0;
                // ao 
                half atten =  CalcAtten(i.worldPos,l);
                col *= atten * _LightColor0 * saturate(dot(n,l));

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
*/

    }
}
