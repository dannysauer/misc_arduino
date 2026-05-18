// dust_cap.scad — press-fit flanged dust cap for the −Y (back) opening
//
// DESCRIPTION:
//   A flanged plug that covers the board-insertion opening of the assembled
//   box. The plug body has a slight interference fit with the inner cavity
//   walls; the flange prevents it from being pushed in too far.
//   Remove to access the USB-C port for programming without disassembling.
//
// PRINT ORIENTATION: flange face down (flat on bed). No supports needed.
// MATERIAL: PETG (flex allows repeated insertion/removal without cracking)
// FIT NOTE: if plug is too tight, sand the plug body or increase cap_interf
//           in params.scad (more negative = looser fit).

include <params.scad>

module dust_cap() {
    union() {
        // ── Flange (outer plate, sits against box −Y face) ─────
        translate([-cap_flange_w/2, 0, 0])
            cube([cap_flange_w, cap_flange_t, cap_flange_l]);

        // ── Press-fit plug (inserted into box inner cavity) ────
        // Dimensions are slightly oversized vs cavity for interference fit.
        // cap_interf is subtracted from each side in params (net: tighter).
        translate([-(cap_plug_w)/2, cap_flange_t, -(cap_plug_l)/2 + cap_flange_l/2])
            cube([cap_plug_w, cap_plug_t, cap_plug_l]);

        // ── Grip tab (pull tab on outside of flange) ───────────
        // Small tab on the outside makes the cap easy to remove by hand.
        translate([-6, -4, cap_flange_l/2 - 3])
            cube([12, 4, 6]);
    }
}

// Centered at origin, flange face at Y=0
dust_cap();
