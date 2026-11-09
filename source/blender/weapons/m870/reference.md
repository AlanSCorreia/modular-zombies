# Referência — M870 (autoral)

Modelo estilizado low-poly, autoral, gerado por
`source/blender/scripts/make_m870.py`.

## Dimensões

- Comprimento: 0,987 m
- Altura: 0,139 m
- Largura: 0,057 m
- Origem: `GunRoot` no receiver, `+Y` frente, `+Z` cima.

## Partes

- `Receiver`, porta de ejeção, cano e tubo de munição.
- Coronha com perfil extrudado, `ButtPlate`.
- `Pump` (empty com corpo extrudado e frisos), `Trigger`, guarda.
- Massa de mira esférica, abraçadeira do cano.
- `GripSocket` em `(0, -0,075, -0,012)`.
- `Muzzle` em `(0, 0,632, 0,060)`.

## Integração

- JSON: `content/weapons/m870.json` (`grip_profile: shotgun`).
- Partes móveis: `Pump`, `Trigger`.
- Mãos: `assets/models/hands/hands.glb` (compartilhado).
