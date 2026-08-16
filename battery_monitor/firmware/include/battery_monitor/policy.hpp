#pragma once

#include <cstdint>

namespace battery_monitor {

struct PolicyConfig {
  uint32_t normal_interval_s = 15 * 60;
  uint32_t long_idle_interval_s = 30 * 60;
  uint32_t fast_interval_s = 30;
  uint32_t settling_interval_s = 2 * 60;
  uint32_t low_interval_s = 2 * 60 * 60;
  uint32_t deep_interval_s = 12 * 60 * 60;

  uint64_t long_idle_after_s = 90ULL * 24 * 60 * 60;
  uint32_t fast_mode_for_s = 10 * 60;
  uint32_t settling_mode_for_s = 60 * 60;

  int32_t charger_rise_mv = 150;
  int32_t stable_delta_mv = 25;

  // Chemistry-neutral relative conservation thresholds. These are measured
  // from the highest credible resting voltage observed after charging.
  int32_t low_drop_from_reference_mv = 700;
  int32_t deep_drop_from_reference_mv = 1200;

  // Optional absolute emergency guardrails. Zero disables them. A board
  // profile may set these when the battery chemistry is known locally.
  int32_t low_absolute_mv = 0;
  int32_t deep_absolute_mv = 0;
};

enum class CadenceMode {
  Normal,
  FastActivity,
  Settling,
  LongIdle,
  LowConservation,
  DeepConservation,
};

struct Observation {
  uint64_t monotonic_s = 0;
  int32_t voltage_mv = 0;
  bool ignition_on = false;
};

struct PolicyState {
  bool initialized = false;
  int32_t previous_voltage_mv = 0;
  int32_t reference_voltage_mv = 0;
  uint64_t last_charge_s = 0;
  uint64_t fast_until_s = 0;
  uint64_t settling_until_s = 0;
};

struct PolicyDecision {
  CadenceMode mode = CadenceMode::Normal;
  uint32_t next_interval_s = 15 * 60;
  bool charger_detected = false;
  bool significant_voltage_change = false;
};

PolicyDecision update_policy(const PolicyConfig& config,
                             PolicyState& state,
                             const Observation& observation);

}  // namespace battery_monitor
