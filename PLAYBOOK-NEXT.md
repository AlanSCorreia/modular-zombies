# Playbook — próximo projeto

Regras curtas aprendidas no Bunker 13 v2. Aplicar desde o primeiro commit.

## 1. Escopo e arquitetura

- Definir **uma frase de produto** e um **golden path** jogável antes de conteúdo.
- Quebrar o runtime em serviços pequenos: mapa, player, combate, rodadas,
  economia, quests, save, UI. **Proibido `GameRoot` onisciente.**
- Dependências explícitas: injeção/export ou interfaces; evitar estáticos
  globais para estado de fluxo.
- Event bus só para eventos de domínio; não usar como desculpa para acoplamento.
- Definir desde o dia 1:
  - unidades, eixos e escala;
  - Input Map (teclado + gamepad) e rebinding;
  - camadas de colisão nomeadas;
  - versionamento de save;
  - orçamento de performance.

## 2. Conteúdo e dados

- JSON como fonte de verdade; DTOs tipados e um validador único.
- **JSON Schema aplicado no CI** — não só documentado.
- IDs globais únicos e prefixados; validar referências, assets e ranges.
- Contratos de nós (ex.: `Door_`, `Plank_`) precisam de validação no import,
  não apenas documentação.
- Nada de conteúdo em `.tres`/`.tscn` além de assets de engine.
- Nenhum ID de mapa/arma/inimigo hardcoded no núcleo.

## 3. Assets

- Todo modelo 3D tem `.blend` fonte em `source/blender/` e GLB em `assets/`.
- Nenhuma geometria 3D gerada em runtime.
- Mãos/viewmodel compartilhados quando o jogo permitir.
- Escala real em metros e `reference.md` por asset relevante.
- Registro de licenças desde o primeiro asset externo (`CREDITS.md` +
  `assets/third_party/README.md`).
- Pipeline de export reproduzível por script.

## 4. Performance

- Definir orçamento por plataforma: FPS mínimo, frame time, draw calls, memória.
- Medir em execução **com renderer real**, não só headless.
- Bench windowed/sem vsync para medir folga; headless para CPU/memória.
- Testar soak com memória, object count e iterações reais.
- Planejar culling/LOD/navmesh antes de mapas verticais.
- Evitar milhares de meshes pequenos; agrupar por material/atlas.

## 5. Testes e CI

- Testes unitários para regras puras; integração para fluxos; um smoke para
  build exportado.
- Todo gate precisa de um teste que **falhe de verdade** se a feature quebrar.
- Evitar fallbacks em testes (ex.: chamar `detonate()` quando o gatilho falha).
- Não usar contagens fixas de conteúdo; validar invariantes e IDs.
- CI deve falhar em erro de import/parse, não engolir log.
- Gates de performance/licença/soak no release, não só no fim do projeto.

## 6. Processo

- Uma etapa ativa, no máximo 1 item em Doing.
- Issues com labels `etapa`, `prio`, `area`; milestones por etapa.
- Decision log desde o primeiro dia: contexto, alternativas, decisão, impacto.
- Work log curto por bloco; arquivar o histórico antigo.
- Revisão por subagente **ao fim de cada etapa**, não só no final.
- Métricas por bloco: entrega, qualidade, performance, tokens/custo.
- Retrospectiva ao fechar cada etapa grande; não esperar o projeto acabar.

## 7. IA e agentes

- Skills da comunidade primeiro; não reescrever o que já é validado.
- RAG/exemplos reais para código de engine; sem isso o modelo volta a primitivas.
- Separar papéis: explorar, implementar, revisar, validar conteúdo.
- Revisão com diff e testes; o agente não decide arquitetura sozinho.
- Medir tokens/custo por issue e comparar com retrabalho.
- Não aceitar “teste passou” sem verificar se o teste pode falhar.

## 8. Release

- Build reproduzível + smoke em máquina limpa.
- Checksums, notas, licenças e créditos no pacote.
- Tag e artefatos congelados; correções pós-release viram nova versão.
- Checklist de release com acessibilidade, soak e validação de conteúdo.

## 9. Checklist do dia 1

- [ ] Frase de produto e golden path.
- [ ] `AGENTS.md` enxuto.
- [ ] Estrutura de pastas e camadas de colisão.
- [ ] Input Map completo.
- [ ] Content schema + validador + CI.
- [ ] Save versionado.
- [ ] Orçamento de performance.
- [ ] Pipeline Blender/GLB + licenças.
- [ ] Decision log + work log.
- [ ] Métricas automáticas.
- [ ] Plano de revisão por etapa.
