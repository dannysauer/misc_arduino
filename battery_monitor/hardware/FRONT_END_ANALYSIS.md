# Front-end component decisions

This note records the component and tolerance work behind the first prototype schematic. These are prototype choices, not a claim that the finished board meets an automotive transient standard. We still have to test the assembled board.

## Decisions in this pass

For the first KiCad revision, use these parts and values unless later analysis finds a concrete problem:

| Function | Prototype choice | Status |
| --- | --- | --- |
| Load-dump TVS | ST SM50T30CAY | freeze for prototype |
| Reverse-battery diode | ST STTH1R02-Y | freeze for prototype |
| 3.3 V regulator | TI TPS7A1633A-Q1 / TPS7A16A-Q1 family | freeze for prototype |
| Four vehicle-input comparators | TI TLV7034-Q1 | freeze for prototype |
| Vehicle-input upper divider | 4.7 M + 4.7 M, 1% | freeze for prototype |
| Vehicle-input lower divider | 1.5 M, 1% | freeze for prototype |
| Vehicle-input feedback | 33 M, 1% | freeze for prototype |
| Vehicle-input filter | 4.7 nF | freeze for prototype |
| Shared comparator reference | 3.9 M / 1.0 M with 100 nF | freeze for prototype |
| Low-leakage signal clamps | Nexperia BAV199-Q family | provisional; verify exact package pinout |
| Remote-start enable sense pullup | 4.7 M external | freeze for prototype |

The battery ADC divider remains provisional until the nRF52840 SAADC source-impedance assumptions are checked one more time against the exact firmware configuration.

## Power-input protection

The power connector enters a deliberately noisy part of the board:

```text
                 raw vehicle side

BAT+ -- fuse --+---------------- TVS ---------------- GND
               |
               +-- reverse diode -- 100 R -- protected VIN -- LDO -- 3V3
                                      |
                                  input bulk C
```

The TVS is before the small series reverse-polarity diode. A load-dump pulse can put a large current through the TVS, and that current should return directly to the harness ground entry rather than pass through the diode or the logic-side ground path.

### TVS selection

Use **SM50T30CAY** for the first prototype.

The ST SM50TxxCAY family is a bidirectional, automotive 5 kW TVS family in an SMC package. For SM50T30AY/CAY, the current datasheet specifies:

- 26 V maximum reverse working voltage (`VRM`)
- 28.9 V minimum breakdown voltage
- 42.1 V maximum clamp at 119 A for a 10/1000 us pulse at 25 C
- 0.2 uA maximum reverse leakage at `VRM` and 25 C
- 1 uA maximum reverse leakage at `VRM` and 85 C

The 26 V working voltage is intentional. This board is for nominal 12 V systems; it should tolerate a 24 V jump-start condition, but it is not a 24 V vehicle monitor. Using a lower stand-off voltage buys useful clamp margin for the 60 V regulator.

ST specifies a positive temperature coefficient for this part. Applying the datasheet formula to the 42.1 V 10/1000 us clamp gives roughly 46.2 V at 125 C and 48.2 V at 175 C. That leaves much more margin below the regulator's 60 V input limit than the 30 V-working-voltage part we considered first.

The short 8/20 us rating is a different and substantially higher-current condition. We are not assuming the TVS alone holds every possible fast pulse below the regulator rating. The reverse diode, 100 ohm series resistor, local capacitance, physical wiring impedance, and layout are part of the protection network, and the complete assembly needs transient testing.

A Bourns SM8S30CA-Q-class part remains a higher-energy alternative if testing shows the 5 kW SMC part is too small. Its package and guaranteed leakage are less attractive for this unusually low-current design.

### Reverse-battery diode

Use **STTH1R02-Y** for the first prototype.

It is a 200 V, 1 A automotive diode in SOD123Flat. ST explicitly identifies reverse-battery protection as an intended automotive use. A series diode is deliberately unsophisticated here: the monitor normally uses microamps, so saving a few hundred millivolts with an ideal-diode controller is not worth another always-on circuit.

The bidirectional TVS is important with this topology. During reverse battery, it does not intentionally short the input and depend on the fuse opening. D2 blocks the downstream electronics instead.

### 3.3 V regulator

Use the fixed 3.3 V member of the **TPS7A16A-Q1** family for the prototype.

