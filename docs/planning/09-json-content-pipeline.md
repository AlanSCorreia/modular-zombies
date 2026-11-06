# Pipeline de conteúdo JSON e assets

## Decisão

**JSON é a fonte de verdade de todo conteúdo de jogo.** Mapas, armas, faca,
explosivos, inimigos, perks, quests e mecânicas são definidos em `.json`.
Não há conteúdo em `.tres`; `.tres`/`.tscn` ficam restritos a assets de engine
(materiais, animações compostas, cenas, bus layout).

O runtime converte JSON em **DTOs tipados** (classes leves em GDScript) depois
de validar. O editor lê e escreve os mesmos JSONs.

**Assets de engine** (cenas, materiais, animações compostas, bus layout) usam
`.tscn`/`.tres`; modelos, texturas, áudio e fontes ficam em `assets/`; fontes
editáveis (`.blend`) ficam em `source/` com `.gdignore`.

## Estrutura

```text
content/
  maps/bunker13.json
  weapons/glock17.json
  weapons/mp5.json
  weapons/knife.json
  explosives/barrel_fuel.json
  explosives/grenade_frag.json
  equipment/grenade.json
  enemies/zombie.json
  perks/jugg.json
  quests/bunker13_music.json
  mechanics/power.json
schemas/
  map.schema.json
  weapon.schema.json
  explosive.schema.json
  melee.schema.json
  quest.schema.json
```

## Fronteira: JSON vs assets

Detalhes da árvore e convenções em `11-assets.md`.

| Tipo | Formato | Onde |
|---|---|---|
| Conteúdo de jogo | **JSON** | `content/` |
| Cenas/prefabs | `.tscn` | `assets/prefabs/` ou `scenes/` |
| Materiais, animações compostas, tema, bus | `.tres` | `assets/materials`, `assets/animations`, `assets/audio` |
| Modelos, texturas, áudio, fontes | GLB/PNG/OGG/TTF | `assets/` |
| Fonte editável | `.blend`/`.py` | `source/` (`.gdignore`) |

```text
assets/
  prefabs/*.tscn
  models/weapons/<id>/<id>.glb
  models/hands/hands.glb
  models/enemies/<id>/<id>.glb
  models/props/<id>/<id>.glb
  textures/world/<set>/{diff,nor,rough,ao}.png
  textures/weapons/<id>/*.png
  textures/ui/*.png
  materials/*.tres
  animations/viewmodels/<id>.tres
  animations/characters/<id>.tres
  audio/{weapons,zombies,music,ui,foley}/*.ogg
  audio/default_bus_layout.tres
  fonts/*.ttf
  ui/{icons,images}/*
  vfx/{explosions,impacts}/*.tscn
  vfx/textures/*.png
  shaders/*.gdshader
source/blender/{weapons,hands,enemies}/*.blend
source/blender/scripts/*.py
```

## Regras

1. Todo JSON tem `schema_version` e `id` estável.
2. IDs usam namespace: `map.*`, `weapon.*`, `explosive.*`, `melee.*`,
   `enemy.*`, `perk.*`, `quest.*`.
3. Referências cruzadas usam IDs, nunca caminhos de cena.
4. Assets (GLB/áudio) são referenciados por `res://...`.
5. Nenhum conteúdo hardcoded no núcleo; se não está no JSON, não existe.
6. JSON inválido bloqueia o playtest e o CI.

## Exemplos

### Arma

```json
{
  "schema_version": 1,
  "id": "weapon.glock17",
  "name": "GLOCK 17",
  "type": "hitscan",
  "scene": "res://assets/models/weapons/glock17/glock17.glb",
  "hands": "res://assets/models/hands/hands.glb",
  "grip_profile": "pistol",
  "animation_set": "res://assets/animations/viewmodels/glock17.tres",
  "moving_parts": ["Slide", "Magazine", "Trigger"],
  "stats": {
    "damage": 34, "head_multiplier": 2.0, "rpm": 420,
    "mag": 17, "reserve": 102, "spread": 0.010,
    "reload_chambered": 1.55, "reload_empty": 2.05
  }
}
```

### Explosivo

```json
{
  "schema_version": 1,
  "id": "explosive.barrel_fuel",
  "radius": 4.0,
  "max_damage": 150,
  "min_damage": 20,
  "falloff": "quadratic",
  "impulse": 8.0,
  "line_of_sight": true,
  "chain_delay": 0.12,
  "chain_max": 6,
  "vfx": "res://assets/vfx/explosions/explosion.tscn",
  "sfx": "explosion"
}
```

### Faca (melee)

```json
{
  "schema_version": 1,
  "id": "melee.knife",
  "scene": "res://assets/models/weapons/knife/knife.glb",
  "hands": "res://assets/models/hands/hands.glb",
  "animation_set": "res://assets/animations/viewmodels/knife.tres",
  "damage": 150,
  "range": 1.6,
  "arc_deg": 100,
  "cooldown": 0.6,
  "impact_time": 0.18,
  "lunge": 0.4
}
```

### Mapa (fragmento)

```json
{
  "schema_version": 1,
  "id": "map.bunker13",
  "name": "Bunker 13",
  "player_spawn": [0, 0.1, 12],
  "doors": [{"id": "door1", "cost": 750, "position": [0, 1.25, 5]}],
  "barricades": [
    {
      "id": "win_A1", "room": "A", "position": [-5.5, 1.4, 6.0],
      "rotation_y": 3.14159, "max_planks": 6, "repair_time": 0.8,
      "repair_points": 10, "spawn_position": [-5.5, 0.1, 7.4]
    }
  ],
  "explosive_props": [
    {
      "id": "barrel_1",
      "explosive": "explosive.barrel_fuel",
      "position": [3.0, 0.0, 9.0],
      "health": 30,
      "respawn": false
    }
  ],
  "quests": ["quest.bunker13_music"]
}
```

## Loader e validação

```text
ContentRegistry
  ├─ scan content/**/*.json
  ├─ JSON.parse_string
  ├─ SchemaValidator (campos, tipos, versão)
  ├─ ContentValidator (IDs, referências, ciclos, softlocks)
  └─ DTOs tipados (MapData, WeaponData, ExplosiveData, MeleeData...)

Editor/CI
  └─ ContentValidator (mesmas regras) + JSON Schema
```

- Erros apontam arquivo, campo e ID.
- Valida existência/importação de `res://` (GLB, texturas, áudio, `.tres`).
- Valida materiais/animações referenciados por armas e VFX.
- Valida barricadas: IDs, room, position/spawn e max_planks > 0.
- O jogo não inicia com conteúdo inválido.
- Hot reload de JSON em desenvolvimento (editor).

## Ferramentas de autoria

- Dock do editor cria/duplica mapas e abre o JSON.
- Formulários para mapas/armas podem ser adicionados depois; o JSON continua
  sendo a fonte.
- Validador no dock e no CI.
- Playtest carrega o JSON selecionado.

## Migração (R1)

1. Definir os schemas JSON.
2. Implementar `ContentRegistry` + `SchemaValidator` + `ContentValidator`.
3. Converter Bunker 13 e as 5 armas para JSON.
4. Adicionar JSON de faca, granada, lança-foguete e barris.
5. Remover qualquer conteúdo em `.tres`.

## Testes

- Schema: todos os JSONs passam.
- Referências: todos os IDs existem.
- Regressão: conteúdo inválido falha com mensagem clara.
- Editor: criar/duplicar/validar um mapa JSON.
