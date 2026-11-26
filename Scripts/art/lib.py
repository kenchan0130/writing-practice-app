"""Tiny helper to write plain SVG (no defs/use/clip/g) and auto-fit it to 512."""
import re

O = "#4a3428"   # outline
EYE = "#3b2f2a"
SW = 11
TARGET = 436    # max geometry size inside 512 (about 85-90% with strokes)


class Art:
    def __init__(self):
        self.els = []  # (tag, geom dict, attrs dict)
        self._part = None

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

    def eye(self, cx, cy, r=17, ry=None, tilt=0):
        """A big shiny eye: dark oval, big white highlight up-right, small one down-left."""
        ry = ry or r * 1.2
        self.ellipse(cx, cy, r, ry, EYE, sw=0, stroke="none")
        self.dot(cx + r * 0.32, cy - ry * 0.38, r * 0.42, "#ffffff")
        self.dot(cx - r * 0.38, cy + ry * 0.38, r * 0.2, "#ffffff")

    def cheek(self, cx, cy, rx=15, ry=9, col="#ff9aa8"):
        self.ellipse(cx, cy, rx, ry, col, sw=0, stroke="none", **{"fill-opacity": "0.65"})

    def lid(self, cx, cy, r, s=1):
        """A short lash flick on the outer corner of an eye."""
        self.path(f"M{cx + s * r * 0.8} {cy - r * 0.7} L{cx + s * r * 1.5} {cy - r * 1.1}", sw=6)

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

    def flipped(self, axis=256):
        """A left-right mirror copy (so a left-facing animal can face right)."""
        b = Art()
        for tag, g, a in self.els:
            g = dict(g)
            if tag == "path":
                g["d"] = mirror(g["d"], axis)
            elif tag in ("circle", "ellipse"):
                g["cx"] = 2 * axis - g["cx"]
            elif tag == "rect":
                g["x"] = 2 * axis - g["x"] - g["width"]
            elif tag == "line":
                g["x1"] = 2 * axis - g["x1"]; g["x2"] = 2 * axis - g["x2"]
            b.els.append((tag, g, dict(a)))
        return b

    def leg(self, joints, widths, yg, fill, d=-1, foot=22, h=16, start=None, sw=SW):
        """Old way (outline per leg). New art: use part() + sil(limb_d(...))."""
        full, neg, fs, pos = _limb(joints, widths, yg, d, foot, h)
        n = len(joints)
        self.path(smooth(full), fill=fill, sw=0, stroke="none")
        if start is None:
            self.path(smooth(full), sw=sw)
        else:
            k = start
            self.path(smooth(neg[k:] + fs + pos[::-1][:n - k], closed=False), sw=sw)

    # --- fills first, outline made automatically ---------------------------
    def part(self, ow=SW):
        """`with a.part():` groups shapes into one part. Shapes added with sil()/sil_ellipse() inside it
        are drawn as fills only; when the block ends, one outline (ow wide, outside the shapes) is put
        behind all of them. So only the outer edge of the whole part gets a line, and shapes of one part
        join without seams. A later part draws its outline over earlier parts, which gives the line where
        a front part overlaps a back part. Lines inside a part: ink()."""
        return _Part(self, ow)

    def sil(self, d, fill):
        """A filled shape that belongs to the outline of the current part (alone: its own outline)."""
        if self._part is None:
            with self.part():
                self.sil(d, fill)
            return
        self._part.append(("path", {"d": d}))
        self.blob(d, fill)

    def sil_ellipse(self, cx, cy, rx, ry, fill):
        if self._part is None:
            with self.part():
                self.sil_ellipse(cx, cy, rx, ry, fill)
            return
        self._part.append(("ellipse", {"cx": cx, "cy": cy, "rx": rx, "ry": ry}))
        self.ellipse(cx, cy, rx, ry, fill, sw=0, stroke="none")

    def ink(self, cubics, w=SW - 2, a=0.0, b=0.0, col=O):
        """A line inside a shape, as a filled tapered stroke: full width w in the middle, a*w at the start
        and b*w at the end (0 = fades to a point, 1 = full, e.g. where it leaves the outline)."""
        self.blob(ink_d(cubics, w, a, b), col)

    def ground_params(self, ground=473, target=TARGET):
        """Fit for side-view animals: the widest side fills `target`, the feet stay at y = `ground`
        (the old art put its feet there), centred left-right."""
        x0, y0, x1, y1 = self._bbox()
        s = min(target / (x1 - x0), target / (y1 - y0))
        return s, 256 - s * (x0 + x1) / 2, ground - s * y1

    def svg(self, target=TARGET, params=None):
        if params:
            s, tx, ty = params
        else:
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


