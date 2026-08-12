// params.scad — shared parameters for XIAO ESP32S3 Sense camera mount
// All dimensions in millimetres. Include this file in every part.
// See specs.md for rationale, print settings, and modification guidance.
//
// ── COORDINATE SYSTEM (box parts) ───────────────────────────────
//   Origin = centre of the box at the split plane between the halves.
//   +Z = the direction the camera looks ("front" of the mount)
//   +Y = USB-C end
//   −X = accessory bay (IR emitter + IR receiver + wiring)
//   The board's top surface sits board_drop below the split plane, so
//   the lid can press down on it.

// ── BOARD: Seeed Studio XIAO ESP32S3 Sense ─────────────────────
// https://wiki.seeedstudio.com/xiao_esp32s3_getting_started/
// The Sense expansion board clips underneath the main PCB; treat the
// pair as one stacked block. Camera module folds over the PCB top.
board_w    = 21.0;  // PCB width  (X)
board_l    = 17.5;  // PCB length (Y)
stack_h    =  6.0;  // expansion-board underside → main-PCB top surface
cam_h      =  9.0;  // camera module top (lens barrel) above main-PCB top
cam_cl     =  0.5;  // air gap above lens barrel
cl         =  0.35; // per-side clearance around the board
pad_h      =  1.5;  // corner pads lift the stack off the cavity floor
board_drop =  1.0;  // board top surface below the split plane

// USB-C receptacle: sits on the PCB top surface, centred on the +Y edge
usb_w      =  9.5;
usb_h      =  3.2;

// ── ACCESSORY BAY ──────────────────────────────────────────────
// Extra cavity width on −X that houses the IR emitter, IR receiver and
// their wiring. Without it there is nowhere to put an LED hole that is
// not blocked by a wall — the board fills the rest of the footprint.
bay_w      =  8.0;  // bay width (X)
extra_l    =  4.0;  // extra cavity length (Y) for wire routing + lid lip
margin_r   =  5.5;  // +X margin reserved for the lid screw bosses

// ── CAVITY ─────────────────────────────────────────────────────
ci_w = board_w + 2*cl + bay_w + margin_r;   // 35.2
ci_l = board_l + 2*cl + extra_l;            // 22.2
ci_h_bot = board_drop + stack_h + pad_h;    //  8.5  (split → floor)
ci_h_top = cam_h - board_drop + cam_cl;     //  8.5  (split → ceiling)

// Board and bay centres within the cavity
board_cx = ci_w/2 - margin_r - cl - board_w/2;   // +1.25
board_cy = 0;
bay_cx   = -ci_w/2 + bay_w/2;                    // −13.6

// ── BOX SHELL ──────────────────────────────────────────────────
wall      = 2.5;
box_w     = ci_w + 2*wall;      // 40.2
box_l     = ci_l + 2*wall;      // 27.2
box_h_bot = ci_h_bot + wall;    // 11.0
box_h_top = ci_h_top + wall;    // 11.0

// Alignment lip on the lid that drops into the lower half
lip_h  = 1.2;
lip_t  = 1.0;
lip_cl = 0.2;

// ── LID SCREWS (4 × M3, self-tapping into printed bosses) ──────
join_boss_d = 5.5;   // boss outer diameter
join_pilot  = 2.5;   // pilot hole — M3 cuts its own thread in PETG
join_free   = 3.3;   // clearance hole through the lid
join_cb_d   = 6.2;   // counterbore for the M3 head
join_cb_h   = 2.5;
join_x = ci_w/2 - join_boss_d/2;         // ±14.85
join_y = ci_l/2 - join_boss_d/2 - 0.5;   // ± 7.85

// ── CAMERA APERTURE (lid top face) ─────────────────────────────
cam_hole_d   =  9.0;   // OV2640 lens barrel ≈ 7 mm; extra for alignment
cam_relief_d = 12.0;   // inner counterbore thins the wall at the lens
cam_relief_h =  1.2;
cam_hole_x   = board_cx;   // over the board centre
cam_hole_y   = board_cy;

