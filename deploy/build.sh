#!/bin/zsh
# Builds the Bluehost launch package: dist/sr-site.zip (upload to public_html and extract).
# The draft keeps noindex; the launch build removes it.
set -e
cd "${0:a:h}/.."
rm -rf dist && mkdir -p dist/site
grep -v 'name="robots"' index.html > dist/site/index.html
# ship only the media index.html actually uses (media/ also holds concept-only files, e.g. unlicensed comps in media/thumbs)
mkdir -p dist/site/media
grep -o 'media/[A-Za-z0-9_./-]*' index.html | sort -u | while read -r f; do
  [[ "$f" == "media/" ]] && continue  # a bare "media/" in script (paths built at runtime), not a file
  top="media/${${f#media/}%%/*}"
  if [[ -d "$top" ]]; then mkdir -p "dist/site/$top" && cp -R "$top/." "dist/site/$top/"; elif [[ -f "$f" ]]; then cp "$f" dist/site/media/; fi
done
cp robots.txt sitemap.xml dist/site/
cp deploy/htaccess dist/site/.htaccess
find dist/site -name '.DS_Store' -delete
(cd dist/site && zip -qr ../sr-site.zip . -x '.DS_Store')
echo "dist/sr-site.zip $(du -h dist/sr-site.zip | cut -f1)"
