import { readdir, writeFile, mkdir } from "fs/promises";
import { join } from "path";

async function generateDirectoryIndex(dirPath, relPath = "") {
  const items = await readdir(dirPath, { withFileTypes: true });
  const entries = [];
  const links = [];

  for (const item of items) {
    if (item.isDirectory()) {
      const subdir = join(dirPath, item.name);
      const subrel = join(relPath, item.name);
      await generateDirectoryIndex(subdir, subrel);
      entries.push(`- [${item.name}](${item.name}/index.qmd)`);
    } else if (item.name.endsWith(".qmd") && item.name !== "index.qmd") {
      const name = item.name.replace(".qmd", "");
      links.push(`- [${name}](${item.name})`);
    }
  }

  if (relPath === "") {
    // Root index.qmd
    const content = `---
title: Documentation Index
sidebar: docs
---

# Documentation

${entries.join("\n")}
`;
    await writeFile(join(dirPath, "index.qmd"), content);
  } else {
    // Per-folder index.qmd
    const content = `---
title: ${relPath}
sidebar: docs
---

# ${relPath}

${links.join("\n")}
`;
    await writeFile(join(dirPath, "index.qmd"), content);
  }
}

await generateDirectoryIndex("DOCS");
console.log("✔ All index.qmd files generated.");
