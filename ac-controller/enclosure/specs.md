# Enclosure Specifications

Adjustable camera mount for the **Seeed Studio XIAO ESP32S3 Sense**, aimed at
an AC unit's display panel. The camera, IR emitter and IR receiver all look out
of one face; the only cable leaving the box is USB-C.

## Parts

| File | Part | Rough print time |
|---|---|---|
| `base.scad` | Wall bracket: plate + post + ball | ~1 h |
| `box.scad` | Open-backed shell, optics in the front face | ~1.5 h |
| `cover.scad` | Flat back plate carrying the ball socket | ~1 h |
| `socket_cap.scad` | Ball clamp, bolts to the cover | ~15 min |

`assembly.scad` is a preview only — never export it. It can drop a mock board,
camera and USB connector into place (`show_board = true`) and tilt the mount on
the ball (`tilt = 25`) to check clearances.

## How it works

The box is a shell that is open at the back. Its closed face points at the AC
unit and carries all three optical holes. The board goes in **camera side
facing that face**, so the lens and the IR parts look out of it and every
solder joint stays inside. The cover closes the back, carries the ball socket,
and pinches the board.

```
     −Z  ← camera, IR emitter and IR receiver all look this way
   ┌──────────────────────┐   aperture wall: 3 holes, nothing else
   │  ▓cam   ▓LED   ▓rx   │
   │        gap           │   IR parts live here, wired to the board
   │  ┌────────────────┐  │   board, camera side down, resting on
   │  │     board      │  │   seats part-way up the standoffs
   │  └────────────────┘  │
   │    wiring space      │   ← USB-C notch in the side wall
   ├──────────────────────┤   cover plate, 4 × M3 into the standoffs
   │        cover         │   ball socket is recessed into its thickness
   └──────────┬───────────┘
          ( ball )             socket_cap, 2 × M3
              │
             post
        ┌─────┴─────┐
        │   base    │          2 × Spax #8 into the wall
        └───────────┘
```

**The screws run beside the board, not through it.** The XIAO has no mounting
holes and drilling one is a bad idea, so each standoff is a post *outside* the
board outline with a seat that steps inboard under the board's corner. The
board is still pinched exactly as intended: seats underneath, cover pads on
top, 0.15 mm of interference (`pinch`) so bolting the cover down squeezes it.

## Assembly order

1. Screw the base to the wall with two Spax #8 screws.
2. Press an M3 nut into each of the two pockets on the cover's inner face.
3. Push the IR LED into its hole from **inside** the box, dome out, and the
   VS1838B into its slot from **outside**, window flush. Glue both.
4. Solder short leads from the LED (through its resistor) to GPIO4 / D3 and
   from the receiver to GPIO3 / D2, plus 3V3 and GND. Everything stays inside.
5. Lower the board in, camera down through the middle, until its corners sit
   on the four seats. The camera lens ends up just behind the aperture.
6. Put the cover on — the lip locates it — and run in four M3 × 16 screws.
7. Drop the ball into the socket recess, fit `socket_cap`, and run the two
   M3 × 14 screws up into the captive nuts. Snug, not tight.
8. Aim at the display, then tighten the two clamp screws.

## Print Settings (PETG)

| Setting | Value |
|---|---|
| Material | PETG |
| Layer height | 0.2 mm |
| Infill | 30% gyroid |
| Walls | 4 perimeters |
| Top/bottom layers | 5 |
| Bed / nozzle | 70–80 °C / 230–240 °C |

| Part | Orientation | Supports |
|---|---|---|
| `base` | plate flat on the bed, ball up | **yes**, for the ball |
| `box` | aperture wall down on the bed | no |
| `cover` | outer (socket) face down on the bed | no |
| `socket_cap` | wide flared face down on the bed | no |

Only the base needs support. Everything else was arranged to avoid it: the
box's cavity opens upward, and the cover's socket is a recess in the plate
rather than a boss standing proud, so its outer face is flat on the bed and
the pads, lip and nut pockets all point up. The socket cavity narrows as it
rises, so it self-supports like a dome; only its apex and the screw
counterbores bridge, which PETG handles.

