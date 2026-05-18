# Enclosure Specifications

Camera enclosure for the **Seeed Studio XIAO ESP32S3 Sense**, designed as a
ball-and-socket adjustable mount for pointing at an AC display panel.

## Parts

| File | Part | Print time est. |
|---|---|---|
| `base.scad` | T-shaped wall bracket with ball | ~2 h |
| `box_lower.scad` | Lower enclosure half + ball clamp | ~1.5 h |
| `box_upper.scad` | Upper enclosure half (lid) + camera hole + IR emitter hole + IR receiver slot | ~1 h |
| `dust_cap.scad` | Press-fit back cover | ~20 min |

## Print Settings (PETG)

| Setting | Value |
|---|---|
| Material | PETG |
| Layer height | 0.2 mm |
| Infill | 30% gyroid |
| Walls | 4 perimeters |
| Top/bottom layers | 5 |
| Supports | Base only (for ball upper hemisphere) |
| Bed temp | 70–80 °C |
| Nozzle temp | 230–240 °C |

PETG is specified because its flex makes the snap clips and press-fit dust cap
durable over many cycles. PLA will work for a rigid version but snap clips may
fatigue. ASA is a good outdoor alternative.

## Key Dimensions

All parameters are defined in `params.scad`. Modify there — do not hardcode
values inside part files.

| Parameter | Default | Notes |
|---|---|---|
| `board_w` | 21.0 mm | XIAO PCB width |
| `board_l` | 18.0 mm | XIAO PCB length (17.5 + margin) |
| `comp_top` | 4.0 mm | Tallest component above PCB |
| `comp_bot` | 3.5 mm | Expansion board + bottom components |
| `cam_rise` | 5.5 mm | Camera module height above top components |
| `wall` | 2.5 mm | Shell wall thickness |
| `cl` | 0.35 mm | Per-side board fit clearance |
| `ball_d` | 20.0 mm | Ball diameter (base and socket must match) |
| `sock_depth` | ball_r × 1.15 | Socket cup depth; >ball_r retains ball |
| `sock_gap` | 1.4 mm | Clamp gap; closes when M4 screw tightens |
| `clamp_screw_d` | 4.5 mm | M4 clearance hole (use 3.7 for M3) |
| `mount_d` | 4.5 mm | Spax #8 shank clearance hole |
| `mount_dx` | 30.0 mm | Half-spacing between mounting holes (60 mm c-c) |
| `ir_led_d` | 5.0 mm | IR emitter package diameter — **T-5 = 5.0, T-1 = 3.0** |
| `ir_led_cl` | 0.2 mm | LED hole clearance (snug; dome flange retains it) |
| `ir_led_xoff` | auto | X offset of emitter hole from center (left of camera) |
| `ir_led_yoff` | cam_hole_yoff | Y position of emitter (same row as camera) |
| `vs1838_w` | 5.8 mm | VS1838B body width |
| `vs1838_h` | 7.4 mm | VS1838B body height |
| `vs1838_d` | 3.0 mm | VS1838B body depth (slightly > wall; ~0.5 mm protrudes inside) |
| `vs1838_cl` | 0.3 mm | Per-side slot clearance |
| `vs1838_yoff` | 0 mm | Receiver slot Y center (0 = centered on box) |
| `vs1838_zoff` | box_h_top/2 | Receiver slot Z center in upper half |

## Hardware BOM

| Qty | Item | Notes |
|---|---|---|
| 2 | Spax #8 × 1.5″ cabinet screws (wafer head) | Mounts base to wall/cabinet |
| 1 | M4 × 20 mm button-head or socket-head screw | Ball clamp |
| 1 | M4 hex nut | Captured in nut-trap pocket on clamp ear |
| 2 | M3 × 12 mm socket-head screws | Join upper + lower box halves |
| 1 | IR LED emitter, T-5 (5 mm) 940 nm | In top-face hole; LED from your kit |
| 1 | VS1838B IR receiver module | In +X side-wall slot; receiver from your kit |
| — | Short hookup wire (~50 mm leads) | Emitter → GPIO4; receiver → GPIO3 (see firmware) |
| 4 | M3 hex nut | Captured in bosses inside lower half |

## Coordinate System (box halves)

```
       +Z (camera)
        ↑
        │       +Y (USB port)
        │      ↗
        └─── +X

  Split plane at Z = 0
  Ball socket below box (−Z direction)
  Back / dust-cap opening at −Y face
```

## Ball-and-Socket Clamp

The clamp is modelled after RAM Mount A-series style:

- The socket wraps `sock_depth = ball_r × 1.15` into the hemisphere (58% of
  ball radius depth), which exceeds the 50% needed for passive retention.
- `sock_gap` is a radial slot cut through the +X side of the socket shell.
  When the M4 screw is loose, the PETG flexes enough to pass the ball through
  the slot opening. Tighten the M4 screw to lock position.
- The clamping ear extends from the +X side of the socket. The M4 screw passes
  through a clearance hole in the outer face and threads into the nut trapped
  in the pocket; tightening draws the gap closed.

## Snap-Clip Detail

Two cantilever clips inside the ±X walls of the lower half, near the −Y
(back) end:

1. Slide the PCB in from the −Y end, USB end leading toward +Y.
2. The board edges ride up the ramp faces of the clips (which flex outward).
3. When the USB port aligns with the +Y opening, the clips spring back and
   the notch ledges capture the board edges.
4. Install the upper half and secure with two M3 screws.
5. Press the dust cap into the −Y opening.

## Modification Guide

**Different board**: change `board_w`, `board_l`, `comp_top`, `comp_bot`,
`cam_rise`. All box geometry derives from these.

**Different ball size**: change `ball_d` in params.scad — both `base.scad` and
the socket modules recalculate automatically.

**Different clamp screw**: change `clamp_screw_d` (hole) and `clamp_nut_af` /
`clamp_nut_h` (nut trap). M3 works for lighter loads; M4 recommended.

**Tighter/looser press fit for dust cap**: adjust `cap_interf` (default 0.18 mm
interference). PETG varies by printer; test with a single cap first.

**More rotation range**: decrease `sock_depth` (less wrapping = more range but
less retention). Minimum retention depth = ball_r × 0.5 (exactly 180°).

## Rendering STLs

OpenSCAD must be installed. Then:
```bash
cd enclosure/
chmod +x render.sh
./render.sh         # all parts → stl/
./render.sh base    # single part
```

Before final export, set `$fn = 128` in `params.scad` for smooth curves.
Preview with `$fn = 32` for speed.
