# PowerGrassPrj

[English](README.md) | [简体中文](README.zh-CN.md)


URP instanced grass rendering with gradient-noise wind waves, interactive push, distance culling and shadows

## Features

- **Grass.shader** (`URP/Nature/Grass`) — cull-off URP grass shader with GPU instancing (`#pragma multi_compile_instancing`)
  - Wind: gradient-noise wave deformation in the vertex shader (`WaveVertex` / `CalcNoise`, driven by `_WaveSpeed/_WaveIntensity/_WaveScale`), tinted by `_WaveColor1/_WaveColor2`, plus global wind `_GlobalWindDir`
  - Interactive: `CalcForce` pushes grass away from global `_PlayerPos` using `_PushRadius/_PushIntensity` (and vertex color `color.x` attenuation)
  - Distance culling: `_DistanceCullingOn/_CullPos/_CullDistance/_CullInvert` (`CalcCullDistance`), clipped in fragment and shadow passes
  - PBR mask: packed metallic/smoothness/occlusion from `_MetallicMaskMap` (`SplitPbrMaskTexture`, `_Metallic/_Smoothness/_Occlusion`)
  - Lighting: main-light diffuse N·L (half-lambert) with `_ColorScale`/`_Color`, SH probes (`SampleSH`), lightmap support (`LIGHTMAP_ON`, per-instance `_LightmapST`)
  - Shadows: receives main-light shadow (`CalcShadow`, `_MainLightShadowSoftScale`, custom `_CustomShadowNormalBias/_CustomShadowDepthBias`), disable via `_RECEIVE_SHADOWS_OFF`
  - Fog: `BlendFogSphere` sphere fog with height/depth/noise toggles (`_HeightFogOn/_DepthFogOn/_FogNoiseOn`, `FOG_LINEAR/SIMPLE_FOG`)
  - Alpha test (`ALPHA_TEST`, `_CutoffOn/_Cutoff`)
- **Lib/GrassPass.hlsl** — main pass vert/frag: `WaveVertex` deformation, PBR-mask split, N·L × wave-color diffuse, SH + lightmap, shadow atten, fog blend
- **Lib/GrassCore.hlsl** — `CalcForce` (interactive push), `CalcNoise` (gradient-noise wave), `WaveVertex` (wave + interactive + global wind), `CalcCullDistance`
- **Lib/GrassInput.hlsl** — samplers, `UnityPerMaterial` instanced properties, global `_PlayerPos`
- **Lib/ShadowCasterPass.hlsl** — shadow pass re-applies `WaveVertex` (shadows follow the wind) + alpha/distance-culling clip
- **DrawChildrenInstancedSO assets** — `Scenes/clip 5/DrawGrass.asset`, `GrassGroup.asset`, `GrassGroup (1).asset`, `Scenes/grass1/GameObject.asset` are baked instanced-draw configs (mesh `Grass_Mesh.fbx`, materials, per-instance transforms) used with the **DrawChildrenInstanced** component from **PowerUtilities**
- **CullingProfile.asset** (clip 5) — ScriptableObject for GPU-instance culling; its script (guid `b4ad7d968845cae44aaaacdf7bf651`) is **not shipped in this workspace**
- Demo scenes: `Scenes/clip 5.unity` (large grass field of `Grass_Mesh.fbx` prefab instances) and `Scenes/grass1.unity` (terrain + baked lighting, plus `GlobalVolumeProfile.asset` URP volume profile with Bloom, `Volume.png`/`VolumeProfileAsset.png` previews, lightmap + reflection probe baked data)
- Sample arts in `Arts/`: `Grass Assets/Grass_Mesh.fbx`, `Green_Grass_AlbedoA.tga`, `Green_Grass_MAODS.tga`, `Green_Grass_Normal.tga`, `01 - Default clipURP.mat` (refers to a shader guid not present here), URP `Terrain/New Terrain.asset` + terrain layers, `QS-GRASS-*.png` textures

## Folder Structure

```
PowerGrassPrj/
├── PowerGrass/
│   ├── Grass.shader                 # URP/Nature/Grass
│   ├── Lib/                         # GrassInput.hlsl, GrassCore.hlsl, GrassPass.hlsl, ShadowCasterPass.hlsl
│   ├── Scenes/
│   │   ├── clip 5.unity             # big instanced grass demo
│   │   │   └── clip 5/              # DrawGrass.asset, GrassGroup*.asset, CullingProfile.asset
│   │   └── grass1.unity             # terrain demo (GlobalVolumeProfile.asset, baked lighting, screenshots)
│   ├── Arts/                        # Grass Assets, Terrain, TerrainLayers, Textures
│   ├── Test/                        # quad.fbx
│   └── Docs/PowerGrass.doc          # (binary document; not parsed)
└── README.md
```

## Usage / Setup

This package ships **no C# scripts itself** — the shader depends on sibling **PowerShaderLib** (`../../../PowerShaderLib/`), and runtime drawing is driven by **PowerUtilities**:

1. **Component**: add **DrawChildrenInstanced** (`PowerUtilities`) to a GameObject and drag a **DrawChildrenInstancedSO** into `drawInfoSO` (e.g. the shipped `GrassGroup (1).asset` / `DrawGrass.asset`).
2. **ScriptableObject**: on `DrawChildrenInstancedSO` press **BakeChildren** (custom inspector button) — it gathers child `MeshRenderer`s (filtered by layer/tag), groups them by (lightmap index, shared mesh, shared material), chunks at 1023 instances, and stores local-to-world transforms + lightmap coords + bounding spheres; optionally `disableChildren` / `culledRatio` (destroy probability).
3. **Runtime**: `DrawChildrenInstanced` builds a `CullingGroup` from the baked bounding spheres, queries visible instances per group each frame, and draws with `Graphics.RenderMeshInstanced` (or `CommandBuffer.DrawMeshInstanced`), with lightmap / shadowmask / receiveShadow / lightProbeUsage options (`DrawChildrenInstancedTools`).
4. Assign a material using **Grass.shader** to the baked group (editor also offers **BakeMaterial** to clone materials), then open `Scenes/clip 5` or `Scenes/grass1` to see the result.

## Reference Git

(no reference gits in the original README)

## Notes / Changelog

- Demo assets were authored with a newer/older variant of `DrawChildrenInstancedSO` (fields such as `originalTransformsGroupList`, `culledUnderLevel2`, `destroyGameObjectWhenCannotUse`); they still bind to the same Mono script guid `7eb3b05bb974b1a4ab7aa0b3cfd8e65e`.
- `CullingProfile.asset` references a script (guid `b4ad7d968845cae44aaaacdf7bf651`) that is not included in this workspace.
- `01 - Default clipURP.mat` references shader guid `727431fe7cd78034093937508f527186`, which is not present in this workspace (external shader).