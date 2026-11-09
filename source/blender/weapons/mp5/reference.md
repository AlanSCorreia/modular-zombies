# Referência — MP5 (autoral)

Modelo estilizado low-poly, autoral, gerado por
`source/blender/scripts/make_mp5.py`.

## Dimensões

- Comprimento: 0,729 m
- Altura: 0,259 m (com magazine)
- Largura: 0,058 m
- Origem: `GunRoot` no receiver, `+Y` frente, `+Z` cima.

## Partes

- `Receiver` tubular, tampa traseira, tubo de caça, `Bolt`.
- Guarda-mão, cano, coroa de boca.
- Punho, `Trigger`, guarda.
- `Magazine` (empty com três segmentos curvos).
- Coronha retrátil (`StockRailL/R`, `ButtPlate`).
- Tambor de mira traseira e anel de mira frontal.
- `GripSocket` em `(0, -0,108, -0,062)`.
- `Muzzle` em `(0, 0,366, 0,050)`.

## Integração

- JSON: `content/weapons/mp5.json` (`grip_profile: rifle`).
- Partes móveis: `Bolt`, `Magazine`, `Trigger`.
- Mãos: `assets/models/hands/hands.glb` (compartilhado).
