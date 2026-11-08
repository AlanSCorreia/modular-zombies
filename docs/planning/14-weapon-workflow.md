# Workflow de criação de armas

## Regra

Toda arma é composta por **GLB do Blender + JSON + AnimationSet**, usando as
**mãos compartilhadas**. Nada de `if weapon_id` no núcleo.

## Pipeline

| # | Etapa | Artefato | Aceite |
|---|---|---|---|
| 0 | Briefing | Tipo (hitscan/projectile/melee), referência, stats | Escopo fechado |
| 1 | Referência | `source/blender/weapons/<id>/reference.md` | Dimensões/partes documentadas |
| 2 | Modelagem | `source/blender/weapons/<id>/<id>.blend` | Escala 1m, `-Z` frente, `+Y` cima |
| 3 | Partes móveis | Nós `Slide`, `Magazine`, `Trigger`, `Pump`, `Bolt` | Pivôs corretos e nomeados |
| 4 | Mãos | `assets/models/hands/hands.glb` | Mesmo asset para todas as armas |
| 5 | Export | `assets/models/weapons/<id>/<id>.glb` | Só a arma, sem mãos duplicadas |
| 6 | JSON | `content/weapons/<id>.json` | Schema válido |
| 7 | Animações | `fire`, `fire_last`, `reload_chambered`, `reload_empty` | Impacto sincronizado |
| 8 | Integração | `WeaponFactory`/`ViewmodelFactory` | Arma + mãos + animações |
| 9 | Áudio | IDs de tiro/recarga | 2D/3D corretos |
| 10 | Validação | `ContentValidator` + testes | 0 erros, testes verdes |
| 11 | Aceite | Checklist abaixo | Pronto para wallbuy/caixa |

## Templates

- `templates/weapon/weapon.json`: JSON base.
- `templates/weapon/CHECKLIST.md`: aceite.
- `templates/weapon/export_weapon.py`: export GLB headless.

## Estrutura

```text
source/blender/weapons/<id>/
  <id>.blend
  reference.md
  export.py
assets/models/weapons/<id>/<id>.glb
assets/animations/viewmodels/<id>.tres
content/weapons/<id>.json
```

## Contrato JSON

```json
{
  "schema_version": 1,
  "kind": "weapon",
  "id": "weapon.example",
  "name": "EXEMPLO",
  "type": "hitscan",
  "scene": "res://assets/models/weapons/example/example.glb",
  "hands": "res://assets/models/hands/hands.glb",
  "grip_profile": "rifle",
  "animation_set": "res://assets/animations/viewmodels/example.tres",
  "moving_parts": ["Slide", "Magazine", "Trigger"],
  "viewmodel": {
    "position": [0.18, -0.19, -0.55],
    "rotation": [0, 0.08, 0],
    "scale": 0.8,
    "muzzle": "Muzzle",
    "grip_socket": "GripSocket"
  },
  "stats": {
    "damage": 34, "head_multiplier": 2.0, "rpm": 600,
    "mag": 30, "reserve": 180, "spread": 0.013, "range": 120,
    "reload_chambered": 2.0, "reload_empty": 2.4
  },
  "reload": { "strategy": "magazine" },
  "audio": { "fire": "gun_rifle", "reload": "reload", "empty": "reload" }
}
```

## Animações

- `fire`: ciclo do ferrolho + recuo curto.
- `fire_last`: deixa o ferrolho travado (quando aplicável).
- `reload_chambered`: troca de carregador com bala na câmara.
- `reload_empty`: carregador vazio + destrave do ferrolho.
- `inspect` (opcional), `melee` (faca).
- Animações das mãos vêm do `hands.glb`; clipes da arma animam as partes móveis.
- Dano/impacto no tempo da animação, nunca no input.

## Checklist de aceite

- [ ] Referência e dimensões documentadas.
- [ ] GLB só com a arma; mãos separadas.
- [ ] Escala/origem/eixos corretos; pivôs nomeados.
- [ ] `GripSocket` e `Muzzle` presentes.
- [ ] JSON válido e referências de asset existentes.
- [ ] `fire`, `fire_last`, `reload_chambered`, `reload_empty`.
- [ ] Arma + mãos montadas por factory, sem caso especial.
- [ ] Áudio, muzzle flash e recuo.
- [ ] Testes: conteúdo, tiro, recarga, headshot, 2 slots.
- [ ] `CREDITS.md` e `docs` atualizados.

## Exemplo: Glock 17

O pipeline da Glock foi: referência (202/186/114 mm) → modelagem procedural no
Blender (`./blender.sh source/blender/weapons/glock17/glock17.blend`) → GLB
`glock17.glb` → JSON `glock17.json` → animações no
`WeaponController` → testes.

> Estado atual: a Glock foi migrada para `hands.glb` + `ViewmodelFactory`
> (issue #14). MP5 também passa pelo mesmo caminho; as demais armas usam o
> fallback por `grip_profile` até receberem sockets próprios.
