================================================
FILE: README.md
================================================
# 📄 PDF-Squeeze: Recursive PDF Compressor

A robust, portable, cross-platform utility that leverages **Ghostscript** to batch-compress PDF files on **Windows** and **Linux**. It scans its current directory recursively, preserves your subfolder structure, prevents files from accidentally becoming larger, and triggers a desktop notification when finished.

---

## ✨ Features

* **Cross-Platform:** Includes both Windows (`.ps1` / `.bat`) and Linux (`.sh` / `.desktop`) launchers.
* **In-Place Folder Scanning:** Run the script from any directory—it automatically compresses all PDFs in the script's folder and subfolders into an `Output` folder.
* **Infinite Loop Protection:** Automatically skips the `Output` directory during scanning to prevent re-compressing already processed files.
* **Smart Compression:** Compares file sizes post-compression; if the compressed version is larger, it keeps a copy of the original instead.
* **Desktop Notifications:** Triggers native system notifications (Windows Action Center or Linux `notify-send`) upon completion, showing total files processed and space saved.
* **Structure Preservation:** Recreates the exact source subfolder tree inside the `Output` directory.

---

## 🚀 Prerequisites

### 1. Ghostscript Installation

| Operating System | Prerequisite Package | Installation Command / Link |
| :--- | :--- | :--- |
| **Windows** | Ghostscript (64-bit) | [Ghostscript Downloads](https://ghostscript.com/releases/gsdnld.html)<br>*(Script auto-detects `gswin64c.exe` in standard paths)* |
| **Ubuntu / Debian** | `ghostscript`, `libnotify-bin` | `sudo apt install ghostscript libnotify-bin` |
| **Fedora / RHEL** | `ghostscript`, `libnotify` | `sudo dnf install ghostscript libnotify` |
| **Arch / Manjaro** | `ghostscript`, `libnotify` | `sudo pacman -S ghostscript libnotify` |

---

## 🛠️ How to Use

### 🪟 Windows
1. Place `CompressPDF.ps1` and `RunCompression.bat` in the folder containing your PDFs (or subfolders of PDFs).
2. Double-click **`RunCompression.bat`**.
3. View progress in the console. A desktop notification will pop up when compression completes.
4. Retrieve your optimized files inside the newly created **`Output/`** folder.

### 🐧 Linux
1. Place `compress_pdf.sh` in the folder containing your PDFs (or subfolders of PDFs).
2. Open a terminal in that folder and grant execution permissions:
   ```bash
   chmod +x compress_pdf.sh



---

## ⚙️ Configuration

You can change the compression level by editing the Ghostscript arguments array in CompressPDF.ps1 or compress_pdf.sh
Look for: `"-dPDFSETTINGS=/ebook"`

| Setting | Quality | Resolution | Best For |
| :--- | :--- | :--- | :--- |
| `/screen` | Low | 72 dpi | Maximum compression, web viewing. |
| `/ebook` | Medium | 150 dpi | Standard balance (Default). |
| `/printer` | High | 300 dpi | Office printing. |
| `/prepress` | Max | 300+ dpi | High-quality color preservation. |

---

## 🛡️ Safety & Privacy
* **Non-Destructive:** This script **never** deletes or modifies your files in the `original` folder.
* **100% Offline:** All processing occurs locally on your machine **no files are uploaded to external servers**.
---

## 📝 License
Distributed under the MIT License. See `LICENSE` for more information.
