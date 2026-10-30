#!/bin/sh
# Generates every icon asset from the SVG sources into ./dist (macOS only: uses Swift and iconutil).
set -e
cd "$(dirname "$0")"
R="swift render.swift"
D=dist
rm -rf $D && mkdir -p $D/png $D/glyph $D/macos/AppIcon.iconset $D/ios $D/windows $D/linux $D/web $D/android
for s in 16 24 32 48 64 96 128 180 192 256 384 512 1024; do $R icon.svg $D/png/icon-$s.png $s; done
# monochrome glyphs: black for light backgrounds / macOS template images, white for dark trays
for s in 16 18 22 24 32 36 44 48 64 128 256 512; do
  $R glyph.svg $D/glyph/glyph-black-$s.png $s "#000000"
  $R glyph.svg $D/glyph/glyph-white-$s.png $s "#ffffff"
done
# macOS app icon set + .icns
for s in 16 32 128 256 512; do
  $R icon-macos.svg $D/macos/AppIcon.iconset/icon_${s}x${s}.png $s
  $R icon-macos.svg $D/macos/AppIcon.iconset/icon_${s}x${s}@2x.png $((s*2))
done
iconutil -c icns $D/macos/AppIcon.iconset -o $D/macos/AppIcon.icns
# iOS (square, opaque, 1024) and Android/maskable
$R icon-square.svg $D/ios/AppIcon-1024.png 1024
for s in 48 72 96 144 192 512; do $R icon-square.svg $D/android/ic_launcher-$s.png $s; done
# Windows .ico
swift makeico.swift $D/windows/icon.ico $D/png/icon-16.png $D/png/icon-24.png $D/png/icon-32.png $D/png/icon-48.png $D/png/icon-64.png $D/png/icon-128.png $D/png/icon-256.png
# Linux (hicolor theme) + web
cp icon.svg $D/linux/syncloom.svg
cp glyph.svg $D/linux/syncloom-symbolic.svg
for s in 16 24 32 48 64 128 256 512; do cp $D/png/icon-$s.png $D/linux/syncloom-$s.png; done
cp icon.svg $D/web/favicon.svg
cp glyph.svg $D/web/glyph.svg
cp $D/png/icon-32.png $D/web/favicon-32.png
cp $D/png/icon-180.png $D/web/apple-touch-icon.png
cp $D/png/icon-192.png $D/web/icon-192.png
$R icon-square.svg $D/web/icon-512-maskable.png 512
cp $D/png/icon-512.png $D/web/icon-512.png
cp $D/windows/icon.ico $D/web/favicon.ico
echo "icons written to $D"
