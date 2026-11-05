@echo off
rem Sets up Python packages and opens the notebook. Double-click this file to run it.
cd /d "%~dp0"

set PY=python
where py >nul 2>nul && set PY=py

if not exist ".venv\Scripts\python.exe" (
    echo Creating the Python environment...
    %PY% -m venv .venv
    if errorlevel 1 goto nopython
)

echo Installing packages. The first time can take several minutes...
".venv\Scripts\python.exe" -m pip install --upgrade pip

where nvidia-smi >nul 2>nul
if not errorlevel 1 (
    echo NVIDIA GPU found. Installing the GPU version of PyTorch...
    ".venv\Scripts\python.exe" -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu126
    if errorlevel 1 echo GPU install failed. Continuing with the normal version.
)

".venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 goto failed

".venv\Scripts\python.exe" -c "import torch; print('NVIDIA GPU:', torch.cuda.is_available())"
call ".venv\Scripts\activate.bat"
python -m notebook yolo_detect_grocery.ipynb
goto end

:nopython
echo.
echo Python was not found. Install Python 3.13 from https://www.python.org/downloads/
echo During install, select "Add python.exe to PATH". Then run this file again.
goto end

:failed
echo.
echo Package install failed. Check the internet connection and run this file again.

:end
pause
