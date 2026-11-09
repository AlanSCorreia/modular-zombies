# Referência — AK-74 (autoral)

Modelo estilizado low-poly, autoral, gerado por
`source/blender/scripts/make_ak74.py`.

## Dimensões

- Comprimento: 0,941 m
- Altura: 0,283 m (com magazine)
- Largura: 0,075 m
- Origem: `GunRoot` no receiver, `+Y` frente, `+Z` cima.

## Partes

- `Receiver`, `DustCover`, `Bolt`, alça traseira.
- Coronha de madeira, `ButtPlate`, punho.
- Guarda-mão inferior/superior, tubo de gás, cano, freio de boca.
- `Magazine` (empty com três segmentos curvos), `Trigger`, guarda.
- `GripSocket` em `(0, -0,108, -0,062)`.
- `Muzzle` em `(0, 0,550, 0,048)`.

## Integração

- JSON: `content/weapons/ak74.json` (`grip_profile: rifle`).
- Partes móveis: `Bolt`, `Magazine`, `Trigger`.
- Mãos: `assets/models/hands/hands.glb` (compartilhado).
