# Bunker 13 v2 — Etapa 8

**Data:** 2026-11-09  
**Plataforma:** Linux x86_64  
**Tag:** `etapa8`

## O que é

FPS de zumbis low-poly em Godot 4.7.2, com conteúdo em JSON, mapas autorais
em Blender e mãos compartilhadas entre todas as armas.

## Conteúdo

- 3 mapas: `slice`, `bunker13` e `depot`.
- 9 armas autorais em escala real + faca, granada, lança-foguete e Ray Gun.
- Menu principal com Jogar, Opções e Sair.
- Save/load (F5/F9), settings persistentes e pausa com opções.
- Rodadas, economia, perks, caixa, barricadas, quests e chefe Brute.
- 2 inimigos: zumbi e Brute.
- Build Linux com binário + PCK.

## Como jogar

1. Baixe `bunker13.x86_64` e `bunker13.pck`.
2. Coloque os dois arquivos na mesma pasta.
3. Dê permissão de execução: `chmod +x bunker13.x86_64`.
4. Execute: `./bunker13.x86_64`.

O jogo abre no menu principal. Não é necessário instalar Godot.

## Controles

| Ação | Tecla |
|---|---|
| Mover | WASD |
| Correr | Shift |
| Pular | Space |
| Mirar/atirar | Mouse |
| Trocar arma | 1/2 ou scroll |
| Recarregar | R |
| Faca | V |
| Granada | G |
| Interagir | F |
| Pausar | Esc |
| Salvar / carregar | F5 / F9 |

## Créditos e licenças

- Armas, mãos, props e mapas: autorais (Blender + scripts).
- Zumbi: “Zombie” por bachosoftdesign, CC BY 3.0, via Poly Pizza.
- Texturas: Poly Haven, CC0.
- Sons: OpenGameArt e Kenney, CC0; trilha/UI sintetizadas no projeto.
- Fontes: Oswald e Rajdhani (OFL 1.1), Special Elite (Apache 2.0).
- Godot Engine: MIT.

Detalhes em `CREDITS.md` e `assets/third_party/README.md`.

## Limitações conhecidas

- Modelos low-poly procedurais; o passe final de arte ainda é manual.
- Navmesh pré-bakeada, pool de VFX, localização, suporte a controle e mods
  ficam para o backlog pós-release.
- Acessibilidade revisada para fonte/contraste, mas sem opção de escala de UI.

## Checksums SHA-256

```text
d9f79ab89b5ae369aeed11c6052d402e8218cd503bf85b4a235f9c30c46a7c63  bunker13.x86_64
1721fcdb02c7ea0648100e2961a9023b13a1d3bbda29f034c63c3eb425289281  bunker13.pck
```