The part accepts 3-60 V and its typical ground current is 5 uA at a 10 uA load. The electrical-characteristics table allows up to 15 uA, so the 25 uA board target is a **measured acceptance target**, not something we can prove by adding every datasheet maximum.

That distinction matters. Typical component values predict a comfortable result, but high-temperature leakage and part-to-part spread can consume more of the budget. We should measure several assembled boards if this design gets duplicated across equipment.

Keep the fixed-output part so there is no feedback divider wasting current.

## Vehicle digital inputs

Use one **TLV7034-Q1** quad push-pull comparator instead of two TLV3702-Q1 dual comparators.

Reasons:

- four channels in one package
- 315 nA/channel typical quiescent current
- 2 pA maximum input bias on TI's product data
- 8 mV maximum input offset at 25 C
- built-in hysteresis and power-on reset
- push-pull output, so no output pullup current is required
- automotive qualification

The lower input bias is particularly valuable because the vehicle dividers intentionally use megaohm resistors.

### Shared threshold reference

Use:

```text
3V3 -- 3.9 M --+-- VREF
                |
              1.0 M
                |
               GND

VREF -- 100 nF -- GND
```

Nominal `VREF` is about 0.673 V. The divider costs about 0.67 uA continuously.

We could make this divider ten times larger, but saving roughly 0.6 uA would make the common reference much more sensitive to contamination and leakage. The current value is a better tradeoff for a board that may live in a vehicle for years.

### One vehicle input channel

Use this network for IGN, DOOR, PARK_LIGHTS, and AUX_IN:

```text
VEH_IN -- 4.7 M -- 4.7 M --+-- VIN_SENSE --> TLV7034 +
                            |
                           1.5 M
                            |
                           GND

VIN_SENSE -- 4.7 nF -- GND

TLV7034 - ---------------- VREF

TLV7034 OUT -------------- MCU GPIO/SENSE
      |
      +------ 33 M ------- VIN_SENSE
```

Add a low-leakage clamp network at `VIN_SENSE`. BAV199-Q is the current family choice; verify the exact package pinout before the KiCad symbol is considered final.

Split the 9.4 M upper leg into two 4.7 M resistors. This shares transient voltage between packages and gives us more freedom when checking resistor working-voltage and pulse ratings.

### Why the divider changed

An earlier version used 11 M + 11 M over 3.3 M. It saved roughly half a microamp when a vehicle input was high, but it made a real PCB uncomfortably sensitive to nanoamp-scale leakage.

The revised 9.4 M / 1.5 M divider uses approximately:

| Vehicle input | Divider/input current, approximate |
| ---: | ---: |
| 12.0 V | 1.1 uA |
| 12.6 V | 1.15 uA |
| 14.4 V | 1.3 uA |
| 16.0 V | 1.45 uA |

An input that is low does not incur this current from the vehicle line. Normally IGN, parking lights, and AUX are all low during long-term storage; the door/courtesy wiring is the input most likely to have vehicle-dependent polarity.

### Nominal switching points

Ignoring the comparator's small internal hysteresis for a moment, the external network switches at roughly:

- rising: 5.1 V vehicle-side
- falling: 4.1 V vehicle-side

The 33 M positive-feedback resistor therefore provides about 1 V of vehicle-side hysteresis. That is intentional; none of these signals is an analog measurement. We want a clean answer in the presence of relay noise, old switch contacts, and wiring leakage.

### Corner analysis

A simple worst-case enumeration was run over:

- all threshold resistors at +/-1%
- 3.3 V rail at +/-2%
- comparator input offset at +/-8 mV
- a broad internal-hysteresis range
- injected leakage at the sense node in both directions

The resulting vehicle-side thresholds were:

| Added sense-node leakage | Rising range | Falling range |
| ---: | ---: | ---: |
| 0 nA | 4.77-5.52 V | 3.75-4.45 V |
| +/-5 nA | 4.73-5.57 V | 3.70-4.50 V |
| +/-10 nA | 4.68-5.62 V | 3.66-4.55 V |
| +/-20 nA | 4.59-5.71 V | 3.57-4.64 V |
| +/-50 nA stress case | 4.31-6.00 V | 3.29-4.93 V |

This is materially better than the earlier 22 M upper-divider version. The old circuit moved by roughly a volt at only tens of nanoamps of unwanted leakage.

