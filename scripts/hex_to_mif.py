#!/usr/bin/env python3

from pathlib import Path
import sys

WIDTH = 32
DEPTH = 8192

def clean_word(line: str) -> str | None:
    # Remove comments and whitespace
    line = line.split("#")[0].split("//")[0].strip()

    if not line:
        return None

    # Allow optional 0x prefix
    if line.lower().startswith("0x"):
        line = line[2:]

    # Normalize
    line = line.strip().upper()

    # Basic validation
    if len(line) > 8:
        raise ValueError(f"Word too wide for 32-bit MIF: {line}")

    int(line, 16)  # validate hex

    return line.zfill(8)

def main() -> None:
    if len(sys.argv) != 3:
        print("Usage: python3 scripts/hex_to_mif.py <input.hex> <output.mif>")
        sys.exit(1)

    in_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2])

    words: list[str] = []

    for raw_line in in_path.read_text().splitlines():
        word = clean_word(raw_line)
        if word is not None:
            words.append(word)

    if len(words) > DEPTH:
        raise ValueError(f"Input has {len(words)} words, but ROM depth is only {DEPTH}")

    out_path.parent.mkdir(parents=True, exist_ok=True)

    with out_path.open("w") as f:
        f.write(f"WIDTH={WIDTH};\n")
        f.write(f"DEPTH={DEPTH};\n\n")
        f.write("ADDRESS_RADIX=HEX;\n")
        f.write("DATA_RADIX=HEX;\n\n")
        f.write("CONTENT BEGIN\n")

        for addr, word in enumerate(words):
            f.write(f"    {addr:04X} : {word};\n")

        # Fill unused ROM space with zeros
        if len(words) < DEPTH:
            f.write(f"    [{len(words):04X}..{DEPTH - 1:04X}] : 00000000;\n")

        f.write("END;\n")

    print(f"Wrote {out_path}")
    print(f"Input words: {len(words)}")
    print(f"ROM depth:   {DEPTH}")
    print(f"Unused:      {DEPTH - len(words)} words filled with zero")

if __name__ == "__main__":
    main()