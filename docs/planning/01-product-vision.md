# Visão de produto — v2

## Objetivo

**Reescrever o Bunker 13** como uma plataforma de conteúdo de FPS zombies:
mapas, armas, perks, inimigos e Easter Eggs adicionáveis sem reescrever o
núcleo. A v1 é referência e rollback; a v2 é a linha principal.

## Estratégia

Reescrita real em paralelo, com paridade:

1. v1 arquivada e jogável.
2. v2 construída com a nova arquitetura.
3. Porte em fatias verticais até paridade funcional.
4. Troca do launcher/atalho quando os testes de paridade passarem.
5. v1 só é aposentada depois da troca.

## Pilares

1. **Loop de rodadas sólido** — pontos, portas, caixa, perks, chefes.
2. **Identidade por mapa** — 1 a 3 mecânicas únicas por mapa.
3. **Armas e mãos como assets** — todas as armas no Blender; mãos compartilhadas.
4. **Conteúdo JSON + assets organizados** — definições em `.json`; modelos,
texturas e áudio em `assets/`, fontes em `source/`.
5. **Descoberta** — Easter Eggs com feedback, validação e anti-softlock.
6. **Autoria** — criar/validar/testar mapas no editor Godot.
7. **Performance em iGPU** — orçamento de FPS e memória por mapa.

## Escopo por fase

| Fase | Escopo |
|---|---|
| R0 | Preparação, scaffold, docs e Kanban |
| R1 | JSON schemas, loader, validador, assets organizados e Bunker 13 em JSON |
| R2 | Loop: player, armas, faca, explosivos, zumbis, rodadas, economia |
| R3 | Interações, traps/props explosivos, HUD, menus e áudio |
| R4 | Ferramentas de mapa no editor |
| R5 | Quests/Easter Eggs |
| R6 | Segundo mapa, armas novas e escala |
| R7 | Save, settings, exportação, CI e performance |

## Não-objetivos

- Multiplayer em rede no curto prazo.
- Réplica 1:1 de mapas/armas de Call of Duty.
- Assets extraídos de jogos comerciais.
- Editor AAA antes de provar o fluxo com 2 mapas.
- Migração para C# sem profiling que comprove gargalo de CPU.

## Métricas de sucesso

| Métrica | Meta |
|---|---|
| Tempo para criar um mapa jogável | ≤ 1 sessão de autoria |
| Erros de conteúdo no validador | 0 antes do playtest |
| Referências de asset quebradas | 0 |
| Definições de conteúdo em `.tres` | 0 (JSON é a fonte) |
| FPS alvo (iGPU, 1200×675, FSR) | ≥ 40 FPS estável |
| Cobertura de regras críticas | 100% das regras puras |
| Mapas sem mudança no núcleo | 2 mapas consecutivos |
| Softlocks conhecidos | 0 |
| Paridade v1 → v2 | checklist completo antes da troca |
