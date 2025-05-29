import { readdir, writeFile, access } from "fs/promises";
import { join, basename } from "path";

const DOCS_DIR = "DOCS";
const IGNORED_FOLDERS = new Set(["styles", "templates"]);

function formatTitle(name) {
  return name.replace(/[-_]/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

async function generateSubdirIndex(dirPath) {
  const dirName = basename(dirPath);
  const title = formatTitle(dirName);
  const indexPath = join(dirPath, "index.qmd");

  const indexContent = `---
title: ${title}
listing:
  type: table
  contents: .
  sort: title
  fields: [title]
---
`;

  try {
    await access(indexPath);
  } catch {
    await writeFile(indexPath, indexContent);
  }
}

async function generateDocsRootIndex(subfolders) {
  const indexPath = join(DOCS_DIR, "index.qmd");

  const indexContent = `---
title: Documentation
listing:
  type: table
  contents:
${subfolders.map((f) => `    - ${f}/index.qmd`).join("\n")}
  sort: title
  fields: [title]
---
`;

  await writeFile(indexPath, indexContent);
}

async function main() {
  const entries = await readdir(DOCS_DIR, { withFileTypes: true });

  const subfolders = [];

  for (const entry of entries) {
    if (entry.isDirectory() && !IGNORED_FOLDERS.has(entry.name)) {
      subfolders.push(entry.name);
      const subdir = join(DOCS_DIR, entry.name);
      await generateSubdirIndex(subdir);
    }
  }

  await generateDocsRootIndex(subfolders);
}

main();
