import uuid, json, re
from pathlib import Path

NAMESPACE = uuid.UUID("bfc8b306-f086-4c8b-9324-f10957ddf937")
_counter = 0
def u():
    global _counter
    _counter += 1
    return str(uuid.uuid5(NAMESPACE, f"battery-monitor-{_counter}"))
ROOT = u()

def eff(size=1.27, hide=False, justify=None):
    s=f'(effects (font (size {size} {size}))'
    if justify: s+=f' (justify {justify})'
    if hide: s+=' hide'
    return s+')'

def prop(k,v,x,y,rot=0,hide=False):
    return f'(property "{k}" "{v}" (at {x} {y} {rot}) {eff(1.0 if not hide else 0.8, hide)})'

def pin_def(ptype,num,name,x,y,ang):
    return f'(pin {ptype} line (at {x} {y} {ang}) (length 2.54) (name "{name}" {eff(0.8)}) (number "{num}" {eff(0.8)}))'

def libsym(name,ref,pins,w=10,h=8,desc=''):
    lines=[f'(symbol "BM:{name}"','  (pin_names (offset 0.8))','  (in_bom yes)','  (on_board yes)',
           f'  {prop("Reference",ref,0,h/2+2)}',f'  {prop("Value",name,0,-h/2-2)}',
           f'  {prop("Footprint","",0,0,hide=True)}',f'  {prop("Datasheet","",0,0,hide=True)}',f'  {prop("Description",desc,0,0,hide=True)}',
           f'  (symbol "{name}_0_1" (rectangle (start {-w/2} {-h/2}) (end {w/2} {h/2}) (stroke (width 0.254) (type default)) (fill (type background))))',
           f'  (symbol "{name}_1_1"']
    for p in pins:
        lines.append('    '+pin_def(*p))
    lines+=['  )',')']
    return '\n'.join(lines)

LIBS=[]
LIBS.append(libsym('R','R',[('passive','1','1',-5,0,0),('passive','2','2',5,0,180)],w=5,h=2,desc='Resistor'))
LIBS.append(libsym('C','C',[('passive','1','1',0,-5,90),('passive','2','2',0,5,270)],w=4,h=3,desc='Capacitor'))
LIBS.append(libsym('DIODE','D',[('passive','1','A',-5,0,0),('passive','2','K',5,0,180)],w=5,h=3,desc='Diode'))
LIBS.append(libsym('TVS','D',[('passive','1','1',0,-5,90),('passive','2','2',0,5,270)],w=5,h=4,desc='Bidirectional TVS'))
LIBS.append(libsym('CLAMP3','D',[('passive','1','GND clamp',0,6,270),('passive','3','SENSE',-6,0,0),('passive','2','3V3 clamp',0,-6,90)],w=6,h=6,desc='BAV199-Q series dual diode used as rail clamp'))
LIBS.append(libsym('NTC','RT',[('passive','1','1',0,-5,90),('passive','2','2',0,5,270)],w=5,h=3,desc='NTC thermistor'))
LIBS.append(libsym('CONN6','J',[('passive','1','BAT+',5,-6,180),('passive','2','GND',5,-3.6,180),('passive','3','IGN',5,-1.2,180),('passive','4','DOOR',5,1.2,180),('passive','5','PARK',5,3.6,180),('passive','6','AUX',5,6,180)],w=8,h=18,desc='Vehicle harness connector'))
LIBS.append(libsym('CONN2','J',[('passive','1','1',5,-2,180),('passive','2','2',5,2,180)],w=8,h=8,desc='Two pin connector'))
LIBS.append(libsym('LDO8','U',[('power_out','1','OUT',10,-6,180),('no_connect','2','DNC',10,-3.6,180),('open_collector','3','PG',10,-1.2,180),('power_in','4','GND',0,9,270),('input','5','EN',-10,6,0),('no_connect','6','NC',10,3.6,180),('output','7','DELAY',10,6,180),('power_in','8','IN',-10,-6,0),('power_in','9','EP',0,12,270)],w=14,h=18,desc='TPS7A1633A-Q1 fixed 3.3 V LDO; pin 9 represents exposed pad'))
LIBS.append(libsym('COMP4','U',[
    ('output','1','OUT_A',12,-9,180),('input','2','-IN_A',-12,-10.5,0),('input','3','+IN_A',-12,-7.5,0),('power_in','4','VCC',0,-15,90),
    ('input','5','+IN_B',-12,-2.5,0),('input','6','-IN_B',-12,-5.5,0),('output','7','OUT_B',12,-4,180),
    ('output','8','OUT_C',12,4,180),('input','9','-IN_C',-12,5.5,0),('input','10','+IN_C',-12,2.5,0),('power_in','11','VEE',0,15,270),
    ('input','12','+IN_D',-12,7.5,0),('input','13','-IN_D',-12,10.5,0),('output','14','OUT_D',12,9,180)],w=18,h=26,desc='TLV7034-Q1 quad nanopower push-pull comparator, TSSOP-14'))
