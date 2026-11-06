# Source — Blender

Fontes editáveis. Esta pasta tem `.gdignore`; o Godot não importa `.blend`.

## Estrutura

```text
source/blender/
  weapons/<id>/<id>.blend
  weapons/<id>/reference.md
  weapons/<id>/export.py
  hands/hands.blend
  enemies/<id>/<id>.blend
  scripts/export_weapon.py
```

## Export

1. Abrir o `.blend` no Blender 4.5.
2. Conferir escala (metros), `-Z` frente, `+Y` cima.
3. Selecionar a arma (sem mãos) e os empties `GripSocket`/`Muzzle`.
4. Rodar `export.py` ou exportar GLB para
   `assets/models/weapons/<id>/<id>.glb`.
5. Validar no Godot e preencher o JSON.

Use o resultado da Glock como referência visual; o pipeline está em
`docs/planning/14-weapon-workflow.md`.
