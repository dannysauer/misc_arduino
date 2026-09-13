# Prototype BOM and electrical constraints

This file is the working purchase list for the first electrical prototype. It exists so the schematic can use real orderable parts rather than family names.

Parts marked **frozen** are the default for the first KiCad revision. We can still change them if the schematic review or bench work finds a problem.

## Core parts

| Ref group | Function | Part | Prototype status |
| --- | --- | --- | --- |
| U1 | 3.3 V regulator | TI TPS7A1633A-Q1 / fixed 3.3 V TPS7A16A-Q1 family member | frozen |
| U2 | four automotive input comparators | TI TLV7034-Q1 | frozen |
| U3 | BLE MCU module | Raytac MDBT50Q-1MV2 | frozen |
| D1 | raw-bus load-dump TVS | ST SM50T30CAY | frozen |
| D2 | reverse-battery series diode | ST STTH1R02-Y | frozen |
| Dx | low-leakage analog clamps | Nexperia BAV199-Q family | provisional until exact package/symbol check |

## Why MDBT50Q-1MV2

Raytac still lists the MDBT50Q-1MV2 as a current nRF52840 module. It provides 1 MB flash, 256 KB RAM, 48 GPIO, a chip antenna, and the usual nRF52840 ADC/debug interfaces in a 10.5 x 15.5 mm module.

The PCB-antenna `MDBT50Q-P1MV2` is also electrically suitable. Start with the chip-antenna version because it is compact and avoids extending a PCB antenna structure farther into the enclosure. Keep the PCB layout modular enough that changing to the `P1MV2` footprint variant is still possible if range testing favors it.

The newer `MDBT50Q-1MEN` line adds APProtect. That feature is not useful enough on a hobby/serviceable device to justify making SWD recovery more complicated during early firmware work.

Raytac's design material provides an external 32.768 kHz crystal option. Include the crystal and load-capacitor footprints in the schematic. Populate them in the first prototype unless sleep-current measurements give a reason not to.

## Battery ADC

Freeze the existing divider for the prototype:

```text
RAW_BAT -- 3.32 M -- 3.32 M --+-- VBAT_ADC -- nRF SAADC
                               |
                             806 k
                               |
                              GND

VBAT_ADC -- 10 nF -- GND
```

Nominal values:

- divider ratio: about 0.10825
- current at 12.6 V: about 1.69 uA
- ADC node at 14.4 V: about 1.56 V
- ADC node at 30 V: about 3.25 V
- source resistance seen by the ADC: about 719 kOhm

The nRF52 SAADC supports a 40 us acquisition time for source resistance up to 800 kOhm. Firmware **must** configure the battery-voltage channel for the 40 us acquisition setting.

The 10 nF capacitor is more than a noise filter. It supplies the ADC sample-and-hold charge locally, which makes this unusually high source impedance much less troublesome for a slowly changing battery voltage.

Firmware should:

1. enable and calibrate the SAADC only when a measurement is needed
2. use the longest 40 us acquisition setting for the battery channel
3. discard the first conversion after SAADC startup if bench measurements show a repeatable settling error
4. take a small burst of samples and average them
5. stop the SAADC completely after the measurement
6. apply board-specific gain/offset calibration stored in nonvolatile settings

Do not leave the SAADC idling between reports; its idle current would be large compared with the whole parked-current budget.

## Automotive input channel

Replicate this four times:

```text
VEH_IN -- 4.7 M -- 4.7 M --+-- SENSE -- TLV7034-Q1 +
                            |
                           1.5 M
                            |
                           GND

SENSE -- 4.7 nF -- GND
TLV7034-Q1 - -- VREF
TLV7034-Q1 OUT -- nRF GPIO/SENSE
TLV7034-Q1 OUT -- 33 M -- SENSE
```

Shared reference:

```text
3V3 -- 3.9 M --+-- VREF
                |
               1 M
                |
               GND

VREF -- 100 nF -- GND
```

Use 1% resistors for the thresholds. The circuit is intentionally not a precision detector; the goal is a stable automotive LOW/HIGH decision with substantial noise margin.

### Resistor footprints

