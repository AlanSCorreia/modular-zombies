# Organização de assets

## Princípio

Três fronteiras claras:

| Camada | Formato | Onde |
|---|---|---|
| Conteúdo de jogo | **JSON** | `content/` |
| Assets de engine | `.tres`/`.tscn`/GLB/PNG/OGG/TTF | `assets/` |
| Fonte editável | `.blend`/`.py` | `source/` (`.gdignore`) |

JSON define **o que existe e como se comporta**; `assets/` guarda **os bytes**;
`source/` guarda **como foi produzido**.

## Árvore

```text
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
    weapons/<id>/*.blend
    hands/hands.blend
    enemies/<id>/*.blend
    scripts/*.py
```

## Regras por tipo

### Modelos 3D
- Um diretório por modelo: `models/<categoria>/<id>/<id>.glb`.
- GLB é o formato de entrega; `.blend` nunca entra em `assets/`.
- Origem no chão, escala em metros, frente `-Z`, cima `+Y` (padrão Godot).
- Partes móveis nomeadas (`Slide`, `Magazine`, `Trigger`, `Pump`) e pivôs
  corretos para animação.
- `GripSocket`/`grip_profile` para encaixar as mãos compartilhadas.
- Pipeline de armas: `14-weapon-workflow.md`.
- Barricadas: tábua reutilizável em `models/props/barricade_plank.glb`; textura
  wood em `textures/world`; lascas em `vfx/impacts`.

### Texturas
- Um conjunto PBR por material: `{diff,nor,rough,ao}.png`.
- Pasta por material: `textures/world/<set>/`.
- Resolução padrão 1k/2k; UI separada em `textures/ui` e `ui/images`.
- Material `.tres` em `assets/materials` referencia as texturas (sem duplicar).

### Animações
- Padrão: animações embutidas no GLB (personagem/arma).
- `.tres` em `assets/animations` só para **composição/override** (viewmodels,
  bibliotecas compartilhadas).
- Mãos compartilhadas: um `hands.glb` com poses por classe (`pistol`, `rifle`,
  `shotgun`, `knife`); armas não duplicam mãos.
- Nomes `snake_case` (`fire`, `reload_empty`, `knife_slash`).

### Áudio
- `audio/weapons`, `audio/zombies`, `audio/music`, `audio/ui`, `audio/foley`.
- Música/loops em OGG; efeitos curtos em OGG/WAV.
- `default_bus_layout.tres` em `assets/audio`.
- Variações/eventos lógicos podem ficar em `content/audio/events.json`.
- Barricada: `foley/wood_break_*`, `foley/wood_repair_*` e impactos.
- 3D para mundo; 2D para HUD/arma do player.

### Imagens e UI
- Ícones em SVG (`ui/icons`); imagens em PNG (`ui/images`).
- Atlas/9-slice quando fizer sentido; sem duplicar assets de UI.
- Fontes em `assets/fonts`.

### VFX
- Cena `.tscn` por efeito (`vfx/explosions`, `vfx/impacts`).
- Texturas em `vfx/textures`; efeitos caros usam pool.

### Shaders
- `.gdshader` em `assets/shaders`; materiais que usam ficam em `materials`.

## Convenções

- `snake_case`, sem espaços/acentos.
- ID do JSON = nome base do asset (`weapon.glock17` → `glock17`).
- Um asset por diretório; sem cópias “final_v2”.
- Assets de terceiros: `assets/third_party/<pack>/` + `LICENSE`.
- Créditos centralizados em `CREDITS.md`.

## Validação

- Toda referência `res://` existe e importa.
- Nenhum `.blend` em `assets/`; fonte em `source/`.
- Material/animação/textura/áudio referenciados existem.
- Modelos têm escala/origem/eixos esperados.
- Licença registrada para todo asset de terceiros.

## Migração

R1: mover assets atuais para a árvore acima, criar `source/blender`, ajustar
paths no JSON e rodar o validador. Nada de conteúdo em `.tres`.
