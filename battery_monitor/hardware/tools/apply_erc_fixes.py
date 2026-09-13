from pathlib import Path

path = Path(__file__).with_name("generate_schematic.py")
text = path.read_text()

text = text.replace(
    "LIBS.append(libsym('CONN6','J',[('passive','1','BAT+',5,-6,180),",
    "LIBS.append(libsym('CONN6','J',[('power_out','1','BAT+',5,-6,180),",
)

if "libsym('PWRFLAG'" not in text:
    text = text.replace(
        "LIBS.append(libsym('CONN2','J',[('passive','1','1',5,-2,180),('passive','2','2',5,2,180)],w=8,h=8,desc='Two pin connector'))\n",
        "LIBS.append(libsym('CONN2','J',[('passive','1','1',5,-2,180),('passive','2','2',5,2,180)],w=8,h=8,desc='Two pin connector'))\n"
        "LIBS.append(libsym('PWRFLAG','P',[('power_out','1','PWR_FLAG',0,5,270)],w=4,h=3,desc='ERC power-source marker'))\n",
    )

text = text.replace(
    "('bidirectional','51','SWDIO',16,-11,180),('input','53','SWDCLK',16,-15,180),('input','40','nRESET/P0.18',16,-7,180),",
    "('bidirectional','51','SWDIO',16,-11,180),('passive','53','SWDCLK',16,-15,180),('passive','40','nRESET/P0.18',16,-7,180),",
)

marker = "for yy in [32.4,34.8,39.6,42]: nc(102,yy)\n"
flags = (
    "inst('PWRFLAG','PF1','VIN_PROTECTED_PWR',82,47); wire(82,42,82,52)\n"
    "inst('PWRFLAG','PF2','GND_PWR',92,57); wire(92,52,92,62)\n"
)
if "VIN_PROTECTED_PWR" not in text:
    text = text.replace(marker, marker + flags)

text = text.replace(
    "inst('C','C3','10u 10V',112,42,'Capacitor_SMD:C_1206_3216Metric','','3.3 V bulk'); wire(112,37,112,30); wire(112,47,112,52); label('GND',112,52)",
    "inst('C','C3','10u 10V',112,42,'Capacitor_SMD:C_1206_3216Metric','','3.3 V bulk'); wire(112,37,112,30); wire(112,47,112,52); label('3V3',112,37); label('GND',112,52)",
)
text = text.replace(
    "inst('C','C4','100n',120,42,'Capacitor_SMD:C_0805_2012Metric','','3.3 V HF bypass'); wire(120,37,120,30); wire(120,47,120,52); label('GND',120,52)",
    "inst('C','C4','100n',120,42,'Capacitor_SMD:C_0805_2012Metric','','3.3 V HF bypass'); wire(120,37,120,30); wire(120,47,120,52); label('3V3',120,37); label('GND',120,52)",
)

# Repair the one extra closing parenthesis introduced during the previous
# source restore. Keep this exact replacement idempotent.
text = text.replace(
    "sl.append(f'  (instances (project \"battery_monitor\" (path \"/{ROOT}\" (reference \"{ref}\") (unit 1)))))')",
    "sl.append(f'  (instances (project \"battery_monitor\" (path \"/{ROOT}\" (reference \"{ref}\") (unit 1))))')",
)

path.write_text(text)
