// socket_cap.scad — clamp half of the ball socket
//
// Bolts to the outer face of the cover with two M3 screws, trapping the
// ball between the cover's recess and this seat. Loosen to aim, tighten
// to lock, remove entirely to take the mount off the ball.
//
// The seat is a spherical band that ends at a throat; below the throat a
// cone flares away so the base's post can tilt without fouling.
//
// PRINT ORIENTATION: wide (flared) face DOWN on the bed. No supports —
//   the flare narrows as it rises and the seat above it is shallower
//   still; only the two screw counterbores bridge.
// MATERIAL: PETG
//
// NOTE: modelled where it sits in the assembly, ~31 mm along +Z from the
//   box's aperture wall. Slicers drop it onto the bed on import.

include <params.scad>

// Seat runs from the cap's top face down to the throat
sock_seat_h = sqrt(pow(ball_r + ball_cl, 2) - pow(sock_throat_d/2, 2))
              - sock_gap;
cap_h  = sock_seat_h + sock_flare_h;
cap_z0 = ball_cz + sock_gap;   // face nearest the cover
cap_z1 = cap_z0 + cap_h;       // outer face

module socket_cap() {
    difference() {
        // ── Body: stadium shape spanning both screws ──────────────
        hull() {
            translate([0, 0, cap_z0])
                cylinder(h=cap_h, d=sock_od);
            for (sy = [-1, 1])
                translate([0, sy * sock_screw_dy, cap_z0])
                    cylinder(h=cap_h, d=9);
        }

        // ── Spherical seat ────────────────────────────────────────
        translate([0, 0, ball_cz])
            sphere(r = ball_r + ball_cl);

        // ── Clearance flare below the throat ──────────────────────
        translate([0, 0, cap_z1 - sock_flare_h])
            cylinder(h = sock_flare_h + 0.01,
                     d1 = sock_throat_d, d2 = sock_flare_d);

        // ── Screw holes, counterbored from the outer face ─────────
        for (sy = [-1, 1])
            translate([0, sy * sock_screw_dy, cap_z0 - 1]) {
                cylinder(h = cap_h + 2, d = sock_screw_d);
                translate([0, 0, cap_h + 1 - sock_cb_h])
                    cylinder(h = sock_cb_h + 1, d = sock_cb_d);
            }
    }
}

socket_cap();
