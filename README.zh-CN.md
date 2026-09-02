# PowerGrassPrj

[English](README.md) | [简体中文](README.zh-CN.md)

## 简介

PowerGrassPrj 是一套 URP 实例化草皮（grass）渲染方案，包含梯度噪声风浪、交互拨动（推开）、距离剔除与阴影等特性，适合大规模草地、植被等地面覆盖物渲染。项目随附完整的示例场景、烘焙好的实例化绘制配置（DrawChildrenInstancedSO 资源）以及地形、贴图等演示资源，可直接打开场景查看效果。

## 功能特性（Features）

- **Grass.shader**（`URP/Nature/Grass`）—— 关闭背面剔除（cull-off）的 URP 草着色器，支持 GPU 实例化（`#pragma multi_compile_instancing`）
  - 风场：顶点着色器中的梯度噪声波浪形变（`WaveVertex` / `CalcNoise`，由 `_WaveSpeed/_WaveIntensity/_WaveScale` 驱动），由 `_WaveColor1/_WaveColor2` 着色，另有全局风 `_GlobalWindDir`
  - 交互：`CalcForce` 利用 `_PushRadius/_PushIntensity`（以及顶点色 `color.x` 衰减）将草从全局 `_PlayerPos`（玩家位置）处推开
  - 距离剔除：`_DistanceCullingOn/_CullPos/_CullDistance/_CullInvert`（`CalcCullDistance`），在片元与阴影 Pass 中进行裁剪
  - PBR 遮罩：从 `_MetallicMaskMap` 解包金属度/光滑度/环境光遮蔽（`SplitPbrMaskTexture`、`_Metallic/_Smoothness/_Occlusion`）
  - 光照：主光漫反射 N·L（半兰伯特）配合 `_ColorScale`/`_Color`、SH 探针（`SampleSH`）、光照贴图支持（`LIGHTMAP_ON`，每实例 `_LightmapST`）
  - 阴影：接收主光阴影（`CalcShadow`、`_MainLightShadowSoftScale`、自定义 `_CustomShadowNormalBias/_CustomShadowDepthBias`），可通过 `_RECEIVE_SHADOWS_OFF` 关闭
  - 雾效：`BlendFogSphere` 球形雾，带高度/深度/噪声开关（`_HeightFogOn/_DepthFogOn/_FogNoiseOn`、`FOG_LINEAR/SIMPLE_FOG`）
  - Alpha 测试（`ALPHA_TEST`、`_CutoffOn/_Cutoff`）
- **Lib/GrassPass.hlsl** —— 主 Pass 顶点/片元：`WaveVertex` 形变、PBR 遮罩解包、N·L × 波浪色漫反射、SH + 光照贴图、阴影衰减、雾效混合
- **Lib/GrassCore.hlsl** —— `CalcForce`（交互拨动）、`CalcNoise`（梯度噪声波浪）、`WaveVertex`（波浪 + 交互 + 全局风）、`CalcCullDistance`
- **Lib/GrassInput.hlsl** —— 采样器、`UnityPerMaterial` 实例化属性、全局 `_PlayerPos`
- **Lib/ShadowCasterPass.hlsl** —— 阴影 Pass 重新应用 `WaveVertex`（阴影跟随风浪）+ alpha/距离剔除裁剪
- **DrawChildrenInstancedSO 资源** —— `Scenes/clip 5/DrawGrass.asset`、`GrassGroup.asset`、`GrassGroup (1).asset`、`Scenes/grass1/GameObject.asset` 均为烘焙好的实例化绘制配置（网格 `Grass_Mesh.fbx`、材质球、每实例变换），配合 **PowerUtilities** 中的 **DrawChildrenInstanced** 组件使用
- **CullingProfile.asset**（clip 5）—— 用于 GPU 实例剔除的 ScriptableObject；其脚本（guid `b4ad7d968845cae44aaaacdf7bf651`）**未随本工作区一并发布**
- 示例场景：`Scenes/clip 5.unity`（由 `Grass_Mesh.fbx` 预制体实例组成的大规模草场）与 `Scenes/grass1.unity`（地形 + 烘焙光照，另含带 Bloom（泛光）的 `GlobalVolumeProfile.asset` URP 体积配置、`Volume.png`/`VolumeProfileAsset.png` 预览图，以及光照贴图和反射探针的烘焙数据）
- `Arts/` 中的示例美术资源：`Grass Assets/Grass_Mesh.fbx`、`Green_Grass_AlbedoA.tga`、`Green_Grass_MAODS.tga`、`Green_Grass_Normal.tga`、`01 - Default clipURP.mat`（引用的着色器 guid 不在此处）、URP `Terrain/New Terrain.asset` 与地形图层、`QS-GRASS-*.png` 贴图

