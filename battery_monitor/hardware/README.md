# Battery monitor hardware

The hardware directory contains the prototype circuit decisions and the generator for the KiCad project.

`tools/generate_schematic.py` is the source for the machine-generated KiCad files. It uses only the Python standard library, so you can regenerate the project without KiCad installed.

From `battery_monitor/hardware/tools/`:

```sh
python3 generate_schematic.py
```

The script writes these files into `battery_monitor/hardware/`:

```text
battery_monitor.kicad_pro
battery_monitor.kicad_sch
BM.kicad_sym
sym-lib-table
fp-lib-table
```

Those files are intentionally not committed. CI generates two independent copies and compares them byte-for-byte, then runs KiCad 10 ERC against one copy. The check fails on any parser error, ERC error, or ERC warning.

The generated schematic includes the power/protection path, four automotive wake inputs, battery ADC divider, temperature channels, remote-start-enable sense input, and a logical nRF52840 module symbol. The future remote-start driver is deliberately not implemented yet.

`VALIDATION.md` records the current validation state and the work that still has to happen before PCB layout. The electrical reasoning behind the component values lives in `FRONT_END_ANALYSIS.md`; `SCHEMATIC.md` is the readable circuit walkthrough; and `PROTOTYPE_BOM.md` is the purchase-oriented part list.
