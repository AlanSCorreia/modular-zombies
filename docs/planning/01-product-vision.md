# Visão de produto — v2

## Objetivo

**Reescrever o Bunker 13** como uma plataforma de conteúdo de FPS zombies:
mapas, armas, perks, inimigos e Easter Eggs adicionáveis sem reescrever o
núcleo. A v1 é apenas histórico; a v2 é a linha principal.

## Estratégia

Reescrita real em fatias verticais:

1. v1 arquivada apenas como histórico.
2. v2 construída com a nova arquitetura.
3. Entregas verticais jogáveis/testáveis.
4. v2 é a linha principal desde já; não há dependência da v1.

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
| Preparação | Preparação, scaffold, docs e Kanban |
| Conteúdo | JSON schemas, loader, validador, assets organizados e Bunker 13 em JSON |
| Gameplay | Loop: player, armas, faca, explosivos, zumbis, barricadas, rodadas, economia |
| Interações | Interações, traps/props explosivos, HUD, menus e áudio |
| Ferramentas | Ferramentas de mapa no editor |
| Quests | Quests/Easter Eggs |
| Escala | Segundo mapa, armas novas e escala |
| Produção | Save, settings, exportação, CI e performance |

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
| Golden path do slice | checklist completo e `ci.sh` verde |
