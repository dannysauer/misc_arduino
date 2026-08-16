# Battery monitor design

## Status

This document records requirements and design decisions for a reusable, ultra-low-power battery monitor intended for vehicles and small engine equipment. The first target is a 1971 Chevelle, but the hardware should also work on motorcycles, generators, lawn equipment, and similar 12 V systems.

The board is still in the design phase. Electrical values and part choices below are provisional until we validate them against datasheets, bench measurements, and automotive transient tests.

## Goals

The monitor should:

- run for months or years from an attached 12 V battery without becoming a meaningful parasitic load
- measure battery voltage and temperature while the equipment is parked
- wake immediately when useful vehicle-state inputs change
- advertise state over Bluetooth Low Energy so existing ESPHome Bluetooth proxies can forward it to Home Assistant
- support different battery chemistries without putting chemistry-specific state-of-charge rules into embedded firmware
- tolerate an older automotive electrical environment with ignition noise, relays, motors, alternator events, reverse polarity, and load-dump-style transients
- leave room on the PCB for a future remote-start trigger output

## Current targets

### Power budget

The design target is less than 25 uA average battery-side current while parked. Roughly 15-20 uA is preferred.

This matters for very small batteries. A 3 Ah powersports battery loses about 0.13 Ah per year to a constant 15 uA load and about 0.22 Ah per year to 25 uA, before accounting for the battery's own self-discharge.

The finished PCB must be measured rather than trusted from a spreadsheet. Development boards are not representative because LEDs, USB interfaces, regulators, and pullups can dominate the sleep budget.

### Reporting cadence

The firmware should use an adaptive cadence rather than one fixed interval.

Initial behavior:

1. Freshly active or recently charged: sample about every 15 minutes when voltage is stable.
2. Significant voltage change: enter an active-monitoring mode and sample about every 30 seconds.
3. Charging or another sustained electrical event: slow to roughly 2-5 minute samples after the voltage slope becomes small.
4. Long inactivity: if no charging event has been detected for about three months, increase the normal interval to roughly 30 minutes.
5. Low-voltage conservation: if battery voltage has fallen substantially, increase the interval to roughly 2 hours or more so the monitor does not materially accelerate discharge.
6. Input transitions: door, ignition, parking-light, and other wake-capable input transitions should cause an immediate measurement and advertisement.

Exact thresholds are firmware policy and will be tuned from real traces. The PCB should not encode charger or chemistry thresholds in hardware.

The device should retain enough state across sleep to know how long it has been since charging was detected and which cadence tier applies. Flash writes should be minimized; elapsed time can normally be accumulated in retained RAM and checkpointed infrequently if needed.

## Home Assistant responsibilities

The node reports facts. Home Assistant interprets them.

The node should report at least:

- battery voltage
- module/interior temperature
- optional external battery temperature
- door/courtesy state
- ignition state
- parking-light state
- spare automotive input state
- remote-start-enable switch state
- wake reason or equivalent diagnostic state where practical

Home Assistant should own:

- battery chemistry
- battery-capacity metadata
- state-of-charge estimation
- low and critical voltage thresholds
- charging-state inference
- long-term voltage trends
- alerts such as lights on with ignition off
- reminders to connect a charger

This keeps the board reusable across AGM, flooded lead-acid, LiFePO4, and other battery types.

## Radio and firmware

The preferred radio family is Nordic nRF52, currently nRF52840.

The production PCB should use a pre-certified module with an integrated RF section rather than laying out the radio from the bare SoC. A Raytac MDBT50Q-class module is a leading candidate.

Normal telemetry should use connectionless BLE advertisements. BTHome is the preferred payload format because Home Assistant and ESPHome Bluetooth proxies already understand it.

The normal sequence should be:

1. wake from RTC or GPIO sense
2. read digital inputs
3. measure voltage and enabled temperature channels
4. update the cadence state machine
5. advertise the current state several times for reception reliability
6. return to low-power sleep

The device should not maintain a BLE connection during ordinary operation.

ESPHome on nRF52 remains interesting, but it is not a hard requirement. A small Zephyr or C/C++ firmware is acceptable if it produces materially lower power or a cleaner BTHome implementation.

## Inputs

The current PCB requirement is:

- IN1: ignition
- IN2: door/courtesy
- IN3: parking lights
- IN4: spare protected automotive input
- local input: remote-start-enable switch sense
- ADC: battery voltage
- ADC: onboard temperature sensor
- ADC: optional external battery thermistor

All automotive digital inputs should be able to wake the MCU on either logical transition.

### Parking lights

Parking-light state is explicitly required so Home Assistant can detect cases such as lights left on while ignition is off.

The embedded node reports only the light and ignition states. Alert timing and policy belong in Home Assistant.

### Remote-start enable switch

The future remote-start output only needs to emulate a momentary ground signal into the AUX trigger of an existing commercial Directed Electronics remote-start system.

The remote starter already provides its own park, brake, hood, over-rev, and other starting interlocks.

The board should still use a physical series disconnect in the AUX trigger wire. A DPDT switch is preferred:

- one pole physically disconnects the trigger path
- the second pole reports whether remote start is enabled or disabled

The MCU indication is informational. The physical disconnect remains effective even if the MCU or firmware fails.

## Future output

Reserve PCB resources for one protected low-side/open-drain output capable of pulling the remote-start AUX input to ground for a configured pulse.

The output stage should be unpopulated or otherwise inactive in the first hardware revision unless we explicitly decide to implement it.

Before selecting that driver, measure or verify the Directed AUX input voltage, current, and trigger timing requirements.

## Temperature

Provide two temperature channels:

1. onboard sensor for module/interior temperature
2. optional external thermistor for battery temperature

A switched NTC divider is attractive because the MCU can power it only during a measurement. This keeps sleep current negligible.

