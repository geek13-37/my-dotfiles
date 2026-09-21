# my-dotfiles

Мои конфиги окружения рабочего стола: niri + noctalia, тема входа SDDM
(caelestia), терминал ghostty, fish, fastfetch, обои.

niri, noctalia и fish считаются предустановленными (как на CachyOS) - скрипт
их не ставит, только подключает конфиги.

## Установка на новую машину (CachyOS/Arch)

```bash
git clone <this-repo-url> ~/my-dotfiles
cd ~/my-dotfiles
./install.sh
```

`--no-packages` пропускает pacman/AUR-установку и только пересоздаёт симлинки.

## Что внутри

- `config/niri` - конфиг niri
- `config/noctalia` + `state/noctalia/settings.toml` - настройки Noctalia,
  включая раскладку бара и список плагинов (плагины из `[plugins]` Noctalia
  подтягивает сама; `plugins/happ-control` - единственный, что не подтянется
  само, т.к. подключен как локальный путь)
- `config/ghostty` - терминал
- `config/fish` - конфиг fish (prompt на tide)
- `config/fastfetch`, `config/mimeapps.list`
- `config/sddm/caelestia-theme` + `config/sddm/theme.conf` - тема входа SDDM
- `config/caelestia/templates/sddm-theme.conf` - шаблон синхронизации цвета
  темы SDDM с текущей палитрой
- `wallpapers/` - обои
- Telegram, Happ, Spotify - только ставятся пакетом, их личные конфиги в
  репозиторий не попадают
