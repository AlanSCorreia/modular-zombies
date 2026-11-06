# Source — Blender

Fontes editáveis. Esta pasta tem `.gdignore`; o Godot não importa `.blend`.

## Estrutura

```text
source/blender/
  weapons/<id>/<id>.blend
  enemies/<id>/<id>.blend
  maps/<id>/<id>.blend          # futuro
  scripts/import_glb_to_blend.py
  scripts/make_overview.py
  overview.blend
```

## Abrir

```bash
./blender.sh                                              # visão geral
./blender.sh source/blender/weapons/glock17/glock17.blend # modelo específico
```

## Export

1. Editar o `.blend` no Blender 4.5 LTS.
2. Conferir escala (metros), `-Z` frente, `+Y` cima.
3. Selecionar a arma (sem mãos) e os empties `GripSocket`/`Muzzle`.
4. Exportar GLB para `assets/models/<categoria>/<id>/<id>.glb`.
5. Validar no Godot e preencher o JSON.

O GLB é artefato de exportação; nunca edite o GLB como fonte.

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
