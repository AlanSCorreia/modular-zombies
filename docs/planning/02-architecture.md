# Arquitetura — v2

## Contexto

A v1 (`zombie-fps-legacy`) é um protótipo funcional, mas concentra
responsabilidades em `game.gd`/`player.gd`, usa conteúdo hardcoded e interações
stringly typed. A v2 **reescreve o runtime** para eliminar esses limites.

| v1 (legado) | v2 (alvo) |
|---|---|
| `game.gd` orquestra tudo | Serviços + `GameRoot` enxuto |
| `player.gd` com combate e viewmodel | `PlayerController` + `WeaponController` + `ViewmodelFactory` |
| `level_builder.gd` com dados fixos | `MapDefinition` + `MapController` + builder |
| Metadados `{kind, cost}` | `Interactable` tipado |
| Dicionário de armas hardcoded | JSON → DTO tipado |
| Conteúdo em `.tres` | JSON canônico + schemas |
| Glock como caso especial no viewmodel | Todas as armas iguais + mãos compartilhadas |
| Strings de estado | Enums/state machines |
| Testes dentro do jogo | `tests/` + harness |
| Navmesh rebake em runtime | Variantes pré-bakeadas (Produção) |

## Estado atual (Preparação concluída)

Já existe: `project.godot`, `main.tscn`, `Events`, `Content`, `Sfx`, `GameRoot`,
`PlayerController`, `WeaponController` (Glock), `ZombieEnemy`, `SliceHUD`,
loader/validador JSON, plugin `bunker_tools`, CI local e vertical slice jogável.

Pendente para Conteúdo/Gameplay: Bunker 13 completo em JSON, reorganização de assets,
5 armas, faca, explosivos, barricadas, rodadas/economia completas e UI/áudio finais.

## Arquitetura alvo

```
ContentRegistry
 ├─ MapDefinition ──► MapController
 │                    ├─ RoundManager
 │                    ├─ EconomyService
 │                    ├─ SpawnService
 │                    ├─ InteractionSystem
 │                    ├─ BarricadeSystem
 │                    ├─ QuestSystem
 │                    └─ MapMechanic[] (nós específicos)
 ├─ WeaponDefinition ─► WeaponFactory ─► WeaponController
 ├─ EnemyDefinition ──► EnemyFactory
 └─ PerkDefinition ───► PerkService

EventBus (sinais) ◄──► HUD / Áudio / VFX / Save
```

## Armas e mãos (v2)

**Todas as armas serão modeladas no Blender.** Workflow completo em
`14-weapon-workflow.md`. A Glock 17 é apenas a primeira
`WeaponDefinition`, não um caso especial. As **mãos são um asset separado,
compartilhado e reutilizado** por todas as armas.

```text
assets/models/
  hands/hands.glb          # rig + animações (grip_pistol, grip_rifle, fire, reload...)
  weapons/glock17/glock17.glb   # somente a arma + partes móveis
  weapons/mp5/mp5.glb
content/weapons/glock17.json
```

```json
{
  "id": "weapon.glock17",
  "name": "GLOCK 17",
  "type": "hitscan",
  "scene": "res://assets/models/weapons/glock17/glock17.glb",
  "hands": "res://assets/models/hands/hands.glb",
  "grip_profile": "pistol",
  "animation_set": "res://assets/animations/viewmodels/glock17.tres",
  "moving_parts": ["Slide", "Magazine", "Trigger"],
  "stats": {"damage": 34, "mag": 17, "reserve": 102, "rpm": 420}
}
```

- `ViewmodelFactory` instancia a arma, pega as mãos do cache, encaixa no
  `GripSocket` e devolve um `ViewmodelRig`.
- `WeaponAnimator` toca clipes da arma e das mãos; as mãos têm poses por
  classe de empunhadura (pistola, rifle, escopeta).
- Nada de `if weapon_id == "glock17"` no núcleo.
- A v1 tratava a Glock como caso especial; a v2 elimina isso.

## JSON como fonte de verdade

**Todo conteúdo de jogo é JSON** (mapas, armas, faca, explosivos, inimigos,
perks, quests e mecânicas). O runtime valida e converte para DTOs tipados.
Não há conteúdo em `.tres`; `.tres`/`.tscn` ficam para assets de engine
(materiais, animações compostas, cenas, bus layout).
Detalhes e exemplos em `09-json-content-pipeline.md`.

### Fronteira: JSON vs assets de engine

| Tipo | Formato | Onde |
|---|---|---|
| Conteúdo de jogo (mapas, armas, quests) | **JSON** | `content/` |
| Cenas/prefabs | `.tscn` | `assets/prefabs/` ou `scenes/` |
| Materiais, animações compostas, tema, bus layout | `.tres` | `assets/materials`, `assets/animations`, `assets/audio` |
| Modelos, texturas, áudio, fontes | GLB/PNG/OGG/TTF | `assets/` |
| Fonte editável (Blender) | `.blend`/`.py` | `source/` (com `.gdignore`) |



## Contratos (DTOs de runtime)

Os contratos abaixo são **DTOs de runtime** criados a partir do JSON; não são
arquivos `.tres`.

```gdscript
class_name MapDefinition extends RefCounted   # DTO de runtime (fonte: JSON)
var id: StringName
var display_name: String
var level_scene: PackedScene        # ou builder procedural
var player_spawn: Vector3
var doors: Array[DoorDefinition]
var wallbuys: Array[WallBuyDefinition]
var spawns: Array[SpawnDefinition]
var perks: Array[PerkDefinition]
var box: BoxDefinition
var mechanics: Array[MapMechanicDefinition]
var barricades: Array[BarricadeData]
var quests: Array[QuestDefinition]
```