LIBS.append(libsym('MCU','U',[
    ('power_in','28','VDD',0,-22,90),('power_in','G','GND',0,22,270),
    ('input','22','P0.06 IGN',-16,-15,0),('input','23','P0.07 DOOR',-16,-11,0),('input','24','P0.08 PARK',-16,-7,0),('input','27','P0.11 AUX',-16,-3,0),
    ('input','11','P0.02/AIN0 VBAT',-16,3,0),('input','9','P0.03/AIN1 TEMP_BOARD',-16,7,0),('input','20','P0.04/AIN2 TEMP_EXT',-16,11,0),('input','29','P0.12 REMOTE_EN',-16,15,0),
    ('output','36','P0.14 TEMP_B_EXC',16,3,180),('output','39','P0.15 TEMP_E_EXC',16,7,180),('output','37','P0.13 REMOTE_OUT',16,11,180),
    ('bidirectional','51','SWDIO',16,-11,180),('input','53','SWDCLK',16,-15,180),('input','40','nRESET/P0.18',16,-7,180),
    ('passive','17','XL1/P0.00',16,15,180),('passive','18','XL2/P0.01',16,19,180)],w=26,h=40,desc='Logical symbol for Raytac MDBT50Q-1MV2; complete 61-pad PCB symbol/footprint still to be created from Raytac drawing'))

symbols=[]; wires=[]; labels=[]; ncs=[]; texts=[]

def inst(lib,ref,val,x,y,foot='',datasheet='',desc='',dnp='no'):
    sid=u()
    ls=next(s for s in LIBS if s.startswith(f'(symbol "BM:{lib}"'))
    nums=re.findall(r'\(number "([^"]+)"',ls)
    plist=[prop('Reference',ref,x,y-5),prop('Value',val,x,y+5),prop('Footprint',foot,x,y,hide=True),prop('Datasheet',datasheet,x,y,hide=True),prop('Description',desc,x,y,hide=True)]
    sl=[f'(symbol (lib_id "BM:{lib}") (at {x} {y} 0) (unit 1) (in_bom yes) (on_board yes) (uuid {sid})']
    sl += ['  '+p for p in plist]
    for num in nums: sl.append(f'  (pin "{num}" (uuid {u()}))')
    sl.append(f'  (instances (project "battery_monitor" (path "/{ROOT}" (reference "{ref}") (unit 1))))')
    sl.append(')')
    symbols.append('\n'.join(sl)); return sid

def wire(x1,y1,x2,y2): wires.append(f'(wire (pts (xy {x1} {y1}) (xy {x2} {y2})) (stroke (width 0) (type default)) (uuid {u()}))')
def label(name,x,y,rot=0): labels.append(f'(label "{name}" (at {x} {y} {rot}) {eff(1.0)} (uuid {u()}))')
def nc(x,y): ncs.append(f'(no_connect (at {x} {y}) (uuid {u()}))')
def text(s,x,y,size=1.27): texts.append(f'(text "{s}" (at {x} {y} 0) {eff(size)} (uuid {u()}))')

inst('CONN6','J1','VEHICLE',20,110,desc='BAT+, ground, ignition, door/courtesy, parking lights, spare input')
for name,yy in [('RAW_BAT',104),('GND',106.4),('VEH_IGN',108.8),('VEH_DOOR',111.2),('VEH_PARK',113.6),('VEH_AUX',116)]:
    wire(25,yy,31,yy); label(name,31,yy)

