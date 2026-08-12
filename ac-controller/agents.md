# Agent Notes — AC Controller

Hints, assumptions, and context for future agents working on this project.

## Hardware

**Main board**: Seeed Studio XIAO ESP32S3 Sense
- Product page: https://www.seeedstudio.com/XIAO-ESP32S3-Sense-p-5639.html
- Wiki / pinout: https://wiki.seeedstudio.com/xiao_esp32s3_getting_started/
- Camera pins: https://wiki.seeedstudio.com/xiao_esp32s3_camera_usage/
- ESP32-S3R8 chip, 8 MB PSRAM (octal), 8 MB Flash, OV2640 camera, PDM mic
- No built-in IR LED — IR LED is external hardware wired to GPIO4 (D3)
- VS1838B IR receiver wired to GPIO3 (D2)
- User-accessible GPIOs on headers: D0–D10 = GPIO1–GPIO9, GPIO43, GPIO44

**AC unit**: Brand/model unknown. IR protocol unknown.
- IR codes must be learned via the VS1838B receiver and the ESPHome log
- After identifying the brand, check https://esphome.io/components/climate/climate_ir.html
  for a native protocol; if supported, replace raw button entities with a
  `climate` entity for a cleaner HA integration

**Power control**: A Z-wave smart outlet already in Home Assistant controls AC
power and tracks consumption. ESPHome does not interact with it. HA template
sensors use `sensor.ac_outlet_power` to gate all display-state readings
(if power ≈ 0 W, AC is off; suppress LED/temperature sensor values).
Adjust the entity ID to match the actual Z-wave outlet entity.

## ESPHome Firmware (`ac-controller.yaml`)

- Board target: `seeed_xiao_esp32s3`, framework `esp-idf`
- Camera at 800×600 / 5 fps; MJPEG stream on `:8080`, snapshot on `:8081`
- IR TX: `remote_transmitter` on GPIO4; all button `code: []` arrays are
  **placeholder** — fill in after learning with VS1838B
- IR RX: `remote_receiver` on GPIO3 with `dump: all`; set `logger: INFO`
  once learning is complete to reduce log noise
- Microphone: PDM on GPIO41/42, wired to `voice_assistant` (HA Assist)
- Status LED: amber user LED GPIO21 (active-low), lights while VA is listening
- Secrets: copy `secrets.yaml.template` → `secrets.yaml` (gitignored)

## Display Reading (`ac_display_reader.py.template`)

- Copy to `/config/scripts/ac_display_reader.py` on the HA host
- Install deps: `apk add py3-pillow ssocr` (HA OS via SSH add-on)
- All `LED_REGIONS` coordinates are `(0, 0, 0, 0)` **placeholders** — must be
  calibrated after physically mounting the XIAO
- Calibration workflow: grab snapshot → open in GIMP → note pixel bounding
  boxes of each LED → paste into script → run `--debug` to tune `THRESHOLD`
- Temperature uses `ssocr`; set `SSOCR_PATH = None` to disable and use HA's
  `image_processing.seven_segments` instead
- HA wiring: `sensor.ac_display_state` (command_line, JSON) → template
  sensors in `ha-notes.yaml`

## HA Configuration (`ha-notes.yaml`)

- Contains sensor, template, and binary_sensor YAML blocks to paste into
  `configuration.yaml` (or split config files)
- Update Z-wave entity IDs: `switch.ac_outlet` and `sensor.ac_outlet_power`
- Frigate/go2rtc config is in commented-out blocks at the bottom (low priority)

## Enclosure (`enclosure/`)

- 4 parts: `base` (wall plate + post + ball), `box_lower` (+ integral socket
  cup), `box_upper` (lid, carries camera + IR emitter + IR receiver),
  `socket_cap` (ball clamp)
- All parametric OpenSCAD; **all** dimensions live in `params.scad`
- Ball 15 mm; two-piece bolted socket clamp (nothing flexes); M3 throughout
  except the two Spax #8 wafer-head screws that hold the base to the wall
- The lid has an 8 mm "accessory bay" on −X because the XIAO fills its own
  footprint — without it there is no room for an IR LED hole that is not
  blocked by a wall underneath
- Full details in [enclosure/specs.md](enclosure/specs.md)
- Render STLs: `cd enclosure && ./render.sh` (requires OpenSCAD installed)
- Preview PNGs in `enclosure/preview/`; STLs go to `enclosure/stl/` (gitignored)
- Renders here were done headless: `apt install openscad xvfb`, then
  `Xvfb :99 & DISPLAY=:99 openscad --render --viewall --autocenter ...`.
  Note the container is ephemeral — apt packages do not survive between
  sessions, so reinstall before rendering.

## Known TODOs

- [ ] Fill in IR raw codes after learning session (in `ac-controller.yaml`)
- [ ] Calibrate LED_REGIONS pixel coordinates (in `ac_display_reader.py`)
- [ ] Verify XIAO PDM mic pin config compiles cleanly (ESPHome i2s_audio API
      varies between versions; may need `i2s_bclk_pin` adjustment)
- [ ] Test-print enclosure and adjust `cl` (fit clearance) if board is tight
- [ ] Verify `stack_h` (6.0 mm) and `cam_h` (9.0 mm) against the real board —
      these were estimated, and they set the box height and where the lens
      lands relative to the aperture
- [ ] Confirm `cam_hole_x` / `cam_hole_y` sit over the actual lens (currently
      assumes the camera is centred on the board; depends on how the flex
      cable is folded)
- [ ] Check the socket grips firmly once printed; if it slips under load,
      reduce `sock_throat_d` for more wrap around the ball