```gdscript
class_name BarricadeData extends RefCounted   # DTO de runtime (fonte: JSON)
var id: StringName
var room: StringName
var position: Vector3
var rotation_y: float
var max_planks := 6
var repair_time := 0.8
var repair_points := 10
var tear_time_base := 2.2
var tear_time_round_scale := 0.08
var spawn_position: Vector3
var climb_time := 0.9
```

```gdscript
class_name MapMechanic extends Node
func setup(ctx: MapContext) -> void
func on_event(event: StringName, payload: Dictionary) -> void
func on_round_start(round_no: int) -> void
func interact(player: Node, target: Interactable) -> bool
func serialize() -> Dictionary
```

```gdscript
class_name QuestDefinition extends RefCounted   # DTO de runtime (fonte: JSON)
var id: StringName
var type: QuestType              # MAIN, SIDE, MUSIC, LORE
var steps: Array[QuestStep]
var rewards: Array[RewardDefinition]
var requires_coop: bool
```

```gdscript
class_name QuestStep extends RefCounted   # DTO de runtime (fonte: JSON)
var trigger: TriggerType          # INTERACT, KILL, ENTER_AREA, COLLECT...
var target_id: StringName
var count: int = 1
var next: Array[StringName]
var hint: String
```

## Estrutura de conteúdo

```
content/
  maps/bunker13.json
  weapons/glock17.json
  weapons/knife.json
  explosives/barrel_fuel.json
  equipment/grenade.json
  enemies/zombie.json
  perks/jugg.json
  quests/bunker13_music.json
schemas/
  map.schema.json
  weapon.schema.json
  explosive.schema.json
  melee.schema.json
  quest.schema.json
```

## Organização de assets

Detalhes e convenções em `11-assets.md`.

```text
assets/
  prefabs/*.tscn
  models/
    weapons/<id>/<id>.glb
    hands/hands.glb
    enemies/<id>/<id>.glb
    props/<id>/<id>.glb
  textures/
    world/<set>/{diff,nor,rough,ao}.png
    weapons/<id>/*.png
    ui/*.png
  materials/*.tres
  animations/
    viewmodels/<id>.tres
    characters/<id>.tres
  audio/
    weapons/<id>/*.ogg
    zombies/*.ogg
    music/*.ogg
    ui/*.ogg
    foley/*.ogg
    default_bus_layout.tres
  fonts/*.ttf
  ui/
    icons/*.svg
    images/*.png
  vfx/
    explosions/*.tscn
    impacts/*.tscn
    textures/*.png
  shaders/*.gdshader
source/
  blender/
    weapons/*.blend
    hands/*.blend
    enemies/*.blend
    scripts/*.py
```

- **GLB é o formato de entrega**; `.blend` fica em `source/` com `.gdignore`.
- **Animações**: por padrão embutidas no GLB; `.tres` só para composição/override
  (viewmodels, bibliotecas compartilhadas).
- **Texturas**: um conjunto PBR por material; o material `.tres` referencia.
- **Áudio**: por categoria; eventos lógicos/variantes podem ficar em
  `content/audio/events.json` quando necessário.
- **VFX**: cena `.tscn` + texturas.
- **Licenças**: `CREDITS.md` central + `assets/third_party/<pack>/LICENSE`.
- **Nomes**: `snake_case`, sem espaços/acentos; um diretório por modelo.


## Regras de ouro

1. Zero `if map_id == ...` no núcleo.
2. Easter Egg é **grafo de passos + predicados**, não sequência de `if`s.
3. Mecânica única é **nó/script isolado**, registrado pelo mapa.
4. Arma é definição + cena GLB + mãos compartilhadas + animações + recarga.
5. Interação é componente tipado.
6. Todo conteúdo é JSON e passa pelo validador antes do playtest.
7. Explosivos usam `ExplosiveDefinition` JSON; faca usa `MeleeDefinition` JSON (`10-combat-systems.md`).
8. Barricadas são dados do mapa (`13-barricades.md`).
9. Assets de engine usam `.tres`/`.tscn`; conteúdo de jogo usa JSON.

## Estratégia de reescrita

| Etapa | Entrega |
|---|---|
| Preparação | Scaffold, docs, Kanban, importação validada |
| Conteúdo | JSON schemas + loader + validador + Bunker 13 em dados |
| Gameplay | Player, armas, faca, explosivos, zumbis, barricadas, rodadas |
| Interações | Interações, HUD e áudio |
| Ferramentas | Ferramentas de mapa no editor |
| Quests | QuestSystem + Easter Eggs |
| Escala | 2º mapa + armas novas |
| Produção | Save, settings, export, performance |

## Decisão de linguagem

**GDScript.** C# pode acelerar lógica CPU-bound, mas o gargalo atual é GPU;
migrar exigiria build .NET e não garantiria FPS. Reavaliar somente após
profiling. Ver `07-adr/0001-gdscript-vs-csharp.md`.

## Riscos

| Risco | Mitigação |
|---|---|
| Perder polish na reescrita | Paridade checklist antes da troca |
| Refatoração longa | Fatias verticais jogáveis |
| Ferramenta antes da base | Ferramentas só após Conteúdo–Interações |
| Quest complexa | Framework de passos + script de escape |
| Conteúdo inválido | Validador + CI |
| Performance | Orçamento por mapa e profiling |
