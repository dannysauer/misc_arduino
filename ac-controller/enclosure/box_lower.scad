// box_lower.scad — lower half of PCB enclosure
//
// Contains: board cavity (lower portion), ball socket clamp, USB-C cutout,
//           snap-clip features (hold board during assembly), antenna groove,
//           and M3 boss holes for joining to box_upper.
//
// COORDINATE SYSTEM: origin at center of box at the split plane.
//   +X = right (looking from camera side)
//   +Y = USB port end
//   −Y = back/dust-cap end
//   −Z = downward (toward ball)
//
// PRINT ORIENTATION: split face up (no supports needed for main body;
//   the clamp gap bridging is short enough for PETG).
// MATERIAL: PETG

include <params.scad>

// ── Helpers ────────────────────────────────────────────────────

// Nut trap pocket (Z-up, for M4 nut dropped from above)
module nut_trap(af, h, through_h=50) {
    // Hex pocket
    cylinder(h=h, d=af/cos(30), $fn=6);
    // Clearance shaft above for screw
    translate([0, 0, h])
        cylinder(h=through_h, d=clamp_screw_d);
}

// M3 screw boss (post with blind hole for join screw)
module join_boss_lower() {
    difference() {
        cylinder(h=box_h_bot - 0.5, d=join_boss);
        translate([0, 0, -1])
            cylinder(h=box_h_bot + 1, d=join_d);
    }
}

// Cantilever snap clip — projects inward from ±X wall near −Y end.
// The ramp rises in −Y direction; board edge snaps under the notch ledge
// when fully inserted toward +Y.
module snap_clip() {
    // Ramp body (wedge): tall at −Y, tapers to clip_t at +Y
    linear_extrude(clip_l)
        polygon([
            [0,        0       ],
            [clip_t,   0       ],
            [clip_t,   clip_h  ],   // full height at board-entry side
            [0,        clip_h - (clip_h - clip_t) ]  // tapered exit
        ]);
    // Notch ledge — overhangs inward, captures board edge after snap
    translate([clip_t, clip_h - pcb_t - clip_land, 0])
        cube([clip_land, pcb_t, clip_l]);
}

// ── Main lower half ─────────────────────────────────────────────
module box_lower() {
    difference() {
        union() {
            // ── Outer body of lower half ───────────────────────
            translate([-box_w/2, -box_l/2, -box_h_bot])
                cube([box_w, box_l, box_h_bot]);

            // ── Ball socket clamp ──────────────────────────────
            // C-shaped cup below the lower half, centered in XY.
            // Gap (sock_gap wide, along +X side) allows clamp to flex
            // open over ball, then M4 screw closes it.
            translate([0, 0, -box_h_bot]) {
                difference() {
                    // Socket shell (truncated sphere)
                    sphere(r=ball_r + sock_wall);
                    // Inner ball cavity (with clearance)
                    sphere(r=ball_r + cl);
                    // Remove everything above Z = 0 (inside box body)
                    translate([-(ball_r+sock_wall+1), -(ball_r+sock_wall+1), 0])
                        cube([(ball_r+sock_wall+1)*2, (ball_r+sock_wall+1)*2,
                               ball_r+sock_wall+1]);
                    // Keep only the lower sock_depth of the hemisphere
                    translate([-(ball_r+sock_wall+1), -(ball_r+sock_wall+1),
                               -(ball_r+sock_wall+1)])
                        cube([(ball_r+sock_wall+1)*2, (ball_r+sock_wall+1)*2,
                               ball_r+sock_wall+1 - sock_depth]);
                    // Clamp gap — cut a slot in +X half
                    translate([0, -(ball_r+sock_wall+1), -(ball_r+sock_wall+1)])
                        cube([ball_r+sock_wall+1, (ball_r+sock_wall+1)*2,
                              (ball_r+sock_wall+1)*2]);
                }

                // Clamping ear (tab on +X side for M4 screw)
                translate([ball_r+sock_wall, -ear_w/2, -ear_h])
                    cube([ear_w, ear_w, ear_h]);
            }
        } // end union

        // ── Board cavity cutout ────────────────────────────────
        translate([-ci_w/2, -ci_l/2, -ci_h_bot])
            cube([ci_w, ci_l, ci_h_bot]);

        // ── USB-C opening (+Y face) ────────────────────────────
        // Centered on board width; height from PCB bottom surface.
        // usb_z_off measured from PCB bottom = -(ci_h_bot - pcb_t/2 - comp_bot)
        usb_z_center = -(ci_h_bot - comp_bot - pcb_t/2) + usb_z_off;
        translate([-usb_cut_w/2, box_l/2 - 0.1, usb_z_center - usb_cut_h/2])
            cube([usb_cut_w, wall + 1, usb_cut_h]);

        // ── Antenna cable groove (−Z face, +X of socket, toward −Y) ──
        // Routes the u.FL antenna cable from XIAO out toward T bracket.
        translate([ant_x_off - ant_w/2, -box_l/2, -box_h_bot])
            cube([ant_w, box_l, ant_h]);

        // ── M4 clamp screw hole (through clamping ear) ────────
        translate([ball_r + sock_wall + ear_w/2,
                   0,
                   -box_h_bot - ear_h/2]) {
            rotate([0, 90, 0])
                cylinder(h=ear_w + 2, d=clamp_screw_d, center=true);
        }

        // ── M4 nut trap (inner side of ear) ───────────────────
        translate([ball_r + sock_wall,
                   -clamp_nut_af/2,
                   -box_h_bot - ear_h/2 - clamp_nut_h/2])
            cube([clamp_nut_af, clamp_nut_af, clamp_nut_h]);

        // ── M3 join screw through-holes (±Y on ±X outer walls) ─
        for (dy = [-join_y, join_y]) {
            translate([-box_w/2 - 1, dy, -box_h_bot/2])
                rotate([0, 90, 0])
                    cylinder(h=box_w + 2, d=join_d);
        }

        // ── −Y face open (board insertion / dust cap) ─────────
        // Already open: bottom of box at −Y has no end wall.
        // Actually keep end wall; dust cap is press-fit into the −Y opening
        // of the assembled box. Board slides in from −Y end.
        // So remove the inner rear wall only (leave outer wall structure):
        translate([-ci_w/2, -box_l/2 - 0.1, -ci_h_bot])
            cube([ci_w, wall + 0.2, ci_h_bot]);
    }

    // ── Snap clips (added, not subtracted) ────────────────────
    // Positioned on ±X inner walls, near −Y (board entry) end.
    // Board slides in +Y and snaps under the notch ledge.
    for (sx = [-1, 1])
        translate([sx * (ci_w/2 - clip_t),
                   clip_y_pos - clip_l/2,
                   -ci_h_bot + comp_bot])
            mirror([sx < 0 ? 1 : 0, 0, 0])
                snap_clip();

    // ── M3 bosses (inside, near ±X walls, for join screws) ────
    for (dy = [-join_y, join_y])
        for (sx = [-1, 1])
            translate([sx * (ci_w/2 - join_boss/2 - 0.5), dy, -box_h_bot + 0.5])
                join_boss_lower();
}

box_lower();
