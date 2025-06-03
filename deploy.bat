@echo off
echo 🚀 Building Flutter Web...

echo 📂 Moving into build\web...
cd build\web

echo 🧹 Cleaning up old Git (if exists)...
rd .git /s /q >nul 2>nul

echo 🔧 Reinitializing Git...
git init
git remote add origin https://github.com/timo456/math-clash-web.git
git checkout -b gh-pages

echo 🗃️ Adding all files...
git add .

echo 📝 Committing...
git commit -m "🚀 自動部署最新版本"

echo 🚀 Pushing to gh-pages...
git push -f origin gh-pages

echo ✅ 部署完成！請打開瀏覽器查看 👉 https://timo456.github.io/math-clash-web/
pause
