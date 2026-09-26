# my-dotfiles

Моё окружение рабочего стола: Hyprland + noctalia, тема входа SDDM
(caelestia), терминал ghostty, fish, fastfetch, обои - плюс все программы,
которые у меня стоят.

## Установка с нуля (голый Arch Linux)

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
повторно - уже установленное пропускается.

Что делает `install.sh`:

- включает `[multilib]`, обновляет систему
- ставит пакеты из `packages.txt` (официальные репо Arch)
- ставит заголовки ядра, микрокод CPU, драйверы NVIDIA (если есть видеокарта
  NVIDIA)
- собирает `yay` и ставит AUR-пакеты из `packages-aur.txt`
- ставит Flatpak-приложения из `flatpaks.txt` (Flathub)
- ставит rustup (+ cargo-xwin), uv и Claude Code
- линкует конфиги в `~/.config`, тему SDDM, состояние Noctalia, обои
- включает сервисы (NetworkManager, bluetooth, sddm, docker, ufw, ...),
  добавляет в группы docker/realtime, делает fish shell по умолчанию,
  ставит плагины fish (tide)

`--no-packages` пропускает всю установку программ и только пересоздаёт
симлинки конфигов.

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
