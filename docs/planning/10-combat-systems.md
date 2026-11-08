---
kind: reference
area: content
status: active
stage: 3
owner: gameplay
last_reviewed: 2026-11-08
---

# Sistemas de combate — explosivos e faca

## Explosivos

### Objetivo

Adicionar granadas, lança-foguetes, armadilhas explosivas e barris de
combustível que explodem ao receber tiro, com dano em área, linha de visão,
impulso e reações em cadeia.

### Componentes

| Componente | Responsabilidade |
|---|---|
| `ExplosionSystem` | Dano em raio, falloff, LOS, impulso, cadeia, VFX/SFX |
| `Explosive` | Componente de barris/traps: vida, trigger, armar, explodir |
| `Projectile` | Granada/foguete: velocidade, gravidade, fusível, colisão |
| `EquipmentController` | Granada equipada, quantidade, arremesso |
| `WeaponController` | Arma `projectile` (lança-foguete) ou `hitscan` |
| `Damageable` | Interface para player, zumbi, barris e traps |
| `ExplosiveDefinition` | JSON: raio, dano, falloff, impulso, cadeia |

### Tipos

| Tipo | Entrada | Definição |
|---|---|---|
| Granada | Tecla G | `equipment.grenade` + `explosive.grenade_frag` |
| Lança-foguete | Tiro | `weapon.rpg` + `projectile.rocket` + `explosive.rocket` |
| Barril | Tiro/morte | `explosive.barrel_fuel` no `map.json` |
| Trap explosiva | Colocação/proximidade | `explosive.trap` + trigger |
| Trap de combustível | Tiro | `explosive.barrel_fuel` |

### Regras de dano

- Overlap de esfera + LOS por raycast contra o mundo.
- Falloff linear/quadrático entre `max_damage` e `min_damage`.
- `impulse` aplicado a corpos rígidos e zumbis.
- `friendly_fire` configurável (padrão: ligado para zumbis, desligado para
  jogador no mesmo esquadrão — solo: ligado).
- Cadeia: barris próximos explodem com `chain_delay`, limitada por `chain_max`.
- Alvos máximos por explosão para controlar performance.

### JSON de arma explosiva

```json
{
  "schema_version": 1,
  "id": "weapon.rpg",
  "type": "projectile",
  "projectile": "projectile.rocket",
  "explosion": "explosive.rocket",
  "stats": {"damage": 0, "mag": 1, "reserve": 4, "reload": 3.2}
}
```

### Testes

- Raio/falloff: alvo no centro recebe mais dano que na borda.
- LOS: parede bloqueia dano.
- Cadeia: barril A detona B com atraso; limite respeitado.
- Barris: tiro reduz vida e explode; respawn conforme JSON.
- Granada: fusível, colisão, quique e detonação.
- Foguete: aceleração, colisão e explosão.
- Performance: N explosões simultâneas sem travar.

## Faca (melee)

### Objetivo

Ao pressionar **V**, o player executa um corte diagonal quase horizontal,
como nos CoDs, com dano, alcance curto e feedback.

### Componentes

| Componente | Responsabilidade |
|---|---|
| `MeleeController` | Input V, estado, cooldown, lunge, hit detection |
| `MeleeDefinition` | JSON: dano, alcance, arco, cooldown, impacto |
| `ViewmodelFactory` | Faca GLB + mãos compartilhadas |
| `WeaponAnimator` | Animação `knife_slash` |
| `Effects` | Sangue, hitmarker, som, shake |

### Regras

- `V` interrompe o viewmodel atual, mostra a faca e executa o slash.
- Hit detection: shape cast/cone à frente; `range` e `arc_deg`.
- Dano aplicado no `impact_time` da animação, não no input.
- Cooldown e lunge configuráveis.
- Retorna à arma anterior ao fim da animação.
- Pode atingir zumbis, barris e traps (se `damageable`).

### JSON

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

### Animação

- Faca modelada no Blender; mãos são o asset compartilhado.
- Slash diagonal quase horizontal, com leve lunge e retorno.
- Animação no `WeaponAnimator`; mãos reutilizadas com `grip_profile: knife`.

### Testes

- `V` inicia o slash e bloqueia tiro durante o estado.
- Dano só no `impact_time`.
- Alvo atrás/fora do arco não recebe dano.
- Cooldown impede spam.
- Arma anterior é restaurada.
- Barris explodem ao serem cortados, se configurado.

## Roadmap

| Etapa | Entrega |
|---|---|
| Etapa 2 — Conteúdo | JSON de explosivos/melee + validator |
| Etapa 3 — Gameplay | `ExplosionSystem`, granada, lança-foguete, barris, faca |
| Etapa 4 — Interações | Traps, props explosivos no mapa, VFX/SFX/HUD |
| Etapa 7 — Escala | Variantes (faca melhorada, explosivos wonder) |
| Etapa 8 — Produção | Pools e orçamento de performance |
