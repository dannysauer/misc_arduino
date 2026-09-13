# Hardware validation status

The files in this directory describe an early prototype schematic, not a released board design.

## Checks completed

The generator verifies balanced KiCad S-expression syntax and deterministic UUID generation. CI also runs the generator twice in separate directories and compares every generated file byte-for-byte.

GitHub Actions currently installs KiCad 10.0.6, generates the project on demand, upgrades the schematic to the current KiCad format, and runs ERC with all severities enabled.

The current result is:

```text
0 total ERC violations
0 errors
0 warnings
```

The warning cleanup was done at the source rather than with blanket exclusions. The generator now emits schematic geometry on KiCad's 50 mil connection grid, registers the local `BM` symbol library and standard footprint libraries, marks intentionally unused MCU pins with explicit no-connects, and omits two redundant capacitor wire stubs that ended without a connection.

## Checks still required

ERC is clean, but the prototype is not ready for PCB layout yet. Before layout:

1. confirm every custom symbol renders correctly in the KiCad GUI
2. verify the logical Raytac module pin assignments against the selected module datasheet
3. replace the logical Raytac symbol with a complete production symbol and footprint
4. verify every assigned footprint against the actual manufacturer package
5. check resistor working-voltage and pulse ratings
6. check capacitor voltage derating
7. verify BAV199-Q orientation and pin mapping
8. review all connector pin numbers against the chosen connector family
9. resolve the battery ADC divider only after checking the nRF52840 SAADC limits against Nordic's primary documentation

## Bench validation required before vehicle installation

The schematic calculations do not establish automotive qualification. The assembled prototype still needs the electrical tests in `FRONT_END_ANALYSIS.md`, including sleep current, threshold measurements, reverse polarity, brownout, elevated DC input, and safe transient testing.

The key acceptance criterion remains measured battery-side parked current below 25 uA in the defined normal parked state, with 20 uA or less preferred.
