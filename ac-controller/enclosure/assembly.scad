// assembly.scad — full assembly preview
//
// Visual check only; do not export this as an STL. The base sits with its
// plate on the Z=0 plane and the box parts are lifted so their socket
// centre lands on the ball.
//
// Run:  openscad assembly.scad
// To study one part, comment out the others.

include <params.scad>
use <base.scad>
use <box_lower.scad>
use <box_upper.scad>
use <socket_cap.scad>

// Tilt of the box on the ball, for checking clearance (0 = straight up).
// The joint is good for roughly ±30° before the post fouls the throat.
tilt = 0;

// ── Wall bracket ────────────────────────────────────────────────
color("SaddleBrown", 0.9)
    base();

// ── Box + socket cap, rotated about the ball centre ─────────────
translate([0, 0, ball_z_base])
    rotate([tilt, 0, 0])
        translate([0, 0, -ball_cz]) {
            color("DodgerBlue", 0.85)   box_lower();
            color("DeepSkyBlue", 0.55)  box_upper();
            color("LightSlateGray", 0.9) socket_cap();
        }
