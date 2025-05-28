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

echo "🧹 Cleaning up cached _site directory..."
rm -rf _site

echo "🖼 Render all documents into to HTML/DOCX"
sudo cp /usr/bin/chromium /usr/bin/chromium-browser
QUARTO_CHROMIUM_HEADLESS_MODE=new quarto render --to html
QUARTO_CHROMIUM_HEADLESS_MODE=new quarto render --to docx --no-clean
find _site -type f -name 'index.docx' -delete


echo "📄 Converting .docx files to .pdf..."
# chmod +x ./convert_docx_to_pdf.sh
timeout 3s .github/scripts/convert_docx_to_pdf.sh || true
timeout 10m .github/scripts/convert_docx_to_pdf.sh

echo "✅ Docs built successfully"