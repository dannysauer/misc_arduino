// base.scad — T-shaped wall-mount bracket with ball
//
// PRINT ORIENTATION: flat face down (the face that mounts against the wall).
//   The ball will require support material; supports detach cleanly in PETG.
// MOUNTING: two Spax #8 wafer-head cabinet screws through the crossbar.
//   The wafer head sits flat on the bracket surface — no countersink needed.
// BALL: 20 mm diameter, compatible with the socket in box_lower.scad.

include <params.scad>

// Full T-bracket with ball, printed flat (wall-face down in slicer)
module base() {
    difference() {
        union() {
            // ── Crossbar ──────────────────────────────────────────
            // Stadium profile (rounded ends) for strength and aesthetics
            hull() {
                for (dx = [-(arm_w/2 - arm_d/2),  arm_w/2 - arm_d/2])
                    translate([dx, 0, 0])
                        cylinder(h=arm_h, d=arm_d);
            }

            // ── Stem ──────────────────────────────────────────────
            // Centered on crossbar, extends in +Y toward ball
            hull() {
                // Blends smoothly into crossbar
                translate([-stem_w/2, 0, 0])
                    cube([stem_w, arm_d*0.6, stem_h]);
                // End of stem (circular for blend into ball)
                translate([0, arm_d*0.6 + stem_l - stem_w/2, stem_h/2])
                    cylinder(h=stem_h, d=stem_w, center=true);
            }

            // ── Ball ──────────────────────────────────────────────
            // Center of ball at top of stem to minimize overhang at base.
            // Upper hemisphere overhangs and needs support in slicer.
            translate([0, arm_d*0.6 + stem_l, arm_h])
                sphere(r=ball_r);
        }

        // ── Mounting holes (Spax #8 wafer head) ──────────────────
        // Through-holes only; wafer head is flat — no countersink.
        for (dx = [-mount_dx, mount_dx])
            translate([dx, arm_d/2, -1])
                cylinder(h=arm_h + 2, d=mount_d);
    }
}

base();