The practical consequence is that the revised circuit is much less dependent on a perfectly clean, perfectly dry PCB. We should still keep `VIN_SENSE` traces short, clean flux residue, and consider conformal coating for boards expected to see condensation.

### Input filtering

The 4.7 nF capacitor with the divider's roughly-megaohm Thevenin impedance gives filtering in the few-millisecond range. Use firmware debounce on top of that.

Door and parking-light reporting does not need microsecond response. Avoid increasing the capacitor enough to make a physical input feel delayed.

## Remote-start enable sense

Use the second pole of the physical DPDT enable switch as a local logic input:

```text
3V3 -- 4.7 M --+-- MCU GPIO/SENSE
                |
             switch pole
                |
               GND
```

The 4.7 M external pullup costs about 0.7 uA only while that pole is closed. A 470 k or 1 M pullup would waste too much current for a switch that may remain in one position for months.

This input only reports the switch position. The other DPDT pole remains the literal series disconnect in the future remote-start AUX-trigger wire.

## Low-frequency clock provision

Provision the PCB for an external 32.768 kHz crystal on the nRF52840 module's low-frequency crystal pins, subject to the final Raytac module pinout.

The device sleeps for most of its life, and interval accuracy over months is useful for the long-storage cadence policy. The nRF52840 can run its RTC from the internal RC oscillator, but an external low-frequency crystal gives substantially better timing accuracy and avoids periodic RC calibration. We will make the crystal population choice after measuring the actual module/firmware sleep current.

Retain only the RAM needed for cadence state. Keeping all nRF52840 RAM alive merely to preserve a few counters is unnecessary current. Firmware can checkpoint the few values that must survive a total power loss without writing flash every wake.

## Updated parked-current estimate

This is an expected-value budget for design work, not a guaranteed maximum:

| Always-on item | Approximate current |
| --- | ---: |
| TPS7A16A-Q1 regulator | 5.0 uA typical |
| nRF52840 System ON + RTC, minimal retained state | about 1.5-3.2 uA, configuration dependent |
| TLV7034-Q1, four channels | about 1.26 uA typical |
| shared comparator reference | 0.67 uA |
| battery-voltage divider | about 1.7 uA at 12.6 V |
| SM50T30CAY leakage | <=0.2 uA at its 26 V VRM and 25 C; expected lower at normal battery voltage |
| one vehicle input held high | about 1.15 uA at 12.6 V |
| remote-enable sense, if grounded | about 0.70 uA |

A representative subtotal lands around 12-14 uA before miscellaneous leakage and the averaged wake/advertise energy. That leaves useful room under the 25 uA acceptance target.

Do not turn that estimate into a guarantee. The LDO alone permits 15 uA ground current at its datasheet maximum, and leakage rises with temperature. The assembled-board measurement is the requirement.

## Prototype acceptance criteria

Before installing a board in a vehicle, measure at least:

1. battery-side sleep current at 12.6 V with all four vehicle inputs low
2. sleep current with each vehicle input high individually
3. sleep current with all four inputs high
4. sleep current with remote-start enable sense in both positions
5. sleep current after warm soak if practical
6. 3.3 V droop and battery-side current during BLE advertising
7. comparator rising/falling thresholds on all four channels
8. threshold behavior with injected noise on a vehicle input
9. reverse-battery survival
10. 24 V jump-start-style input operation
11. brownout/recovery behavior during crank-like dips
12. positive and negative transient tests within safe bench capability

The board passes the parked-current requirement only if the measured battery-side current is below 25 uA in the defined normal parked state. Prefer 20 uA or less so temperature, aging, dirt, and unit-to-unit spread have room.

## What remains before KiCad

The front-end architecture is now stable enough to draw. The remaining checks before calling the schematic ready for PCB layout are:

- re-check the nRF52840 SAADC source-impedance requirement and freeze the battery divider
- verify BAV199-Q package/pinout and signal-clamp orientation
- choose actual resistor series/footprints with enough working-voltage and pulse margin
- choose the input and output capacitor parts, including DC-bias derating
- select the exact Raytac module variant and copy its antenna keepout and low-frequency-crystal pins from the current module drawing
- choose connector families and decide whether the enclosure needs meaningful moisture sealing