text('POWER / AUTOMOTIVE PROTECTION',20,20,1.6)
label('RAW_BAT',20,30); wire(20,30,28,30)
inst('TVS','D1','SM50T30CAY',28,42,'Diode_SMD:D_SMC','https://www.st.com/','5 kW bidirectional automotive TVS')
wire(28,37,28,30); wire(28,47,28,52); label('GND',28,52)
inst('DIODE','D2','STTH1R02-Y',42,30,'Diode_SMD:D_SOD-123F','https://www.st.com/','200 V automotive reverse-battery diode')
wire(28,30,37,30)
inst('R','R1','100R 1W',55,30,'Resistor_SMD:R_2512_6332Metric','','Supply isolation / pulse limiting')
wire(47,30,50,30); wire(60,30,66,30); label('VIN_PROTECTED',66,30)
inst('C','C1','4.7u 100V',66,42,'Capacitor_SMD:C_1210_3225Metric','','Protected input bulk capacitor'); wire(66,37,66,30); wire(66,47,66,52); label('GND',66,52)
inst('C','C2','100n 100V',74,42,'Capacitor_SMD:C_0805_2012Metric','','LDO input HF bypass'); wire(74,37,74,30); wire(74,47,74,52); label('GND',74,52)
inst('LDO8','U1','TPS7A1633AQDGNRQ1',92,36,'','https://www.ti.com/product/TPS7A16A-Q1','60 V 5 uA IQ fixed 3.3 V automotive LDO')
wire(82,30,74,30); wire(82,42,78,42); label('VIN_PROTECTED',78,42)
wire(102,30,110,30); label('3V3',110,30)
wire(92,45,92,52); label('GND',92,52); wire(92,48,92,52)
for yy in [32.4,34.8,39.6,42]: nc(102,yy)
inst('C','C3','10u 10V',112,42,'Capacitor_SMD:C_1206_3216Metric','','3.3 V bulk'); wire(112,37,112,30); wire(112,47,112,52); label('GND',112,52)
inst('C','C4','100n',120,42,'Capacitor_SMD:C_0805_2012Metric','','3.3 V HF bypass'); wire(120,37,120,30); wire(120,47,120,52); label('GND',120,52)

text('WAKE INPUT REFERENCE',130,20,1.4)
inst('R','R2','3.9M 1%',138,30,'Resistor_SMD:R_0805_2012Metric'); label('3V3',128,30); wire(128,30,133,30)
inst('R','R3','1.0M 1%',151,30,'Resistor_SMD:R_0805_2012Metric'); wire(143,30,146,30); wire(156,30,162,30); label('GND',162,30); label('VREF_WAKE',145,30)
inst('C','C5','100n',145,42,'Capacitor_SMD:C_0805_2012Metric'); wire(145,37,145,30); wire(145,47,145,52); label('GND',145,52)

inst('COMP4','U2','TLV7034QPWRQ1',170,112,'Package_SO:TSSOP-14_4.4x5mm_P0.65mm','https://www.ti.com/product/TLV7034-Q1','Quad nanopower automotive comparator')
wire(170,97,170,91); label('3V3',170,91); wire(170,127,170,133); label('GND',170,133)
for yy in [101.5,106.5,117.5,122.5]: wire(158,yy,153,yy); label('VREF_WAKE',153,yy)

rows=[('IGN',72,104.5,103),('DOOR',92,109.5,108),('PARK',112,114.5,116),('AUX',132,119.5,121)]
for idx,(name,row,plusy,outy) in enumerate(rows, start=1):
    y=row
    label('VEH_'+name,34,y); wire(34,y,40,y)
    inst('R',f'R{10+(idx-1)*4}', '4.7M 1%',45,y,'Resistor_SMD:R_1206_3216Metric')
    inst('R',f'R{11+(idx-1)*4}', '4.7M 1%',58,y,'Resistor_SMD:R_1206_3216Metric')
    wire(34,y,40,y); wire(50,y,53,y); wire(63,y,70,y); label(f'{name}_SENSE',70,y)
    inst('R',f'R{12+(idx-1)*4}','1.5M 1%',76,y+7,'Resistor_SMD:R_1206_3216Metric')
    label(f'{name}_SENSE',146,plusy); wire(146,plusy,158,plusy)
    label(f'{name}_SENSE',70,y+7); wire(70,y+7,71,y+7); wire(81,y+7,86,y+7); label('GND',86,y+7)
    inst('C',f'C{10+idx}', '4.7n',92,y+7,'Capacitor_SMD:C_0805_2012Metric'); wire(92,y+2,92,y+1); label(f'{name}_SENSE',92,y+1); wire(92,y+12,92,y+13); label('GND',92,y+13)
    inst('CLAMP3',f'D{2+idx}','BAV199-Q',108,y+7,'Package_TO_SOT_SMD:SOT-23','https://www.nexperia.com/product/BAV199-Q','Low leakage rail clamp'); wire(102,y+7,98,y+7); label(f'{name}_SENSE',98,y+7); wire(108,y+1,108,y); label('3V3',108,y); wire(108,y+13,108,y+14); label('GND',108,y+14)
    wire(182,outy,190,outy); label(f'{name}_WAKE',190,outy)
    inst('R',f'R{13+(idx-1)*4}','33M 1%',128,y+7,'Resistor_SMD:R_1206_3216Metric')
    label(f'{name}_WAKE',123,y+7); wire(133,y+7,139,y+7); label(f'{name}_SENSE',139,y+7)

