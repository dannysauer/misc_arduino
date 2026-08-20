// params.scad — shared parameters for the XIAO ESP32S3 Sense camera mount
// All dimensions in millimetres. Include this file in every part.
// See specs.md for rationale, print settings and modification guidance.
//
// ── ARRANGEMENT ─────────────────────────────────────────────────
//   The box is an open-backed shell. Its closed face ("aperture wall")
//   points at the AC unit and carries the camera, IR emitter and IR
//   receiver holes. The board goes in with its camera side facing that
//   wall, so the lens and the IR parts all look out of the same face and
//   every solder joint stays inside. The cover is a flat plate that
//   closes the open side, carries the ball socket, and pinches the board
//   against seats on the standoffs.
//
//   The only cable leaving the box is USB-C.
//
// ── COORDINATE SYSTEM (box, cover, socket_cap) ──────────────────
//   z = 0   inner face of the aperture wall
//   +z      into the box, towards the cover and the ball
//   +y      USB-C end
//   The camera therefore looks along −z.
//
//        −z  ← camera / IR emitter / IR receiver look this way
//   ┌──────────────────┐  z = −wall   aperture wall (outer face)
//   │ ▓ camera  ▓ LED  │  z = 0       aperture wall (inner face)
//   │      gap         │              IR parts live in here
//   │ ┌──────────────┐ │  z = seat_h  board, camera side
//   │ │    board     │ │
//   │ └──────────────┘ │  z = board_top
//   │   wiring space   │
//   ├──────────────────┤  z = stand_top   cover plate, inner face
//   │      cover       │
//   └────────┬─────────┘  z = ball_cz     cover plate, outer face
//         ( ball )                        socket cavity is inside the plate
//        socket_cap

// ── BOARD: Seeed Studio XIAO ESP32S3 Sense ─────────────────────
// https://wiki.seeedstudio.com/xiao_esp32s3_getting_started/
// Main PCB plus the Sense expansion board, treated as one block.
// The camera is on the expansion-board side; the USB-C receptacle and
// the ESP32 module are on the opposite (main PCB) side.
board_w  = 21.0;   // PCB width  (X)
board_l  = 17.5;   // PCB length (Y)
stack_h  =  6.0;   // expansion-board outer face → main-PCB top face
cam_h    =  9.0;   // camera lens tip above the expansion-board face
cam_gap  =  0.4;   // lens tip → inner face of the aperture wall
cl       =  0.35;  // per-side clearance around the board

// USB-C receptacle: sits on the main-PCB top face, centred on the +Y edge
usb_h    =  3.2;   // connector height above the PCB
usb_cut_w = 11.0;  // notch width — passes the plug's metal shell
usb_cut_ch = 2.0;  // chamfer on the outside of the notch, for the plug nose

// ── Z LAYOUT ───────────────────────────────────────────────────
wall      = 2.5;
seat_h    = cam_h + cam_gap;      //  9.4  board's camera-side face
board_top = seat_h + stack_h;     // 15.4  board's wiring-side face
wire_gap  = 4.0;                  // clearance over the wiring side; must
                                  // exceed usb_h so the connector clears
stand_top = board_top + wire_gap; // 19.4  box rim = cover's inner face
pinch     = 0.15;                 // cover pad interference onto the board

// ── STANDOFFS ──────────────────────────────────────────────────
// The XIAO has no mounting holes, so the screws pass BESIDE the board,
// not through it. Each standoff is a full-height post outside the board
// outline plus a seat that steps inboard under the board's corner.
stand_d     = 5.5;    // post diameter
stand_pilot = 2.5;    // pilot hole — M3 self-taps into PETG
stand_x     = 7.7;    // ± from centre
board_edge  = board_l/2 + cl;                  // 9.1
stand_y     = board_edge + stand_d/2 + 0.35;   // 12.2
seat_w      = 5.0;    // seat width (X)
seat_over   = 2.5;    // how far the seat reaches under the board (Y)

