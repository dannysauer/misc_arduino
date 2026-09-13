#include "battery_monitor/policy.hpp"

#include <algorithm>
#include <cstdlib>

namespace battery_monitor {
namespace {

bool below_optional_threshold(int32_t voltage_mv, int32_t threshold_mv) {
  return threshold_mv > 0 && voltage_mv <= threshold_mv;
}

}  // namespace

PolicyDecision update_policy(const PolicyConfig& config,
                             PolicyState& state,
                             const Observation& observation) {
  PolicyDecision decision;

  if (!state.initialized) {
    state.initialized = true;
    state.previous_voltage_mv = observation.voltage_mv;
    state.reference_voltage_mv = observation.voltage_mv;
    state.last_charge_s = observation.monotonic_s;
    decision.next_interval_s = config.normal_interval_s;
    return decision;
  }

  const int32_t delta_mv = observation.voltage_mv - state.previous_voltage_mv;
  decision.significant_voltage_change =
      std::abs(delta_mv) >= config.charger_rise_mv;

  // A charger is inferred only while ignition is off. A large rise while the
  // engine is running is alternator activity, not evidence of an external
  // charger being attached during storage.
  const bool new_charge_session =
      !observation.ignition_on &&
      delta_mv >= config.charger_rise_mv &&
      observation.monotonic_s >= state.settling_until_s;
  if (new_charge_session) {
    decision.charger_detected = true;
    state.last_charge_s = observation.monotonic_s;
    state.fast_until_s = observation.monotonic_s + config.fast_mode_for_s;
    state.settling_until_s =
        state.fast_until_s + config.settling_mode_for_s;
  }

  // Once external charging has been observed, allow the resting-voltage
  // reference to move upward. Never lower it merely because the battery has
  // discharged; that would defeat relative low-voltage conservation.
  if (decision.charger_detected ||
      observation.voltage_mv > state.reference_voltage_mv) {
    state.reference_voltage_mv = observation.voltage_mv;
  }

  const int32_t drop_from_reference_mv =
      state.reference_voltage_mv - observation.voltage_mv;
  const bool deep =
      drop_from_reference_mv >= config.deep_drop_from_reference_mv ||
      below_optional_threshold(observation.voltage_mv,
                               config.deep_absolute_mv);
  const bool low =
      drop_from_reference_mv >= config.low_drop_from_reference_mv ||
      below_optional_threshold(observation.voltage_mv,
                               config.low_absolute_mv);

  if (!observation.ignition_on && deep) {
    decision.mode = CadenceMode::DeepConservation;
    decision.next_interval_s = config.deep_interval_s;
  } else if (!observation.ignition_on && low) {
    decision.mode = CadenceMode::LowConservation;
    decision.next_interval_s = config.low_interval_s;
  } else if (observation.monotonic_s < state.fast_until_s) {
    decision.mode = CadenceMode::FastActivity;
    decision.next_interval_s = config.fast_interval_s;
  } else if (observation.monotonic_s < state.settling_until_s &&
             std::abs(delta_mv) > config.stable_delta_mv) {
    decision.mode = CadenceMode::Settling;
    decision.next_interval_s = config.settling_interval_s;
  } else if (!observation.ignition_on &&
             observation.monotonic_s - state.last_charge_s >=
                 config.long_idle_after_s) {
    decision.mode = CadenceMode::LongIdle;
    decision.next_interval_s = config.long_idle_interval_s;
  } else {
    decision.mode = CadenceMode::Normal;
    decision.next_interval_s = config.normal_interval_s;
  }

  state.previous_voltage_mv = observation.voltage_mv;
  return decision;
}

}  // namespace battery_monitor
