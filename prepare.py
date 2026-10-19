import pcbnew
board = pcbnew.GetBoard()
mm = pcbnew.FromMM

# 1. Placement (J1 f tarf l'carte, C1/C2 qrab l U2)
placements = {
    "J1": (103, 117.5, 270),   # ila USB ma-tl3ch l barra, beddel l'angle (90/180/270)
    "U1": (118, 105, 90),
    "U2": (132, 117.5, 0),
    "C1": (125, 108, 0),
    "C2": (140, 108, 0),
    "J2": (155, 117.5, 180),
}
for ref, (x, y, a) in placements.items():
    fp = board.FindFootprintByReference(ref)
    if fp:
        fp.SetPosition(pcbnew.VECTOR2I(mm(x), mm(y)))
        fp.SetOrientationDegrees(a)

# 2. Contour dyal l'carte
ox, oy, w, h = 98, 95, 65, 35
for d in list(board.GetDrawings()):
    if d.GetLayerName() == "Edge.Cuts":
        board.Remove(d)
pts = [(ox,oy),(ox+w,oy),(ox+w,oy+h),(ox,oy+h),(ox,oy)]
for i in range(4):
    s = pcbnew.PCB_SHAPE(board)
    s.SetShape(pcbnew.SHAPE_T_SEGMENT)
    s.SetStart(pcbnew.VECTOR2I(mm(pts[i][0]), mm(pts[i][1])))
    s.SetEnd(pcbnew.VECTOR2I(mm(pts[i+1][0]), mm(pts[i+1][1])))
    s.SetLayer(pcbnew.Edge_Cuts)
    s.SetWidth(mm(0.15))
    board.Add(s)

# 3. Msah les pistes l9dima
for t in list(board.GetTracks()):
    board.Remove(t)

# 4. Plan de masse GND (F.Cu + B.Cu)
gnd = board.FindNet("GND")
for z in list(board.Zones()):
    board.Remove(z)
for layer in (pcbnew.F_Cu, pcbnew.B_Cu):
    z = pcbnew.ZONE(board)
    z.SetLayer(layer)
    z.SetNet(gnd)
    z.SetMinThickness(mm(0.2))
    o = z.Outline()
    o.NewOutline()
    for x, y in [(ox+0.5,oy+0.5),(ox+w-0.5,oy+0.5),(ox+w-0.5,oy+h-0.5),(ox+0.5,oy+h-0.5)]:
        o.Append(mm(x), mm(y))
    board.Add(z)

# 5. Largeur dyal les pistes (power ktar 3ard)
nc = board.GetDesignSettings().m_NetSettings.GetDefaultNetclass()
nc.SetTrackWidth(mm(0.25))
nc.SetClearance(mm(0.2))
nc.SetViaDiameter(mm(0.6))
nc.SetViaDrill(mm(0.3))

# 6. Export l Freerouting
pcbnew.ExportSpecctraDSN(board, r"C:\Users\DELL\Downloads\board.dsn")
pcbnew.Refresh()
print("DSN jahez: board.dsn")