wires=[w for w in wires if not re.search(r'\(xy ([\d.]+) ([\d.]+)\) \(xy \1 \2\)',w)]

text('BATTERY ADC',20,150,1.4)
label('RAW_BAT',20,160); wire(20,160,25,160)
inst('R','R30','3.32M 1%',30,160,'Resistor_SMD:R_1206_3216Metric'); inst('R','R31','3.32M 1%',43,160,'Resistor_SMD:R_1206_3216Metric'); wire(35,160,38,160); wire(48,160,55,160); label('VBAT_ADC',55,160)
inst('R','R32','806k 1%',62,168,'Resistor_SMD:R_1206_3216Metric'); label('VBAT_ADC',57,168); wire(67,168,72,168); label('GND',72,168)
inst('C','C20','10n',80,168,'Capacitor_SMD:C_0805_2012Metric'); wire(80,163,80,160); label('VBAT_ADC',80,160); wire(80,173,80,176); label('GND',80,176)
inst('CLAMP3','D7','BAV199-Q',94,168,'Package_TO_SOT_SMD:SOT-23'); wire(88,168,84,168); label('VBAT_ADC',84,168); wire(94,162,94,160); label('3V3',94,160); wire(94,174,94,176); label('GND',94,176)

text('MCU / BLE',205,20,1.4)
inst('MCU','U3','MDBT50Q-1MV2 (logical symbol)',225,110,'','https://www.raytac.com/','nRF52840 module; full 61-pad symbol and footprint still TBD')
wire(225,88,225,82); label('3V3',225,82); wire(225,132,225,138); label('GND',225,138)
for net,yy in [('IGN_WAKE',95),('DOOR_WAKE',99),('PARK_WAKE',103),('AUX_WAKE',107),('VBAT_ADC',113),('TEMP_BOARD_ADC',117),('TEMP_EXT_ADC',121),('REMOTE_ENABLE',125)]:
    wire(209,yy,203,yy); label(net,203,yy)
for net,yy in [('TEMP_BOARD_EXCITE',113),('TEMP_EXT_EXCITE',117),('REMOTE_START_OUT_DNP',121),('SWDIO',99),('SWDCLK',95),('RESET_N',103),('XL1',125),('XL2',129)]:
    wire(241,yy,247,yy); label(net,247,yy)

text('TEMPERATURE',120,150,1.4)
label('TEMP_BOARD_EXCITE',120,160); wire(120,160,125,160); inst('R','R40','10k 1%',130,160,'Resistor_SMD:R_0805_2012Metric'); wire(135,160,140,160); label('TEMP_BOARD_ADC',140,160)
inst('NTC','RT1','10k NTC TBD',150,168,'Resistor_SMD:R_0805_2012Metric'); wire(150,163,150,160); label('TEMP_BOARD_ADC',150,160); wire(150,173,150,176); label('GND',150,176)
label('TEMP_EXT_EXCITE',165,160); wire(165,160,170,160); inst('R','R41','10k 1%',175,160,'Resistor_SMD:R_0805_2012Metric'); wire(180,160,185,160); label('TEMP_EXT_ADC',185,160)
inst('CONN2','J2','EXT_NTC',195,168,desc='Remote battery thermistor connector'); wire(200,166,205,166); label('TEMP_EXT_ADC',205,166); wire(200,170,205,170); label('GND',205,170)

text('REMOTE START PROVISION',215,150,1.4)
label('3V3',215,160); wire(215,160,220,160); inst('R','R42','4.7M',225,160,'Resistor_SMD:R_0805_2012Metric'); wire(230,160,235,160); label('REMOTE_ENABLE',235,160)
inst('CONN2','J3','DPDT_SENSE_POLE',245,168,desc='Second pole of physical remote-start disable switch'); wire(250,166,255,166); label('REMOTE_ENABLE',255,166); wire(250,170,255,170); label('GND',255,170)
text('Future REMOTE_START_OUT driver intentionally DNP / not designed yet',215,180,1.0)