// ── IR EMITTER (through-hole LED, lid top face, in the bay) ────
// Faces the same direction as the camera. Set ir_led_d = 3.0 for T-1.
ir_led_d  = 5.0;   // T-5 (5 mm) package body diameter
ir_led_cl = 0.2;   // per-side clearance — dome flange retains the LED
ir_led_x  = bay_cx;
ir_led_y  = 0;

// ── IR RECEIVER: VS1838B (side wall of the bay) ────────────────
// Package: flat window 5.8 mm wide × 7.4 mm tall × 3.0 mm deep.
// Faces sideways so it picks up the remote from off-axis.
vs_w    = 5.8;
vs_h    = 7.4;
vs_d    = 3.0;   // slightly deeper than wall — protrudes ~0.5 mm inside
vs_cl   = 0.3;
vs_side = -1;    // −1 = −X wall (bay side), +1 = +X wall
vs_y    = 0;
vs_z    = ci_h_top/2;   // centred in the lid cavity

// ── BALL AND SOCKET ────────────────────────────────────────────
// Two-piece clamp: an integral cup under the lower half plus a
// separate socket_cap bolted up against it. No flexing needed —
// the ball drops in when the cap is off.
ball_d    = 15.0;   // ball diameter (base and socket must match)
ball_r    = ball_d/2;
ball_cl   = 0.15;   // socket cavity clearance over the ball
sock_wall =  3.0;   // material around the ball cavity
sock_od   = ball_d + 2*sock_wall;   // 21.0
sock_roof =  2.5;   // material between box floor and top of ball
sock_gap  =  1.6;   // parting gap; screws close it onto the ball

// Ball centre in box coordinates (also the socket parting plane)
ball_cz = -box_h_bot - sock_roof - ball_r;   // −21.0

// Socket clamp screws (2 × M3 with nuts, side-loaded nut traps)
sock_screw_d  =  3.4;    // M3 clearance
sock_screw_dx = 13.0;    // ± from centre
sock_nut_af   =  5.5;    // M3 nut across flats
sock_nut_h    =  2.6;
// The ear must reach well inside the cup radius (sock_od/2) so it merges
// into the cup wall instead of hanging off it — this joint carries the
// whole clamping load.
sock_ear_w    = 14.0;    // ear size (X): spans x = 6 … 20
sock_ear_l    = 11.0;    // ear size (Y)
sock_ear_h    =  6.0;    // ear thickness (Z)

// Cap seat: throat diameter sets the tilt range. Larger throat = more
// tilt, less wrap around the ball. 13.5 mm gives roughly ±30°.
sock_throat_d = 13.5;
sock_flare_d  = 20.0;   // clearance cone below the throat
sock_flare_h  =  3.0;

// ── T-BASE (wall bracket) ──────────────────────────────────────
// Flat plate, two screw holes, short tapered post, ball on top —
// the RAM-mount pattern.
plate_l  = 50.0;   // plate length (X)
plate_w  = 24.0;   // plate width  (Y); ends are rounded to plate_w/2
plate_t  =  6.0;   // plate thickness
// Spax #8 wafer head: shank ≈ 4.2 mm, head ≈ 9.5 mm across.
mount_d     =  4.5;   // through-hole for the #8 shank
mount_cb_d  = 10.0;   // shallow counterbore so the head sits recessed
mount_cb_h  =  1.0;
mount_dx    = 17.0;   // ± from centre (34 mm hole spacing)
// Post. A slim neck keeps most of the sphere exposed, which is what the
// socket grips and what sets the tilt range — a fat neck buries the ball.
post_d_base = 12.0;   // post diameter where it meets the plate
post_d_top  =  7.0;   // post diameter where it meets the ball
post_clear  = 10.0;   // exposed post length: plate top → ball underside
ball_z_base = plate_t + post_clear + ball_r;   // ball centre height

// ── GLOBAL RENDER QUALITY ──────────────────────────────────────
$fn = 64;   // 32 for fast preview, 128 for final STL export