def fit_params(arts, target=TARGET):
    """One scale/offset for several Arts (union bbox), so poses line up."""
    bs = [a._bbox() for a in arts]
    x0 = min(b[0] for b in bs); y0 = min(b[1] for b in bs)
    x1 = max(b[2] for b in bs); y1 = max(b[3] for b in bs)
    s = target / max(x1 - x0, y1 - y0)
    return s, 256 - s * (x0 + x1) / 2, 256 - s * (y0 + y1) / 2


def limb(x, y_top, y_ground, w_top, w_bot, d=-1, foot=22, lean=0, toe_h=14):
    """A tapered leg ending in a rounded paw that points toward d (-1 left, +1 right).
    x is the leg's centre line at the top; the ankle sits at x + lean. Closed path, fill it yourself."""
    xa = x + lean
    xf, xb = xa + d * w_bot / 2, xa - d * w_bot / 2
    tf, tb = x + d * w_top / 2, x - d * w_top / 2
    ya = y_ground - toe_h - 6
    ym = y_top + (ya - y_top) * 0.45
    tx = xf + d * foot
    r = toe_h
    return (f"M{tf:g} {y_top:g} C{tf:g} {ym:g} {xf:g} {ym:g} {xf:g} {ya:g} "
            f"C{xf:g} {ya + 8:g} {tx:g} {ya + 4:g} {tx:g} {y_ground - r * 0.5:g} "
            f"C{tx:g} {y_ground + 1:g} {tx - d * 6:g} {y_ground:g} {tx - d * 14:g} {y_ground:g} "
            f"L{xb + d * 4:g} {y_ground:g} C{xb - d * 4:g} {y_ground:g} {xb:g} {ya + 12:g} {xb:g} {ya:g} "
            f"C{xb:g} {ym:g} {tb:g} {ym:g} {tb:g} {y_top:g} Z")


def smooth(pts, closed=True):
    """A smooth bezier path through the points (Catmull-Rom). Handy for organic outlines and spots."""
    n = len(pts)
    f = lambda v: f"{v:.1f}".rstrip("0").rstrip(".")
    out = [f"M{f(pts[0][0])} {f(pts[0][1])}"]
    last = n if closed else n - 1
    for i in range(last):
        p0 = pts[(i - 1) % n] if (closed or i > 0) else pts[0]
        p1, p2 = pts[i], pts[(i + 1) % n]
        p3 = pts[(i + 2) % n] if (closed or i + 2 < n) else pts[-1]
        c1 = (p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6)
        c2 = (p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6)
        out.append(f"C{f(c1[0])} {f(c1[1])} {f(c2[0])} {f(c2[1])} {f(p2[0])} {f(p2[1])}")
    return " ".join(out) + (" Z" if closed else "")