text('Prototype schematic: input/power values frozen for first build; full Raytac footprint, connectors, remote-start driver, and PCB layout remain open.',20,194,1.0)
text('Generated KiCad source; open/save in KiCad 10 and run ERC before PCB layout.',20,199,1.0)

schematic=['(kicad_sch','  (version 20231120)','  (generator "battery_monitor_generator")',f'  (uuid {ROOT})','  (paper "A3")','  (title_block (title "Low-power BLE battery monitor") (date "2026-08-16") (rev "0.1") (comment 1 "Prototype power, sensing, and wake-input schematic"))','  (lib_symbols']
for ls in LIBS: schematic.append('\n'.join('    '+ln for ln in ls.splitlines()))
schematic.append('  )')
for seq in [texts,wires,ncs,labels,symbols]:
    for item in seq: schematic.append('  '+item.replace('\n','\n  '))
schematic.append(f'  (sheet_instances (path "/" (page "1")))')
schematic.append(')')
textout='\n'.join(schematic)+'\n'
OUT_DIR = Path(__file__).resolve().parents[1]
OUT_DIR.mkdir(parents=True, exist_ok=True)
Path(OUT_DIR / 'battery_monitor.kicad_sch').write_text(textout)

pro={
  'board': {'3dviewports': [], 'design_settings': {'defaults': {}, 'diff_pair_dimensions': [], 'drc_exclusions': [], 'rules': {}, 'track_widths': [], 'via_dimensions': []}, 'layer_presets': [], 'viewports': []},
  'boards': [], 'cvpcb': {'equivalence_files': []},
  'erc': {'erc_exclusions': [], 'meta': {'version': 0}, 'pin_map': []},
  'libraries': {'pinned_footprint_libs': [], 'pinned_symbol_libs': []},
  'meta': {'filename': 'battery_monitor.kicad_pro', 'version': 2},
  'net_settings': {'classes': [{'bus_width': 12, 'clearance': 0.2, 'diff_pair_gap': 0.25, 'diff_pair_via_gap': 0.25, 'diff_pair_width': 0.2, 'line_style': 0, 'microvia_diameter': 0.3, 'microvia_drill': 0.1, 'name': 'Default', 'pcb_color': 'rgba(0, 0, 0, 0.000)', 'schematic_color': 'rgba(0, 0, 0, 0.000)', 'track_width': 0.25, 'via_diameter': 0.8, 'via_drill': 0.4, 'wire_width': 6}], 'meta': {'version': 3}, 'net_colors': None, 'netclass_assignments': None},
  'pcbnew': {'last_paths': {}, 'page_layout_descr_file': ''},
  'schematic': {'annotate_start_num': 0, 'drawing': {'dashed_lines_dash_length_ratio': 12.0, 'dashed_lines_gap_length_ratio': 3.0, 'default_line_thickness': 6.0, 'default_text_size': 50.0, 'field_names': [], 'intersheets_ref_own_page': False, 'intersheets_ref_prefix': '', 'intersheets_ref_short': False, 'intersheets_ref_show': False, 'intersheets_ref_suffix': '', 'junction_size_choice': 3, 'label_size_ratio': 0.375, 'operating_point_overlay_i_precision': 3, 'operating_point_overlay_i_range': '~A', 'operating_point_overlay_v_precision': 3, 'operating_point_overlay_v_range': '~V', 'overbar_offset_ratio': 1.23, 'pin_symbol_size': 25.0, 'text_offset_ratio': 0.15}, 'legacy_lib_dir': '', 'legacy_lib_list': []},
  'sheets': [], 'text_variables': {}
}
Path(OUT_DIR / 'battery_monitor.kicad_pro').write_text(json.dumps(pro, indent=2, sort_keys=True)+'\n')

s=textout
stack=[]; inq=False; esc=False
for i,ch in enumerate(s):
    if inq:
        if esc: esc=False
        elif ch=='\\': esc=True
        elif ch=='"': inq=False
    else:
        if ch=='"': inq=True
        elif ch=='(': stack.append(i)
        elif ch==')':
            if not stack: raise SystemExit(f'extra ) at {i}')
            stack.pop()
if inq or stack: raise SystemExit(f'parse issue quote={inq} stack={len(stack)}')
print('root',ROOT)
print('schematic bytes',len(textout.encode()),'lines',len(textout.splitlines()),'symbols',len(symbols),'wires',len(wires),'labels',len(labels))
print('balanced s-expression: yes')
