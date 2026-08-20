// box.scad — open-backed shell that holds the board and the optics
//
// The closed face (the "aperture wall", at −Z) points at the AC unit and
// carries the camera, IR emitter and IR receiver holes. The board sits on
// seats part-way up four standoffs with its camera side facing that wall;
// the cover plate bolts into the standoffs and pinches the board down.
//
// The XIAO has no mounting holes, so the screws run beside the board
// rather than through it: each standoff is a full-height post outside the
// board outline with a seat stepping inboard under the board's corner.
//
// PRINT ORIENTATION: aperture wall DOWN on the bed, cavity opening up.
//   No supports. The optical holes print against the bed, which gives the
//   cleanest edges on the face that matters.
// MATERIAL: PETG

include <params.scad>

// One standoff: post + inboard seat. sx, sy ∈ {−1, +1}.
module standoff(sx, sy) {
    // Full-height post, outside the board outline, takes the cover screw
    translate([sx * stand_x, sy * stand_y, 0])
        difference() {
            cylinder(h=stand_top, d=stand_d);
            translate([0, 0, -0.1])
                cylinder(h=stand_top + 0.2, d=stand_pilot);
        }

    // Seat: runs from under the board's corner out to the post, so the
    // two merge into one body. Its top face is where the board lands.
    seat_y0 = (sy > 0) ? (board_edge - seat_over) : -stand_y;
    translate([sx * stand_x - seat_w/2, seat_y0, 0])
        cube([seat_w, stand_y - board_edge + seat_over, seat_h]);
}

module box() {
    difference() {
        // ── Shell ─────────────────────────────────────────────────
        translate([-box_w/2, -box_l/2, -wall])
            cube([box_w, box_l, wall + stand_top]);

        // ── Cavity ────────────────────────────────────────────────
        translate([-ci_w/2, -ci_l/2, 0])
            cube([ci_w, ci_l, stand_top + 1]);

        // ── Camera aperture ───────────────────────────────────────
        translate([cam_hole_x, cam_hole_y, -wall - 0.1])
            cylinder(h = wall + 0.2, d = cam_hole_d);
        // Inner relief so the aperture does not vignette the lens
        translate([cam_hole_x, cam_hole_y, -cam_relief_h])
            cylinder(h = cam_relief_h + 0.1, d = cam_relief_d);

        // ── IR emitter hole ───────────────────────────────────────
        // Pushed in from inside, dome out; glue it in place.
        translate([ir_led_x, ir_led_y, -wall - 0.1])
            cylinder(h = wall + 0.2, d = ir_led_d + 2*ir_led_cl);

        // ── IR receiver window ────────────────────────────────────
        // Window flush with the outer face, body sitting in the gap.
        translate([vs_x - (vs_w + 2*vs_cl)/2,
                   vs_y - (vs_h + 2*vs_cl)/2,
                   -wall - 0.1])
            cube([vs_w + 2*vs_cl, vs_h + 2*vs_cl, wall + 0.2]);

        // ── USB-C notch (+Y wall) ─────────────────────────────────
        // Open to the rim, so the cover plate forms its ceiling: no
        // bridging, and the plug's shell reaches the recessed connector.
        translate([-usb_cut_w/2, box_l/2 - wall - 0.1, board_top - 1.0])
            cube([usb_cut_w, wall + 0.2, wire_gap + 1.2]);
        // Flared mouth so a chunky plug nose can seat against the wall
        translate([0, box_l/2 + 0.1, board_top - 1.0 + (wire_gap + 1.2)/2])
            rotate([90, 0, 0])
                linear_extrude(height = usb_cut_ch, scale = 0.72)
                    square([usb_cut_w + 2*usb_cut_ch,
                            wire_gap + 1.2 + 2*usb_cut_ch], center=true);
    }

    // ── Standoffs (added after the cavity is cut) ─────────────────
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            standoff(sx, sy);
}

box();
