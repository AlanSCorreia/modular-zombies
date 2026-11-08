---
kind: reference
area: content
status: active
stage: 5
owner: docs
last_reviewed: 2026-11-08
---

# Quickstart — autor de mapas

Guia curto para criar, validar e testar um mapa usando o dock
`bunker_tools`, sem editar o núcleo.

## Pré-requisitos

- Godot 4.7.2 no caminho padrão ou `GODOT_BIN`.
- Abrir o projeto com `./editor.sh`.
- O dock **Bunker Tools** aparece no painel inferior do editor.

## Criar um mapa

1. No dock, preencha o campo de ID, por exemplo `map.minha_fase`.
2. Preencha o nome exibido, por exemplo `Minha Fase`.
3. Clique em **Novo (template)**.
4. O arquivo é criado em `content/maps/minha_fase.json` (o prefixo `map.` vira
   parte do ID, não do nome do arquivo).
5. O validador roda automaticamente e mostra `OK` ou os erros.

O template usa `templates/map/template.json` e reutiliza a cena
`assets/models/maps/slice/slice.glb` até você exportar a geometria própria.

## Duplicar um mapa

1. Selecione o mapa de origem no dropdown.
2. Preencha o novo ID e nome.
3. Clique em **Duplicar selecionado**.
4. O JSON é copiado com o novo `id`/`name`; a cena do mapa de origem é
   reutilizada.

Duplicar não copia GLB/texturas. Troque o campo `scene` quando a geometria nova
estiver exportada.

## Trocar a geometria

1. Modele/edite o mapa no Blender (`source/blender/maps/<id>/<id>.blend`).
2. Exporte para `assets/models/maps/<id>/<id>.glb`.
3. No JSON, ajuste `"builder": "scene"` e
   `"scene": "res://assets/models/maps/<id>/<id>.glb"`.
4. Preserve os nomes que o runtime procura:
   `Door_<id>`, `WallBuy_<id>`, `Perk_<id>`, `Box`, `Lid`,
   `Barricade_<id>`, `Plank_*`.
5. Para janelas, separe as paredes em segmentos com peitoril/verga; a colisão é
   gerada por AABB de cada mesh.

## Preencher o JSON

| Campo | Conteúdo |
|---|---|
| `rooms` | retângulos jogáveis usados pelo `MapNav` (BFS) |
| `doors` | portas compráveis e a sala que liberam |
| `zombie_spawns` | fallback de spawn quando não há barricadas |
| `barricades` | janelas: tábuas, reparo, `spawn_position` |
| `barrels` / `traps` | props explosivos e explosivo usado |
| `wallbuys` | armas compráveis |
| `perks` | perks e efeito |
| `box` | caixa misteriosa |
| `player_spawn` | posição inicial do jogador |
| `starting_points` | pontos iniciais |

Regras rápidas:
- `id` de cada elemento é único.
- `room` de porta/barricada/spawn precisa existir em `rooms`.
- `explosive` de barril/trap precisa existir em `content/explosives/`.
- `weapon` de wallbuy precisa existir em `content/weapons/`.
- Não edite `.tres` de conteúdo; JSON é a fonte.

## Validar

No dock, clique em **Validar**. Para validar tudo pela linha de comando:

```bash
./run.sh --headless --script res://tests/run_content_validation.gd
./run.sh --headless --script res://tests/run_logic_tests.gd
```

Para o mapa novo carregar no jogo, o `ContentValidator` precisa aceitar o JSON e
`--map <id>` precisa abrir a cena. O nome do arquivo não importa; o `id` sim.

## Playtest

1. Selecione o mapa no dropdown.
2. Clique em **Playtest mapa**.
3. O dock grava `user://playtest.cfg`; o jogo consome o override uma vez.
4. `--map` na linha de comando continua tendo prioridade.
5. O override é apagado na primeira leitura; o próximo playtest sem mapa usa o
   default.

## Erros comuns

| Sintoma | Onde corrigir |
|---|---|
| “mapa já existe” | escolha outro ID ou remova o JSON antigo |
| JSON não carrega | valide vírgulas/aspas e o campo `id` |
| Porta/barricada não aparece | confira `Door_<id>`/`Barricade_<id>` na cena GLB |
| Zumbi não encontra caminho | `rooms`/`doors` precisam formar o grafo correto |
| Mapa abre vazio | `scene` aponta para GLB existente e importado |
| Player cai ou atravessa parede | colisão AABB: ajuste a geometria/segmentos |
| Playtest abre o mapa errado | selecione o mapa no dock antes do botão |

## Limites atuais

- O template reutiliza a cena do slice; a geometria própria é uma etapa manual.
- Não há marcadores 3D/content browser no dock ainda.
- O builder de runtime é `scene`; builders legados são só exportação.
- Nada de modelo 3D gerado em runtime.

## Checklist de aceite

- [ ] ID único e arquivo em `content/maps/`.
- [ ] `scene` existente e importada.
- [ ] `rooms`/`doors` sem softlock.
- [ ] Wallbuys/perks/barricadas com IDs únicos.
- [ ] `Validar` sem erros.
- [ ] Playtest abre o mapa selecionado.
- [ ] `./tests/ci.sh` verde.
