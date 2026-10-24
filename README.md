# my-dotfiles

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/60dc04f1-a33b-46d8-8f3b-622c8cf993a1" />

Моё окружение рабочего стола: Hyprland + Caelestia, тема входа SDDM
(where-is-my-sddm-theme), терминал alacritty, fish, fastfetch, обои - плюс все программы,
которые у меня стоят.

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

Скрипт спросит пароль sudo один раз, дальше идет сам. Его можно запускать
повторно - уже установленное пропускается.

## Что внутри

- `config/hypr` - Hyprland (Lua-конфиг, раскладка dwindle)
- `config/caelestia` - шелл [Caelestia](https://github.com/caelestia-dots/shell)
  (ставится из AUR `caelestia-shell`): `shell.json` - настройки шелла (то, что
  меняешь в Nexus, Super+Shift+, сохраняется сюда же), `cli.json` - Caelestia
  перекрашивает под обои только себя и fuzzel, терминалы/GTK/Qt/Spicetify/Discord
  не трогает. Обои в репозиторий не входят: install.sh берёт первую картинку из
  `~/Pictures`, сменить - в лаунчере `>wallpaper`
- Бинды шелла (`config/hypr/config/binds.lua`): Super+Ctrl+Enter - лаунчер
  (`>calc`, `>wallpaper`), Super+S - дашборд, Super+N - уведомления,
  Super+Shift+Q - выключение, Super+V - буфер обмена, Super+; - эмодзи,
  Alt+L - блокировка, Super+Shift+S - скриншот области
- `config/noctalia` + `state/noctalia/settings.toml` - старые настройки Noctalia,
  больше не ставятся (оставлены на случай отката)
- `config/alacritty` - терминал (JetBrainsMono Nerd Font)
- `config/fish` - конфиг fish (prompt на tide); `config/fish/cachyos` - копия
  fish-конфига CachyOS (алиасы eza/bat и т.п.), чтобы работало и на чистом Arch
- `config/fastfetch`, `config/mimeapps.list`
- `bin/spotify` - запуск Spotify (бинд Ctrl+S и лаунчер): после обновления
  Spotify сам заново накатывает Spicetify с темой Comfy
- `config/sddm/theme.conf` - выбор темы входа SDDM (where-is-my-sddm-theme,
  ставится из AUR)
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
