// params.scad — shared parameters for XIAO ESP32S3 Sense enclosure
// All dimensions in millimeters. Include this file in every part.
// See specs.md for rationale and modification guidance.

// ── BOARD: Seeed Studio XIAO ESP32S3 Sense ─────────────────────
// https://wiki.seeedstudio.com/xiao_esp32s3_getting_started/
// Main PCB: 21.0 × 17.5 mm; Sense expansion board clips to back,
// adding ~3 mm. Camera module on flex cable sits above PCB.
board_w    = 21.0;   // PCB width  (X in box coords)
board_l    = 18.0;   // PCB length (Y in box coords; 17.5 rounded up)
pcb_t      =  1.6;   // PCB thickness
comp_top   =  4.0;   // max component height above PCB (tallest cap)
comp_bot   =  3.5;   // total expansion board + bottom component height
cam_rise   =  5.5;   // camera module height above top components
// USB-C receptacle (centered on the +Y edge of the board)
usb_w      =  9.5;   // USB-C opening width
usb_h      =  3.8;   // USB-C opening height
usb_z_off  =  1.8;   // USB-C center height above PCB bottom face

// ── BOX ────────────────────────────────────────────────────────
wall       = 2.5;    // wall thickness (PETG min ~2 mm; 2.5 for rigidity)
cl         = 0.35;   // per-side clearance for board fit
// Interior cavity
ci_w  = board_w + 2*cl;
ci_l  = board_l + 2*cl;
// Split line at midpoint of PCB thickness (Z=0 in box coords)
ci_h_bot = comp_bot + pcb_t/2 + cl;  // below split
ci_h_top = pcb_t/2 + comp_top + cam_rise + cl;  // above split
// Outer box
box_w = ci_w + 2*wall;
box_l = ci_l + 2*wall;
box_h_bot = ci_h_bot + wall;   // height of lower half
box_h_top = ci_h_top + wall;   // height of upper half

// ── CAMERA HOLE (in top face of upper half) ──────────────────
cam_hole_d  = 9.0;   // lens aperture; OV2640 lens ~7 mm, extra for cable routing
cam_hole_xoff = 0;   // offset from box centerline (X); 0 = centered
cam_hole_yoff = 1.5; // offset toward USB end (adjust after test print)

// ── IR EMITTER (T-5 through-hole LED, top face alongside camera) ─
// Change ir_led_d to 3.0 for T-1 (3 mm) package.
ir_led_d    = 5.0;   // LED body/dome diameter mm (T-5 = 5.0, T-1 = 3.0)
ir_led_cl   = 0.2;   // per-side clearance — snug friction fit; dome lip retains LED
// Placed left of camera on the same Y row (adjustable via ir_led_xoff)
ir_led_xoff = -(cam_hole_d/2 + ir_led_d/2 + 2.0);
ir_led_yoff = cam_hole_yoff;

// ── IR RECEIVER (VS1838B, +X side wall of upper half) ────────────
// Package: flat front window 5.8 mm wide × 7.4 mm tall × 3.0 mm deep.
// Receiver window faces outward (+X); leads/wire run into cavity to XIAO.
vs1838_w  = 5.8;   // body width  (Y direction in slot)
vs1838_h  = 7.4;   // body height (Z direction in slot)
vs1838_d  = 3.0;   // body depth  (through wall; protrudes ~0.5 mm into cavity)
vs1838_cl = 0.3;   // per-side slot clearance
vs1838_yoff = 0;           // slot center Y (0 = box center; no conflict with M3 at ±join_y)
vs1838_zoff = box_h_top/2; // slot center Z in upper half
vs1838_side = 1;           // which X wall: 1 = +X (right), -1 = -X (left)

// ── USB OPENING (in +Y face, centered on board edge) ─────────
usb_cut_w = usb_w + 1.0;  // clearance for plug
usb_cut_h = usb_h + 1.0;

// ── SNAP CLIPS (inside ±X walls, near −Y end) ────────────────
// Board slides in from −Y; clips on ±X inner walls engage the board edge.
clip_l     = 5.0;   // clip body length (Y direction)
clip_h     = pcb_t + 1.5;  // clip height spans PCB edge
clip_t     = 1.4;   // cantilever arm thickness (flex arm for PETG)
clip_land  = 1.2;   // notch ledge depth (captures board edge)
clip_y_pos = -ci_l/2 + clip_l/2 + 1.0;  // near back wall (−Y)

// ── DUST CAP (press-fit into −Y opening) ─────────────────────
cap_plug_t     = 4.0;    // depth of interference plug
cap_flange_t   = 2.5;    // flange plate thickness
cap_interf     = 0.18;   // press-fit interference per side (PETG flex)
cap_plug_w     = box_w - 2*cap_interf;  // slightly oversized → tight fit
cap_plug_l     = box_l - 2*cap_interf;
cap_flange_w   = box_w + 4.0;           // flange overhangs box by 2 mm each side
cap_flange_l   = box_l + 4.0;

// ── BALL JOINT ───────────────────────────────────────────────
ball_d    = 20.0;   // ball diameter; matches socket on box
ball_r    = ball_d / 2;
sock_wall = 3.5;    // socket shell thickness
// Socket wraps ~58% of sphere depth for retention without jamming.
// (50%+ is required for ball retention; 65%+ requires force to remove)
sock_depth = ball_r * 1.15;
sock_gap  = 1.4;    // clamp gap width; closes when M4 screw is tightened
// Clamping ear: tab extending from one X side, houses the M4 screw
ear_w     = 14.0;  // ear tab width (X direction)
ear_h     = 10.0;  // ear tab height (Z direction, from split line down)
clamp_screw_d = 4.5;   // M4 clearance through-hole (3.5 for M3)
clamp_nut_af  = 7.0;   // M4 nut across-flats
clamp_nut_h   = 3.2;   // M4 nut height (for nut-trap pocket)

// ── BOX JOIN SCREWS (M3, one per long side) ──────────────────
join_d    = 2.7;   // M3 clearance hole
join_boss = 5.5;   // boss OD
join_y    = ci_l / 2 - join_boss / 2 - 1.0;  // Y position of bosses — near corners, clears VS1838B slot

// ── ANTENNA CABLE GROOVE (on −Z face of lower half) ──────────
ant_w     = 4.0;   // groove width
ant_h     = 2.5;   // groove depth
// Positioned to one side of ball socket, routing toward −Y (T bracket)
ant_x_off = ball_r + sock_wall + 2.0;

// ── T-BASE ───────────────────────────────────────────────────
arm_w    = 80.0;   // crossbar total width
arm_d    = 22.0;   // crossbar depth (front-to-back)
arm_h    =  6.0;   // crossbar thickness
stem_w   = 24.0;   // stem width
stem_l   = 38.0;   // stem length (crossbar rear face to ball center)
stem_h   =  6.0;   // stem thickness (same as arm)
// Spax #8 wafer-head: major thread ≈ 4.2 mm, head ≈ 14 mm flat diameter.
// Wafer head sits flush on surface — no countersink needed.
mount_d  = 4.5;    // through-hole for #8 shank
mount_dx = 30.0;   // half-spacing between hole centers (holes at ±mount_dx)

// ── GLOBAL RENDER QUALITY ────────────────────────────────────
$fn = 64;   // set to 32 for fast preview, 128 for final STL export
