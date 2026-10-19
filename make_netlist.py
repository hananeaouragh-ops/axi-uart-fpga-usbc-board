import os
import glob

# 1. البحث الأوتوماتيكي عن كونيكتور USB-C أنثى (Receptacle) خاص بـ الـ PCB
usb_footprint = None

fp_search_paths = [
    r"C:\Program Files\KiCad\*\share\kicad\footprints\Connector_USB.pretty",
    r"C:\Program Files\KiCad\share\kicad\footprints\Connector_USB.pretty"
]

found_receptacles = []
for p in fp_search_paths:
    for fp_dir in glob.glob(p):
        found_receptacles.extend(glob.glob(os.path.join(fp_dir, "*USB_C_Receptacle*.kicad_mod")))

if found_receptacles:
    exact_name = os.path.basename(found_receptacles[0]).replace(".kicad_mod", "")
    usb_footprint = f"Connector_USB:{exact_name}"
    print(f"[OK] Empreinte USB-C Receptacle trouvee : {usb_footprint}")
else:
    usb_footprint = "Connector_USB:USB_C_Receptacle_HRO_TYPE-C-31-M-12"
    print(f"[INFO] Utilisation du fallback USB-C : {usb_footprint}")

# 2. كتابة ملف Netlist بدون 'SHIELD'
netlist_content = f"""(export (version "E")
  (design
    (tool "Direct Python Netlist Generator")
  )
  (components
    (comp (ref "J1")
      (value "USB_C")
      (footprint "{usb_footprint}"))
    (comp (ref "U1")
      (value "AMS1117-3.3")
      (footprint "Package_TO_SOT_SMD:SOT-223-3_TabPin2"))
    (comp (ref "U2")
      (value "FT232RL")
      (footprint "Package_SO:SSOP-28_5.3x10.2mm_P0.65mm"))
    (comp (ref "J2")
      (value "Conn_01x06_Pin")
      (footprint "Connector_PinHeader_2.54mm:PinHeader_1x06_P2.54mm_Vertical"))
    (comp (ref "C1")
      (value "C")
      (footprint "Capacitor_SMD:C_0805_2012Metric"))
    (comp (ref "C2")
      (value "C")
      (footprint "Capacitor_SMD:C_0805_2012Metric"))
  )
  (nets
    (net (code "1") (name "VBUS")
      (node (ref "J1") (pin "A4"))
      (node (ref "J1") (pin "B4"))
      (node (ref "U1") (pin "3")))
    (net (code "2") (name "+3V3")
      (node (ref "U1") (pin "2"))
      (node (ref "U2") (pin "4"))
      (node (ref "U2") (pin "20"))
      (node (ref "J2") (pin "1"))
      (node (ref "C1") (pin "1"))
      (node (ref "C2") (pin "1")))
    (net (code "3") (name "GND")
      (node (ref "J1") (pin "A1"))
      (node (ref "J1") (pin "B1"))
      (node (ref "U1") (pin "1"))
      (node (ref "U2") (pin "7"))
      (node (ref "U2") (pin "18"))
      (node (ref "U2") (pin "21"))
      (node (ref "U2") (pin "25"))
      (node (ref "U2") (pin "26"))
      (node (ref "J2") (pin "6"))
      (node (ref "C1") (pin "2"))
      (node (ref "C2") (pin "2")))
    (net (code "4") (name "USB_DP")
      (node (ref "J1") (pin "A6"))
      (node (ref "U2") (pin "15")))
    (net (code "5") (name "USB_DN")
      (node (ref "J1") (pin "A7"))
      (node (ref "U2") (pin "16")))
    (net (code "6") (name "UART_TX")
      (node (ref "U2") (pin "1"))
      (node (ref "J2") (pin "2")))
    (net (code "7") (name "UART_RX")
      (node (ref "U2") (pin "5"))
      (node (ref "J2") (pin "3")))
  )
)
"""

with open("AXI_UART.net", "w", encoding="utf-8") as f:
    f.write(netlist_content)

print("\n---> SUCCESS: Netlist AXI_UART.net genere avec succes !")