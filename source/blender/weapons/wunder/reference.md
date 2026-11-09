# Referência — Wunder (autoral)

Modelo estilizado low-poly, autoral, gerado por
`source/blender/scripts/make_wunder.py`. O mesmo GLB serve à Wunder e ao
lança-foguete (`content/weapons/rocket.json`).

## Dimensões

- Comprimento: 0,796 m
- Altura: 0,262 m (com scope)
- Largura: 0,094 m
- Origem: `GunRoot` no corpo, `+Y` frente, `+Z` cima.

## Partes

- Corpo, painéis laterais, trilho superior.
- Cano com shroud, núcleo emissivo e quatro bobinas (`Coil0..3`).
- Punho, `Magazine` (célula de energia), `Trigger`, guarda.
- Coronha curta com duas hastes e `ButtPlate`.
- Scope com lente emissiva e montagens.
- `GripSocket` em `(0, -0,118, -0,060)`.
- `Muzzle` em `(0, 0,486, 0,060)`.

## Integração

- JSON: `content/weapons/wunder.json` (`grip_profile: wunder`) e
  `content/weapons/rocket.json` (`grip_profile: rocket`).
- Partes móveis: `Magazine`, `Trigger`.
- Mãos: `assets/models/hands/hands.glb` (compartilhado).
