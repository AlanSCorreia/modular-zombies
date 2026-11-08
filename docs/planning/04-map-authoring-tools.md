---
kind: reference
area: content
status: reference
stage: 5
owner: infra
last_reviewed: 2026-11-08
---

# Ferramentas de autoria de mapas

## Estado na v2

**Planejado para a Etapa 5 — Ferramentas; ainda não implementado.** O plugin `bunker_tools` não
existe no scaffold atual. A ordem é: Etapa 2 — Conteúdo (dados) → Etapas 3–4 — Gameplay/Interações (loop/UI) → Etapa 5 — Ferramentas.

## Objetivo

Permitir que o usuário crie, valide e teste mapas **dentro do editor Godot**,
sem editar código do núcleo.

## Fluxo do autor

1. Abrir o projeto pelo atalho **Bunker 13 — Editor**.
2. Criar mapa a partir de um template.
3. Preencher portas, wallbuys, spawns, perks, caixa, barricadas e modificadores.
4. Adicionar props explosivos (`explosive_props`) e traps.
5. Posicionar marcadores na cena 3D.
6. Montar Easter Eggs no grafo de passos.
7. Clicar em **Validar**.
8. Clicar em **Playtest** (abre o jogo no mapa).
9. Iterar.

## Ferramentas

| Ferramenta | Responsabilidade |
|---|---|
| Launcher do editor | Atalho e `editor.sh` com `--editor --path` |
| Plugin `bunker_tools` | Registro do plugin e docks |
| `Map JSON` + editor | Editar dados do mapa |
| Marcadores 3D | Posicionar portas, spawns, wallbuys, barricadas e áreas |
| Templates | Bunker, corredor, arena, mapa vazio |
| Validador | JSON schema, IDs, referências, barricadas e softlocks |
| Playtest | Rodar o mapa selecionado |
| Content browser | Listar/criar mapas, armas, inimigos e perks |
| Quest graph | GraphEdit com passos e conexões |
| Debug runtime | Mostrar passo atual, triggers e estado da quest |

## Design técnico

```text
addons/bunker_tools/
  plugin.cfg
  plugin.gd                 # EditorPlugin
  map_dock.gd               # lista/criar/duplicar/validar/playtest
  map_inspector.gd          # EditorInspectorPlugin
  marker_gizmo.gd           # EditorNode3DGizmoPlugin
  marker_tool.gd            # posicionamento 3D
  quest_graph.gd            # GraphEdit
  quest_node.gd             # GraphNode
  validator.gd              # validação de conteúdo
  playtest.gd               # EditorInterface.play_custom_scene
```

- `EditorPlugin.forward_3d_gui_input` para clicar e posicionar marcadores.
- `EditorUndoRedoManager` para undo/redo.
- `EditorInterface` para abrir cenas e rodar playtest.
- Dados salvos em `.json`; nada de conteúdo em `.tres` ou escondido em cena.
- O mapa referencia assets via `res://`; o validador confere existência e importação.
- O jogo roda com `--map <id>` ou uma cena de teste que carrega o mapa.

## Fases

### Fase A — MVP
- Launcher do editor.
- `Map JSON` + schema + editor.
- Conversão do Bunker 13.
- Validador + playtest.
- **Aceite:** criar/duplicar/validar/testar um mapa sem tocar em código.

### Fase B — Marcadores 3D
- Ferramenta de posicionamento com gizmos.
- Templates e content browser.
- **Aceite:** mapa jogável montado só pelo editor.

### Fase C — Quests
- Grafo de Easter Eggs, triggers e recompensas.
- Debug overlay e validação de grafo.
- **Aceite:** criar uma música secreta e uma main quest de 3 passos.

### Fase D — Escala
- Docs para autores, lint no CI, exportação.
- **Aceite:** segundo mapa e nova arma sem mudança no núcleo.

## Riscos

| Risco | Mitigação |
|---|---|
| Ferramenta antes da base | Só iniciar após a Etapa 2 |
| API do editor mudar | Fixar versão 4.7.x e testar |
| Editor complexo demais | MVP primeiro; graph depois |
| Dados inválidos | Validador obrigatório |
| Playtest lento | Cache de conteúdo e cena de teste dedicada |
