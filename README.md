<h1 align="center">Автоматический установщик программ для Windows</h1>

<hr>

## Для чего этот скрипт?
Скрипт облегчит поиск и установку основных программ для простого пользователя. Автоматически скачает и установит выбранную вами программу из списка (список будет пополнен).

---

## Как использовать?

### PowerShell (Windows 8 или позднее)

1.   Откройте PowerShell с правами администратора.
2.   Скопируйте и вставьте в открывшееся окно следующую команду:  
```
irm https://powertoy.erney.monster | iex
```
  Команда с альтернативной ссылкой с GitHub:
```
irm https://raw.githubusercontent.com/erneywhite/powertoy_home/refs/heads/main/home.ps1 | iex
```

3.   Выберите программу, которую хотите установить (1-9) и нажмите Enter.
4.   Программа установлена.

---

> [!NOTE]
>
> - При первом запуске скрипта - выполняется проверка на наличие архиватора 7-Zip и при его отсутствии выполняется автоматическая установка.
> - Права администратора: Для установки программ скрипт требует запуска с правами администратора.
> - Сетевое соединение: Убедитесь, что у вас есть стабильное интернет-соединение для скачивания программ.
> - Безопасность: Убедитесь, что скрипт загружен из доверенного источника. Используйте только официальные ссылки и проверяйте целостность загруженного кода.

---

<p align="center">Made by ErneyWhite</p>
