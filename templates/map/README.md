# Template de mapa

`template.json` é a base de “Novo mapa” no dock `bunker_tools`.

- `id`/`name` são substituídos pela ferramenta.
- A cena aponta para `assets/models/maps/slice/slice.glb` até o autor criar/exportar
  a geometria própria.
- O JSON passa pelo `ContentValidator`; salas, spawns e jogador já são válidos.
- Duplicar um mapa existente copia o JSON e reutiliza a cena de origem; troque
  `scene` depois de exportar a geometria nova.

Guia completo: [`../../docs/planning/23-map-author-quickstart.md`](../../docs/planning/23-map-author-quickstart.md).
