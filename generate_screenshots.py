import os
from playwright.sync_api import sync_playwright
from PIL import Image

screens = [
    ("01_inicio", "docs/stitch/02_inicio.html", "Tela Inicial: Visão Geral da Despensa, Alertas e Status"),
    ("02_despensa", "docs/stitch/03_despensa.html", "Minha Despensa: Estoque Completo, Categorias e Filtros"),
    ("03_validades", "docs/stitch/04_validades.html", "Centro de Validades: Alertas de Vencimento e Ações Rápidas"),
    ("04_impacto", "docs/stitch/05_meu_impacto.html", "Meu Impacto: Economia Real em R$ e Desperdício Evitado"),
    ("05_cadastro", "docs/stitch/06_adicionar_alimento.html", "Cadastro Ágil: Validades, Compartimentos e Categorias"),
    ("06_configuracoes", "docs/stitch/08_configuracoes.html", "Configurações: Banco Local SQLite, Backup e Privacidade LGPD"),
    ("07_premium", "docs/stitch/09_assinatura_premium.html", "Valora Pro: Sincronização em Nuvem e Recursos Avançados"),
    ("08_indique_e_ganhe", "docs/stitch/10_indique_e_ganhe.html", "Indique e Ganhe: Convide Amigos e Ganhe Premium")
]

os.makedirs("screenshots", exist_ok=True)
os.makedirs("valora_web/screenshots", exist_ok=True)

with sync_playwright() as p:
    browser = p.chromium.launch()
    
    # We use viewport 540 x 960 (standard modern 9:16 ratio)
    # With device_scale_factor = 2.0 -> exactly 1080 x 1920 px (high information density)
    page = browser.new_page(
        viewport={"width": 540, "height": 960},
        device_scale_factor=2.0,
        is_mobile=True,
        has_touch=True
    )
    
    for filename_base, rel_path, desc in screens:
        abs_path = os.path.abspath(rel_path).replace("\\", "/")
        url = f"file:///{abs_path}"
        page.goto(url)
        page.wait_for_timeout(600)
        
        # 1. 1080x1920 (Google Play standard 9:16)
        out_1080 = f"screenshots/{filename_base}_1080x1920.png"
        page.screenshot(path=out_1080)
        
        # Copy to valora_web for online viewing
        img = Image.open(out_1080)
        # Ensure RGB 24bpp without alpha if needed
        if img.mode != "RGB":
            img = img.convert("RGB")
        img.save(out_1080, "PNG", optimize=True)
        img.save(f"valora_web/{out_1080}", "PNG", optimize=True)
        
        sz_kb = os.path.getsize(out_1080) / 1024
        print(f"[1080x1920] {filename_base}: {img.size} ({sz_kb:.1f} KB) - {desc}")

    # Also generate a QHD 1440x2560 version (super high-res 9:16) for extra clarity
    page_qhd = browser.new_page(
        viewport={"width": 540, "height": 960},
        device_scale_factor=1440 / 540,  # 2.6666666666666665 -> 1440 x 2560
        is_mobile=True,
        has_touch=True
    )
    
    for filename_base, rel_path, desc in screens:
        abs_path = os.path.abspath(rel_path).replace("\\", "/")
        url = f"file:///{abs_path}"
        page_qhd.goto(url)
        page_qhd.wait_for_timeout(600)
        
        out_qhd = f"screenshots/{filename_base}_1440x2560.png"
        page_qhd.screenshot(path=out_qhd)
        
        img = Image.open(out_qhd)
        if img.mode != "RGB":
            img = img.convert("RGB")
        # Ensure exact 1440x2560
        if img.size != (1440, 2560):
            img = img.resize((1440, 2560), Image.Resampling.LANCZOS)
        img.save(out_qhd, "PNG", optimize=True)
        img.save(f"valora_web/{out_qhd}", "PNG", optimize=True)
        
        sz_kb = os.path.getsize(out_qhd) / 1024
        print(f"[1440x2560] {filename_base}: {img.size} ({sz_kb:.1f} KB)")
        
    browser.close()

print("ALL SCREENSHOTS GENERATED SUCCESSFULLY!")
