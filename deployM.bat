@echo off
echo 🚀 推送 main 分支中...
git branch
git checkout main
git add .
git commit -m "✨ 修改遊戲邏輯與畫面文字"
git push origin main

echo 🏗️ 建置 Flutter Web...
flutter build web --base-href="/math-clash-web/"

echo 🚀 正在部署到 gh-pages...
cd build\web
rd .git /s /q >nul 2>nul
git init
git remote add origin https://github.com/timo456/math-clash-web.git
git checkout -b gh-pages
git add .
git commit -m "🚀 自動部署最新版本"
git push -f origin gh-pages

echo ✅ 全部完成！請開啟瀏覽器查看： https://timo456.github.io/math-clash-web/
pause
