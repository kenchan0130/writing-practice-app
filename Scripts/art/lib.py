"""Tiny helper to write plain SVG (no defs/use/clip/g) and auto-fit it to 512."""
import re

O = "#4a3428"   # outline
EYE = "#3b2f2a"
SW = 11
TARGET = 436    # max geometry size inside 512 (about 85-90% with strokes)


class Art:
    def __init__(self):
        self.els = []  # (tag, geom dict, attrs dict)

    # --- primitives -------------------------------------------------------
    def path(self, d, fill="none", sw=SW, stroke=O, **kw):
        self.els.append(("path", {"d": d}, self._a(fill, sw, stroke, kw)))

    def circle(self, cx, cy, r, fill, sw=SW, stroke=O, **kw):
        self.els.append(("circle", {"cx": cx, "cy": cy, "r": r}, self._a(fill, sw, stroke, kw)))

    def ellipse(self, cx, cy, rx, ry, fill, sw=SW, stroke=O, **kw):
        self.els.append(("ellipse", {"cx": cx, "cy": cy, "rx": rx, "ry": ry}, self._a(fill, sw, stroke, kw)))

    def rect(self, x, y, w, h, fill, rx=0, sw=SW, stroke=O, **kw):
        self.els.append(("rect", {"x": x, "y": y, "width": w, "height": h, "rx": rx}, self._a(fill, sw, stroke, kw)))

    def line(self, x1, y1, x2, y2, sw=SW, stroke=O, **kw):
        self.els.append(("line", {"x1": x1, "y1": y1, "x2": x2, "y2": y2}, self._a("none", sw, stroke, kw)))

    def tube(self, d, color, outer=40, inner=18):
        """A thick outlined bar along a path (outline + colour)."""
        self.path(d, sw=outer)
        self.path(d, stroke=color, sw=inner)

    def dot(self, cx, cy, r, fill=EYE, **kw):
        self.circle(cx, cy, r, fill, sw=0, stroke="none", **kw)

    def blob(self, d, fill, **kw):
        """Fill only, no outline."""
        self.path(d, fill=fill, sw=0, stroke="none", **kw)

    def shine(self, d, sw=7):
        self.path(d, stroke="#ffffff", sw=sw, **{"stroke-opacity": "0.6"})

    def face(self, cx=256, cy=180, gap=52, mouth_y=None, blush_y=None, blush_dx=96, r=15):
        for s in (-1, 1):
            x = cx + s * gap
            self.ellipse(x, cy, r, r * 1.2, EYE, sw=0, stroke="none")
            self.dot(x + 5, cy - 7, r * 0.37, "#ffffff")
            self.ellipse(cx + s * blush_dx, blush_y or cy + 42, 16, 10, "#ff9aa8", sw=0, stroke="none",
                         **{"fill-opacity": "0.7"})
        if mouth_y is not None:
            self.path(f"M{cx-14} {mouth_y} C{cx-6} {mouth_y+10} {cx+6} {mouth_y+10} {cx+14} {mouth_y}", sw=8)

    @staticmethod
    def _a(fill, sw, stroke, kw):
        a = {"fill": fill}
        if sw and stroke != "none":
            a.update({"stroke": stroke, "stroke-width": sw, "stroke-linejoin": "round", "stroke-linecap": "round"})
        for k, v in kw.items():
            a[k.replace("_", "-")] = v
        return a

    # --- fitting ----------------------------------------------------------
    def _bbox(self):
        xs, ys = [], []
        for tag, g, a in self.els:
            m = float(a.get("stroke-width", 0)) / 2
            if tag == "path":
                for x, y in _points(g["d"]):
                    xs += [x - m, x + m]; ys += [y - m, y + m]
            elif tag == "circle":
                xs += [g["cx"] - g["r"] - m, g["cx"] + g["r"] + m]; ys += [g["cy"] - g["r"] - m, g["cy"] + g["r"] + m]
            elif tag == "ellipse":
                xs += [g["cx"] - g["rx"] - m, g["cx"] + g["rx"] + m]; ys += [g["cy"] - g["ry"] - m, g["cy"] + g["ry"] + m]
            elif tag == "rect":
                xs += [g["x"] - m, g["x"] + g["width"] + m]; ys += [g["y"] - m, g["y"] + g["height"] + m]
            elif tag == "line":
                xs += [g["x1"], g["x2"]]; ys += [g["y1"], g["y2"]]
        return min(xs), min(ys), max(xs), max(ys)

    def svg(self, target=TARGET):
        x0, y0, x1, y1 = self._bbox()
        s = target / max(x1 - x0, y1 - y0)
        cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
        tx, ty = 256 - s * cx, 256 - s * cy
        f = lambda v: f"{v:.1f}".rstrip("0").rstrip(".")
        out = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">']
        for tag, g, a in self.els:
            if tag == "path":
                geom = f'd="{_tx_path(g["d"], s, tx, ty)}"'
            elif tag in ("circle", "ellipse"):
                parts = {"cx": s * g["cx"] + tx, "cy": s * g["cy"] + ty}
                for k in ("r", "rx", "ry"):
                    if k in g:
                        parts[k] = s * g[k]
                geom = " ".join(f'{k}="{f(v)}"' for k, v in parts.items())
            elif tag == "rect":
                parts = {"x": s * g["x"] + tx, "y": s * g["y"] + ty, "width": s * g["width"],
                         "height": s * g["height"], "rx": s * g["rx"]}
                geom = " ".join(f'{k}="{f(v)}"' for k, v in parts.items())
            elif tag == "line":
                parts = {"x1": s * g["x1"] + tx, "y1": s * g["y1"] + ty, "x2": s * g["x2"] + tx, "y2": s * g["y2"] + ty}
                geom = " ".join(f'{k}="{f(v)}"' for k, v in parts.items())
            attrs = " ".join(f'{k}="{v}"' for k, v in a.items())
            out.append(f"  <{tag} {geom} {attrs}/>")
        out.append("</svg>\n")
        return "\n".join(out)