// ── CAVITY AND SHELL ───────────────────────────────────────────
ci_w  = board_w + 2*cl;                  // 21.7
ci_l  = 2 * (stand_y + stand_d/2 + 0.4); // 30.2 — sized by the standoffs
box_w = ci_w + 2*wall;                   // 26.7
box_l = ci_l + 2*wall;                   // 35.2

// ── APERTURE WALL FEATURES ─────────────────────────────────────
// All three optical parts look out of this one face. They sit in the gap
// between the wall and the board, so they can be placed anywhere on the
// wall that clears the standoffs — the ends are the roomiest spots.
cam_hole_d   =  9.0;   // aperture; OV2640 lens barrel ≈ 7 mm
cam_relief_d = 12.0;   // inner counterbore thins the wall at the lens
cam_relief_h =  1.2;
cam_hole_x   =  0;     // camera assumed centred on the board
cam_hole_y   =  0;

// IR emitter: through-hole LED, glued in. 5.0 = T-5, 3.0 = T-1.
ir_led_d  =  5.0;
ir_led_cl =  0.2;
ir_led_x  =  0;
ir_led_y  = -11.5;     // far end, clear of the standoffs

// IR receiver: VS1838B, window flush with the wall, body inside the gap
vs_w  = 5.8;
vs_h  = 7.4;
vs_d  = 3.0;
vs_cl = 0.3;
vs_x  =  0;
vs_y  = 11.0;          // USB end, clear of the standoffs and the wall

// ── COVER PLATE ────────────────────────────────────────────────
// Thick enough to hold the ball's upper hemisphere as a recess, which
// keeps its outer face flat — that face goes on the bed, so every
// feature on the inner face prints upwards without support.
cover_w = box_w;
cover_l = box_l;
cover_t = 10.0;
cover_z0 = stand_top;             // 19.4 inner face
cover_z1 = cover_z0 + cover_t;    // 29.4 outer face
cover_screw_d  = 3.3;   // M3 clearance
cover_cb_d     = 6.2;   // counterbore for the head, on the outer face
cover_cb_h     = 3.0;
pad_w = seat_w;         // pads sit directly opposite the seats
pad_l = seat_over;
pad_y = board_edge - seat_over/2;   // 7.85
lip_h  = 1.0;           // registration lip, ±X walls only
lip_t  = 1.0;
lip_cl = 0.2;
lip_y  = 5.0;           // half-length of each lip segment

// ── BALL AND SOCKET ────────────────────────────────────────────
// Two-piece clamp: the cover holds the upper hemisphere, socket_cap
// takes a band below the equator, two M3 screws pull them together.
// Nothing flexes — with the cap off the ball drops straight in.
ball_d  = 15.0;
ball_r  = ball_d/2;
ball_cl = 0.15;
ball_cz = cover_z1;                     // ball centre = cover's outer face
sock_roof = cover_t - (ball_r + ball_cl);  // 2.35 material over the ball
sock_gap  = 1.6;    // parting gap; the screws preload against the ball
sock_od   = 21.0;   // socket cap body diameter
// Cap seat: the throat sets the tilt range. Bigger = more tilt, less grip.
sock_throat_d = 13.5;
sock_flare_d  = 20.0;
sock_flare_h  =  3.0;
// Clamp screws, along ±Y so they stay inside the cover's footprint
sock_screw_d  = 3.4;
sock_screw_dy = 11.5;
sock_nut_af   = 5.6;   // press-fit pocket for an M3 nut (5.5 across flats)
sock_nut_h    = 2.6;
sock_cb_d     = 6.4;   // counterbore for the screw head, under the cap
sock_cb_h     = 3.0;

// ── T-BASE (wall bracket) — unchanged ──────────────────────────
plate_l  = 50.0;
plate_w  = 24.0;
plate_t  =  6.0;
mount_d     =  4.5;
mount_cb_d  = 10.0;
mount_cb_h  =  1.0;
mount_dx    = 17.0;
post_d_base = 12.0;
post_d_top  =  7.0;
post_clear  = 10.0;
ball_z_base = plate_t + post_clear + ball_r;

// ── GLOBAL RENDER QUALITY ──────────────────────────────────────
$fn = 64;   // 32 for fast preview, 128 for final STL export
