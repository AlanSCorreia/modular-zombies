---
kind: reference
area: content
status: reference
stage: 6
owner: gameplay
last_reviewed: 2026-11-08
---

# Easter Eggs e mecânicas por mapa

## Pesquisa consolidada

Catálogo por **tipo**, não passo a passo (seriam centenas de etapas).

| Jogo | Mapas principais | Eggs/mecânicas marcantes |
|---|---|---|
| WaW | Nacht, Verrückt, Shi no Numa, Der Riese | Músicas secretas, rádios, power, perks, traps, teleporters, fly trap |
| BO1 | Kino, Five, Ascension, Call of the Dead, Shangri-La, Moon | “115”, “Won’t Back Down”, “Abracadavre”, “Not Ready to Die”, “Pareidolia”, “Nightmare”; landers, macacos, George Romero, eclipse, baixa gravidade |
| BO2 | TranZit, Nuketown, Die Rise, Mob of the Dead, Buried, Origins | “Carrion”, “We All Fall Down”, “Where Are We Going”, “Always Running”, “Archangel”; bus, névoa, afterlife, elevadores, gigante, staffs |
| BO3 | Shadows, The Giant, Der Eisendrache, Zetsubou, Gorod Krovi, Revelations | “Snakeskin Boots”, “Dead Again”, “Dead Flowers”, “Ace of Spades”, “The Gift”; Beast mode, rituais, arcos, plantas, dragões |
| BO4 | IX, Voyage, Blood, Classified, Dead of the Night, Ancient Evil, Alpha Omega, Tag | Músicas secretas, main quests, gladiadores, navio, Alcatraz, vampiros, mitologia grega |
| Cold War | Die Maschine, Firebase Z, Mauer, Forsaken, Outbreak | Dark Aether, DIE Shockwave, Rai K-84, Klaus, CRBR-S, Chrysalax, exfil |
| Vanguard | Der Anfang, Terra Maledicta, Shi no Numa, The Archon | Objetivos, altares, relics, main quests |
| MW3 | Operation Deadbolt | Extração/open world, missões de história |
| BO6 | Terminus, Liberty Falls, Citadelle, The Tomb, Shattered Veil | Main quests, augments, gobblegums, side eggs, bosses |
| BO7 | Ashes of the Damned, Vandorm Farm, Astra Malorum | Main quests, relics, survival maps |
| Não-Treyarch | AW Exo Zombies, IW Spacetime, WWII | Main eggs, músicas, celebridades, jumpscares |

**Padrões:** música secreta (3+ gatilhos), rádios/cifras, wonder weapon
(caixa ou build), upgrade de wonder weapon, perk grátis, main quest multi-etapas,
boss, final alternativo, coletáveis, co-op obrigatório, passos com RNG/timing.

## Mecânicas genéricas

| Categoria | Função | Custo | Reuso |
|---|---|---|---|
| Traversal (bus, elevador, portal, slide, afterlife) | Identidade e ritmo | Alto | Baixo |
| Power/utility (geradores, válvulas, rituais) | Portão de progressão | Médio | Alto |
| Buildables (escudo, trap, wonder weapon) | Crafting e exploração | Alto | Médio |
| Wonder weapon | Recompensa e poder | Alto | Baixo |
| Boss/special enemy | Pico de tensão | Alto | Médio |
| Hazard (fog, lava, água, baixa gravidade) | Pressão ambiental | Médio | Médio |
| Quest steps (fetch, escort, defense, puzzle, código) | Conteúdo de egg | Muito alto | Alto com framework |
| Coletáveis/lore (rádios, cifras, filmes) | Narrativa | Baixo | Alto |
| Música secreta | Recompensa barata | Baixo | Alto |
| Progressão persistente (bank, fridge, perma-perks) | Retenção | Médio | Alto |
| Segredos curtos (pontos, jump scare, sala) | Densidade | Baixo | Alto |

**Conclusão:** identidade vem de **1–3 mecânicas únicas** + sistemas genéricos
reutilizáveis. O erro é hardcodar cada mapa no núcleo.

## Modelo de quest

```json
{
  "schema_version": 1,
  "id": "quest.bunker13_music",
  "type": "music",
  "requires_coop": false,
  "repeatable": false,
  "steps": [
    {"id": "radio_1", "trigger": "interact", "target": "radio_1"},
    {"id": "radio_2", "trigger": "interact", "target": "radio_2"},
    {"id": "radio_3", "trigger": "interact", "target": "radio_3"}
  ],
  "rewards": [
    {"type": "music", "id": "music.bunker13"},
    {"type": "points", "amount": 500}
  ]
}
```

> Quests são **JSON**; o runtime converte para DTOs tipados.

| Trigger | Uso |
|---|---|
| `INTERACT` | Ativar objeto/NPC |
| `KILL` | Matar tipo/quantidade |
| `ENTER_AREA` | Entrar em zona |
| `COLLECT` | Coletar item |
| `DEFEND` | Defender ponto por tempo |
| `ESCORT` | Escoltar alvo |
| `PUZZLE` | Código/sequência |
| `TIMER` | Janela de tempo |
| `BOSS` | Derrotar chefe |

**Tipos de passo reutilizáveis:** `InteractStep`, `CollectStep`, `EscortStep`,
`DefendStep`, `PuzzleStep`, `SequenceStep`, `BossStep`.

## Exemplos de mapeamento

| Egg clássico | Como vira dados |
|---|---|
| Música secreta (3 objetos) | JSON de quest tipo `music` + 3 passos `interact` + reward `music` |
| Rádio/cifra | Passo `interact` + reward `lore` |
| Wonder weapon build | 3 passos `collect` + 1 `interact` + reward `weapon` |
| Main quest | Grafo de 5–15 passos + `boss` + reward `ending` |
| Perk grátis | Passo `puzzle`/`sequence` + reward `perk` |
| Co-op | `requires_coop` + passos com múltiplos jogadores |

## Regras de design e validação

- Feedback em cada passo (som, HUD, diálogo, luz).
- Diário de quests/objetivos para evitar dependência de guia.
- Anti-softlock: nenhum passo pode consumir item único sem reposição.
- Validar: IDs, referências, ciclos, passos inalcançáveis, recompensas órfãs.
- Testar solo e co-op quando aplicável.
- RNG controlado e documentado.

## Aplicação na v2 (Etapa 6 — Quests)

- O catálogo acima é referência de **padrões**, não uma lista de cópias.
- A v2 implementará o framework na Etapa 6 — Quests, não os eggs individualmente.
- Primeiro egg de teste: **3 rádios no Bunker 13** → música + pontos.
- Mecânica única de mapa: `Bunker13PowerMechanic` (interruptor de energia).
- Tudo validado por `QuestValidator` (IDs, ciclos, passos órfãos e softlocks).

## Fontes

- Wikipedia — Call of Duty Zombies.
- Call of Duty Wiki — Easter Eggs / mapas.
- Guias comunitários (Steam, IGN, GameRant).
- Documentação e código do próprio projeto.
