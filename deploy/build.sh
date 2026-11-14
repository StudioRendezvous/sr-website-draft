#!/bin/zsh
# Builds the Bluehost launch package: dist/sr-site.zip (upload to public_html and extract).
# The home page is the Canvas design (concepts/f-canvas.html). The draft keeps noindex; the launch build removes it
# and points the page's ../media/ paths at media/ (it ships at the site root).
set -e
cd "${0:a:h}/.."
rm -rf dist && mkdir -p dist/site/media
python3 - <<'PY'
import re, os, shutil, sys
src = open('concepts/f-canvas.html', encoding='utf-8').read()
out = '\n'.join(l for l in src.split('\n') if 'name="robots"' not in l)
assert 'noindex' not in out, 'noindex is still in the page'
out = out.replace('../media', 'media')
assert '../' not in out, 'a relative path still points above the site root'
open('dist/site/index.html', 'w', encoding='utf-8').write(out)
# ship only the media the page uses: explicit media/... paths, plus the bare file names the script joins to media/ and media/thumbs/
names = set(re.findall(r"[\w./-]+\.(?:jpg|jpeg|webp|png|mp4|vtt|svg|woff2)\b", out))
copied, missing = 0, []
for n in sorted(names):
    n = n.split('studiorendezvous.net/')[-1]
    cands = [n] if n.startswith('media/') else ['media/' + n, 'media/thumbs/' + n]
    hit = False
    for c in cands:
        if os.path.isfile(c):
            os.makedirs(os.path.dirname('dist/site/' + c), exist_ok=True); shutil.copy2(c, 'dist/site/' + c); copied += 1; hit = True
    if not hit: missing.append(n)
print('media files:', copied)
if missing: print('NOT FOUND (check these):', ', '.join(missing))
PY
cp robots.txt sitemap.xml favicon.ico dist/site/
cp deploy/htaccess dist/site/.htaccess
find dist/site -name '.DS_Store' -delete
# the server only serves world-readable files (four team photos once shipped as 600 and came back 403)
find dist/site -type f -exec chmod 644 {} + ; find dist/site -type d -exec chmod 755 {} +
(cd dist/site && zip -qr ../sr-site.zip . -x '.DS_Store')
echo "dist/sr-site.zip $(du -h dist/sr-site.zip | cut -f1)"
