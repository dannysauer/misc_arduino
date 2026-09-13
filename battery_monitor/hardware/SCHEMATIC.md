# Battery monitor schematic notes

This file turns the high-level design into a first-pass circuit. It is not yet a release schematic. Values here are intended to be copied into KiCad after we review the electrical assumptions and choose footprints.

## Sheet 1: battery input and 3.3 V supply

The front end has four jobs: survive the vehicle, reject noise, prevent reverse-battery damage, and waste almost no current while parked.

### Proposed topology

```text
                         vehicle harness

BAT+ ---- external fuse ----+------------------------------+
                            |                              |
                            |                        D1 load-dump TVS
                            |                              |
                            +---- D2 reverse diode ---- R1 ----+---- U1 3.3 V LDO ---- 3V3
                                                              |         |
                                                             C1        C2
                                                              |         |
GND ----------------------------------------------------------+---------+---------------- GND
```

D1 is intentionally before D2. A load-dump TVS can carry far more current than the low-current reverse-polarity diode should ever see.

A bidirectional TVS is preferred at this location. With a unidirectional TVS directly across the raw battery input, a reversed battery would forward-bias the TVS and turn reverse connection into an intentional fuse-blowing event. That is survivable if designed for it, but it is not the behavior we need here.

### External fuse

Require an inline fuse close to the battery connection. The monitor itself normally draws microamps and brief milliamp radio bursts, so a small fuse is sufficient electrically. The exact fuse value should also tolerate harness and connector realities; 0.5-1 A is a reasonable starting range.

The PCB should not assume the vehicle fuse box protects a long added battery lead.

### D1: load-dump TVS

Requirements:

- automotive/load-dump-rated part
- bidirectional
- roughly 30 V working standoff for a 12 V system
- clamp voltage comfortably below the 60 V absolute input rating of U1
- package and copper area capable of handling the specified pulse energy

A Littelfuse SLD8S-class part remains the leading family, but the exact suffix is not locked until we confirm a bidirectional part and its clamp behavior from the current datasheet.

The board layout matters as much as the part number. D1 should sit near the power connector with a short, wide return to the same ground entry region used by the harness.

### D2: reverse-polarity diode

The first revision should use a boring series diode rather than an ideal-diode controller.

Candidate characteristics:

- AEC-Q qualified where practical
- at least 100 V reverse rating; 200 V is comfortable
- at least several hundred milliamps forward capability despite the much smaller expected load
- low leakage is useful but not critical in normal polarity because the diode is in series

STTH1R02-Y is a current candidate. Its forward drop costs essentially nothing in this application because the load is tiny and the regulator has plenty of input-voltage headroom.

### R1: supply isolation

Start with 100 ohms in 1206 or a similarly pulse-tolerant package.

R1 serves three purposes:

- limits current into the downstream network during residual transients
- isolates the LDO input capacitor from the vehicle harness
- forms a useful low-pass filter with C1

At a 5 mA BLE transmit load, 100 ohms drops about 0.5 V. That is harmless from a normal 12 V battery. We should verify cold-cranking behavior with the finished load before freezing the value.

### C1: protected input bulk capacitor

Start with 2.2-4.7 uF after D2/R1, plus 100 nF ceramic close to U1.

Voltage rating should leave comfortable margin below the TVS clamp. A 100 V ceramic is attractive electrically, but DC-bias derating must be checked for the selected package. Film or electrolytic parts are alternatives if the ceramic becomes impractical.

### U1: 3.3 V regulator

Current choice: **TPS7A1633A-Q1 / TPS7A16A-Q1 family**.

Reasons:

- 3-60 V input range
- 5 uA typical quiescent current
- 100 mA output capability
- automotive-qualified version
- fixed 3.3 V option
- minimum 2.2 uF output capacitance

The older TPS7A16-Q1 is also suitable; the A revision is the preferred starting point for a new design.

Use at least 4.7 uF on the 3.3 V output, plus local 100 nF decoupling at every IC. We may increase the bulk value after measuring the nRF52840 advertisement burst on the real board.

Do not use the power-good pullup unless firmware needs it. Any pullup becomes part of the parked-current budget.

## Sheet 2: shared digital-input reference

Four automotive inputs use two TLV3702-Q1 dual nanopower comparators.

The comparators run from 3.3 V. Each channel consumes roughly 0.56 uA typical, so all four channels cost about 2.2 uA before the external divider current.

Create one filtered reference for all four channels:

```text
3V3 ---- RREF1 3.9M ----+---- VREF_IN ~= 0.67 V
                         |
                    RREF2 1.0M
                         |
                        GND

VREF_IN ---- CREF 100 nF ---- GND
```

Nominal reference:

```text
3.3 V * 1.0M / (3.9M + 1.0M) ~= 0.673 V
```

Divider current is about 0.67 uA.

