// cover.scad — flat back plate carrying the ball socket
//
// Closes the open side of the box, bolts into the four standoffs, and
// pinches the board between its pads and the standoff seats. The ball
// socket is a recess in the plate's thickness rather than a boss standing
// proud of it, which keeps the outer face flat.
//
// PRINT ORIENTATION: outer face (socket side) DOWN on the bed.
//   No supports. Everything on the inner face — pads, lip, nut pockets —
//   points up. The socket cavity narrows as it rises, so it self-supports
//   like a dome; only its small apex and the screw counterbores bridge.
// MATERIAL: PETG

include <params.scad>

module cover() {
    difference() {
        union() {
            // ── Plate ─────────────────────────────────────────────
            translate([-cover_w/2, -cover_l/2, cover_z0])
                cube([cover_w, cover_l, cover_t]);

            // ── Board pads ────────────────────────────────────────
            // Directly opposite the standoff seats. They stand proud by
            // the wiring clearance plus a little interference, so bolting
            // the cover down squeezes the board onto the seats.
            for (sx = [-1, 1])
                for (sy = [-1, 1])
                    translate([sx * stand_x - pad_w/2,
                               sy * pad_y - pad_l/2,
                               cover_z0 - (wire_gap + pinch)])
                        cube([pad_w, pad_l, wire_gap + pinch]);

            // ── Registration lip (±X walls only) ──────────────────
            // Short segments clear of the standoffs; they drop into the
            // cavity and locate the plate while the screws go in.
            for (sx = [-1, 1])
                translate([sx * (ci_w/2 - lip_cl - lip_t), -lip_y,
                           cover_z0 - lip_h])
                    cube([lip_t, 2*lip_y, lip_h]);
        }

        // ── Ball socket ───────────────────────────────────────────
        // Centred on the outer face, so the plate holds exactly the
        // upper hemisphere and sock_roof of material above it.
        translate([0, 0, ball_cz])
            sphere(r = ball_r + ball_cl);

        // ── Cover screws ──────────────────────────────────────────
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx * stand_x, sy * stand_y, cover_z0 - 1]) {
                    cylinder(h = cover_t + 2, d = cover_screw_d);
                    translate([0, 0, cover_t + 1 - cover_cb_h])
                        cylinder(h = cover_cb_h + 1, d = cover_cb_d);
                }

        // ── Clamp screws + captive nuts ───────────────────────────
        // The nut presses into a pocket on the inner face; the screw
        // comes up from under the cap and pulls it against the ball.
        for (sy = [-1, 1])
            translate([0, sy * sock_screw_dy, cover_z0 - 0.1]) {
                cylinder(h = cover_t + 0.2, d = sock_screw_d);
                cylinder(h = sock_nut_h + 0.1, d = sock_nut_af/cos(30), $fn=6);
            }
    }
}

cover();