def bez_pts(cubics, n=40):
    """Points + unit normals along a chain of cubic beziers [(x0,y0,x1,y1,x2,y2,x3,y3), ...]."""
    res = []
    k = len(cubics)
    for i, (x0, y0, x1, y1, x2, y2, x3, y3) in enumerate(cubics):
        m = max(2, n // k)
        for j in range(m + (1 if i == k - 1 else 0)):
            t = j / m
            u = 1 - t
            x = u**3 * x0 + 3 * u * u * t * x1 + 3 * u * t * t * x2 + t**3 * x3
            y = u**3 * y0 + 3 * u * u * t * y1 + 3 * u * t * t * y2 + t**3 * y3
            dx = 3 * u * u * (x1 - x0) + 6 * u * t * (x2 - x1) + 3 * t * t * (x3 - x2)
            dy = 3 * u * u * (y1 - y0) + 6 * u * t * (y2 - y1) + 3 * t * t * (y3 - y2)
            L = (dx * dx + dy * dy) ** 0.5 or 1
            res.append((x, y, -dy / L, dx / L))
    return res


def at(cubics, t, off=0.0, n=60):
    """Point at fraction t (0..1) along the chain, pushed `off` to the side (+ = right of travel)."""
    p = bez_pts(cubics, n)
    x, y, nx, ny = p[min(len(p) - 1, int(round(t * (len(p) - 1))))]
    return x + nx * off, y + ny * off


def taper(cubics, w0, w1, n=48, cap=True):
    """A closed outline around a centre line whose width goes from w0 to w1: trunks, tails, necks, arms."""
    import math
    p = bez_pts(cubics, n)
    L, R = [], []
    for i, (x, y, nx, ny) in enumerate(p):
        w = (w0 + (w1 - w0) * i / (len(p) - 1)) / 2
        L.append((x + nx * w, y + ny * w)); R.append((x - nx * w, y - ny * w))
    x, y, nx, ny = p[-1]
    r = w1 / 2
    a0 = math.atan2(ny, nx)
    capp = []
    if cap:
        for j in range(1, 8):
            a = a0 - math.pi * j / 8
            capp.append((x + r * math.cos(a), y + r * math.sin(a)))
    pts = L + capp + R[::-1]
    f = lambda v: f"{v:.1f}".rstrip("0").rstrip(".")
    return "M" + " L".join(f"{f(a)} {f(b)}" for a, b in pts) + " Z"


class _Part:
    def __init__(self, art, ow):
        self.art, self.ow = art, ow

    def __enter__(self):
        self.art._part = []
        self.at = len(self.art.els)
        return self.art

    def __exit__(self, *exc):
        a = self.art
        shapes, a._part = a._part, None
        attrs = {"fill": O, "stroke": O, "stroke-width": 2 * self.ow, "stroke-linejoin": "round", "stroke-linecap": "round"}
        back = []
        ds = [g["d"] for tag, g in shapes if tag == "path"]
        if ds:
            back.append(("path", {"d": " ".join(ds)}, dict(attrs)))
        back += [(tag, dict(g), dict(attrs)) for tag, g in shapes if tag != "path"]
        a.els[self.at:self.at] = back
        return False


def _limb(joints, widths, yg, d, foot, h):
    n = len(joints)
    neg, pos = [], []
    for i, (x, y) in enumerate(joints):
        p, q = joints[max(i - 1, 0)], joints[min(i + 1, n - 1)]
        tx, ty = q[0] - p[0], q[1] - p[1]
        L = (tx * tx + ty * ty) ** 0.5 or 1
        nx, ny = ty / L, -tx / L
        w = widths[i] / 2
        pos.append((x + nx * w, y + ny * w)); neg.append((x - nx * w, y - ny * w))
    xa, ya = joints[-1]
    wa = widths[-1]
    T = (xa + d * (wa / 2 + foot), yg - h * 0.55)
    Bt = (xa + d * (wa / 2 + foot * 0.55), yg - 1)
    M = (xa, yg)
    H = (xa - d * wa / 2, yg - 3)
    fs = [T, Bt, M, H] if d < 0 else [H, M, Bt, T]
    return neg + fs + pos[::-1], neg, fs, pos


def limb_d(joints, widths, yg, d=-1, foot=22, h=16):
    """Closed path of a leg: centre line through joints (hip, knee/hock, ankle...), a width at each joint,
    a rounded paw on the ground line yg pointing toward d. Start the first joint well inside the body."""
    return smooth(_limb(joints, widths, yg, d, foot, h)[0])


def ink_d(cubics, w, a=0.0, b=0.0, n=28):
    p = bez_pts(cubics, n)
    m = len(p) - 1
    ss = lambda t: t * t * (3 - 2 * t)
    L, R = [], []
    for i, (x, y, nx, ny) in enumerate(p):
        t = i / m
        k = a + (1 - a) * ss(min(1, t * 2.2)) if t < 0.5 else b + (1 - b) * ss(min(1, (1 - t) * 2.2))
        h = max(0.4, w * k / 2)
        L.append((x + nx * h, y + ny * h)); R.append((x - nx * h, y - ny * h))
    f = lambda v: f"{v:.1f}".rstrip("0").rstrip(".")
    return "M" + " L".join(f"{f(u)} {f(v)}" for u, v in L + R[::-1]) + " Z"
