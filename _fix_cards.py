"""Clean up duplicate cards and fix div balance"""
html_path = 'C:/Users/HP/Downloads/07_Code/arch-hyprland-rice/hyprland-rice-showcase.html'

with open(html_path, encoding='utf-8') as f:
    content = f.read()

import re

# Find and remove the DUPLICATE cards at the end (btop, fontconfig, systemd, xdg-portal)
# The duplicates were inserted before </div><!-- /config-grid -->
# Remove them by finding the start of each and removing up to the config-grid end
config_grid = content.find('<!-- /config-grid -->')

# Find the first duplicate card - search for btop/btop.conf near the end
# There should be TWO btop cards - one at position ~7 and one near the end
# Remove the LAST occurrence of each
for marker in ['btop/btop.conf', 'fontconfig/fonts.conf', 'systemd/user/*.service', 'xdg-desktop-portal']:
    # Find all occurrences
    positions = [m.start() for m in re.finditer(re.escape(marker), content)]
    if len(positions) > 1:
        # Remove the LAST one (the duplicate)
        last_pos = positions[-1]
        # Find the card start (comment or config-card div)
        card_start = content.rfind('      <!-- ──', 0, last_pos)
        if card_start < 0:
            card_start = content.rfind('      <!--', 0, last_pos)
        # Find the card end by tracking the config-card div closing
        div_open = content.find('<div class="config-card"', card_start)
        # Navigate through multi-tab structure by finding 4 closing </div> after the </div> that closes the HEAD section
        # Actually let me find the Yazi card's template opening to find the matching close
        # Better: just find the </div> that comes right before </div><!-- /config-grid -->
        # or use depth tracking
        
        # Use a simpler approach: the duplicate cards are the LAST cards before </div><!-- /config-grid -->
        # Find the last card's start by looking backwards from config_grid
        # Then track div depth
        depth = 0
        pos = card_start
        first_div = content.find('<div', pos)
        if first_div >= 0:
            pos = first_div
            while pos < len(content):
                next_open = content.find('<div', pos + 1, pos + 100)
                next_close = content.find('</div>', pos + 1, pos + 100)
                
                if next_open < 0 and next_close < 0:
                    break
                
                if next_open >= 0 and (next_close < 0 or next_open < next_close):
                    depth += 1
                    pos = next_open + 4
                else:
                    depth -= 1
                    pos = next_close + 5
                    if depth < 0:
                        card_end = next_close + 6
                        break
                    if depth <= 0 and next_close < 0:
                        card_end = pos
                        break
            
            content = content[:card_start] + content[card_end:]
            print("Removed duplicate '%s' (%d-%d)" % (marker, card_start, card_end))

# Now fix div balance
opens = len(re.findall(r'<div[\s>]', content))
closes = len(re.findall(r'</div>', content))
print("After cleanup: %d opens, %d closes" % (opens, closes))

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(content)

# Verify card order
config_start = content.find('CONFIG SECTION')
section_open = content.find('<section class="sections" id="configs">', config_start)
config_section = content[section_open:]
cards = re.findall(r'config-card-title">([^<]+)<', config_section)
print("\n=== Config cards in order ===")
for i, c in enumerate(cards):
    print("  %2d. %s" % (i+1, c.strip()))
