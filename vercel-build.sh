#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found. Installing Flutter stable..."
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git /tmp/flutter
  export PATH="/tmp/flutter/bin:$PATH"
fi

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release