The external thermistor is optional on equipment where battery-temperature compensation is not useful.

## Battery voltage measurement

The current preference is a permanently connected very-high-value divider rather than a switched divider.

Reasons:

- fewer leakage paths and switching components
- no divider-settling delay after wake
- no charge injection from a switch
- the current can be held to only a few microamps with megaohm-range resistors

The divider must be selected alongside the nRF52840 SAADC acquisition-time limits. The ADC node should include capacitance and low-leakage protection so automotive transients do not reach the MCU pin.

Use multiple series resistors in the upper divider leg so one small resistor does not see the full transient voltage.

Calibrate battery-voltage measurements in firmware against a known-good DMM. Do not assume resistor tolerance and ADC gain error alone will meet the desired absolute accuracy.

## Automotive digital-input concept

The current preference is protected nanopower comparator inputs rather than optocouplers.

Reasons:

- the monitor already shares chassis ground with the vehicle
- some vehicle inputs may remain at 12 V for months, so optocoupler LED current could become a meaningful parked load
- a megaohm-range divider can make the high-state current well below 1 uA
- a comparator gives a clean logic level and predictable threshold without optocoupler CTR variation

A TLV3702-Q1-class dual nanopower comparator is a leading candidate. Two dual packages can service four automotive inputs.

A representative channel is:

```text
vehicle input
    |
 high-value series/divider network
    |
    +---- low-leakage clamp / RC filter ---- comparator +
                                              comparator - ---- shared reference
                                                     |
                                                     +---- nRF GPIO SENSE
```

The threshold should be comfortably above ground noise and comfortably below a valid 12 V state. Roughly 5 V vehicle-side is a reasonable starting point, but the final value must come from the complete divider, hysteresis, leakage, and transient design.

Each channel should tolerate automotive input transients without relying on the MCU's internal ESD diodes.

## Power and protection

The intended power path is:

```text
BAT+ ---- fuse ----+---- reverse-polarity element ---- low-Iq 3.3 V regulator ---- 3V3
                   |
                   +---- high-energy automotive TVS ---- chassis ground
```

The TVS belongs before a small series reverse-polarity diode so load-dump surge current returns directly to chassis instead of flowing through the diode.

The current regulator candidate is TPS7A16-Q1 because it combines low quiescent current with a 60 V input rating. This is attractive for an nRF52 load because short BLE transmit bursts do not dissipate enough power to make an LDO unreasonable.

A high-voltage automotive buck regulator remains an alternative if later loads make the LDO unattractive.

The protection design must consider:

- normal battery range
- alternator charging voltage
- cranking brownout
- reverse battery
- jump-start conditions
- relay and motor transients
- positive load-dump-style events
- negative ISO 7637-style pulses
- EMI from ignition, electric fans, fuel pump, injectors, and a capacitive-discharge ignition system

A TVS alone is not proof of automotive robustness. We still need proper source impedance, capacitors, layout, component voltage ratings, and bench testing.

## Preliminary always-on current budget

These are planning numbers, not measured results.

| Load | Approximate target |
| --- | ---: |
| nRF52840 low-power sleep with RTC / retained state | 2-4 uA |
| 60 V low-Iq LDO | about 5 uA |
| four nanopower comparator channels | about 2-3 uA |
| battery-voltage divider | about 1.5-2 uA |
| comparator reference and miscellaneous leakage | about 1-3 uA |
| total design target | roughly 15-20 uA |
| maximum parked target | 25 uA |

BLE wake energy is expected to add little to the average current at 15-minute or slower intervals, but we will measure the complete wake/measure/advertise cycle on real hardware.

## Low-battery self-preservation

The monitor should reduce its own contribution to discharge as a battery remains unused.

The first policy to prototype is:

```text
normal, recently active
    -> 15 minute reports

no charger detected for ~3 months
    -> 30 minute reports

battery voltage has declined substantially
    -> 2 hour reports

battery becomes deeply discharged
    -> very sparse reports, while retaining GPIO wake capability where safe
```

This policy is intentionally separate from battery-health classification. We should prefer relative decline and configurable absolute guardrails so a reusable board is not silently assuming AGM thresholds.

Home Assistant should alert well before the firmware reaches its deepest conservation tier.

## Schematic work order

The schematic should be developed and reviewed in this order:

1. battery input, fuse assumptions, TVS, reverse-polarity protection, regulator, and decoupling
2. one complete protected automotive comparator input with hysteresis and wake behavior
3. replicate the verified input channel for ignition, door, parking lights, and AUX
4. battery-voltage ADC network and clamps
5. onboard and external temperature channels
6. nRF52840 module, SWD/programming interface, reset, crystals if required by the selected module, and RF keepout
7. remote-start-enable sense input
8. reserved remote-start low-side output
9. connectors, test points, mechanical mounting, and enclosure constraints

## Planned repository layout

```text
battery_monitor/
    DESIGN.md
    hardware/
        battery_monitor.kicad_pro
        battery_monitor.kicad_sch
        battery_monitor.kicad_pcb
    firmware/
    enclosure/
        battery_monitor.scad
```

The KiCad and OpenSCAD files will be added after the electrical interfaces and board dimensions settle enough that generating them is useful.

## Open decisions

- exact nRF52840 module and footprint
- exact TVS and reverse-polarity components
- regulator package and thermal/layout details
- comparator input resistor values, clamps, hysteresis, and filtering
- divider ratio and ADC protection values
- onboard temperature sensor type
- external thermistor value and connector
- firmware framework: ESPHome/Zephyr versus small custom firmware
- BTHome object mapping for ignition, parking lights, AUX, and diagnostics
- low-battery conservation thresholds
- enclosure connector style and environmental sealing
- final remote-start output component after AUX input characterization
