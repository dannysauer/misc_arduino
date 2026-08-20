// base.scad — wall-mount bracket: flat plate + post + ball
//
// Follows the RAM-mount pattern: a rectangular plate with rounded ends,
// two screw holes near the ends, and a short tapered post rising from
// the centre carrying the ball. The "T" is the side profile, not the
// plan view.
//
//        ●        ← ball (ball_d)
//        |        ← tapered post (post_clear exposed)
//   ○─────────○   ← plate with two mounting holes
//
// PRINT ORIENTATION: plate flat on the bed, ball pointing up.
//   The ball needs supports where it flares out above the post; PETG
//   supports snap off cleanly. Alternatively print at 0.12 mm layers
//   with a brim and accept a slightly rough underside on the ball —
//   that surface is inside the socket and never seen.
// MATERIAL: PETG. This is the load-bearing part.

include <params.scad>

// Plate: stadium profile (rectangle with semicircular ends)
module base_plate() {
    hull()
        for (sx = [-1, 1])
            translate([sx * (plate_l/2 - plate_w/2), 0, 0])
                cylinder(h=plate_t, d=plate_w);
}

module base() {
    // Post reaches up to where the sphere has narrowed to post_d_top,
    // so the two surfaces meet without a step or an undercut.
    post_top_z = ball_z_base - sqrt(pow(ball_r, 2) - pow(post_d_top/2, 2));

    difference() {
        union() {
            base_plate();

            // ── Tapered post ──────────────────────────────────────
            translate([0, 0, plate_t - 0.01])
                cylinder(h = post_top_z - plate_t + 0.01,
                         d1 = post_d_base, d2 = post_d_top);

            // ── Ball ──────────────────────────────────────────────
            translate([0, 0, ball_z_base])
                sphere(r=ball_r);
        }

        // ── Mounting holes (Spax #8 wafer head) ───────────────────
        // Counterbore recesses the head so it cannot foul the socket
        // when the mount is tilted hard over.
        for (sx = [-1, 1])
            translate([sx * mount_dx, 0, 0]) {
                translate([0, 0, -1])
                    cylinder(h=plate_t + 2, d=mount_d);
                translate([0, 0, plate_t - mount_cb_h])
                    cylinder(h=mount_cb_h + 1, d=mount_cb_d);
            }
    }
}

base();
