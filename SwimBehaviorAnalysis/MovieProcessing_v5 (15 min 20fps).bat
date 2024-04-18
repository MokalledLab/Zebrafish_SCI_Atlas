@cd /d "%~dp0"
mkdir SwimBehavior
for %%A IN (*.avi) DO ffmpeg -i "%%A" -r 20 -an -c:v mjpeg -q:v 10 -y -ss 00:00:00.00 "SwimBehavior/%%~nA.avi"
