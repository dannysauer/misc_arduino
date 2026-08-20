// assembly.scad — full assembly preview
//
// Visual check only; do not export this as an STL.
// Set show_board = true to drop a mock-up of the board, camera and USB
// connector into place and check the fit.
//
// Run:  openscad assembly.scad

include <params.scad>
use <base.scad>
use <box.scad>
use <cover.scad>
use <socket_cap.scad>

show_board = true;
tilt = 0;      // degrees of tilt on the ball; good for about ±30°

// ── Box, cover and clamp ────────────────────────────────────────
color("DodgerBlue",  0.85) box();
color("DeepSkyBlue", 0.60) cover();
color("LightSlateGray", 0.9) socket_cap();

// ── Board mock-up ───────────────────────────────────────────────
if (show_board) {
    color("ForestGreen", 0.8) {
        // stacked main PCB + Sense expansion board
        translate([-board_w/2, -board_l/2, seat_h])
            cube([board_w, board_l, stack_h]);
    }
    // camera module, poking down into the gap towards the aperture
    color("DimGray", 0.9)
        translate([cam_hole_x - 4.5, cam_hole_y - 4.5, seat_h - cam_h])
            cube([9, 9, cam_h]);
    // USB-C receptacle on the wiring side, at the +Y edge
    color("Silver", 0.9)
        translate([-4.4, board_l/2 - 7, board_top])
            cube([8.8, 7.6, usb_h]);
}

// ── Base, rotated so its ball sits in the socket ────────────────
color("SaddleBrown", 0.9)
    translate([0, 0, ball_cz])
        rotate([tilt, 0, 0])
            translate([0, 0, ball_z_base])
                rotate([180, 0, 0])
                    base();
