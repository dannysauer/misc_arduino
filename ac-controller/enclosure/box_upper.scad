// box_upper.scad — lid: camera aperture, IR emitter hole, IR receiver slot
//
// Contains: camera aperture with an inner relief, the IR LED hole in the
//           accessory bay, the VS1838B slot in the bay's side wall, the
//           upper part of the USB-C opening, an alignment lip, four screw
//           columns, and pads that press the board onto the lower half's
//           support pads.
//
// The lid carries NO socket geometry — the ball joint lives entirely on
// box_lower plus socket_cap.
//
// PRINT ORIENTATION: top face DOWN on the bed (cavity opening upwards).
//   No supports: the aperture, LED hole and lip all print cleanly, and
//   the camera face gets the best surface finish.
// MATERIAL: PETG

include <params.scad>

module box_upper() {
    difference() {
        union() {
            // ── Shell of the lid ──────────────────────────────────
            translate([-box_w/2, -box_l/2, 0])
                cube([box_w, box_l, box_h_top]);

            // ── Alignment lip ─────────────────────────────────────
            // Drops into the lower half's cavity and locates the lid.
            difference() {
                translate([-(ci_w/2 - lip_cl), -(ci_l/2 - lip_cl), -lip_h])
                    cube([ci_w - 2*lip_cl, ci_l - 2*lip_cl, lip_h]);
                translate([-(ci_w/2 - lip_cl - lip_t),
                           -(ci_l/2 - lip_cl - lip_t), -lip_h - 0.1])
                    cube([ci_w - 2*(lip_cl + lip_t),
                          ci_l - 2*(lip_cl + lip_t), lip_h + 0.2]);
            }

            // ── Screw columns ─────────────────────────────────────
            // Carry the screw from the lid's top face down to just above
            // the bosses in the lower half.
            for (sx = [-1, 1])
                for (sy = [-1, 1])
                    translate([sx * join_x, sy * join_y, -lip_h])
                        cylinder(h = ci_h_top + lip_h, d = join_boss_d);

            // ── Board press pads ──────────────────────────────────
            // Directly above the support pads in the lower half, so the
            // board is clamped at its four corners when the lid is bolted
            // down.
            for (sx = [-1, 1])
                for (sy = [-1, 1])
                    translate([board_cx + sx * (board_w/2 - 2) - 2,
                               board_cy + sy * (board_l/2 - 2) - 2,
                               -board_drop])
                        cube([4, 4, board_drop]);
        }

        // ── Lid cavity ────────────────────────────────────────────
        translate([-ci_w/2, -ci_l/2, -0.1])
            cube([ci_w, ci_l, ci_h_top + 0.1]);

        // ── Camera aperture ───────────────────────────────────────
        translate([cam_hole_x, cam_hole_y, ci_h_top - 0.1])
            cylinder(h = wall + 0.2, d = cam_hole_d);
        // Inner relief: thins the wall at the lens so the aperture does
        // not vignette the OV2640's field of view.
        translate([cam_hole_x, cam_hole_y, ci_h_top - 0.1])
            cylinder(h = cam_relief_h + 0.1, d = cam_relief_d);

        // ── IR emitter hole ───────────────────────────────────────
        // The LED is pushed in from INSIDE, dome first. The flange at the
        // base of the dome is wider than the hole and seats against the
        // inner face of the top plate, so the LED cannot fall out.
        translate([ir_led_x, ir_led_y, ci_h_top - 0.1])
            cylinder(h = wall + 0.2, d = ir_led_d + 2*ir_led_cl);

        // ── VS1838B receiver slot ─────────────────────────────────
        // Pushed in from outside; the window sits flush with the wall and
        // ~0.5 mm of the body protrudes into the bay.
        vs_sw = vs_w + 2*vs_cl;
        vs_sh = vs_h + 2*vs_cl;
        vs_x0 = (vs_side > 0) ? (ci_w/2 - 0.1) : (-box_w/2 - 0.1);
        translate([vs_x0, vs_y - vs_sw/2, vs_z - vs_sh/2])
            cube([wall + 0.2, vs_sw, vs_sh]);

        // ── USB-C opening (+Y wall, portion above the split) ──────
        translate([board_cx - (usb_w + 1.5)/2, ci_l/2 - 0.1, -1])
            cube([usb_w + 1.5, wall + 1, usb_h + 1.6]);

        // ── Screw holes + counterbores ────────────────────────────
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx * join_x, sy * join_y, -lip_h - 1]) {
                    cylinder(h = box_h_top + lip_h + 2, d = join_free);
                    translate([0, 0, box_h_top + lip_h + 1 - join_cb_h])
                        cylinder(h = join_cb_h + 1, d = join_cb_d);
                }
    }
}

box_upper();
