// assembly.scad — full assembly preview
//
// Use this for visual checking only; do not export as STL.
// Each part is positioned as it would be in real life.
// Run: openscad assembly.scad
// To isolate a part, comment out the others.

include <params.scad>
use <base.scad>
use <box_lower.scad>
use <box_upper.scad>
use <dust_cap.scad>

// Distance from box split plane to ball center
// Ball sits below lower half; box mounts on top of ball.
box_above_ball = box_h_bot + sock_depth - ball_r;

// ── T-base (wall mount) ─────────────────────────────────────
// Shown with stem pointing up (+Z) for a wall-mount perspective.
color("SaddleBrown", 0.9)
    rotate([0, 0, 0])
        base();

// ── Box lower half ──────────────────────────────────────────
color("DodgerBlue", 0.8)
    translate([0, arm_d*0.6 + stem_l, arm_h + box_above_ball])
        box_lower();

// ── Box upper half ──────────────────────────────────────────
color("DeepSkyBlue", 0.7)
    translate([0, arm_d*0.6 + stem_l, arm_h + box_above_ball])
        box_upper();

// ── Dust cap (shown slightly pulled out for visibility) ─────
color("LightGray", 0.85)
    translate([0, arm_d*0.6 + stem_l - box_l/2 - 8,
               arm_h + box_above_ball])
        rotate([90, 0, 0])
            dust_cap();
