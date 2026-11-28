"""めぐり KataSeed の絵（カタカナのことばの はじめの1語「バス」。D199）。
描き方は Content/Art/style-guide.md（part()/sil()/ink()。顔はつけない。本体は1つの部品）。"""
from lib import Art
from words import word, BLUE_D, WHITE, NAVY, c_rect, c_glass, c_line, c_wheel, c_lamp

BUS, BUS_D = "#f7c948", "#e3a92f"


@word
def basu():
    a = Art()
    with a.part():                                    # body and cab: one part
        a.sil("M44 184 Q44 152 76 152 L404 152 C436 152 454 168 462 198 L474 282 L474 346 Q474 376 444 376 "
              "L74 376 Q44 376 44 346 Z", BUS)
        a.blob("M45 344 L473 344 L473 346 Q473 375 444 375 L74 375 Q45 375 45 346 Z", BUS_D)   # shade under the stripe
        a.blob("M45 296 L473 296 L473 322 L45 322 Z", BLUE_D)                                   # stripe
        a.blob(c_rect(404, 160, 50, 16, 7), NAVY)                                              # route sign
    for x in (66, 134, 202, 270):                      # four side windows
        c_glass(a, c_rect(x, 190, 56, 64, 12), glint=(x + 10, 200, 20) if x == 66 else None)
    c_glass(a, c_rect(342, 186, 52, 150, 12), glint=None)                                      # door
    c_line(a, 368, 192, 368, 330, 7, s=0.6, e=0.6)                                             # door seam
    c_glass(a, "M410 190 L436 190 C444 190 448 196 450 204 L458 252 Q459 260 452 260 L410 260 Q404 260 404 254 "
               "L404 196 Q404 190 410 190 Z", glint=(414, 202, 22))                            # windshield
    a.blob(c_rect(402, 336, 40, 10, 5), WHITE)                                                 # handle strip on the bumper
    c_lamp(a, 462, 322, 10, 14)
    a.shine("M74 166 L210 166", sw=6)
    for x in (130, 388):
        c_wheel(a, x, 378, 46)
    return a
