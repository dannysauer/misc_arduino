#include "battery_monitor/policy.hpp"

#include <cassert>
#include <iostream>

using battery_monitor::CadenceMode;
using battery_monitor::Observation;
using battery_monitor::PolicyConfig;
using battery_monitor::PolicyState;
using battery_monitor::update_policy;

static constexpr uint64_t day = 24ULL * 60 * 60;

int main() {
  PolicyConfig cfg;
  PolicyState state;

  auto d = update_policy(cfg, state, Observation{0, 12600, false});
  assert(d.mode == CadenceMode::Normal);
  assert(d.next_interval_s == 900);

  d = update_policy(cfg, state, Observation{900, 12610, false});
  assert(d.mode == CadenceMode::Normal);
  assert(!d.charger_detected);

  // External charger attachment: 390 mV rise with ignition off.
  d = update_policy(cfg, state, Observation{1800, 13000, false});
  assert(d.charger_detected);
  assert(d.mode == CadenceMode::FastActivity);
  assert(d.next_interval_s == 30);

  // Voltage continues climbing, then transitions to settling cadence.
  d = update_policy(cfg, state, Observation{1800 + 11 * 60, 13500, false});
  assert(d.mode == CadenceMode::Settling);
  assert(d.next_interval_s == 120);

  // Stable charger voltage no longer needs medium-rate samples forever.
  d = update_policy(cfg, state, Observation{1800 + 12 * 60, 13510, false});
  assert(d.mode == CadenceMode::Normal);

  // A 90-day lack of charging backs off normal monitoring.
  d = update_policy(cfg, state, Observation{1800 + 91 * day, 13490, false});
  assert(d.mode == CadenceMode::LongIdle);
  assert(d.next_interval_s == 1800);

  // Relative decline from the observed charged reference enters conservation.
  d = update_policy(cfg, state, Observation{1800 + 92 * day, 12750, false});
  assert(d.mode == CadenceMode::LowConservation);
  assert(d.next_interval_s == 7200);

  d = update_policy(cfg, state, Observation{1800 + 93 * day, 12200, false});
  assert(d.mode == CadenceMode::DeepConservation);
  assert(d.next_interval_s == 43200);

  // Alternator rise must not reset the external-charger timer.
  PolicyState vehicle_state;
  update_policy(cfg, vehicle_state, Observation{0, 12400, false});
  d = update_policy(cfg, vehicle_state, Observation{900, 14200, true});
  assert(!d.charger_detected);

  std::cout << "policy tests passed\n";
  return 0;
}
