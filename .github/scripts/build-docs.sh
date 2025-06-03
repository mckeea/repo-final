#!/bin/bash
set -e

# echo "🐍 Setting up Python environment..."
# apt-get update
# apt-get install -y python3 python3-venv python3-pip

# echo "📦 Creating virtual environment..."
# python3 -m venv venv
# source venv/bin/activate

# echo "⬆️ Upgrading pip inside virtual environment..."
# pip install --upgrade pip

# echo "📦 Installing Python dependencies..."
# pip install \
#     keybert \
#     ruamel.yaml \
#     pyyaml \
#     transformers==4.37.2 \
#     accelerate==0.27.2

# source venv/bin/activate

# echo "🛠 Setting up default Quarto configuration..."
# mv _quarto_not_used.yaml _quarto.yaml

# echo "🏷 Generating keywords..."
# python scripts/render/generate_keywords.py

#echo "🧹 Cleaning up cached _site directory..."
#rm -rf _site


echo "🛠 Generate index.qmd files for all DOCS/* folders"
node .github/scripts/generate_index_all.mjs

echo "📄 Rendering all index.qmd files without metadata-files..."
mv .github/config/_quarto-index.yaml .github/config/_quarto.yaml
find DOCS -type f -name index.qmd -print0 | while IFS= read -r -d '' src; do
  echo "🔧 Rendering $src without metadata..."
  (
    cd .github/config
    quarto render "../../$src" --to html
  )
done
mv .github/config/_quarto.yml .github/config/_quarto-index.yml

echo "🖼 Render all documents into to HTML/DOCX"
sudo cp /usr/bin/chromium /usr/bin/chromium-browser
QUARTO_CHROMIUM_HEADLESS_MODE=new quarto render --to html
QUARTO_CHROMIUM_HEADLESS_MODE=new quarto render --to docx --no-clean
find _site -type f -name 'index.docx' -delete


echo "📄 Converting .docx files to .pdf..."
# chmod +x ./convert_docx_to_pdf.sh
timeout 3s .github/scripts/convert_docx_to_pdf.sh || true
timeout 10m .github/scripts/convert_docx_to_pdf.sh

echo "🧹 Cleaning up..."
find _site -type f -name '*.docx' -delete

echo "✅ Docs built successfully"