The threshold intentionally follows the 3.3 V rail. Absolute threshold precision is not important; we need a clean distinction between an inactive automotive line and a real 12 V state.

## Sheet 3: protected automotive digital input

Use the same circuit for ignition, door/courtesy, parking lights, and AUX.

### First-pass channel

```text
VEH_IN ---- RIN1 11M ---- RIN2 11M ----+---- VIN_SENSE ----> Ux non-inverting input
                                        |
                                      RBOT 3.3M
                                        |
                                       GND

VIN_SENSE ---- CFILT 4.7 nF ---- GND

Ux inverting input -------------------- VREF_IN

Ux output ----------------------------- MCU GPIO/SENSE
      |
      +---- RHYS 68M ------------------ VIN_SENSE
```

Add low-leakage clamps at `VIN_SENSE` to ground and 3.3 V. BAV199-Q-family diodes are a candidate because leakage matters when the divider itself only carries fractions of a microamp.

### Why split the upper resistor

Two 11 M resistors share transient voltage and make resistor working-voltage limits easier to satisfy. The final footprint and resistor series must still be checked for rated working voltage and pulse behavior.

### Input current

Ignoring hysteresis current, the main divider is 22 M + 3.3 M.

At 12.6 V:

```text
12.6 V / 25.3 M ~= 0.50 uA
```

At 14.4 V:

```text
14.4 V / 25.3 M ~= 0.57 uA
```

This is acceptable even if an input stays high for months.

### Threshold and hysteresis

With a nominal 0.673 V reference, 22 M upper resistance, 3.3 M lower resistance, and 68 M positive-feedback resistor, the rough switching points are:

- rising threshold: about 5.4 V vehicle-side
- falling threshold: about 4.3 V vehicle-side

These are hand-analysis values. Before freezing them, run the circuit through SPICE with comparator offset, resistor tolerance, clamp leakage, supply tolerance, and temperature corners.

The point is not a precision 5 V detector. The point is to ignore ground noise and leakage while recognizing a real automotive high state.

### Filtering

The input divider has a multi-megaohm Thevenin resistance, so even 4.7 nF produces a useful millisecond-scale filter. That is desirable for old switches, relay noise, and ignition hash.

Do not make the capacitor large until we simulate wake latency. Door, ignition, and light-state changes do not need microsecond response, but they should feel immediate in Home Assistant.

### MCU wake behavior

Each comparator output goes to an nRF52840 GPIO that supports low-power `SENSE` wake.

Firmware re-arms the opposite level before sleeping:

```text
current input low  -> arm SENSE high
current input high -> arm SENSE low
```

That gives wake-on-change behavior without leaving a higher-current peripheral running.

## Sheet 4: battery-voltage ADC

The battery ADC can remain permanently connected if the divider current stays near 2 uA.

### Proposed network

```text
RAW_BAT ---- RBAT1 3.32M ---- RBAT2 3.32M ----+---- VBAT_ADC ---- MCU SAADC
                                               |
                                           RBAT3 806k
                                               |
                                              GND

VBAT_ADC ---- CBAT 10 nF ---- GND
```

Add low-leakage clamps from `VBAT_ADC` to ground and 3.3 V.

Nominal divider ratio:

```text
806k / (3.32M + 3.32M + 806k) ~= 0.1082
```

Representative values:

| Raw battery | ADC node |
| ---: | ---: |
| 12.0 V | 1.30 V |
| 12.8 V | 1.39 V |
| 14.4 V | 1.56 V |
| 20.0 V | 2.16 V |
| 30.0 V | 3.25 V |

Divider current at 12.6 V is about 1.69 uA.

The source resistance seen by the ADC is roughly 720 kohms. This is intentionally near, but below, the nRF52840 SAADC source-resistance limit when the longest acquisition time is selected. Re-check this against the exact Nordic specification before creating the KiCad schematic.

CBAT also acts as a charge reservoir during ADC acquisition and filters ignition noise.

The raw battery node is preferred over the post-diode supply node because the reported voltage should be the battery terminal voltage, not battery voltage minus the reverse-protection diode. The megaohm resistor chain limits fault current into the ADC protection network during transients or reverse polarity.

Firmware will calibrate gain and offset against a DMM.

## Sheet 5: temperature inputs

Use switched thermistor dividers so they consume no meaningful current while asleep.

### Onboard temperature

```text
TEMP_EXCITE GPIO ---- RTOP 10k ----+---- TEMP_BOARD_ADC
                                    |
                                  NTC 10k
                                    |
                                   GND
```

`TEMP_EXCITE` is driven high only while measuring and returns to high impedance afterward.

Place the onboard NTC away from U1 and the nRF module so it tracks enclosure/interior temperature rather than local regulator or radio heat.

### External battery temperature

Duplicate the circuit with a connector for a remote 10 k NTC. Add ESD protection and a small series resistor at the connector because this wire may leave the enclosure.

