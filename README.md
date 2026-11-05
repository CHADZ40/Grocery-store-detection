# Grocery Product Detection with YOLOv8

This project trains YOLOv8 to find grocery products in real store shelf photos, then looks up each product's price.

It follows the professor's blood cell notebook (`yolo_detect_blood_cell_fixed.ipynb`) step by step. The main change is the dataset. [What changed from the professor's notebook](#what-changed-from-the-professors-notebook) lists every difference.

## Quick start

This repository has everything needed, including the prepared dataset. Clone it on the laptop, then open the repository folder.

1. Install **Python 3.13** if the laptop doesn't have it. On Windows, select **Add python.exe to PATH** during install.
2. Start the project:
   - **Windows:** double-click `start_windows.bat`.
   - **Mac or Linux:** open a terminal in this folder and run `bash start_mac_linux.sh`.
3. When the notebook opens, choose **Run > Run All Cells**.
4. Keep the laptop plugged in and awake until the last cell finishes.

The first start needs internet and downloads about 2–3 GB of packages. On Windows with an NVIDIA GPU, the script installs the GPU version automatically.

**Check the `Training on:` line.** `0` means NVIDIA GPU, `mps` means Apple GPU, and `cpu` means no GPU. On a CPU, 80 epochs can take many hours, so change `EPOCHS` to `30` and `IMGSZ` to `640` in the Train cell. On a GPU, expect about 1 hour or less.

## Save results to GitHub

After the notebook finishes, save it with **File > Save**. Then run these commands from the repository folder:

```bash
git add .
git commit -m "Add training results"
git push
```

Keep `runs/` and the saved notebook in the commit, because they contain the results. `.venv` is ignored, so it won't be uploaded.

## Project files

```text
grocery/
├── .gitignore                  Files Git should skip
├── .gitattributes              Line endings for the start scripts
├── yolo_detect_grocery.ipynb   Main notebook
├── README.md                   This file
├── start_windows.bat           One-click setup for Windows
├── start_mac_linux.sh          One-click setup for Mac and Linux
├── requirements.txt            Python packages
├── prices.csv                  Example price for each product
├── yolov8n.pt                  Pretrained YOLOv8 model
├── dataset/grocery_dataset/    Prepared dataset (train, valid, test)
├── data.yaml                   Created when the notebook runs
└── runs/detect/                Results, created when the notebook runs
```

The raw 0.9 GB dataset isn't needed, because `dataset/grocery_dataset` is already prepared. If you delete that folder, the notebook downloads the raw data and prepares it again.

## Manual setup

Use these steps only if the start scripts don't work. You need Python 3.13 and about 6 GB of free disk space. Open a terminal in the repository folder, then follow the steps for your computer.

### Mac

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
jupyter notebook yolo_detect_grocery.ipynb
```

Apple Silicon Macs (M1 or newer) use the GPU automatically (`mps`).

### Windows

Use PowerShell:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
jupyter notebook yolo_detect_grocery.ipynb
```

If PowerShell blocks the activate command, run this once and try again:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

If you use Command Prompt, activate with `.venv\Scripts\activate.bat` instead.

### Linux

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
jupyter notebook yolo_detect_grocery.ipynb
```

On Ubuntu or Debian, if `venv` is missing, run `sudo apt install python3-venv`. If OpenCV reports a missing `libGL` file, run `sudo apt install libgl1`.

### NVIDIA GPU (Windows and Linux)

Run this after setup to check the GPU:

```bash
python -c "import torch; print(torch.cuda.is_available())"
```

If it prints `False`, install the CUDA version of PyTorch using the command from [pytorch.org](https://pytorch.org/get-started/locally/). The notebook then uses the GPU automatically. On Windows, `start_windows.bat` tries this for you. Without a GPU it still works on the CPU, but training is much slower.

## Run the project

1. Open `yolo_detect_grocery.ipynb`.
2. Choose **Kernel > Restart Kernel and Run All Cells** (in the classic Jupyter view: **Kernel > Restart & Run All**).
3. Check the label picture in the **Prepare the dataset** section. The boxes should sit on the products.
4. Wait for training to finish. Results are saved in `runs/detect/`.

To skip training after it has finished once, go to the **Predict** section and use the commented `best_path0` line with your run folder. Run the setup cells first, because later cells use `IMGSZ`, `BATCH`, `WORKERS` and `device`.

To test your own photo, set `my_photo` in the last code cell, for example `my_photo = 'my_shelf.jpg'`.

## Dataset

**Source:** [NorgesGruppen Grocery Detection Dataset](https://huggingface.co/datasets/valiantlynxz/norwegian-grocery), from the NorgesGruppen Data competition, hosted on Hugging Face by `valiantlynxz`.

**License:** CC BY-NC 4.0. You may use it for non-commercial work such as this class project, and you must credit it.

**Changes made to the dataset:** this repository has a prepared copy, not the original files. The images were resized and the labels were converted and regrouped, as shown below.

The raw dataset has 248 shelf photos, 22,731 boxes and 356 product classes. The notebook prepares it like this:

| Step | What it does | Why |
|---|---|---|
| Choose products | Keeps the top 5 products from each of 4 sections: crispbread, cereal, hot drinks, eggs | 248 photos can't teach 356 products, and the overall top 20 would be almost all crispbread |
| Keep other products | Labels all other products as `other_product` | The model should not learn that a real product is background |
| Convert labels | COCO boxes become YOLO `.txt` files | YOLOv8 needs this format |
| Split | 174 train, 37 valid, 37 test, balanced by section, with a fixed seed | The raw dataset has no test split |
| Resize | Longest side becomes at most 1280 px and all files become `.jpg` | Faster training, and the professor's code looks for `.jpg` |

The photos come from many different stores and angles. The most similar pair of photos had a correlation of only 0.56, so the split doesn't have obvious near-copies. Some photos may still show the same store.

## Prices

The dataset has no prices. `prices.csv` is a table we made, and **its prices are examples, not real store prices**. To use real prices, edit `price_nok` in that file and keep the product names the same.

The price report uses detections with confidence 0.5 or higher. `other_product` has no price, so it isn't counted.

## What changed from the professor's notebook

Cells not listed here are the same as the professor's code.

| Notebook part | Change | Why |
|---|---|---|
| Title | New title and dataset source | New project |
| Install | `%pip` instead of `!pip`, and adds `huggingface_hub` | Installs into the running notebook's Python on every system, and can download the data |
| Paths | New dataset folder, and finds the raw data | New dataset |
| Bounding box colors | 21 generated colors | Three colors would crash with 21 classes |
| Create yaml | Uses `class_names`, and saves as UTF-8 | Keeps IDs matched to labels, and supports Norwegian letters |
| Train | Adds NVIDIA GPU support, more epochs, `imgsz=960`, `batch=8`, safe Windows workers, and `project=runs_dir` | Small objects need more detail, the project must run on every system, and results must stay in this folder |
| Predict and test | Use the same image size as training | Results must match training |
| PBOX and `draw_box2` | `os.path.basename` instead of `split('/')` | `split('/')` fails on Windows paths |
| True vs predicted animation | Shows the first 6 test images | Keeps the notebook file small |
| IoU matching | Compares each prediction with all true boxes of the same class, and matches each true box once | The old code only checked the first box in each image, which is wrong with about 90 boxes per photo |
| mAP | Uses the training settings | Results must match training |
| IoU column notes | Example file name changed to `img_00001.jpg` | Matches this dataset |

**New cells:**
- Prepare the dataset, with a label check picture
- Show training curves and the confusion matrix
- Show precision, recall and per-class scores
- Price lookup and a test for your own photo

**Not copied:** the professor's class list was `['WBC', 'RBC', 'Platelets']`, but the blood dataset's labels use `['Platelets', 'RBC', 'WBC']`. This project builds labels and names from the same list, so that mix-up can't happen.

## Troubleshooting

| Problem | Fix |
|---|---|
| Out of memory | Change `BATCH` to `4`. If it still fails, change `IMGSZ` to `640`. |
| Training is very slow | You are probably on the CPU. Check `Training on:`, then use `EPOCHS = 30` and `IMGSZ = 640`. |
| Windows blocks `start_windows.bat` | Click **More info > Run anyway**, or use the manual setup. |
| `yolo` command not found | This cell is optional. Start Jupyter from the activated environment, or skip it. |
| `ModuleNotFoundError` | The environment is not active. Activate it and start Jupyter again. |
| Wrong or broken dataset | Delete `dataset/grocery_dataset` and run the notebook again. It needs internet to download the raw data. |
| `prices.csv must list the same 20 products` | A product name was changed. Restore the name exactly. |
| Notebook can't read a path on Windows | Move the project to a path with only English letters, such as `C:\Projects\grocery`. |

## Credits

- Base notebook: course material, `yolo_detect_blood_cell_fixed.ipynb`
- Model: [Ultralytics YOLOv8](https://docs.ultralytics.com/)
- Dataset: [NorgesGruppen Grocery Detection Dataset](https://huggingface.co/datasets/valiantlynxz/norwegian-grocery), CC BY-NC 4.0
