# Сценарии iptables

### Задачи.
1. реализовать knocking port
2. centralRouter может попасть на ssh inetrRouter через knock скрипт
3. добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост.
4. запустить nginx на centralServer.
5. пробросить 80й порт на inetRouter2 8080.
6. дефолт в инет оставить через inetRouter.
7. реализовать проход на 80й порт без маскарадинга

### Структура каталогов и файлов проекта. Краткое описание.
```
.
├── playbooks
│   ├── files
│   │   ├── CR
│   │   │   ├── knock-knock.sh
│   │   │   └── prepare_os.sh
│   │   ├── CS
│   │   │   └── prepare_os.sh
│   │   ├── IR1
│   │   │   └── prepare_os.sh
│   │   └── IR2
│   │       └── prepare_os.sh
│   ├── playbook-CR.yml
│   └── playbook-CS.yml
├── README.md
└── Vagrantfile
```
`Vagrantfile` - файл сценария для `Vagrant`. Создание виртуальных машин, установка ОС и первичная настройка. <br/>
`playbook-CR.yml` - пьеса `Ansible`. `Ansible` ради `Ansible` - копирование скрипта "простукивания" портов на CR. <br/>
`playbook-CS.yml` - пьеса `Ansible`. Установка `Nginx` на ВМ `CS`. <br/>
`knock-knock.sh` -  <br/>
`prepare_os_CR.sh` -  <br/>
`prepare_os_CS.sh` -  <br/>
`prepare_os_IR1.sh` -  <br/>
`prepare_os_IR2.sh` -  <br/>
