# Enclosure Specifications

Adjustable camera mount for the **Seeed Studio XIAO ESP32S3 Sense**, aimed at
an AC unit's display panel. Ball-and-socket head on a wall bracket, with an
IR emitter and IR receiver carried in the same housing.

## Parts

| File | Part | Rough print time |
|---|---|---|
| `base.scad` | Wall bracket: plate + post + ball | ~1 h |
| `box_lower.scad` | Lower half + integral socket cup | ~1.5 h |
| `box_upper.scad` | Lid: camera, IR emitter, IR receiver | ~1 h |
| `socket_cap.scad` | Ball clamp, bolts to the cup | ~15 min |

`assembly.scad` is a preview only — never export it.

## How it goes together

```
              camera + IR LED point this way (+Z)
                        ▲
            ┌───────────────────────┐
            │   lid (box_upper)     │  ← 4 × M3 into bosses below
            ├───────────────────────┤  ← split plane
            │   lower (box_lower)   │  ← board sits on corner pads
            └────────┐  ┌───────────┘
                  ┌──┴──┴──┐            socket cup (part of lower)
                  │  ball  │
                  └──┬──┬──┘            socket_cap, 2 × M3 + nuts
                     │  │
                     post
              ┌──────┴──┴──────┐
              │  plate, 2 holes │        base, screwed to the wall
              └─────────────────┘
```

1. Screw the base to the wall/cabinet with two Spax #8 screws.
2. Drop the ball into the cup on `box_lower`, offer up `socket_cap`, and run
   the two M3 × 12 screws up into the nuts in the cup's ears. Leave them
   loose enough to swivel.
3. Push the IR LED into its hole in the lid **from the inside** — dome first.
   The flange at the base of the dome is wider than the hole and seats
   against the inside face, so the LED cannot fall out.
4. Push the VS1838B into the slot in the bay's side wall from the outside.
5. Solder short flying leads (~50 mm) to both, route them through the bay,
   and connect: LED → GPIO4 (D3) through its resistor, receiver → GPIO3 (D2),
   plus 3V3 and GND.
6. Lay the board on the four support pads, camera lens pointing up.
7. Fit the lid — the alignment lip locates it — and run in the four M3 × 16
   screws. The pads inside the lid clamp the board's corners.
8. Aim the camera at the display and tighten the two socket screws.

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
| `box_lower` | split face up, socket cup on the bed | no — use a brim |
| `box_upper` | top face down on the bed | no |
| `socket_cap` | flat face down on the bed | no |

`box_lower` bridges a ~10 mm dome at the top of the ball cavity; PETG handles
this, but the bed contact is small so a brim is worth using. `box_upper`
printed face-down puts the camera aperture and LED hole on the bed surface,
which gives the cleanest holes.

## Hardware BOM

| Qty | Item | Where |
|---|---|---|
| 2 | Spax #8 × 1.5″ wafer-head screws | base → wall |
| 4 | M3 × 16 self-tapping (or machine) screws | lid → bosses in the lower half |
| 2 | M3 × 12 screws | socket cap → cup |
| 2 | M3 hex nuts | side-loaded traps in the cup's ears |
| 1 | IR LED, T-5 (5 mm), 940 nm | lid top face, beside the camera |
| 1 | VS1838B IR receiver | bay side wall |
| — | ~50 mm hookup wire | LED → GPIO4, receiver → GPIO3 |

The four lid screws thread directly into printed bosses (2.5 mm pilot). PETG
takes a self-tapped M3 well; if a boss ever strips, drill it 4.2 mm and glue
in a nut or heat-set insert.

## Coordinate system

Origin is the centre of the box at the split plane between the halves.

| Axis | Direction |
|---|---|
| +Z | where the camera and IR emitter point |
| +Y | USB-C end |
| −X | accessory bay (IR emitter, IR receiver, wiring) |

The board's top surface sits `board_drop` (1 mm) below the split plane so the
lid's pads can press on it.

## The accessory bay

