# GAdmin - Lua скрипт облегчающий работу администраторов на проекте Gambit - RP

Этот репозиторий(как и исходный код) доступен для всех под стандартной [GNU General Public License v3 (GPLv3)](https://github.com/Vadim-Kamalov/GAdmin/blob/main/LICENSE) лицензией.
Репозиторий также используется для создания репортов о каких-либо ошибках связанными со скриптом,
или [запросов на изменение исходного кода](https://github.com/Vadim-Kamalov/GAdmin/pulls).

Исходный код написан на диалекте Lua - [Clue](https://github.com/ClueLang/Clue). Имейте ввиду то, что если вы переместите файлы из
`src/` директории в вашу `gta_sa/moonloader/` директорию, то ничего не произойдет, поскольку потребуется компиляция `.clue` файлов в один общий Lua файл.
Для инструкций по компиляции смотрите ниже.

# Компиляция/установка

В скрипте присутствует автообновление: одна установка скрипта - всегда будет стабильная версия скрипта.
Обновление также можно пропустить, в этом случае не будет появляться окно с обновлением до следующего релиза версии.

Чтобы установить скрипт необходимо сперва скачать последнюю версию скрипта.
Затем скомпилированный файл(последней версии) из раздела [Releases](https://github.com/Vadim-Kamalov/GAdmin/releases)
необходимо переместить по пути `<путь до игры>/moonloader`. Также необходимы
библиотеки скрипта, полный список содержится в файле [`LIBRARIES`](https://github.com/Vadim-Kamalov/GAdmin/blob/main/LIBRARIES).
Устанавливать их нужно по пути `<путь до игры>/moonloader/lib/<библиотеки из LIBRARIES>`.

Помимо библиотек необходимо то, что будет выполнять Lua файл, а конкретно:

- MoonLoader    == **v.026.5-beta**
- SAMPFUNCS     >= **v5.4.1-final**
- CLEO          >= **v4.1.1**
- SA:MP         == **037-R1** 

### Компиляция

Используйте вспомогательный скрипт сборки: `./build.sh`

```
build.sh [TARGET] [--output [PARAMETER]]
 
TARGET:
   debug   - Compile source with __GADMIN_DEBUG__ environment variable and with debug base-script.
   release - Just compile source with release base-script.
```

# Лицензия

Copyright (C) 2023-2024 The Contributors\*.
*Licensed under the GNU General Public License v3 (GPLv3)*.

> [The Contributors\*](https://github.com/Vadim-Kamalov/GAdmin/blob/main/CONTRIBUTORS)
