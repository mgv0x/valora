from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# Google Play Feature Graphic: exactly 1024 x 500 px
W, H = 1024, 500
SCALE = 2
SW, SH = W * SCALE, H * SCALE  # 2048 x 1000

# Base image
img = Image.new("RGBA", (SW, SH), (27, 59, 43, 255))
draw = ImageDraw.Draw(img)

# 1. Background Gradient (Deep Forest Green to Rich Pine)
# Top-left: (22, 48, 35) -> Bottom-right: (34, 73, 53)
for y in range(SH):
    ratio = y / SH
    r = int(22 + (38 - 22) * ratio)
    g = int(48 + (82 - 48) * ratio)
    b = int(35 + (58 - 35) * ratio)
    draw.line([(0, y), (SW, y)], fill=(r, g, b, 255))

# Decorative organic background ambient glow
glow_layer = Image.new("RGBA", (SW, SH), (0, 0, 0, 0))
glow_draw = ImageDraw.Draw(glow_layer)

# Ambient emerald circle top-right
glow_draw.ellipse([SW - 600, -200, SW + 400, 700], fill=(70, 145, 95, 45))
# Ambient warm golden/sage accent bottom-left
glow_draw.ellipse([-200, SH - 500, 600, SH + 300], fill=(45, 100, 68, 50))
glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(100))
img = Image.alpha_composite(img, glow_layer)
draw = ImageDraw.Draw(img)

# Fonts
bold_font_path = "C:/Windows/Fonts/segoeuib.ttf"
semi_font_path = "C:/Windows/Fonts/seguisb.ttf"
reg_font_path = "C:/Windows/Fonts/segoeui.ttf"

font_tag = ImageFont.truetype(bold_font_path, 22 * SCALE)
font_brand = ImageFont.truetype(bold_font_path, 60 * SCALE)
font_h1 = ImageFont.truetype(bold_font_path, 48 * SCALE)
font_sub = ImageFont.truetype(reg_font_path, 22 * SCALE)
font_badge = ImageFont.truetype(semi_font_path, 18 * SCALE)

font_card_title = ImageFont.truetype(bold_font_path, 22 * SCALE)
font_card_sub = ImageFont.truetype(reg_font_path, 17 * SCALE)
font_card_pill = ImageFont.truetype(bold_font_path, 15 * SCALE)

# 2. LEFT SIDE CONTENT
LEFT_X = 90 * SCALE

# Pill Tag at Top
tag_text = "GESTAO INTELIGENTE DE ALIMENTOS"
tag_w = draw.textlength(tag_text, font=font_tag)
tag_h = 44 * SCALE
tag_y = 65 * SCALE

draw.rounded_rectangle(
    [LEFT_X, tag_y, LEFT_X + tag_w + 36 * SCALE, tag_y + tag_h],
    radius=22 * SCALE,
    fill=(255, 255, 255, 30),
    outline=(145, 205, 160, 80),
    width=2 * SCALE
)
draw.ellipse(
    [LEFT_X + 16 * SCALE, tag_y + 16 * SCALE, LEFT_X + 28 * SCALE, tag_y + 28 * SCALE],
    fill=(120, 215, 150, 255)
)
draw.text((LEFT_X + 36 * SCALE, tag_y + 8 * SCALE), tag_text, fill=(210, 240, 220), font=font_tag)

# App Logo Icon + Wordmark
logo_y = 135 * SCALE
if os.path.exists("valora_icon_512.png"):
    app_icon = Image.open("valora_icon_512.png").convert("RGBA")
    icon_size = 84 * SCALE
    app_icon = app_icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    
    # Shadow for icon
    icon_shadow = Image.new("RGBA", (SW, SH), (0, 0, 0, 0))
    is_draw = ImageDraw.Draw(icon_shadow)
    is_draw.rounded_rectangle(
        [LEFT_X, logo_y + 6 * SCALE, LEFT_X + icon_size, logo_y + icon_size + 6 * SCALE],
        radius=20 * SCALE,
        fill=(0, 0, 0, 80)
    )
    icon_shadow = icon_shadow.filter(ImageFilter.GaussianBlur(12 * SCALE))
    img = Image.alpha_composite(img, icon_shadow)
    draw = ImageDraw.Draw(img)
    
    img.paste(app_icon, (LEFT_X, logo_y), app_icon)
    wordmark_x = LEFT_X + icon_size + 24 * SCALE
else:
    wordmark_x = LEFT_X

draw.text((wordmark_x, logo_y + 4 * SCALE), "Valora", fill=(255, 255, 255), font=font_brand)

# Main Headline
h1_y = 245 * SCALE
draw.text((LEFT_X, h1_y), "Menos desperdício.", fill=(255, 255, 255), font=font_h1)
draw.text((LEFT_X, h1_y + 54 * SCALE), "Mais economia.", fill=(132, 215, 155), font=font_h1)

# Subtitle
sub_y = 370 * SCALE
draw.text((LEFT_X, sub_y), "Controle de validades, despensa organizada", fill=(205, 225, 215), font=font_sub)
draw.text((LEFT_X, sub_y + 30 * SCALE), "e consumo consciente para a sua casa.", fill=(175, 200, 185), font=font_sub)

# Bottom Feature Badges
badge_y = 445 * SCALE
badges = [
    ("100% Offline", (50, 110, 75)),
    ("Zero Anuncios", (45, 95, 115)),
    ("Alertas no Celular", (110, 80, 50))
]