## Hardware BOM

| Qty | Item | Where |
|---|---|---|
| 2 | Spax #8 × 1.5″ wafer-head screws | base → wall |
| 4 | M3 × 16 screws | cover → standoffs (self-tapping into PETG) |
| 2 | M3 × 14 screws | socket cap → cover |
| 2 | M3 hex nuts | pressed into the cover's inner face |
| 1 | IR LED, T-5 (5 mm), 940 nm + series resistor | aperture wall |
| 1 | VS1838B IR receiver | aperture wall |
| — | ~40 mm hookup wire | all internal |

The cover screws self-tap into 2.5 mm pilot holes. If a standoff ever strips,
drill it 4.2 mm and glue in a nut.

## Coordinate system

`z = 0` is the inner face of the aperture wall; `+z` runs into the box towards
the cover and the ball; `+y` is the USB-C end. The camera looks along `−z`.

| Plane | z | What |
|---|---|---|
| `−wall` | −2.5 | outer face of the aperture wall |
| `0` | 0 | inner face; IR parts start here |
| `seat_h` | 9.4 | board's camera-side face — set by `cam_h` |
| `board_top` | 15.4 | board's wiring-side face |
| `stand_top` | 19.4 | box rim = cover's inner face |
| `ball_cz` | 29.4 | cover's outer face = ball centre |

## Key dimensions

All in `params.scad` — change them there, never in the part files.

| Parameter | Default | Notes |
|---|---|---|
| `board_w` / `board_l` | 21.0 / 17.5 mm | XIAO PCB |
| `stack_h` | 6.0 mm | expansion-board face → main-PCB top face |
| `cam_h` | 9.0 mm | **lens tip above the expansion-board face — sets how deep the box is** |
| `wire_gap` | 4.0 mm | clearance over the wiring side; must exceed `usb_h` |
| `pinch` | 0.15 mm | cover-pad interference onto the board |
| `cl` | 0.35 mm | per-side board clearance |
| `wall` | 2.5 mm | shell thickness |
| `box_w` × `box_l` | 26.7 × 35.7 mm | outer footprint |
| `stand_d` / `stand_pilot` | 5.5 / 2.5 mm | standoff post and pilot hole |
| `cam_hole_d` | 9.0 mm | aperture; `cam_relief_d` thins the wall behind it |
| `ir_led_d` | 5.0 mm | **T-5. Set 3.0 for a T-1 (3 mm) LED.** |
| `vs_w` / `vs_h` / `vs_d` | 5.8 / 7.4 / 3.0 mm | VS1838B body |
| `cover_t` | 10.0 mm | thick enough to hold the ball's upper hemisphere |
| `ball_d` | 15.0 mm | base and socket both follow it |
| `sock_throat_d` | 13.5 mm | **bigger = more tilt, less grip** |

Tilt is roughly ±30°, plus free rotation about the post. Past that the cap
fouls the base plate.

## Modification guide

**Different camera height** — `cam_h` is the number to check first; it sets
the gap between the aperture wall and the board, and therefore the box depth
and whether the lens ends up at the aperture.

**Different board** — `board_w`, `board_l`, `stack_h`. The cavity, standoffs,
seats and cover pads all follow.

**Board rattles / cover won't seat** — raise or lower `pinch`.

**Different IR LED package** — `ir_led_d` (5.0 = T-5, 3.0 = T-1).

**Move the IR parts** — `ir_led_x/y` and `vs_x/y` place them anywhere on the
aperture wall that clears the standoffs; the ends are the roomiest spots
because the board does not reach there.

**More tilt** — raise `sock_throat_d` or lower `post_d_top`, then check the
cap still wraps enough of the ball to grip.

## Rendering

```bash
cd enclosure/
./render.sh              # all parts → stl/
./render.sh cover        # one part
openscad assembly.scad   # visual check
```

Set `$fn = 128` before the final export. `cover` and `socket_cap` are modelled
where they sit in the assembly, tens of millimetres along +Z; slicers drop them
onto the bed automatically.
