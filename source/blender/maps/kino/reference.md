# Referência — Kino der Toten (recriação low-poly)

Fonte de pesquisa original: `../zombie-fps/docs/kino/kino_der_toten.md`
(documento do projeto anterior). Este arquivo registra a adaptação usada no
Bunker 13 v2.

## Escala e sistema

- Metros; Godot X/Z no plano, Y para cima.
- Andares principais em `y=0`; palco sem desnível para manter a navegação
  estável. A verticalidade fica sugerida por balcões, arco de proscênio e
  mezanino decorativo.
- Gerado por `source/blender/scripts/make_kino.py` com `map_kit.py`.

## Salas (x1, z1, x2, z2)

| Sala | Retângulo | Altura |
|---|---|---|
| Lobby | -8, -26, 8, -10 | 8 m |
| Corredor inferior | -12, -18, -8, -12 | 3,2 m |
| Lower Hall | -26, -18, -12, -8 | 3,4 m |
| Alley + pátio | -30, -8, -22, 10 | 6 m |
| Back Room | -28, 10, -18, 18 | 6 m |
| Corredor Back→Stage | -18, 12, -12, 16 | 3,2 m |
| Stage | -12, 10, 12, 18 | 12 m |
| Teatro (travessa) | -12, 0, 12, 10 | 13 m |
| Corredor do teatro | -4, -10, 4, 0 | 6 m |
| Corredor superior | 8, -18, 10, -12 | 3,2 m |
| Upper Hall | 10, -16, 22, -8 | 3,4 m |
| Corredor Upper→Foyer | 14, -8, 22, -6 | 3,2 m |
| Foyer | 14, -6, 24, 4 | 6 m |
| Corredor Foyer→Dressing | 14, 4, 24, 8 | 3,2 m |
| Dressing Room | 14, 8, 24, 16 | 3,6 m |

## Rotas

- **Oeste (4 portas, 4.250 pts):** Lobby → Lower Hall (750) → Alley (1.000)
  → Back Room (1.250) → Stage (1.250).
- **Leste (4 portas, 4.250 pts):** Lobby → Upper Hall (750) → Foyer (1.000)
  → Dressing Room (1.250) → Stage (1.250).
- **Atalho com energia:** Lobby → Teatro e Stage → Teatro (cortina). As portas
  `door_lobby_theater` e `door_stage_curtain` usam `requires_power`.
- Corredores internos e arcos usam `open: true` e não custam pontos.

## Conteúdo

- Wallbuys: Glock 17, MP5, AK-74, SKS, M870 e M1911.
- Perks: Reviver, Gatilho Duplo, Mãos Rápidas e Aço Vital.
- Caixa misteriosa no lobby; teleporter/Pack-a-Punch decorativos no palco.
- 17 barricadas em janelas; spawns externos correspondentes.
- Energia no palco abre as portas `requires_power`.
- Brute a partir da rodada 3.

## Simplificações

- Sem teleporte jogável, Pack-a-Punch funcional, Hellhounds, Nova 6 ou traps
  canônicas nesta primeira versão.
- Mezanino do lobby e balcões do teatro são decorativos.
- A fachada externa/letreiro KINO não foi modelada; o beco tem porta azul,
  dumpster, cerca e iluminação fria.
