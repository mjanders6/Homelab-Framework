from pathlib import Path
import re

pattern = re.compile(r'^([A-Za-z0-9_.-]+):.*?##\s*(.+)$')

for line in Path("Makefile").read_text().splitlines():
    m = pattern.match(line)
    if m:
        print(f"  {m.group(1):<30} {m.group(2)}")