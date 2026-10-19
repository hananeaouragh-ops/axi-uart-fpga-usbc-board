import pcbnew

board = pcbnew.GetBoard()
mm = pcbnew.FromMM

# 1. Debloquer tous les objets
for fp in board.GetFootprints():
    fp.SetLocked(False)
for t in board.GetTracks():
    t.SetLocked(False)

# 2. Contour de la carte (65 x 35 mm) sur Edge.Cuts
for d in list(board.GetDrawings()):
    if d.GetLayerName() == "Edge.Cuts":
        board.Remove(d)

ox, oy, w, h = 98, 95, 65, 35
pts = [(ox, oy), (ox + w, oy), (ox + w, oy + h), (ox, oy + h), (ox, oy)]
for i in range(4):
    s = pcbnew.PCB_SHAPE(board)
    s.SetShape(pcbnew.SHAPE_T_SEGMENT)
    s.SetStart(pcbnew.VECTOR2I(mm(pts[i][0]), mm(pts[i][1])))
    s.SetEnd(pcbnew.VECTOR2I(mm(pts[i + 1][0]), mm(pts[i + 1][1])))
    s.SetLayer(pcbnew.Edge_Cuts)
    s.SetWidth(mm(0.15))
    board.Add(s)

# 3. Plan de masse GND (F.Cu + B.Cu)
for z in list(board.Zones()):
    board.Remove(z)

gnd = board.FindNet("GND")
for layer in (pcbnew.F_Cu, pcbnew.B_Cu):
    z = pcbnew.ZONE(board)
    z.SetLayer(layer)
    z.SetNet(gnd)
    z.SetMinThickness(mm(0.2))
    try:
        z.SetPadConnection(pcbnew.ZONE_CONNECTION_FULL)
    except Exception:
        pass
    o = z.Outline()
    o.NewOutline()
    for x, y in [(ox + 0.5, oy + 0.5), (ox + w - 0.5, oy + 0.5),
                 (ox + w - 0.5, oy + h - 0.5), (ox + 0.5, oy + h - 0.5)]:
        o.Append(mm(x), mm(y))
    board.Add(z)

pcbnew.ZONE_FILLER(board).Fill(board.Zones())
pcbnew.Refresh()
print("Contour + GND jahzin. Dir Ctrl+S w DRC.")