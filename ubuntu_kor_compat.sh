#!/usr/bin/env bash
# =========================================================
# Ubuntu 24.04 Korean & Compatibility Fix
# Author: Hybirdss (oinkm@naver.com)
# Purpose: Fix 한글입력, 로케일, 폰트, GTK, VSCode, 파일명 깨짐, SMB/NTFS 호환
# =========================================================

set -euo pipefail

log(){ echo -e "\033[1;36m[FIX]\033[0m $*"; }

[[ $EUID -eq 0 ]] || { echo "Run as root (sudo)."; exit 1; }

log "1️⃣ System Locale to ko_KR.UTF-8"
apt install -y language-pack-ko fonts-noto-cjk fonts-unfonts-core fonts-nanum
update-locale LANG=ko_KR.UTF-8 LANGUAGE=ko_KR:ko LC_ALL=ko_KR.UTF-8
echo "export LANG=ko_KR.UTF-8" >> /etc/profile
locale-gen ko_KR.UTF-8
log "✅ 로케일 완료"

log "2️⃣ 한글 입력기 (Fcitx5 + Mozc + Hangul)"
apt install -y fcitx5 fcitx5-hangul fcitx5-mozc fcitx5-config-qt fcitx5-frontend-gtk4 fcitx5-frontend-gtk3
im-config -n fcitx5

mkdir -p /etc/environment.d
cat <<EOF >/etc/environment.d/99-fcitx5.conf
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
EOF
log "✅ Fcitx5 입력기 및 환경변수 세팅 완료"

log "3️⃣ 폰트 개선 (나눔 + Noto + Windows 폰트 지원)"
apt install -y fonts-nanum fonts-nanum-coding fonts-nanum-extra fonts-noto-cjk
mkdir -p /usr/share/fonts/truetype/custom
# 윈도우 폰트 가져오기 (옵션)
if [ -d "/mnt/c/Windows/Fonts" ]; then
  cp /mnt/c/Windows/Fonts/{malgun,batang,gulim,arial,tahoma,verdana}*.ttf /usr/share/fonts/truetype/custom/ 2>/dev/null || true
  fc-cache -fv
  log "✅ Windows 폰트 복사 완료"
else
  fc-cache -fv
fi

log "4️⃣ 한글 폰트 렌더링 & 깨짐 방지"
cat <<EOF >/etc/fonts/local.conf
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
 <match target=\"pattern\">
  <test qual=\"any\" name=\"family\"><string>sans-serif</string></test>
  <edit name=\"family\" mode=\"prepend\" binding=\"strong\">
   <string>Noto Sans CJK KR</string>
  </edit>
 </match>
</fontconfig>
EOF

log "5️⃣ NTFS, exFAT, Samba (Windows 호환)"
apt install -y ntfs-3g exfat-fuse exfatprogs samba cifs-utils gvfs-backends
systemctl enable smbd nmbd || true
log "✅ 파일시스템 및 네트워크 공유 호환 완료"

log "6️⃣ VSCode 한글 입력 문제 (IME Lag Fix)"
mkdir -p ~/.config/Code/User
cat <<EOF > ~/.config/Code/User/settings.json
{
  "editor.fontFamily": "D2Coding, 'Nanum Gothic Coding', 'Noto Sans CJK KR', monospace",
  "editor.fontLigatures": false,
  "files.encoding": "utf8",
  "terminal.integrated.fontFamily": "D2Coding, monospace",
  "terminal.integrated.detectLocale": "off",
  "terminal.integrated.shellIntegration.enabled": true,
  "keyboard.dispatch": "keyCode",
  "window.titleBarStyle": "custom",
  "update.mode": "manual"
}
EOF
log "✅ VSCode 한글 입력/렌더링 설정 완료"

log "7️⃣ GTK/Qt 환경 변수 (한글 깨짐, 다크모드 버그 방지)"
cat <<EOF >/etc/environment.d/99-gui.conf
GTK_THEME=Adwaita:dark
QT_QPA_PLATFORMTHEME=gtk2
GDK_SCALE=1
GDK_DPI_SCALE=1
EOF
log "✅ GTK/Qt 환경 변수 설정 완료"

log "8️⃣ 터미널/콘솔 한글 표시 확인"
append_to_bashrc(){
  grep -qxF "$1" ~/.bashrc || echo "$1" >> ~/.bashrc
}
append_to_bashrc "export LANG=ko_KR.UTF-8"
append_to_bashrc "export LC_ALL=ko_KR.UTF-8"
append_to_bashrc "export LANGUAGE=ko_KR:ko"

log "✅ 모든 한글 관련 설정 완료. 재부팅 후 적용됩니다."
echo "🎯 Reboot 후 'fcitx5-configtool' 실행하여 Hangul/Mozc 설정 확인!"
