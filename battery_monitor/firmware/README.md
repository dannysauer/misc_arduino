# Battery monitor firmware

The firmware is split into a platform-independent policy layer and a future nRF52840 hardware layer.

The policy layer exists now because the storage cadence is easy to get subtly wrong and does not depend on Zephyr, ESPHome, BLE, or Nordic hardware. We can test it with a normal C++ compiler before choosing the final embedded framework.

## Current behavior

`update_policy()` consumes elapsed time, battery voltage, and ignition state. It returns the next sampling interval and the current cadence mode.

The default policy is:

- stable/recently active: 15 minutes
- newly detected charger activity: 30 seconds for 10 minutes
- continuing voltage movement after fast mode: 2 minutes, for up to an hour
- no detected charger for about 90 days: 30 minutes
- substantial decline from the highest observed charged reference: 2 hours
- deeper decline: 12 hours

The low-battery tiers are based on voltage drop from a learned reference rather than AGM-specific absolute voltages. Optional absolute emergency thresholds are available in `PolicyConfig`, but default to disabled. Battery-health interpretation still belongs in Home Assistant.

A large voltage rise is considered a new external-charging session only while ignition is off and only when the device is not already inside the existing charge session's fast/settling window. This prevents a rising charger curve from repeatedly resetting fast mode.

## What the policy does not own

The platform layer still needs to provide:

- RTC/monotonic time
- battery ADC measurement and calibration
- ignition, door, parking-light, AUX, and remote-enable inputs
- onboard and external temperature readings
- wake-reason tracking
- BTHome advertisement encoding
- GPIO `SENSE` wake setup
- retained-state and occasional nonvolatile checkpointing
- actual sleep entry

Door and light changes should still cause immediate wake/report behavior even when the battery cadence has backed off to hours. The cadence policy controls periodic sampling; it does not suppress hardware wake inputs.

## Host test

The policy currently builds as C++17 with no external dependencies:

```sh
g++ -std=c++17 -Wall -Wextra -Werror \
  -Iinclude src/policy.cpp tests/policy_test.cpp \
  -o /tmp/battery-monitor-policy-test

/tmp/battery-monitor-policy-test
```

Expected output:

```text
policy tests passed
```

The test covers normal cadence, charger detection, fast and settling modes, 90-day idle backoff, low/deep conservation, and the rule that an alternator voltage rise with ignition on is not an external-charger event.

## Next firmware step

Keep the policy API small while the hardware schematic settles. The next embedded work should be a thin nRF52840 platform layer that can wake, collect one observation, encode one BTHome advertisement, and sleep. Do not add a persistent BLE connection to the normal measurement path.
