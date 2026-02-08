# 📄 PDF-Squeeze: Recursive PDF Compressor

A robust, portable PowerShell utility that leverages **Ghostscript** to batch-compress PDF files. It preserves your folder hierarchy, handles spaces in filenames, and includes a safety check to ensure files never get larger during the process.

---

## ✨ Features

* **Recursive Processing:** Automatically scans all subfolders within the `Input` directory.
* **Structure Preservation:** Recreates the exact source folder tree in the `Output` directory.
* **Smart Compression:** Compares file sizes post-compression; if the "compressed" version is larger, it keeps a copy of the original instead.
* **Space Management:** Provides a final summary of the total disk space saved (in MB).
* **Admin-Free:** Designed to run with standard user permissions (once Ghostscript is installed).

---

## 🚀 Getting Started

### 1. Prerequisite: Ghostscript
This script requires Ghostscript (64-bit) installed on your system.
* **Download:** [Ghostscript Official Releases](https://ghostscript.com/releases/gsdnld.html)
* The script will automatically look for `gswin64c.exe` in standard paths like `C:\Program Files\gs`.

### 2. Installation
1.  Clone this repository or download the source files.
2.  Ensure `CompressPDFs.ps1` and `Run_Compression.bat` are in the same folder.

---

## 🛠️ How to Use

1.  **Prepare Input:** Drop your PDF files (or entire folders of PDFs) into the `Input` folder.
2.  **Run:** Double-click `Run_Compression.bat`.
3.  **Review:** Once finished, check the `Output` folder for your optimized files.
4.  **Summary:** View the terminal window to see the percentage reduction for each file and the total MB saved.



---

## ⚙️ Configuration

You can change the compression level by editing the `$gsArgs` array in `CompressPDFs.ps1`. Look for the line:

`"-dPDFSETTINGS=/ebook"`

| Setting | Quality | Resolution | Best For |
| :--- | :--- | :--- | :--- |
| `/screen` | Low | 72 dpi | Maximum compression, web viewing. |
| `/ebook` | Medium | 150 dpi | Standard balance (Default). |
| `/printer` | High | 300 dpi | Office printing. |
| `/prepress` | Max | 300+ dpi | High-quality color preservation. |

---

## 🛡️ Safety & Privacy
* **Non-Destructive:** This script **never** deletes or modifies your files in the `Input` folder.
* **Git-Safe:** The included `.gitignore` ensures your private PDFs are not accidentally uploaded if you push this to a public repository.

---

## 📝 License
Distributed under the MIT License. See `LICENSE` for more information.