The exact NTC beta value should be recorded in firmware configuration rather than assumed from the nominal 10 k resistance.

## Sheet 6: nRF52840 module

Use a pre-certified module. Current preferred family: Raytac MDBT50Q.

The schematic should expose:

- 3.3 V and ground with local bulk and 100 nF decoupling
- SWDIO
- SWCLK
- RESET
- a ground reference on the programming header
- optional serial/debug pads if GPIO allows
- enough ADC pins for battery and both thermistors
- five wake-capable digital inputs
- one reserved GPIO for future remote-start output
- at least two spare test pads/GPIOs

Follow the module maker's antenna keepout exactly. Do not run copper, traces, ground pour, enclosure metal, or a wiring bundle through the antenna zone.

## Sheet 7: remote-start enable switch sense

The DPDT switch has two independent jobs.

Pole A is a literal series disconnect in the eventual AUX-trigger wire. It is not routed through firmware.

Pole B reports the same switch position to the MCU.

A simple local low-current circuit is sufficient:

```text
3V3 ---- internal or external pullup ---- MCU GPIO
                                       |
                                  DPDT sense pole
                                       |
                                      GND
```

Prefer an MCU pullup if its measured sleep current is acceptable. Otherwise use a large external resistor such as 470 k-1 M.

Home Assistant can then expose `remote_start_enabled`, but that state does not participate in the physical isolation function.

## Sheet 8: future remote-start output

Reserve the footprint and connector path now, but do not select the final driver until the Directed Electronics AUX input is characterized.

Expected topology:

```text
MCU GPIO ---- gate/base network ---- protected low-side device ---- AUX TRIGGER
                                                        |
                                                       GND

AUX TRIGGER ---- physical series enable switch ---- remote starter AUX input
```

A small logic-level N-MOSFET is likely sufficient if the AUX input is a normal low-current ground-trigger input. An optocoupler or relay remains possible if measurements show an unexpected interface.

The output must default off during reset, boot, programming, brownout, and MCU power loss.

## Connector plan

The final connector count is not frozen, but the electrical functions are:

```text
POWER
  BAT+
  GND

VEHICLE INPUTS
  IGN
  DOOR
  PARK_LIGHTS
  AUX_IN

TEMPERATURE
  EXT_NTC
  EXT_NTC_RETURN

REMOTE START
  AUX_TRIGGER_OUT
  AUX_TRIGGER_RETURN/GND as required
  ENABLE_SWITCH_SENSE
```

It may make mechanical sense to combine power and vehicle inputs into one locking connector and keep temperature/remote-start functions separate.

## Grounding and layout rules

Treat the harness entry as a noisy zone.

- TVS return goes directly to the connector-side ground region.
- Keep high-current TVS pulse paths away from MCU and ADC ground routing.
- Route the battery ADC divider away from the antenna and digital edges.
- Put comparator RC components close to the comparators.
- Put LDO input/output capacitors against U1 pins.
- Keep SWD and other test pads out of the antenna keepout.
- Provide test points for RAW_BAT, protected VIN, 3V3, VREF_IN, VBAT_ADC, and every comparator output.

A two-layer board is probably sufficient electrically, but four layers may make the RF keepout, ground return, and compact enclosure easier. Do not decide layer count until the module footprint and connector placement are known.

## Bench tests before vehicle installation

At minimum, verify:

1. parked current at 12.6 V with all vehicle inputs low
2. parked current with each input high, one at a time and all together
3. current and rail droop during BLE advertisements
4. battery ADC accuracy from roughly 6-16 V
5. ADC behavior during rapid input noise
6. comparator switching thresholds and hysteresis over the useful supply range
7. wake on both input transitions
8. reverse battery
9. brownout/cold-cranking-style input dips
10. elevated DC input and jump-start-like voltage
11. positive and negative transient testing within available safe test-equipment limits

Only after those tests should the prototype go into the Chevelle.

## Parts currently worth carrying into KiCad

| Ref | Candidate | Status |
| --- | --- | --- |
| U1 | TPS7A1633A-Q1 / TPS7A16A-Q1 | strong candidate |
| U2/U3 | TLV3702-Q1 | strong candidate |
| U4 | Raytac MDBT50Q nRF52840 module | family selected, exact variant TBD |
| D1 | 30 V bidirectional automotive load-dump TVS | exact part TBD |
| D2 | STTH1R02-Y-class high-voltage automotive diode | candidate |
| ADC clamps | BAV199-Q family | candidate |
| NTCs | 10 k automotive/industrial NTC | value selected, exact part TBD |

## Next schematic decision

The highest-value unresolved item is D1. Once the exact load-dump TVS is chosen, verify its worst-case clamp voltage against U1 and then freeze the battery-input sheet.

After that, simulate one TLV3702-Q1 input channel over tolerances. If the threshold and leakage behavior look good, replicate it for ignition, door, parking lights, and AUX and begin the actual KiCad project.
