# Referência — M1911 (autoral)

Modelo estilizado low-poly, autoral, gerado por
`source/blender/scripts/make_m1911.py`.

## Dimensões

- Comprimento: 0,226 m
- Altura: 0,130 m
- Largura: 0,038 m (com comandos laterais)
- Origem: `GunRoot` na região do frame, `+Y` frente, `+Z` cima.

## Partes

- `Frame` e `Slide` com perfis extrudados; `Barrel`, `BarrelBushing`,
  `RecoilPlug`.
- `TriggerGuard` como anel extrudado (furo real).
- `Grip` extrudado, painéis de madeira com frisos e parafusos, `Magazine`,
  base do magazine.
- `Trigger` com pivô no topo, `Hammer`, `Beavertail`.
- Comandos: `ThumbSafety`, `SlideStop`, `MagRelease`.
- Serrilhas do slide, porta de ejeção, miras dianteira/traseira com notch.
- `GripSocket` em `(0, -0,056, -0,040)`.
- `Muzzle` em `(0, 0,114, 0,051)`.

## Integração

- JSON: `content/weapons/pistol.json` (`grip_profile: pistol`).
- Partes móveis: `Slide`, `Magazine`, `Trigger`.
- Mãos: `assets/models/hands/hands.glb` (compartilhado).
