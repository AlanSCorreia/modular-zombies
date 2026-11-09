# Referência — M1911 (autoral)

Modelo estilizado low-poly, autoral, gerado por
`source/blender/scripts/make_m1911.py`.

## Dimensões

- Comprimento: 0,227 m
- Altura: 0,159 m
- Largura: 0,035 m
- Origem: `GunRoot` na região do frame, `+Y` frente, `+Z` cima.

## Partes

- `Frame`, `Slide`, `DustCover`, `Barrel`, `BarrelBushing`.
- `Grip` (perfil extrudado em madeira), parafusos, `Magazine`, base do magazine.
- `Trigger`, guarda, `Hammer`, `Beavertail`, segurança, miras.
- `GripSocket` em `(0, -0,056, -0,040)`.
- `Muzzle` em `(0, 0,114, 0,051)`.

## Integração

- JSON: `content/weapons/pistol.json` (`grip_profile: pistol`).
- Partes móveis: `Slide`, `Magazine`, `Trigger`.
- Mãos: `assets/models/hands/hands.glb` (compartilhado).