The XIAO fills its own footprint almost exactly, so there is nowhere to put an
LED hole in the lid that is not blocked by a wall below it. `bay_w` (8 mm) of
extra cavity on −X solves that: the LED hole sits over open space, the
receiver goes in the bay's outer wall, and the wiring has somewhere to live.
It costs about 8 mm of width. Set `bay_w = 0` to delete it — but then move
`ir_led_x` and the receiver somewhere that works.

## Ball and socket

Two-piece clamp rather than a flexing C-clip: the cup on `box_lower` takes the
upper hemisphere, `socket_cap` takes a band below the equator, and two M3
screws pull them together. Nothing has to flex, so nothing fatigues, and the
ball drops straight in when the cap is off.

| Parameter | Default | Effect |
|---|---|---|
| `ball_d` | 15.0 mm | Ball diameter. Base and both socket halves follow it. |
| `ball_cl` | 0.15 mm | Cavity clearance over the ball |
| `sock_gap` | 1.6 mm | Parting gap; the screws never close it, they preload against the ball |
| `sock_throat_d` | 13.5 mm | Cap's throat. **Bigger = more tilt, less grip.** |
| `sock_flare_d` | 20.0 mm | Clearance cone below the throat |
| `post_d_top` | 7.0 mm | Neck diameter. Thinner = more tilt, weaker post. |

Tilt range is roughly ±30° from vertical, plus unlimited rotation about the
post axis. It is set by the angle between where the post leaves the sphere
(`asin(post_d_top/2 / ball_r)`) and where the throat rim meets it
(`asin(sock_throat_d/2 / (ball_r + ball_cl))`).

## Key dimensions

All in `params.scad` — change them there, never in the part files.

| Parameter | Default | Notes |
|---|---|---|
| `board_w` / `board_l` | 21.0 / 17.5 mm | XIAO PCB |
| `stack_h` | 6.0 mm | Sense expansion board underside → main PCB top |
| `cam_h` | 9.0 mm | camera module top above the PCB top |
| `cl` | 0.35 mm | per-side board clearance |
| `wall` | 2.5 mm | shell thickness |
| `bay_w` | 8.0 mm | accessory bay width |
| `box_w` × `box_l` | 40.2 × 27.2 mm | outer footprint |
| `box_h_bot` + `box_h_top` | 11.0 + 11.0 mm | box height, split in the middle |
| `cam_hole_d` | 9.0 mm | aperture; `cam_relief_d` thins the wall behind it |
| `ir_led_d` | 5.0 mm | **T-5. Set 3.0 for a T-1 (3 mm) LED.** |
| `vs_w` / `vs_h` / `vs_d` | 5.8 / 7.4 / 3.0 mm | VS1838B body |
| `vs_side` | −1 | receiver wall: −1 = −X (bay), +1 = +X |
| `mount_dx` | 17.0 mm | ± from centre → 34 mm hole spacing |
| `plate_l` × `plate_w` × `plate_t` | 50 × 24 × 6 mm | base plate |
| `post_clear` | 10.0 mm | exposed post: plate top → ball underside |

## Modification guide

**Different board** — change `board_w`, `board_l`, `stack_h`, `cam_h`. Cavity,
pads, bosses and the camera hole all follow.

**Different IR LED package** — set `ir_led_d` (5.0 → T-5, 3.0 → T-1).

**Different receiver** — set `vs_w` / `vs_h` / `vs_d` to its body size. If the
body is deeper than `wall` it simply protrudes further into the bay.

**Receiver on the other side** — set `vs_side = 1`.

**Tighter board fit** — reduce `cl`. If the board rattles, raise `board_drop`
slightly so the lid's pads press harder.

**More tilt** — raise `sock_throat_d` or lower `post_d_top`, then re-check that
the cap still wraps enough of the ball to grip.

## Rendering

```bash
cd enclosure/
./render.sh              # all parts → stl/
./render.sh box_upper    # one part
openscad assembly.scad   # visual check
```

Set `$fn = 128` in `params.scad` before the final export; leave it at 32–64 for
quick previews. `socket_cap` is modelled where it sits in the assembly (~27 mm
below the origin) — slicers drop it onto the bed automatically.
