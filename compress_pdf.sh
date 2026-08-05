#!/usr/bin/env bash

# Exit immediately if a pipeline exits with a non-zero status
set -e

# 1. Initialize Paths (Run from script's current directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SOURCE_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$SCRIPT_DIR/Output"
TOTAL_OLD_SIZE=0
TOTAL_NEW_SIZE=0

# Create Output folder if it does not exist
mkdir -p "$OUTPUT_DIR"

# 2. Find Ghostscript
if ! command -v gs >/dev/null 2>&1; then
    echo -e "\e[31mERROR: Ghostscript ('gs') not found!\e[0m"
    echo "Please install it using your package manager:"
    echo "  Ubuntu/Debian: sudo apt install ghostscript"
    echo "  Fedora/RHEL:   sudo dnf install ghostscript"
    echo "  Arch Linux:    sudo pacman -S ghostscript"
    exit 1
fi

GS_EXE=$(command -v gs)

# 3. Process Files Recursively (excluding the Output directory itself)
PDF_COUNT=0
while IFS= read -r -d '' file; do
    PDF_COUNT=$((PDF_COUNT + 1))
done < <(find "$SOURCE_DIR" -path "$OUTPUT_DIR" -prune -o -type f -name "*.pdf" -print0 2>/dev/null)

if [ "$PDF_COUNT" -eq 0 ]; then
    echo -e "\e[33mNo PDFs found in '$SOURCE_DIR'.\e[0m"
    # Optional notification when no PDFs are found
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -i dialog-warning "PDF Compression" "No PDF files found to compress."
    fi
else
    while IFS= read -r -d '' file; do
        # Get relative path from SOURCE_DIR
        REL_PATH="${file#$SOURCE_DIR/}"
        TARGET="$OUTPUT_DIR/$REL_PATH"
        TARGET_DIR="$(dirname "$TARGET")"

        # Create target subdirectories if needed
        mkdir -p "$TARGET_DIR"

        echo -e "\e[97mProcessing: $REL_PATH...\e[0m"

        # Run Ghostscript
        "$GS_EXE" \
            -sDEVICE=pdfwrite \
            -dCompatibilityLevel=1.4 \
            -dPDFSETTINGS=/ebook \
            -dNOPAUSE -dQUIET -dBATCH \
            -sOutputFile="$TARGET" \
            "$file"

        if [ -f "$TARGET" ]; then
            # Get file sizes in bytes (stat -c%s works on GNU Linux)
            OLD_SIZE=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
            NEW_SIZE=$(stat -c%s "$TARGET" 2>/dev/null || stat -f%z "$TARGET")

            if [ "$NEW_SIZE" -ge "$OLD_SIZE" ] && [ "$OLD_SIZE" -gt 0 ]; then
                echo -e "\e[33mSKIPPED: No improvement. Keeping original.\e[0m"
                cp -f "$file" "$TARGET"
                TOTAL_OLD_SIZE=$((TOTAL_OLD_SIZE + OLD_SIZE))
                TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + OLD_SIZE))
            else
                # Calculate reduction percentage and MB using awk
                REDUCTION=$(awk -v old="$OLD_SIZE" -v new="$NEW_SIZE" 'BEGIN { printf "%.1f", ((old - new) / old) * 100 }')
                NEW_MB=$(awk -v new="$NEW_SIZE" 'BEGIN { printf "%.2f", new / 1048576 }')
                
                echo -e "\e[32mSUCCESS: Reduced by ${REDUCTION}% (${NEW_MB} MB)\e[0m"
                TOTAL_OLD_SIZE=$((TOTAL_OLD_SIZE + OLD_SIZE))
                TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + NEW_SIZE))
            fi
        fi
    done < <(find "$SOURCE_DIR" -path "$OUTPUT_DIR" -prune -o -type f -name "*.pdf" -print0)

    # Final Summary
    SAVED_MB=$(awk -v old="$TOTAL_OLD_SIZE" -v new="$TOTAL_NEW_SIZE" 'BEGIN { printf "%.2f", (old - new) / 1048576 }')
    echo -e "\e[36m\n===============================================\e[0m"
    echo -e "\e[32mTOTAL SPACE SAVED: ${SAVED_MB} MB\e[0m"
    echo -e "\e[36m===============================================\e[0m"

    # 4. Trigger Desktop Notification
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u normal -i document-save "PDF Compression Complete" "Processed ${PDF_COUNT} file(s).\nTotal Space Saved: ${SAVED_MB} MB"
    fi
fi
