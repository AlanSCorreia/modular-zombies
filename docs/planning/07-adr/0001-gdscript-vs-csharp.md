# ADR 0001 — GDScript vs C#

## Contexto

O projeto usa Godot 4.7 portátil (build padrão, sem .NET) e GDScript. A
pergunta é se C# aumentaria a performance e se deve ser adotado agora.

## Aplica-se à v2

A reescrita v2 também será em **GDScript**. A decisão é arquitetural, não uma
limitação da v1.

## Decisão

**Manter GDScript nesta fase.** Não migrar para C# sem profiling que comprove
gargalo de CPU.

## Justificativa

- O gargalo observado é **GPU** (FSR 0.75, SSAO/fog desligados, sombras seletivas).
- A lógica de gameplay (rodadas, IA de poucos zumbis, economia) é leve em GDScript.
- C# exige build .NET do Godot, SDK .NET, recompilação e templates de exportação.
- A interoperabilidade C#/GDScript adiciona complexidade de build e depuração.
- O ganho de C# aparece em cargas CPU-bound: milhares de entidades, simulação
  pesada, processamento de dados, geração procedural em massa.

## Alternativas

| Alternativa | Prós | Contras |
|---|---|---|
| GDScript | Simples, hot reload, sem build extra | Mais lento em loops pesados |
| C# | Melhor CPU em lógica pesada | Build .NET, mais complexidade |
| GDExtension (C++) | Máximo desempenho | Custo alto de manutenção |

## Consequências

- O roadmap permanece em GDScript.
- Criar um **gate de profiling** antes de qualquer migração:
  1. medir FPS e tempo de CPU por sistema;
  2. identificar hot path real;
  3. só então isolar o sistema em C#/GDExtension.
- Se adotado no futuro, começar por um módulo isolado (ex.: validador de
  conteúdo ou simulação de hordas), não reescrever o jogo inteiro.

## Quando revisitar

- Hordas > 100 zumbis simultâneos.
- Validação de conteúdo/quests pesada no editor.
- Geração procedural de mapas grandes.
- Queda de FPS com GPU ociosa e CPU saturada.
