// box_lower.scad — lower half of the enclosure + upper half of the ball socket
//
// Contains: board cavity with support pads, accessory bay, four lid screw
//           bosses, the lower part of the USB-C opening, and the integral
//           socket cup the ball seats into.
//
// The socket is a two-piece clamp: this cup takes the top half of the ball,
// socket_cap.scad takes the bottom half, and two M3 screws pull them
// together. Nothing has to flex — with the cap off, the ball drops in.
//
// PRINT ORIENTATION: split face UP (socket cup down on the bed).
//   No supports. The dome at the top of the ball cavity is a ~10 mm
//   bridge, which PETG handles. Use a brim: bed contact is only the ring
//   around the socket mouth plus the two clamp ears.
// MATERIAL: PETG

include <params.scad>

// Side-loaded hex nut trap: pocket on the screw axis plus a slot out to
// the ear's outer face, so the nut slides in sideways and stays captive.
// open_dir = +1 or −1, the X direction the slot exits towards.
module nut_trap_side(open_dir) {
    cylinder(h=sock_nut_h, d=sock_nut_af/cos(30), $fn=6);
    translate([open_dir > 0 ? 0 : -(sock_ear_w/2 + 1), -sock_nut_af/2, 0])
        cube([sock_ear_w/2 + 1, sock_nut_af, sock_nut_h]);
}

module box_lower() {
    difference() {
        union() {
            // ── Shell of the lower half ────────────────────────────
            translate([-box_w/2, -box_l/2, -box_h_bot])
                cube([box_w, box_l, box_h_bot]);

            // ── Socket cup (upper half of the ball joint) ──────────
            // Flared at 45° where it meets the box floor: stronger, and
            // still prints without support.
            translate([0, 0, ball_cz]) {
                cylinder(h = -ball_cz - box_h_bot, d = sock_od);
                translate([0, 0, -ball_cz - box_h_bot - 3])
                    cylinder(h=3, d1=sock_od, d2=sock_od + 6);

                // Clamp ears
                for (sx = [-1, 1])
                    translate([sx * sock_screw_dx - sock_ear_w/2,
                               -sock_ear_l/2, 0])
                        cube([sock_ear_w, sock_ear_l, sock_ear_h]);
            }
        }

        // ── Board cavity ──────────────────────────────────────────
        translate([-ci_w/2, -ci_l/2, -ci_h_bot])
            cube([ci_w, ci_l, ci_h_bot + 1]);

        // ── Ball cavity ───────────────────────────────────────────
        translate([0, 0, ball_cz])
            sphere(r = ball_r + ball_cl);

        // ── USB-C opening (+Y wall, portion below the split) ──────
        translate([board_cx - (usb_w + 1.5)/2,
                   ci_l/2 - 0.1,
                   -board_drop - 0.6])
            cube([usb_w + 1.5, wall + 1, usb_h + 2.4]);

        // ── Clamp screw holes and nut traps ───────────────────────
        for (sx = [-1, 1])
            translate([sx * sock_screw_dx, 0, ball_cz]) {
                translate([0, 0, -1])
                    cylinder(h=sock_ear_h + 2, d=sock_screw_d);
                translate([0, 0, (sock_ear_h - sock_nut_h)/2])
                    nut_trap_side(sx);
            }
    }

    // ── Board support pads ────────────────────────────────────────
    // The stacked board rests on these, holding its underside clear of
    // the floor so the components below the PCB have room.
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([board_cx + sx * (board_w/2 - 2) - 2,
                       board_cy + sy * (board_l/2 - 2) - 2,
                       -ci_h_bot])
                cube([4, 4, pad_h]);

    // ── Lid screw bosses ──────────────────────────────────────────
    // They stop short of the split plane so they clear the lid's
    // alignment lip; the screw simply spans the gap.
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx * join_x, sy * join_y, -ci_h_bot])
                difference() {
                    cylinder(h=ci_h_bot - 1.5, d=join_boss_d);
                    translate([0, 0, -0.1])
                        cylinder(h=ci_h_bot, d=join_pilot);
                }
}

box_lower();