bx = LEFT_X
for text, col in badges:
    bw = draw.textlength(text, font=font_badge) + 32 * SCALE
    bh = 38 * SCALE
    draw.rounded_rectangle(
        [bx, badge_y, bx + bw, badge_y + bh],
        radius=19 * SCALE,
        fill=(col[0], col[1], col[2], 180),
        outline=(255, 255, 255, 50),
        width=1 * SCALE
    )
    draw.text((bx + 16 * SCALE, badge_y + 8 * SCALE), text, fill=(245, 255, 248), font=font_badge)
    bx += bw + 14 * SCALE


# 3. RIGHT SIDE: FLOATING APP UI CARDS
def draw_card(cx, cy, cw, ch, title, sub, pill_text, pill_color, pill_bg, icon_char=""):
    # Card shadow
    shadow = Image.new("RGBA", (SW, SH), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow)
    s_draw.rounded_rectangle(
        [cx, cy + 8 * SCALE, cx + cw, cy + ch + 8 * SCALE],
        radius=18 * SCALE,
        fill=(0, 0, 0, 100)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(16 * SCALE))
    global img, draw
    img = Image.alpha_composite(img, shadow)
    draw = ImageDraw.Draw(img)

    # Card background (clean elevated white/surface)
    draw.rounded_rectangle(
        [cx, cy, cx + cw, cy + ch],
        radius=18 * SCALE,
        fill=(255, 255, 255, 248),
        outline=(230, 240, 235, 200),
        width=2 * SCALE
    )

    # Accent color strip on left
    draw.rounded_rectangle(
        [cx, cy, cx + 8 * SCALE, cy + ch],
        radius=4 * SCALE,
        fill=pill_color
    )

    # Title & Sub
    draw.text((cx + 26 * SCALE, cy + 18 * SCALE), title, fill=(25, 38, 30), font=font_card_title)
    draw.text((cx + 26 * SCALE, cy + 48 * SCALE), sub, fill=(100, 120, 110), font=font_card_sub)

    # Pill Badge on right
    pw = draw.textlength(pill_text, font=font_card_pill) + 24 * SCALE
    ph = 30 * SCALE
    px = cx + cw - pw - 20 * SCALE
    py = cy + 26 * SCALE
    draw.rounded_rectangle(
        [px, py, px + pw, py + ph],
        radius=15 * SCALE,
        fill=pill_bg,
        outline=pill_color,
        width=1 * SCALE
    )
    draw.text((px + 12 * SCALE, py + 6 * SCALE), pill_text, fill=pill_color, font=font_card_pill)


# Card 1: Vence Hoje (Morangos)
CARD_W = 390 * SCALE
CARD_H = 88 * SCALE
RX = SW - CARD_W - 85 * SCALE

draw_card(
    cx=RX,
    cy=90 * SCALE,
    cw=CARD_W,
    ch=CARD_H,
    title="Morangos Frescos",
    sub="Geladeira  |  500g  |  Frutas",
    pill_text="VENCE HOJE",
    pill_color=(215, 60, 60),
    pill_bg=(255, 235, 235)
)

# Card 2: Vence em 2 dias (Leite Integral)
draw_card(
    cx=RX - 25 * SCALE,
    cy=200 * SCALE,
    cw=CARD_W,
    ch=CARD_H,
    title="Iogurte Grego Natural",
    sub="Geladeira  |  2 un  |  Laticinios",
    pill_text="VENCE EM 2 DIAS",
    pill_color=(225, 130, 45),
    pill_bg=(255, 243, 230)
)

# Card 3: Seguro (Queijo Minas Frescal)
draw_card(
    cx=RX + 10 * SCALE,
    cy=310 * SCALE,
    cw=CARD_W,
    ch=CARD_H,
    title="Queijo Minas Frescal",
    sub="Geladeira  |  1 un  |  Laticinios",
    pill_text="SEGURO (7 DIAS)",
    pill_color=(40, 145, 75),
    pill_bg=(235, 248, 238)
)

# Card 4: Impacto / Economia Pill at Bottom Right
impact_w = CARD_W + 15 * SCALE
impact_h = 65 * SCALE
ix = RX - 15 * SCALE
iy = 415 * SCALE

draw.rounded_rectangle(
    [ix, iy, ix + impact_w, iy + impact_h],
    radius=18 * SCALE,
    fill=(20, 45, 32, 230),
    outline=(100, 180, 130, 120),
    width=2 * SCALE
)

draw.text((ix + 24 * SCALE, iy + 12 * SCALE), "ECONOMIA ESTE MES", fill=(130, 205, 160), font=font_card_pill)
draw.text((ix + 24 * SCALE, iy + 32 * SCALE), "R$ 314,80 poupados de desperdicio", fill=(255, 255, 255), font=font_card_title)

# Downscale 2x with LANCZOS to exact 1024 x 500 px
final_img = img.resize((W, H), Image.Resampling.LANCZOS)

# Save as PNG (RGB 24-bit without alpha or RGB PNG)
final_rgb = final_img.convert("RGB")
final_rgb.save("valora_feature_graphic_1024x500.png", "PNG", optimize=True)
final_rgb.save("valora_web/valora_feature_graphic_1024x500.png", "PNG", optimize=True)
print("SUCCESS: valora_feature_graphic_1024x500.png generated (1024x500 px)")
