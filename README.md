# my-dotfiles

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/60dc04f1-a33b-46d8-8f3b-622c8cf993a1" />

Моё окружение рабочего стола: Hyprland + Noctalia Shell, SDDM, терминал
alacritty, fish, fastfetch, обои - плюс
список программ, которые я использую.

## Установка с нуля

1. Поставить Arch через `archinstall` (профиль: minimal, загрузчик - любой,
   сеть - NetworkManager, пользователь с sudo).
2. Загрузиться, залогиниться в TTY и выполнить:

```bash
sudo pacman -S --needed git
git clone https://github.com/geek13-37/my-dotfiles.git ~/my-dotfiles
cd ~/my-dotfiles
./install.sh
```

3. Перезагрузиться и войти в сессию Hyprland.

Скрипт спросит пароль sudo один раз, дальше идёт сам. Его можно запускать
повторно - уже установленное пропускается. Большие игры (Dota 2, Sober)
и Steam сюда не входят - они в `extras.txt`, ставятся отдельно (см. ниже).

Флаги: `--no-packages` (только перелинковать конфиги), `--no-flatpak`,
`--no-rust` (без rustup/uv), `--list` (показать список программ),
`--help`.

Если что-то по пути не установилось (например, Spicetify без залогиненного
Spotify), скрипт пишет об этом и продолжает, а не падает.

## Программы

Что ставится одной командой (`packages.txt` + `packages-aur.txt` +
`flatpaks.txt`). Полный машинночитаемый список - `./install.sh --list`.

**Окружение и shell**
- Hyprland - воркспейсы и раскладка dwindle (конфиг на Lua)
- Noctalia - бар, лаунчер, уведомления, OSD, локскрин, центр управления;
  палитра из обоев идёт в темы приложений
- Alacritty, fish (tide), hyprpicker, grim/slurp; лаунчер, калькулятор, буфер
  и обои - силами самой Noctalia
- SDDM (стандартная тема)

**Консоль**
eza, bat, fzf, zoxide, ripgrep, yazi, vim/micro/nano, fastfetch, btop,
glances, duf, pv, tealdeer, git, pkgfile, pacman-contrib, reflector

**Приложения**
Firefox, Telegram, Discord, Spotify (+ Spicetify с темой Comfy), VS Code,
alacritty, Luciole, Papers/Лупа, GIMP, LibreOffice, VLC, OBS, Meld,
Remmina, Tor Browser, scrcpy, nmap, KeePassXC (flatpak),
Happ, LocalSend, Ventoy

**Разработка**
base-devel, gcc (в т.ч. mingw), cmake, go, node/npm/pnpm, Python + uv,
Docker, VirtualBox (Windows/C++, см. mingw), rustup (+cargo-xwin), OpenSSH

**Приватность и системное**
ufw, OpenSnitch, ClamAV, smartmontools, hwinfo, fstrim, power-profiles-daemon

**Ставлю сам отдельно (не в основной установке)**
Steam и Dota 2, Sober/Roblox (flatpak), Lutris, PyCharm - это тяжёлые вещи,
список лежит в `extras.txt`:

```bash
yay -S --needed $(grep -vE '^\s*(#|$)' extras.txt)  # Steam, Lutris
# Dota 2 - изнутри Steam
# Sober (Roblox) - flatpak install flathub org.vinegarhq.Sober
```

## Что внутри

- `config/hypr` - Hyprland (Lua-конфиг, раскладка dwindle). `hyprland-gui.lua`
  генерирует HyprMod, поэтому в репо лежит только дефолт
- `config/noctalia` + `state/noctalia/settings.toml` - Noctalia Shell:
  бар (воркспейсы, трей, RAM/CPU, сеть, Docker, буфер, яркость, питание),
  лаунчер (Super+Ctrl+Enter), калькулятор (Super+Z), история буфера (Super+V),
  уведомления, OSD, меню питания (Super+Shift+Q), выбор обоев (Super+Shift+Enter),
  центр управления (Super+S). Палитра берётся из обоев и рендерится в темы
  приложений (alacritty, GTK, Spotify, Telegram, SDDM...)
- `bin/screenshot` - скриншоты в буфер и в `~/Pictures/Screenshots`
  (выделение области - без рамки); у окон в Hyprland рамок нет
- `config/alacritty` - терминал (JetBrainsMono Nerd Font, цвета из обоев)
- диспетчер задач - **rproc** (Rust, как в Windows) на `Ctrl+Shift+Esc`; на
  Flathub его нет, поэтому `install.sh` берёт последний `.flatpak` из его
  GitHub-релизов
- `config/fish` - конфиг fish (prompt на tide); `config/fish/cachyos` - копия
  fish-конфига CachyOS (алиасы eza/bat и т.п.), чтобы работало и на чистом Arch
- `config/fastfetch`, `config/mimeapps.list`
- `bin/spotify` - запуск Spotify (бинд Ctrl+S и лаунчер): после обновления
  Spotify сам заново накатывает Spicetify с темой Comfy в цветах обоев
- SDDM - стандартная тема (старая where-is-my-sddm-theme убрана совсем)
- Приватность:
  - `config/networkmanager/00-privacy.conf` -> `/etc/NetworkManager/conf.d/`:
    свой фейковый MAC для каждой сети, hostname не уходит по DHCP, временные
    IPv6-адреса
  - `config/firefox/policies.json` -> `/etc/firefox/policies/`: без телеметрии,
    Studies и спонсорского контента, HTTPS-only, DNS-over-HTTPS через Quad9
  - Docker публикует порты только на `127.0.0.1` (иначе `-p` обходит ufw;
    наружу - явно `-p 0.0.0.0:8080:80`)
  - `bin/localsend` - порт LocalSend (53317) открыт в ufw только пока
    LocalSend запущен (через `/usr/local/bin/localsend-port`, sudo без пароля
    только для `open`/`close`)
  - avahi (mDNS) не ставится и выключается; OpenSnitch спрашивает, каким
    программам можно в сеть
- Telegram, Happ, Spotify - только ставятся пакетом, их личные конфиги в
  репозиторий не попадают

## Секреты

API-ключи (например, `VENICE_API_KEY`) не лежат в репозитории. При установке
создаётся `~/.config/fish/secrets.fish` из `config/fish/secrets.fish.example`,
туда и вписываются ключи - этот файл игнорируется гитом.

## Обслуживание

```bash
./install.sh --no-packages   # после git pull: перелинковать конфиги
./install.sh --list          # что и как ставится
```
