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
- `SliceBuilder`/`Bunker13Builder` são **legado temporário** até a migração.

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

- Fontes `.blend`: Glock 17, MP5, M870, AK-74, Wunder, pistol e zumbi.
- `source/blender/overview.blend` mostra todos os modelos lado a lado.
- **Dívida:** a geometria do mapa ainda é construída em runtime. A migração
  para cena autoral é P0 da Etapa 3.

## Regras

- Toda arma/inimigo novo entra com `.blend` + GLB + JSON.
- Não commitar `*.blend1`/`*.blend2` (backups do Blender).
- Assets de terceiros exigem licença em `CREDITS.md`.
- O validador deve falhar se um asset referenciado não existir.