_TOK = re.compile(r"[MLCSQTHVAZ]|-?\d*\.?\d+")


def _tokens(d):
    for t in _TOK.findall(d):
        yield t


def _parse(d):
    cmd, nums, res = None, [], []
    for t in _tokens(d):
        if t.isalpha():
            if cmd:
                res.append((cmd, nums))
            cmd, nums = t, []
        else:
            nums.append(float(t))
    if cmd:
        res.append((cmd, nums))
    return res


def _points(d):
    pts, cur = [], (0, 0)
    for c, n in _parse(d):
        if c in "MLCSQT":
            for i in range(0, len(n), 2):
                cur = (n[i], n[i + 1]); pts.append(cur)
        elif c == "H":
            for v in n:
                cur = (v, cur[1]); pts.append(cur)
        elif c == "V":
            for v in n:
                cur = (cur[0], v); pts.append(cur)
        elif c == "A":
            for i in range(0, len(n), 7):
                cur = (n[i + 5], n[i + 6]); pts.append(cur)
    return pts


def _tx_path(d, s, tx, ty):
    f = lambda v: f"{v:.1f}".rstrip("0").rstrip(".")
    out = []
    for c, n in _parse(d):
        if c in "MLCSQT":
            vals = [s * v + (tx if i % 2 == 0 else ty) for i, v in enumerate(n)]
        elif c == "H":
            vals = [s * v + tx for v in n]
        elif c == "V":
            vals = [s * v + ty for v in n]
        elif c == "A":
            vals = []
            for i in range(0, len(n), 7):
                rx, ry, rot, la, sf, x, y = n[i:i + 7]
                vals += [s * rx, s * ry, rot, la, sf, s * x + tx, s * y + ty]
        else:
            vals = []
        out.append(c + " ".join(f(v) for v in vals))
    return " ".join(out)


def mirror(d, axis=256):
    """Mirror an absolute path left-right around x = axis."""
    out = []
    for c, n in _parse(d):
        if c in "MLCSQT":
            vals = [(2 * axis - v) if i % 2 == 0 else v for i, v in enumerate(n)]
        elif c == "H":
            vals = [2 * axis - v for v in n]
        elif c == "A":
            vals = []
            for i in range(0, len(n), 7):
                rx, ry, rot, la, sf, x, y = n[i:i + 7]
                vals += [rx, ry, -rot, la, 1 - sf, 2 * axis - x, y]
        else:
            vals = n
        out.append(c + " ".join(f"{v:g}" for v in vals))
    return " ".join(out)


def shift(d, dx, dy):
    return _tx_path(d, 1, dx, dy)


def place(dst, src, dx=0, dy=0):
    """Copy all elements of src into dst, moved by (dx, dy)."""
    for tag, g, a in src.els:
        g = dict(g)
        if tag == "path":
            g["d"] = shift(g["d"], dx, dy)
        elif tag in ("circle", "ellipse"):
            g["cx"] += dx; g["cy"] += dy
        elif tag == "rect":
            g["x"] += dx; g["y"] += dy
        elif tag == "line":
            g["x1"] += dx; g["x2"] += dx; g["y1"] += dy; g["y2"] += dy
        dst.els.append((tag, g, dict(a)))
