---
kind: reference
area: content
status: active
stage: 3
owner: assets
last_reviewed: 2026-11-08
---

# Assets autorais — regra do projeto

## Decisão

**Nenhum modelo 3D é gerado em runtime.** Todo asset 3D tem uma fonte editável
e um arquivo exportado:

```text
source/blender/<categoria>/<id>/<id>.blend   # fonte editável
assets/models/<categoria>/<id>/<id>.glb      # export para o Godot
```

O jogo carrega o GLB; o código só posiciona, anima e conecta gameplay. A
geometria não nasce de `BoxMesh`/`MeshInstance3D` em GDScript.

## Mapas

- A geometria estática do mapa deve ser autoral (`.blend` ou `.tscn`).
- O JSON do mapa guarda apenas **âncoras e gameplay**: portas, spawns,
  wallbuys, perks, caixa, barricadas e pontos de interesse.
- `SliceBuilder`/`Bunker13Builder` ficam em `src/maps/legacy/` e são usados
  **apenas** por `tools/export_map.gd` para gerar o GLB inicial. O runtime carrega
  o GLB e só cria colisão, áreas e labels.

## Pipeline

1. Editar/modelar no Blender.
2. Exportar GLB para `assets/models/`.
3. Validar escala, pivôs, nomes de nós e materiais no Godot.
4. Rodar `./tests/ci.sh`.

Não editar o GLB como fonte: ele é artefato de exportação.

## Comandos

```bash
./blender.sh                                              # visão geral
./blender.sh source/blender/weapons/glock17/glock17.blend # modelo específico
blender -b --python source/blender/scripts/import_glb_to_blend.py -- \
  assets/models/weapons/glock17/glock17.glb \
  source/blender/weapons/glock17/glock17.blend
blender -b --python source/blender/scripts/make_overview.py
```

## Estado

- Fontes `.blend`: todas as armas (AK-74, M1911, Glock 17, MP5, M870, SKS,
  Ray Gun, Wunder, faca), mãos, zumbi, props, `slice`, Bunker 13, Depot e
  Kino der Toten.
- As armas AK-74, M1911, MP5, M870 e Wunder são geradas por scripts
  (`make_ak74.py`, `make_m1911.py`, `make_mp5.py`, `make_m870.py`,
  `make_wunder.py`) usando `weapon_kit.py`.
- `source/blender/overview.blend` mostra todos os modelos lado a lado.
- Geometria do mapa autoral em `assets/models/maps/<id>/<id>.glb`; o runtime
  carrega o GLB e gera colisão a partir dos AABBs. Nós `Ramp_*`/`Stair_*` usam
  colisão trimesh para permitir rampas.
- Kino é gerado por `make_kino.py` + `map_kit.py`, com `reference.md` próprio.
- Builders de runtime foram removidos do registry; os antigos ficam em
  `src/maps/legacy/` apenas para exportação.

## Nomes que o runtime procura

`Door_<id>`, `WallBuy_<id>`, `Perk_<id>`, `Box`, `Lid`, `Barricade_<id>` e
`Plank_*`. Renomear esses nós no Blender quebra a interação. Vãos de janela
usam segmentos `Wall_N_*`/`Wall_S_*`/`Wall_W_*`/`Wall_E_*` com peitoril e
verga; ver `source/blender/scripts/open_windows.py`.

## Regras

- Toda arma/inimigo novo entra com `.blend` + GLB + JSON.
- Armas devem ser normalizadas em **metros reais** antes do export; o mesmo
  `viewmodel.scale` não corrige fontes em cm/mm/unidades arbitrárias.
- Não commitar `*.blend1`/`*.blend2` (backups do Blender).
- Assets de terceiros exigem licença em `CREDITS.md`.
- O validador deve falhar se um asset referenciado não existir.
