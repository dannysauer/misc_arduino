// box_upper.scad — upper half (lid) of PCB enclosure
//
// Contains: board cavity (upper portion, camera space), camera hole,
//           upper half of ball socket, M3 through-holes for joining,
//           and alignment lip that registers on lower half split face.
//
// COORDINATE SYSTEM: same as box_lower — origin at split plane center.
//   +Z = upward (camera direction)
//
// PRINT ORIENTATION: split face down (camera-hole face up).
//   The camera hole bridging is short; no supports needed.
// MATERIAL: PETG

include <params.scad>

// M3 clearance hole with counter-bore for screw head
module join_hole() {
    // Through-hole
    cylinder(h=box_h_top + 2, d=join_d);
    // Counter-bore for M3 cap head (5.5 mm OD, 3 mm deep) — optional
    translate([0, 0, box_h_top - 3])
        cylinder(h=4, d=5.8);
}

module box_upper() {
    difference() {
        union() {
            // ── Outer body of upper half ───────────────────────
            translate([-box_w/2, -box_l/2, 0])
                cube([box_w, box_l, box_h_top]);

            // ── Upper ball socket ──────────────────────────────
            // Mirror of lower socket: fills gap between lower clamp
            // and the bottom of the upper half at Z = 0.
            // The upper socket is a shallow dish that seats over the ball.
            difference() {
                sphere(r=ball_r + sock_wall);
                sphere(r=ball_r + cl);
                // Keep only the band from Z=0 down to -(sock_depth - box_h_bot socket contribution)
                // Upper half socket is shallower — keeps ball aligned laterally.
                translate([-(ball_r+sock_wall+1), -(ball_r+sock_wall+1),
                           -(ball_r+sock_wall)/2])
                    cube([(ball_r+sock_wall+1)*2, (ball_r+sock_wall+1)*2,
                           (ball_r+sock_wall)/2 + 0.01]);
                translate([-(ball_r+sock_wall+1), -(ball_r+sock_wall+1), 0])
                    cube([(ball_r+sock_wall+1)*2, (ball_r+sock_wall+1)*2,
                           ball_r+sock_wall+1]);
                // Mirror the clamp gap (+X side)
                translate([0, -(ball_r+sock_wall+1), -(ball_r+sock_wall+1)])
                    cube([ball_r+sock_wall+1, (ball_r+sock_wall+1)*2,
                          (ball_r+sock_wall+1)*2]);
            }

            // ── Alignment lip ─────────────────────────────────
            // 1 mm lip around the inner perimeter of the split face
            // registers the upper half on the lower half precisely.
            difference() {
                translate([-ci_w/2 - 0.8, -ci_l/2 - 0.8, -1.0])
                    cube([ci_w + 1.6, ci_l + 1.6, 1.0]);
                translate([-ci_w/2 + 0.8, -ci_l/2 + 0.8, -1.1])
                    cube([ci_w - 1.6, ci_l - 1.6, 1.2]);
            }
        }

        // ── Board cavity cutout (upper portion) ───────────────
        translate([-ci_w/2, -ci_l/2, 0])
            cube([ci_w, ci_l, ci_h_top]);

        // ── Camera hole (top face, +Z) ─────────────────────────
        translate([cam_hole_xoff, cam_hole_yoff, box_h_top - 0.1])
            cylinder(h=wall + 0.2, d=cam_hole_d);
        // Countersunk funnel on outside for easier camera alignment
        translate([cam_hole_xoff, cam_hole_yoff, box_h_top - 0.5])
            cylinder(h=1.0, d1=cam_hole_d, d2=cam_hole_d + 2.0);

        // ── USB-C opening continues into upper half (+Y face) ──
        usb_z_center = -(ci_h_bot - comp_bot - pcb_t/2) + usb_z_off;
        translate([-usb_cut_w/2, box_l/2 - 0.1, usb_z_center - usb_cut_h/2])
            cube([usb_cut_w, wall + 1, usb_cut_h]);

        // ── M3 join through-holes (±Y positions on ±X walls) ──
        for (dy = [-join_y, join_y])
            translate([-box_w/2 - 1, dy, box_h_top/2])
                rotate([0, 90, 0])
                    join_hole();

        // ── −Y face: open inner cavity (dust cap end) ─────────
        translate([-ci_w/2, -box_l/2 - 0.1, 0])
            cube([ci_w, wall + 0.2, ci_h_top]);
    }
}

box_upper();
