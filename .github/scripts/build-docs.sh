#!/bin/bash
set -e

echo "🐍 Setting up Python environment..."
apt-get update -qq
apt-get install -y python3 python3-venv python3-pip > /dev/null

echo "📦 Creating and activating virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "⬆️ Upgrading pip and installing dependencies..."
pip install --upgrade pip pyyaml

echo "🧹 Cleaning up cached _site directory..."
rm -rf _site

echo "🔄 Copying DOCS to origin_DOCS..."
mv DOCS origin_DOCS

echo "🔄 Updating URL mappings..."
python .github/scripts/update_url_mappings.py

echo "🔄 Grouping documents by category..."
python .github/scripts/group_docs_by_category.py

echo "🖼 Render all documents into to HTML/DOCX"
sudo cp /usr/bin/chromium /usr/bin/chromium-browser
QUARTO_CHROMIUM_HEADLESS_MODE=new quarto render --to html --no-clean
QUARTO_CHROMIUM_HEADLESS_MODE=new quarto render --to docx --no-clean
find _site -type f -name 'index.docx' -delete

echo "🛠 Generate index.qmd files for all DOCS/* folders"e
node .github/scripts/generate_index_all.mjs

echo "📄 Render only index.qmd files using 'index' profile"
mv _quarto.yml _quarto_not_used.yml
mv _quarto-index.yml _quarto.yml
find DOCS -type f -name index.qmd -print0 | while IFS= read -r -d '' src; do
  echo "🔧 Rendering $src using profile=index..."
  QUARTO_CHROMIUM_HEADLESS_MODE=new quarto render "$src" --profile index --to html --no-clean
done
mv _quarto.yml _quarto-index.yml
cp _quarto_not_used.yml _quarto.yml && rm _quarto_not_used.yml

echo "🔄 Additional processing of index.html file"
echo '<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="refresh" content="0; url=DOCS/index.html" />
    <title>Redirecting...</title>
  </head>
  <body>
    <p>If you are not redirected automatically, <a href="DOCS/index.html">click here</a>.</p>
  </body>
</html>' > _site/index.html


echo "📄 Converting .docx files to .pdf..."
#chmod +x ./convert_docx_to_pdf.sh
timeout 3s .github/scripts/convert_docx_to_pdf.sh || true
timeout 10m .github/scripts/convert_docx_to_pdf.sh

echo "🧹 Cleaning up..."
find _site -type f -name '*.docx' -delete

cp ./404.html _site/404.html
cp ./redirect_map.json _site/redirect_map.json
cp ./url_mapping.json _site/url_mapping.json


echo "✅ Docs built successfully"