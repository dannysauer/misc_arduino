# ac-controller

ESPHome firmware for a **Seeed Studio XIAO ESP32S3 Sense** mounted in front of
a window/portable AC unit, integrating it with Home Assistant.

## What it does

| Capability | How |
|---|---|
| Read AC display — temperature | Camera → Python OCR script (`ssocr`) |
| Read AC display — mode LEDs | Camera → Python ROI brightness detection |
| Read AC display — fan speed LEDs | Camera → Python ROI brightness detection |
| Read AC display — filter change LED | Camera → Python ROI brightness detection |
| Send IR commands (power, mode, fan, temp) | External IR LED on GPIO4 |
| Learn IR codes from existing remote | VS1838B receiver on GPIO3 |
| Voice commands (HA Assist pipeline) | Built-in PDM microphone |
| Low-framerate MJPEG stream in HA | ESPHome camera entity + web server |
| Video feed to Frigate (optional) | go2rtc re-streams MJPEG as RTSP |

AC state is **always read from the camera** — the unit can be controlled by its
own remote or panel buttons, so the ESPHome device is never authoritative for
state. IR buttons are write-only.

Power on/off is handled by a Z-wave smart outlet already in Home Assistant.
That outlet's power consumption sensor is used to gate all camera-derived state
(when the outlet reports ~0 W, the AC is off and all indicators are suppressed).

## Hardware

- **Seeed Studio XIAO ESP32S3 Sense** (ESP32-S3, OV2640 camera, PDM mic, 8 MB PSRAM)
- **940 nm IR LED** (e.g. TSAL6400) + **100 Ω resistor** → GPIO4 (D3)
- **VS1838B IR receiver** → GPIO3 (D2), GND, 3V3 (no external components needed)

The XIAO has no built-in IR LED. Direct GPIO drive at 20 mA (38 kHz / 50% duty)
is sufficient for ≤ 2 m range. For more range, buffer the LED with an NPN
transistor (BC547 / 2N3904): base via 1 kΩ from GPIO4, collector to LED, LED to
supply via 10–33 Ω resistor.

## Files

| File | Purpose |
|---|---|
| `ac-controller.yaml` | ESPHome firmware — flash this to the XIAO |
| `secrets.yaml.template` | Copy to `secrets.yaml`, fill in credentials |
| `ha-notes.yaml` | Home Assistant config snippets (sensors, templates) |
| `ac_display_reader.py.template` | Copy to HA, calibrate ROIs, reads display state |
| `agents.md` | Context and hints for future AI agents working on this project |
| `enclosure/` | 3D-printable adjustable mount — see [enclosure/specs.md](enclosure/specs.md) |

`secrets.yaml` is gitignored.

## Setup

### 1. Flash the firmware

```bash
cp secrets.yaml.template secrets.yaml
# edit secrets.yaml with your WiFi/API credentials
esphome run ac-controller.yaml
```

The device will appear automatically in the Home Assistant ESPHome integration.

### 2. Learn IR codes

With the firmware running, open the ESPHome log viewer and point the AC's
original remote at the VS1838B from about 15 cm. Press each button you want to
capture. The log will print `Raw:` lines for each code received.

Copy those raw code arrays into the matching `button:` entries in
`ac-controller.yaml`, then reflash.

Once you know the AC brand, check [ESPHome climate IR components](https://esphome.io/components/climate/climate_ir.html)
— if your protocol is supported you can replace the raw buttons with a proper
`climate` entity.

### 3. Install HA dependencies

On your HA host (via SSH & Web Terminal add-on):

```bash
apk add py3-pillow ssocr
```

Copy the detection script:

```bash
cp ac_display_reader.py.template /config/scripts/ac_display_reader.py
chmod +x /config/scripts/ac_display_reader.py
```

### 4. Calibrate the display reader

Mount the XIAO pointing at the AC display, then grab a reference snapshot:

```bash
curl -o /tmp/snap.jpg http://ac-controller.local:8081/snapshot
```

Open the image in GIMP (or any editor showing pixel coordinates). For each LED
indicator and the temperature digit area, note the pixel bounding box `(x1, y1,
x2, y2)` and enter it in the `LED_REGIONS` / `TEMP_CROP` section of
`ac_display_reader.py`.

Run with `--debug` to see per-region brightness:

```bash
python3 /config/scripts/ac_display_reader.py --debug
```

Adjust `THRESHOLD` until lit LEDs are reliably above it and dark regions are
reliably below it.

### 5. Add HA configuration

Add the sensor and template blocks from `ha-notes.yaml` to your Home Assistant
`configuration.yaml` (or the relevant split config files). Update the Z-wave
entity IDs to match your outlet.

### 6. Frigate (optional)

See the commented-out go2rtc and Frigate config at the bottom of `ha-notes.yaml`.

## Camera settings

The firmware uses 800×600 at 5 fps. If you see WiFi disconnects, reduce to
640×480 in `ac-controller.yaml`. Adjust `contrast` and `brightness` in the same
file to maximize LED/digit visibility for OCR.
