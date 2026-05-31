"""Extract all config files from HTML showcase to disk.
Finds each config card, parses its tabs, and writes files."""
import os, re, html as html_mod

html_path = 'C:/Users/HP/Downloads/07_Code/arch-hyprland-rice/hyprland-rice-showcase.html'
base = 'C:/Users/HP/Downloads/07_Code/arch-hyprland-rice'

with open(html_path, encoding='utf-8') as f:
    content = f.read()

config_start = content.find('<!-- CONFIG SECTION -->')
config_end = content.find('<!-- KEYBINDS -->')
config_block = content[config_start:config_end]

# Find each card by its title and extract the surrounding block
# Use the fact that each card starts with <div class="config-card"> and
# the title follows shortly after
titles = list(re.finditer(r'config-card-title">([^<]+)</div>', config_block))

written = []

for i, m in enumerate(titles):
    title = m.group(1).strip()
    title_pos = m.start()
    
    # Find the opening <div class="config-card"> for THIS card
    # Go backward from title_pos
    card_start = config_block.rfind('<div class="config-card">', 0, title_pos)
    if card_start < 0:
        print(f"  SKIP {title}: no card start found")
        continue
    
    # Find the card end by tracking div depth from card_start
    pos = card_start + len('<div class="config-card">')
    depth = 1
    while pos < len(config_block):
        # Scan for next tag
        nxt = config_block.find('<', pos)
        if nxt < 0:
            break
        
        tag_end = config_block.find('>', nxt)
        if tag_end < 0:
            break
        
        tag = config_block[nxt:tag_end+1]
        
        if tag.startswith('</div'):
            depth -= 1
            if depth == 0:
                card_end = tag_end + 1
                break
            pos = tag_end + 1
        elif tag.startswith('<div'):
            depth += 1
            pos = tag_end + 1
        else:
            pos = tag_end + 1
    
    if depth != 0:
        print(f"  SKIP {title}: depth tracking failed (depth={depth})")
        continue
    
    card_html = config_block[card_start:card_end]
    
    # Extract tab buttons and panels from this card only
    tab_btns = re.findall(r'tab-btn[^>]*>([^<]+)', card_html)
    tab_panels = re.findall(
        r'<div id="[^"]*" class="tab-panel[^"]*">\s*<pre>(.*?)</pre>',
        card_html, re.DOTALL
    )
    
    if not tab_panels:
        print(f"  SKIP {title}: no tab panels found")
        continue
    
    print(f"\n  {title}:")
    
    for idx, (btn_name, panel_html) in enumerate(zip(tab_btns, tab_panels)):
        btn_name = btn_name.strip()
        
        # Decode HTML and strip syntax spans
        raw = panel_html
        raw = raw.replace('&amp;', '&')
        raw = raw.replace('&lt;', '<')
        raw = raw.replace('&gt;', '>')
        raw = raw.replace('&quot;', '"')
        raw = raw.replace('&#x27;', "'")
        raw = re.sub(r'<span[^>]*>', '', raw)
        raw = raw.replace('</span>', '')
        raw = raw.replace('&amp;', '&')  # double-decode if nested
        raw = raw.replace('&lt;', '<')
        raw = raw.replace('&gt;', '>')
        
        # Map title + button name to file path
        def determine_path(title, btn):
            t = title.strip()
            b = btn.strip()
            
            # Special handling for scripts: only write the first occurrence
            if t == 'scripts':
                dir_p = os.path.join(base, 'configs', 'hypr', 'scripts')
                return dir_p, b.replace('/', os.sep)
            
            if t == 'waybar':
                if '/' in b:
                    sub = os.path.dirname(b)
                    dir_p = os.path.join(base, 'configs', 'waybar', sub.replace('/', os.sep))
                    return dir_p, os.path.basename(b)
                else:
                    return os.path.join(base, 'configs', 'waybar'), b
            
            if t == 'neovim colorscheme':
                if 'gtk' in b:
                    sub = os.path.dirname(b).replace('/', os.sep)
                    dir_p = os.path.join(base, 'configs', sub)
                    return dir_p, os.path.basename(b)
                if 'cliphist' in b:
                    return os.path.join(base, 'configs', 'cliphist'), 'config'
                if 'swappy' in b:
                    return os.path.join(base, 'configs', 'swappy'), 'config'
                return os.path.join(base, 'configs', 'neovim'), b
            
            if t == 'swaync':
                return os.path.join(base, 'configs', 'swaync'), b
            
            if t == 'shell (.zshrc + .zshenv)':
                return os.path.join(base, 'configs', 'shell'), b
            
            if t == 'gtk-3.0':
                return os.path.join(base, 'configs', 'gtk-3.0'), b
            
            if t == 'systemd/user/*.service':
                return os.path.join(base, 'configs', 'systemd', 'user'), b
            
            if t == 'hyprland (Lua v0.55+)':
                return os.path.join(base, 'configs', 'hypr'), b
            
            if '/' in t:
                parts = t.split('/')
                dir_p = os.path.join(base, 'configs', *parts[:-1])
                return dir_p, parts[-1]
            
            # Single file cards
            single_map = {
                'kitty.conf': ('kitty', 'kitty.conf'),
                'hyprpaper.conf': ('hypr', 'hyprpaper.conf'),
                'hyprlock.conf': ('hypr', 'hyprlock.conf'),
                'hypridle.conf': ('hypr', 'hypridle.conf'),
                'style.css': ('swayosd', 'style.css'),
                'rofi/config.rasi': ('rofi', 'config.rasi'),
                'fastfetch/config.jsonc': ('fastfetch', 'config.jsonc'),
                'fontconfig/fonts.conf': ('fontconfig', 'fonts.conf'),
                'btop/btop.conf': ('btop', 'btop.conf'),
                'yazi/theme.toml': ('yazi', 'theme.toml'),
                'starship.toml': ('.', 'starship.toml'),
                'xdg-desktop-portal/hyprland-portals.conf': ('xdg-desktop-portal', 'hyprland-portals.conf'),
            }
            
            if t in single_map:
                subdir, fname = single_map[t]
                return os.path.join(base, 'configs', subdir), fname
            
            return os.path.join(base, 'configs'), f'{t}.conf'
        
        dir_path, filename = determine_path(title, btn_name)
        
        # For scripts card, write script files
        if title == 'scripts':
            # Use the tab button name as filename
            os.makedirs(dir_path, exist_ok=True)
            filepath = os.path.join(dir_path, btn_name)
        else:
            os.makedirs(dir_path, exist_ok=True)
            filepath = os.path.join(dir_path, filename)
        
        # Don't overwrite if already written (first tab wins for multi-tab cards)
        if os.path.exists(filepath):
            print(f"    already exists: {os.path.relpath(filepath, base)}")
            continue
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(raw)
        
        print(f"    {os.path.relpath(filepath, base)}")
        written.append(filepath)

print(f"\n=== Extracted {len(written)} files ===")
