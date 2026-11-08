---
kind: reference
area: content
status: active
stage: 3
owner: gameplay
last_reviewed: 2026-11-08
---

# Barricadas (janelas)

## Objetivo

Reproduzir a mecânica clássica do CoD Zombies: zumbis arrancam tábuas das
janelas, o player segura **F** para reconstruí-las e ganha pontos; quando as
tábuas acabam, o zumbi entra.

## Regras

- Cada barricada tem `max_planks` (padrão 6).
- Zumbi se aproxima, arranca 1 tábua por `tear_time` e, com 0 tábuas, faz a
  animação de entrada e passa para dentro.
- Player segura **F** perto da barricada: cada tábua leva `repair_time` e dá
  `repair_points` (padrão 10).
- Soltar F, tomar dano ou mudar de arma cancela o progresso atual.
- Barricada cheia não dá pontos.
- Reparo pode ser feito com zumbis atacando (se estiverem dentro).
- A barricada não bloqueia tiro; o player pode atirar nos zumbis na janela.

## Fluxo

```text
spawn fora → aproxima → arranca tábua → ... → 0 tábuas → climb → dentro
                    ↑                              ↓
                    └── player repara (hold F) ────┘
```

## JSON

```json
{
  "id": "win_A1",
  "room": "A",
  "position": [-5.5, 1.4, 6.0],
  "rotation_y": 3.14159,
  "max_planks": 6,
  "repair_time": 0.8,
  "repair_points": 10,
  "tear_time_base": 2.2,
  "tear_time_round_scale": 0.08,
  "spawn_position": [-5.5, 0.1, 7.4],
  "climb_time": 0.9
}
```

- `position`: centro da janela (altura das tábuas).
- `spawn_position`: ponto externo onde o zumbi nasce.
- `tear_time` efetivo: `base / (1 + round * scale)`.
- `board_scene`/`sfx` podem ser referências de asset no schema completo.

## Arquitetura

| Componente | Responsabilidade |
|---|---|
| `Barricade` | Estado local: tábuas, progresso, visual e colisão |
| `BarricadeSystem` | Registro por mapa, spawn, reparo e eventos |
| `InteractionSystem` | Prompt + hold F + progresso |
| `ZombieEnemy` | Estados `approach`, `tear`, `climb`, `inside` |
| `Economy` | Pontos por tábua |
| `Events` | `barricade_repaired`, `barricade_board_broken`, `barricade_breached` |

`MapData` ganha `barricades: Array[BarricadeData]`; o spawn de zumbis usa
`spawn_position` da barricada, não um ponto solto.

## UI e feedback

- Prompt: `[F] REPARAR` + barra de progresso.
- Som de madeira quebrando/reparando e passos.
- Partículas de lascas; tábua some/aparece.
- Contador de tábuas opcional no HUD de debug.
- Pontos flutuantes ao reparar.

## Casos de borda

- Player solta F no meio → progresso reseta (não consome tábua).
- Barricada cheia → não inicia.
- Zumbi arranca a última tábua durante o reparo → reparo falha e zumbi entra.
- Dois zumbis na mesma janela → fila; só um arranca por vez.
- Dano recebido → cancela reparo.
- Barricada destruída e sem zumbis → pode ser reparada normalmente.
- Co-op: até N jogadores reparam; somar velocidade com limite.

## Testes

- Unidade: clamp 0..max, pontos, tempo de reparo, tempo de arranque.
- Integração: reparar até 6, ganhar 60 pontos, zumbi arranca até 0 e entra.
- Interrupção: soltar F/dano cancela sem consumir.
- Performance: 8 barricadas + 20 zumbis sem queda.
- Conteúdo: IDs únicos, posição/spawn válidos, sala existente.

## Roadmap

| Etapa | Entrega |
|---|---|
| Etapa 2 — Conteúdo | Schema e dados JSON de barricadas |
| Etapa 3 — Gameplay | `BarricadeSystem`, hold F, tear/climb, pontos |
| Etapa 4 — Interações | HUD/progresso, áudio/VFX, authoring no editor |
| Etapa 6 — Quests | Barricadas em quests/mecânicas de mapa |
| Etapa 8 — Produção | Save/load do estado das tábuas |
