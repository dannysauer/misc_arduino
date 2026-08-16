# Hardware validation status

The files in this directory are an early prototype schematic, not a released board design.

## Checks completed

The schematic generator currently verifies:

- balanced KiCad S-expression syntax
- deterministic UUID generation
- stable output: two consecutive generator runs produce byte-for-byte identical project and schematic files
- unique schematic reference designators
- no generated zero-length wires
- expected counts of symbols, wires, and net labels

The current generated-file hashes are:

```text
battery_monitor.kicad_sch  a57e26d75e7c7469461b7d2926ae4e945eefa7c119d1b735781165c405217daa
battery_monitor.kicad_pro  3319749b7ba1d4b7eb5cc83aed310ab91bf45f98b87fe2468c770c821f109be7
```

These hashes are useful only as a regression check for this revision. Saving the project in KiCad will legitimately rewrite metadata and change them.

## Checks still required

This environment does not currently have a working KiCad installation, so the generated schematic has **not** yet been opened by Eeschema or checked with `kicad-cli sch erc`.

Before PCB layout, open the project in the current KiCad release and:

1. confirm every custom symbol renders correctly
2. verify the logical Raytac module pin assignments against the selected module datasheet
3. replace the logical Raytac symbol with a complete production symbol/footprint
4. run ERC and review every warning rather than blanket-excluding errors
5. verify every assigned footprint against the actual manufacturer package
6. check resistor working-voltage and pulse ratings
7. check capacitor voltage derating
8. verify BAV199-Q orientation and pin mapping
9. review all connector pin numbers against the chosen connector family
10. save the project in KiCad and commit the normalized files

## Bench validation required before vehicle installation

The schematic calculations do not establish automotive qualification. The assembled prototype still needs the electrical tests in `FRONT_END_ANALYSIS.md`, including sleep current, threshold measurements, reverse polarity, brownout, elevated DC input, and safe transient testing.

The key acceptance criterion remains measured battery-side parked current below 25 uA in the defined normal parked state, with 20 uA or less preferred.
