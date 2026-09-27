# my-dotfiles

Моё окружение рабочего стола: Hyprland + noctalia, тема входа SDDM
(caelestia), терминал ghostty, fish, fastfetch, обои - плюс все программы,
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
- `config/noctalia` + `state/noctalia/settings.toml` - настройки Noctalia,
  включая раскладку бара и список плагинов (плагины из `[plugins]` Noctalia
  подтягивает сама; `plugins/happ-control` - единственный, что не подтянется
  само, т.к. подключен как локальный путь)
- `config/ghostty` - терминал
- `config/fish` - конфиг fish (prompt на tide); `config/fish/cachyos` - копия
  fish-конфига CachyOS (алиасы eza/bat и т.п.), чтобы работало и на чистом Arch
- `config/fastfetch`, `config/mimeapps.list`
- `config/sddm/caelestia-theme` + `config/sddm/theme.conf` - тема входа SDDM
- `config/caelestia/templates/sddm-theme.conf` - шаблон синхронизации цвета
  темы SDDM с текущей палитрой
- `wallpapers/` - обои
- Telegram, Happ, Spotify - только ставятся пакетом, их личные конфиги в
  репозиторий не попадают
