import urllib.request
import re
import html as htmlmod
import sys

PAGES = [
    ("Homepage", "https://www.thepartyspecialistllc.com/"),
    ("Testimonials", "https://www.thepartyspecialistllc.com/testimonials"),
    ("Sample Menus", "https://www.thepartyspecialistllc.com/sample-menus"),
    ("About Us", "https://www.thepartyspecialistllc.com/aboutus"),
    ("Food Drinks Desserts", "https://www.thepartyspecialistllc.com/food-drinks-desserts"),
    ("Our Staff", "https://www.thepartyspecialistllc.com/our-staff"),
    ("Cakes", "https://www.thepartyspecialistllc.com/cakes"),
    ("Room Displays", "https://www.thepartyspecialistllc.com/room-displays"),
    ("Gluten Free Menu", "https://www.thepartyspecialistllc.com/gluten-free-menu"),
    ("Contact", "https://www.thepartyspecialistllc.com/contact"),
    ("Guests", "https://www.thepartyspecialistllc.com/guests"),
    ("Slideshow", "https://www.thepartyspecialistllc.com/slideshow"),
    ("Post Covid", "https://www.thepartyspecialistllc.com/post-covid"),
]

headers = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"}

output = []

for name, url in PAGES:
    output.append(f"\n{'='*80}")
    output.append(f"# {name}")
    output.append(f"# URL: {url}")
    output.append(f"{'='*80}\n")
    
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=15) as resp:
            content = resp.read().decode('utf-8', errors='replace')
        
        # Extract rich text content (Wix WRichText components)
        rich_texts = re.findall(r'<div[^>]*class="[^"]*rich-text[^"]*"[^>]*>(.*?)</div>', content, re.DOTALL)
        
        seen = set()
        for rt in rich_texts:
            # Decode HTML entities
            decoded = htmlmod.unescape(rt)
            # Convert <br>, <p>, <div> to newlines
            decoded = re.sub(r'<br\s*/?>|</p>|</div>', '\n', decoded)
            # Remove remaining tags
            clean = re.sub(r'<[^>]+>', '', decoded).strip()
            # Skip duplicates and very short
            if clean and len(clean) > 2 and clean not in seen:
                seen.add(clean)
                output.append(clean)
        
        # Also extract from span elements with font styles (Wix text)
        spans = re.findall(r'<span[^>]*style="[^"]*font[^"]*"[^>]*>(.*?)</span>', content, re.DOTALL)
        for s in spans:
            decoded = htmlmod.unescape(s)
            clean = re.sub(r'<[^>]+>', '', decoded).strip()
            if clean and len(clean) > 5 and clean not in seen:
                seen.add(clean)
                output.append(clean)
        
        # Extract image URLs and alt text
        images = re.findall(r'<img[^>]*src="([^"]*)"[^>]*alt="([^"]*)"', content)
        if images:
            output.append("\n## Images Found:")
            for src, alt in images:
                if alt and 'data:image' not in src:
                    output.append(f"  - [{alt}] {src[:100]}")
        
        # Also extract WPhoto components
        photos = re.findall(r'"uri":"([^"]+\.(?:jpg|jpeg|png|gif|webp))"[^}]*"alt":"([^"]*)"', content)
        if photos:
            output.append("\n## Wix Photos:")
            for uri, alt in photos:
                if alt:
                    output.append(f"  - [{alt}] {uri}")
                else:
                    output.append(f"  - [no alt] {uri}")
        
        if not seen:
            output.append("(No text content extracted - page may be purely visual/gallery)")
            
    except Exception as e:
        output.append(f"ERROR fetching: {e}")

result = "\n".join(output)
with open("/Users/gregracki/partyspecialist/current-site-content.md", "w") as f:
    f.write(result)
print(f"Wrote {len(result)} chars to current-site-content.md")
print("First 3000 chars preview:")
print(result[:3000])
