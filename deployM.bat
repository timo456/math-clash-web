@echo off
echo 🚀 Building Flutter Main...
git branch
git checkout main
git add .
git commit -m "✨ 修改遊戲邏輯與畫面文字"
git push origin main
flutter build web --base-href="/math-clash-web/"
echo ✅ 部署完成！
pause