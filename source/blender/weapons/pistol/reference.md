# Referência — M1911 (autoral)

Modelo estilizado low-poly, autoral, gerado por
`source/blender/scripts/make_m1911.py`.

## Dimensões

- Comprimento: 0,227 m
- Altura: 0,163 m
- Largura: 0,037 m
- Origem: `GunRoot` na região do frame, `+Y` frente, `+Z` cima.

## Partes

- `Frame`, `Slide`, `DustCover`, `Barrel`, `BarrelBushing`.
- `Grip`, painéis de madeira, `Magazine`, base do magazine.
- `Trigger`, guarda, `Hammer`, `Beavertail`, segurança, miras.
- `GripSocket` em `(0, -0,054, -0,038)`.
- `Muzzle` em `(0, 0,114, 0,051)`.

## Integração

- JSON: `content/weapons/pistol.json` (`grip_profile: pistol`).
- Partes móveis: `Slide`, `Magazine`, `Trigger`.
- Mãos: `assets/models/hands/hands.glb` (compartilhado).