## 目录结构（Folder structure）

```
PowerGrassPrj/
├── PowerGrass/
│   ├── Grass.shader                 # URP/Nature/Grass
│   ├── Lib/                         # GrassInput.hlsl、GrassCore.hlsl、GrassPass.hlsl、ShadowCasterPass.hlsl
│   ├── Scenes/
│   │   ├── clip 5.unity             # 大规模实例化草皮示例
│   │   │   └── clip 5/              # DrawGrass.asset、GrassGroup*.asset、CullingProfile.asset
│   │   └── grass1.unity             # 地形示例（GlobalVolumeProfile.asset、烘焙光照、截图）
│   ├── Arts/                        # 草地资源、地形、地形图层、贴图
│   ├── Test/                        # quad.fbx
│   └── Docs/PowerGrass.doc          # （二进制文档；未解析）
└── README.md
```

## 使用说明（Usage）

本包**自身不包含 C# 脚本**——着色器依赖同级 **PowerShaderLib**（`../../../PowerShaderLib/`），运行时绘制由 **PowerUtilities** 驱动：

1. **组件**：在 GameObject 上添加 **DrawChildrenInstanced**（`PowerUtilities`）组件，并将 **DrawChildrenInstancedSO** 拖入 `drawInfoSO` 字段（例如随包提供的 `GrassGroup (1).asset` / `DrawGrass.asset`）。
2. **ScriptableObject**：在 `DrawChildrenInstancedSO` 上点击 **BakeChildren**（自定义检查器按钮）——它会收集子级 `MeshRenderer`（按图层/标签过滤），按（光照贴图索引、共享网格、共享材质）分组，以 1023 个实例为一块进行分块（chunking），并存储本地到世界变换、光照贴图坐标与包围球；可选 `disableChildren` / `culledRatio`（销毁概率）。
3. **运行时**：`DrawChildrenInstanced` 根据烘焙的包围球构建 `CullingGroup`，每帧查询每个分组中可见的实例，并使用 `Graphics.RenderMeshInstanced`（或 `CommandBuffer.DrawMeshInstanced`）进行绘制，支持 lightmap（光照贴图）/ shadowmask / receiveShadow / lightProbeUsage 等选项（`DrawChildrenInstancedTools`）。
4. 为烘焙好的分组指定使用 **Grass.shader** 的材质球（编辑器还提供 **BakeMaterial** 用于克隆材质球），然后打开 `Scenes/clip 5` 或 `Scenes/grass1` 即可看到效果。

## 参考仓库 / 依赖（Reference Gits）

（原英文 README 中未列出参考仓库）

## 备注 / 更新记录（Notes / Changelog）

- 示例资源由较新/较旧版本的 `DrawChildrenInstancedSO` 制作（字段如 `originalTransformsGroupList`、`culledUnderLevel2`、`destroyGameObjectWhenCannotUse`）；它们仍绑定到同一个 Mono 脚本 guid `7eb3b05bb974b1a4ab7aa0b3cfd8e65e`。
- `CullingProfile.asset` 引用的脚本（guid `b4ad7d968845cae44aaaacdf7bf651`）未包含在本工作区中。
- `01 - Default clipURP.mat` 引用的着色器 guid 为 `727431fe7cd78034093937508f527186`，该着色器不在本工作区中（外部着色器）。
