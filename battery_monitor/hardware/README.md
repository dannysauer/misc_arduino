# Battery monitor hardware

The hardware directory contains the prototype circuit decisions and the start of the KiCad project.

Until the schematic has been opened, checked, and saved in KiCad, treat `tools/generate_schematic.py` as the reproducible source for the generated schematic. It uses only the Python standard library.

From `battery_monitor/hardware/tools/`:

```sh
python3 generate_schematic.py
```

The script writes:

```text
battery_monitor.kicad_pro
battery_monitor.kicad_sch
```

into `battery_monitor/hardware/`.

The generated schematic includes the power/protection path, four automotive wake inputs, battery ADC divider, temperature channels, remote-start-enable sense input, and a logical nRF52840 module symbol. The future remote-start driver is deliberately not implemented yet.

`VALIDATION.md` records what has and has not been checked. In particular, structural generation checks are not a substitute for opening the project in KiCad and running ERC.

The electrical reasoning behind the component values lives in `FRONT_END_ANALYSIS.md`; `SCHEMATIC.md` is the readable circuit walkthrough; and `PROTOTYPE_BOM.md` is the purchase-oriented part list.
