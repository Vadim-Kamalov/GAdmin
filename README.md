# GAdmin - Lua скрипт облегчающий работу администраторов на проекте Gambit - RP

Этот репозиторий(как и исходный код) доступен для всех под стандартной [GNU General Public License v3 (GPLv3)](https://github.com/Vadim-Kamalov/GAdmin/blob/main/LICENSE) лицензией, он  содержит исходный код скрипта **`gadmin.lua`**, а также всех написанных/измененных библиотек для скрипта.
Репозиторий также используется для баг репортов связанные со скриптом, или [запросов на изменение исходного кода](https://github.com/Vadim-Kamalov/GAdmin/pulls).
### Если вы нашли ошибку
В случае если вы нашли ошибку связанную со скриптом, вы можете создать баг репорт в соответствующем [разделе](https://github.com/Vadim-Kamalov/GAdmin/issues).
<br>
Перед созданием баг репорта, убедитесь что вы

- имеете последнюю, стабильную версию скрипта(вы можете получить последнюю версию в разделе `Release`);
- имеете все библиотеки, которые прописаны в файле [`LIBRARIES`](https://github.com/Vadim-Kamalov/GAdmin/blob/main/LIBRARIES);
- не создали одинаковый или подобный баг репорт, который уже создали ранее.

Учтите, что название ошибки должно отображать всю суть ошибки, не должно быть никаких "ошибка на строке 1894".
Для создания баг репорта есть определенный шаблон, он вставится сразу в тело репорта. 

### Зависимости

- MoonLoader    >= **v.026.5-beta**
- SAMPFUNCS     >= **v5.4.1-final**
- CLEO          >= **v4.1.1**
- Все библиотеки из `LIBRARIES` файла.

# Помощь в разработке
Есть много путей как вы можете помочь в разработке, как пример вы можете

- [создавать баг репорты](https://github.com/Vadim-Kamalov/GAdmin/issues)
- смотреть [изменения в исходном коде](https://github.com/Vadim-Kamalov/GAdmin/commits/main)

Если вы заинтересованы в решении ошибок, или в добавлении изменений в исходный код, то вы можете создавать [запросы на изменение исходного кода](https://github.com/Vadim-Kamalov/GAdmin/pulls).<br>
Учтите, что основной язык скрипта - **Lua**, а написан для игры GTA: San Andreas Multiplayer, используя **Moonloader API**. Больше информации вы можете узнать в файле [`CONTRIBUTING.md`](https://github.com/Vadim-Kamalov/GAdmin/blob/main/CONTRIBUTING.md).
# License
Copyright (C) 2023 The Contributors\*.<br> Licensed under the [GNU General Public License v3 (GPLv3)](https://github.com/Vadim-Kamalov/GAdmin/blob/main/LICENSE).
> \* Вы можете найти всех кто внес вклад в разработку GAdmin в файле `CONTRIBUTORS`.