Do not automatically use tiny 0402 parts for the high-side resistors. Working-voltage and pulse ratings matter more than board area here.

For `RAW_BAT`, `IGN`, `DOOR`, `PARK_LIGHTS`, and `AUX_IN` high-side chains, start the KiCad BOM with 0805 or 1206 high-value resistors from a series whose continuous working-voltage specification we have actually checked. Split high-voltage legs across two physical resistors even when one part's nominal resistance would be convenient.

Keep high-impedance sense nodes physically short and away from the raw harness connector, TVS current path, SWD clocks, and RF antenna.

## Power front end

Prototype topology:

```text
BAT+ -- external fuse --+-- SM50T30CAY -- GND
                        |
                        +-- STTH1R02-Y -- 100 R -- VIN_PROTECTED -- TPS7A1633A-Q1 -- 3V3
                                                |
                                           2.2-4.7 uF
                                                |
                                               GND
```

The 100 ohm series resistor is still a prototype value. It loses about 0.5 V at a 5 mA radio load, which is harmless at normal battery voltage. Bench-test BLE bursts and crank-like supply dips before freezing it for a production PCB.

Place a 100 nF ceramic directly at the LDO input and output pins in addition to the required bulk capacitors. Use capacitor voltage ratings that remain sensible after DC-bias derating.

The TVS return gets its own short, wide path to the harness-side ground entry. Do not route a large transient current under or through the MCU/ADC ground region.

## Temperature channels

Use two 10 k NTC channels:

- one onboard NTC, placed away from the regulator and radio module
- one optional remote NTC near the battery

Excite each divider only while measuring. A GPIO-driven 10 k top resistor is acceptable for the first prototype.

Add a small series resistor and ESD protection to the remote sensor connector because that cable leaves the enclosure.

The exact NTC part remains open. Choose a common beta curve and document the actual beta/reference-temperature values in firmware rather than assuming every 10 k NTC is interchangeable.

## Remote-start provisions

### Physical enable

Use a DPDT switch:

- pole A is wired directly in series with the remote-start AUX trigger path
- pole B goes to the MCU as the enable-state indication

Sense pole B with a 4.7 M pullup to 3.3 V. The local logic input does not replace the physical disconnect.

### Future AUX trigger output

Reserve footprints for:

- one MCU output GPIO
- gate/base resistor
- gate/base pulldown
- low-side N-MOSFET or transistor
- optional clamp/ESD part at the connector
- test point

Leave the driver DNP until the Directed Electronics AUX input voltage/current is measured or verified. The output must remain off through MCU reset, SWD programming, brownout, and loss of MCU power.

## Programming and debug

Expose at least:

- SWDIO
- SWCLK
- RESET
- 3V3 reference
- GND

Use a small pogo/test-pad pattern rather than committing enclosure space to a permanent header. The first hand-built board may also carry through-hole pads or a Tag-Connect-compatible footprint if convenient.

Add named test points for:

- RAW_BAT
- VIN_PROTECTED
- 3V3
- VREF
- VBAT_ADC
- all four comparator outputs
- TEMP_BOARD_ADC
- TEMP_BAT_ADC

## Current-budget acceptance

The target remains:

- preferred normal parked current: <=20 uA battery-side
- hard prototype acceptance target: <25 uA battery-side

Measure that with the production-intent regulator, radio module, and input circuits. A development board result is not relevant because LEDs, debugger circuits, and board regulators change the answer.

Also record current for these states so firmware/HA documentation can explain the real cost of each feature:

- all vehicle inputs low
- each input high separately
- all inputs high
- remote-start enable sense open and closed
- 15-minute advertising cadence
- 30-second active-monitoring cadence
- deep-conservation cadence

## Remaining part selections

The schematic can now begin in KiCad. These choices can remain open while the first sheet is drawn:

- exact BAV199-Q package for clamp networks
- exact 32.768 kHz crystal and load capacitors
- exact NTCs
- connector family
- high-value resistor manufacturer/series and footprints
- bulk capacitor dielectric/package
- future AUX-trigger transistor

The next hardware review should focus on the actual KiCad power and analog sheets rather than another round of architecture discussion.
