import os
import shutil
import re
from pathlib import Path


EXCLUDED_DOCS_DIRS = {"templates", "theme", "includes"}


# Change working directory to root of the repository
script_dir = Path(__file__).parent
root_dir = script_dir / "../../"
os.chdir(root_dir.resolve())


def extract_category_from_qmd(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Look for YAML frontmatter between --- markers
        yaml_match = re.search(
            r"^---\s*\n(.*?)\n---", content, re.DOTALL | re.MULTILINE
        )
        if yaml_match:
            yaml_content = yaml_match.group(1)

            # Extract category field (handles quoted and unquoted values)
            category_match = re.search(
                r'^category:\s*["\']?([^"\']+)["\']?', yaml_content, re.MULTILINE
            )
            if category_match:
                return category_match.group(1).strip()

    except Exception as e:
        print(f"Error reading {file_path}: {e}")

    return None


def group_qmd_files_by_category(source_dir="origin_DOCS", target_dir="DOCS"):
    source_path = Path(source_dir)
    target_path = Path(target_dir)

    # Create target directory if it doesn't exist
    target_path.mkdir(exist_ok=True)

    # Find all .qmd files
    qmd_files = [
        f
        for f in source_path.glob("**/*.qmd")
        if not any(
            part in EXCLUDED_DOCS_DIRS
            for part in f.relative_to(source_path).parent.parts
        )
    ]

    if not qmd_files:
        print("No .qmd files found in the current directory")
        return

    print(f"Found {len(qmd_files)} .qmd files")

    # Group files by category
    for qmd_file in qmd_files:
        category = extract_category_from_qmd(qmd_file)

        if category:
            # Create category folder
            category_folder = target_path / category
            category_folder.mkdir(exist_ok=True)

            # Copy file to category folder
            target_file = category_folder / qmd_file.name
            shutil.copy2(qmd_file, target_file)

            print(f"Copied {qmd_file.name} → {category}/")
        else:
            # Handle files without category
            uncategorized_folder = target_path / "uncategorized"
            uncategorized_folder.mkdir(exist_ok=True)

            target_file = uncategorized_folder / qmd_file.name
            shutil.copy2(qmd_file, target_file)

            print(f"Copied {qmd_file.name} → uncategorized/ (no category found)")


def copy_excluded_dirs(source_dir="origin_DOCS", target_dir="DOCS"):
    source_path = Path(source_dir)
    target_path = Path(target_dir)
    for excluded_dir in EXCLUDED_DOCS_DIRS:
        src = source_path / excluded_dir
        dst = target_path / excluded_dir
        if src.exists() and src.is_dir():
            if dst.exists():
                shutil.rmtree(dst)
            shutil.copytree(src, dst)
            print(f"Copied excluded directory: {excluded_dir}/")


if __name__ == "__main__":
    group_qmd_files_by_category()
    copy_excluded_dirs()
    print("\nGrouping complete! Check the 'grouped_qmd' folder.")
