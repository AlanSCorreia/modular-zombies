# Source — Blender

Fontes editáveis. Esta pasta tem `.gdignore`; o Godot não importa `.blend`.

## Estrutura

```text
source/blender/
  weapons/<id>/<id>.blend
  enemies/<id>/<id>.blend
  maps/<id>/<id>.blend
  hands/hands.blend
  scripts/import_glb_to_blend.py
  scripts/weapon_kit.py
  scripts/make_ak74.py
  scripts/make_m1911.py
  scripts/make_mp5.py
  scripts/make_m870.py
  scripts/make_wunder.py
  scripts/make_hands.py
  scripts/make_knife.py
  scripts/prepare_weapon_hands.py
  scripts/open_windows.py
  scripts/make_overview.py
  overview.blend
```

## Abrir

```bash
./blender.sh                                              # visão geral
./blender.sh source/blender/weapons/glock17/glock17.blend # modelo específico
./blender.sh source/blender/maps/bunker13/bunker13.blend  # mapa
```

## Export

1. Editar o `.blend` no Blender 4.5 LTS.
2. Conferir escala (metros), `-Z` frente, `+Y` cima.
3. Selecionar a arma (sem mãos) e os empties `GripSocket`/`Muzzle`.
4. Exportar GLB para `assets/models/<categoria>/<id>/<id>.glb`
   (mapas: `assets/models/maps/<id>/<id>.glb`).
5. Validar no Godot e preencher o JSON.

O GLB é artefato de exportação; nunca edite o GLB como fonte.

## Mãos compartilhadas

`hands.glb` é único para todas as armas e contém `GripSocket`, `HandL` e
`HandR`. Regenere com:

```bash
blender -b --python source/blender/scripts/make_hands.py
blender -b source/blender/weapons/glock17/glock17.blend \
  --python source/blender/scripts/prepare_weapon_hands.py -- glock17
blender -b source/blender/weapons/mp5/mp5.blend \
  --python source/blender/scripts/prepare_weapon_hands.py -- mp5
```

Nenhum GLB de arma deve conter `HandL`/`HandR`; o `ViewmodelFactory` anexa o
asset compartilhado no `GripSocket` da arma.

Armas autorais AK-74, M1911, MP5, M870 e Wunder:

```bash
blender -b --python source/blender/scripts/make_ak74.py
blender -b --python source/blender/scripts/make_m1911.py
blender -b --python source/blender/scripts/make_mp5.py
blender -b --python source/blender/scripts/make_m870.py
blender -b --python source/blender/scripts/make_wunder.py
```

Cada pasta de arma tem `reference.md` com dimensões, sockets e partes móveis.

A faca segue a mesma convenção e é gerada por:

```bash
blender -b --python source/blender/scripts/make_knife.py
```

Ela é anexada ao `HandR` do `hands.glb` (não tem mãos próprias).

Nos mapas, preserve os nomes `Door_<id>`, `WallBuy_<id>`, `Perk_<id>`, `Box`,
`Lid`, `Barricade_<id>` e `Plank_*`; o runtime depende deles.

## Janelas do Bunker 13

Os vãos são segmentos das paredes `Wall_N_*`/`Wall_S_*`/`Wall_W_*`/
`Wall_E_*`, com peitoril e verga. Para regenerar:

```bash
blender -b source/blender/maps/bunker13/bunker13.blend \
  --python source/blender/scripts/open_windows.py
```

O script é idempotente: se as paredes originais já não existem, apenas
reexporta o GLB com as luzes.

## Importar GLB existente

```bash
blender -b --python source/blender/scripts/import_glb_to_blend.py -- \
  assets/models/weapons/glock17/glock17.glb \
  source/blender/weapons/glock17/glock17.blend
```

## Regenerar a visão geral

```bash
blender -b --python source/blender/scripts/make_overview.py
```

Pipeline completo em `docs/planning/14-weapon-workflow.md` e
`docs/planning/18-authored-assets.md`.
