# Сценарии iptables

### Задачи.
1. реализовать knocking port
2. centralRouter может попасть на ssh inetrRouter через knock скрипт
3. добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост.
4. запустить nginx на centralServer.
5. пробросить 80й порт на inetRouter2 8080.
6. дефолт в инет оставить через inetRouter.

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
`knock-knock.sh` - скрипт "простукивания" портов. Использует nmap. Порты захардкожжены. <br/>
`prepare_os_CR.sh` - скрипт настройки утсановки ПО и настройки ОС `CentralRouter`. <br/>
`prepare_os_CS.sh` - скрипт настройки `CentralServer` <br/>
`prepare_os_IR1.sh` - скрипт настройки `InetRouter1` <br/>
`prepare_os_IR2.sh` - скрипт настройки `InetRouter1` <br/>

### Реализация проекта:
1. Система "простукивания" портов реализования по средствам iptables. Основной принцип - использование модуля `recent`, позволяющего по определённым правилам вносить IP адрес отправителя пакета в конкретный список.<br/>
В данном примере таких списков 3: TARGET1, TARGET2, TARGET3.<br/>
IP адрес попадает в тот или иной список, в зависимости от порта (и последовательности "простукивания"), на который приходит запрос. Если пакеты отправителя поочерёдно побывали во всех трёх цепочках iptables, тогда отправителю становится доступен 22 порт для подключения (на 30 секунд).<br/><br/>
2. Запуск скрипта `knock-knock.sh` на сервере `CR`, автоматизирует "простукивание" портов сервера `IR1`.<br/>
3. На порт 8080 ВМ IR2, проброшен порт 8082 (настройка параметра в `Vagrantfile`):
```
box.vm.network "forwarded_port", guest: 8080, host: 8082, host_ip: "127.0.0.1", id: "nginx"
```
4. Установка `Nginx`, как указывалось выше, реализованиа при помощи пьесы `playbook-CS.yml`. 
5. Маршрутизация пакетов, приходящих на порт 8080 ВМ IR2 на порт 80 ВМ CS:
```
iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport 8080 -j DNAT --to-destination 192.168.0.2:80
iptables -t nat -A POSTROUTING -d 192.168.0.2 -p tcp -m tcp --dport 80 -j SNAT --to-source 192.168.255.2
```
6. Отклбчение дэфолтного маршрута и указание адреса шлюза - достаточное условие:
```
echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
echo "GATEWAY=192.168.255.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
```
### Запуск, проверка проекта.
Из корневого каталога проекта:
```
vagrant up
```
С хостовой машины:
```
curl http://127.0.0.1:8082/
```
Из корневого каталога проекта:
```
vagrant ssh CR
```
На сервере `CR`:
```
./knock-knock.sh
```
