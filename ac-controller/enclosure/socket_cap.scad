// socket_cap.scad — lower half of the ball clamp
//
// Bolts up against the cup on box_lower with two M3 screws, trapping the
// ball between them. Loosen the screws and the mount swivels; tighten and
// it locks. Take the screws out and the ball lifts straight out — no
// flexing, no snap fit.
//
// The seat is a spherical cup that ends at a throat; below the throat a
// cone flares away so the post on the base can tilt without fouling.
// Widening sock_throat_d buys tilt range at the cost of grip.
//
// PRINT ORIENTATION: flat (bottom) face down on the bed. No supports —
//   the flare below the throat is a ~47° overhang and the seat above it
//   is shallower still.
// MATERIAL: PETG
//
// NOTE: the part is modelled in box coordinates (it sits ~27 mm below the
//   origin, where it lives in the assembly). Slicers drop it onto the bed
//   automatically on import.

include <params.scad>

// Depth of the spherical seat: from the cap's top face down to the throat
seat_h = sqrt(pow(ball_r + ball_cl, 2) - pow(sock_throat_d/2, 2)) - sock_gap;
cap_h  = seat_h + sock_flare_h;
cap_top_z = ball_cz - sock_gap;

module socket_cap() {
    difference() {
        union() {
            // ── Body ──────────────────────────────────────────────
            translate([0, 0, cap_top_z - cap_h])
                cylinder(h=cap_h, d=sock_od);

            // ── Clamp ears (match the ears on box_lower) ──────────
            for (sx = [-1, 1])
                translate([sx * sock_screw_dx - sock_ear_w/2,
                           -sock_ear_l/2,
                           cap_top_z - cap_h])
                    cube([sock_ear_w, sock_ear_l, cap_h]);
        }

        // ── Spherical seat ────────────────────────────────────────
        translate([0, 0, ball_cz])
            sphere(r = ball_r + ball_cl);

        // ── Clearance flare below the throat ──────────────────────
        translate([0, 0, cap_top_z - cap_h - 0.01])
            cylinder(h = sock_flare_h + 0.01,
                     d1 = sock_flare_d, d2 = sock_throat_d);

        // ── Screw holes, counterbored from below for the heads ────
        for (sx = [-1, 1])
            translate([sx * sock_screw_dx, 0, cap_top_z - cap_h - 1]) {
                cylinder(h = cap_h + 2, d = sock_screw_d);
                cylinder(h = 3 + 1, d = 6.4);
            }
    }
}

socket_cap();
