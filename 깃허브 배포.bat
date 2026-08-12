@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
chcp 65001 >nul

echo.
echo  ============================================
echo    Deploy to GitHub Pages
echo  ============================================
echo.

where git >nul 2>&1
if errorlevel 1 (
  echo   [X] git not found. Install from https://git-scm.com
  pause & exit /b 1
)

rem ---- 1. build the public copy into docs/ ----
echo   [1/4] Building docs/index.html ...
python build.py --public --docs
if errorlevel 1 ( echo   [X] build failed & pause & exit /b 1 )

rem ---- 2. init repo on first run ----
if not exist ".git" (
  echo   [2/4] Initialising repository ...
  git init -b main
  git add .
  git commit -m "Nakseongdae lunch app"
) else (
  echo   [2/4] Repository already exists.
  git add .
  git diff --cached --quiet
  if errorlevel 1 (
    for /f "tokens=1-3 delims=/ " %%a in ("%date%") do set D=%%a-%%b-%%c
    git commit -m "Update data and build (!D!)"
  ) else (
    echo         Nothing changed.
  )
)

rem ---- 3. remote ----
git remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo.
  echo   [3/4] No remote yet. Do this once:
  echo.
  echo     1^) Create an EMPTY repo at https://github.com/new
  echo        - do NOT add a README or .gitignore
  echo     2^) Run, with your own id/repo:
  echo.
  echo        git remote add origin https://github.com/YOUR_ID/YOUR_REPO.git
  echo        git push -u origin main
  echo.
  echo     3^) On GitHub: Settings ^> Pages
  echo        Source = Deploy from a branch, Branch = main, Folder = /docs
  echo.
  echo     Then run this file again to publish updates.
  echo.
  pause & exit /b 0
)

rem ---- 4. push ----
echo   [4/4] Pushing ...
git push -u origin main
if errorlevel 1 (
  echo.
  echo   [X] Push failed. Check the remote URL and your GitHub login.
  pause & exit /b 1
)

for /f "delims=" %%u in ('git remote get-url origin') do set URL=%%u
echo.
echo   Done. Your site (once Pages is enabled, ~1 min):
echo     !URL:~0,-4! ^-^> Settings ^> Pages shows the live address
echo.
pause
