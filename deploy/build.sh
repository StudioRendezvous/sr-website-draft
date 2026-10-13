#!/bin/zsh
# Builds the Bluehost launch package: dist/sr-site.zip (upload to public_html and extract).
# The draft keeps noindex; the launch build removes it.
set -e
cd "${0:a:h}/.."
rm -rf dist && mkdir -p dist/site
grep -v 'name="robots"' index.html > dist/site/index.html
cp -R media robots.txt sitemap.xml dist/site/
cp deploy/htaccess dist/site/.htaccess
find dist/site -name '.DS_Store' -delete
(cd dist/site && zip -qr ../sr-site.zip . -x '.DS_Store')
echo "dist/sr-site.zip $(du -h dist/sr-site.zip | cut -f1)"
