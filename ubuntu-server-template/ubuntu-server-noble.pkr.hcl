# Ubuntu Server Noble Numbat
# ---
# Packer шаблон для создания Ubuntu Server 24.04 LTS (Noble Numbat) на Proxmox
# Packer template to create Ubuntu Server 24.04 LTS (Noble Numbat) on Proxmox

# Определение ресурсов для шаблона виртуальной машины
# Resource Definition for the VM Template

packer {
  required_plugins {
    name = {
      version = "~> 1"  # Версия плагина / Plugin version
      source  = "github.com/hashicorp/proxmox"  # Источник плагина / Plugin source
    }
  }
}
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}
source "proxmox-iso" "ubuntu-server-noble" {
    # Настройки подключения к Proxmox
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"  # URL для подключения к Proxmox / URL to connect to Proxmox
    username = "${var.proxmox_api_token_id}"  # Имя пользователя для подключения / Username for connection
    token = "${var.proxmox_api_token_secret}"  # Токен для аутентификации / Authentication token

    # (Опционально) Пропустить проверку TLS
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true  # Отключить проверку TLS / Disable TLS verification
    
    # Общие настройки виртуальной машины
    # VM General Settings
    node = "server"  # Узел Proxmox для создания VM / Proxmox node for VM creation
    vm_id = "301"  # Идентификатор виртуальной машины / Virtual machine ID
    vm_name = "ubuntu-server-noble"  # Имя виртуальной машины / Virtual machine name
    template_description = "Noble Numbat"  # Описание шаблона / Template description

    # Настройки ОС виртуальной машины
    # VM OS Settings
    iso_url = "https://releases.ubuntu.com/noble/ubuntu-24.04-live-server-amd64.iso"
    iso_checksum = "sha256:8762f7e74e4d64d72fceb5f70682e6b069932deedb4949c6975d0f0fe0a91be3"
    #iso_file = "local:iso/ubuntu-24.04-live-server-amd64.iso"  # Путь к ISO файлу / Path to the ISO file
    iso_storage_pool = "local"  # Пул хранения ISO / ISO storage pool
    unmount_iso = true  # Автоматическое размонтирование ISO после установки / Automatically unmount ISO after installation
    template_name = "packer-ubuntu2404"  # Имя шаблона / Template name

    # Системные настройки виртуальной машины
    # VM System Settings
    qemu_agent = true  # Включить QEMU агент / Enable QEMU agent

    # Настройки жесткого диска виртуальной машины
    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"  # Контроллер SCSI / SCSI controller

    disks {
        disk_size = "20G"  # Размер диска / Disk size
        format = "raw"  # Формат диска / Disk format
        storage_pool = "lvm2"  # Пул хранения диска / Disk storage pool
        type = "virtio"  # Тип диска / Disk type
    }

    # Настройки процессора виртуальной машины
    # VM CPU Settings
    cores = "1"  # Количество ядер процессора / Number of CPU cores
    
    # Настройки памяти виртуальной машины
    # VM Memory Settings
    memory = "2048"  # Объем памяти (в МБ) / Memory size (in MB)

    # Настройки сети виртуальной машины
    # VM Network Settings
    network_adapters {
        model = "virtio"  # Модель сетевого адаптера / Network adapter model
        bridge = "vmbr0"  # Сетевой мост / Network bridge
        firewall = "false"  # Отключить брандмауэр / Disable firewall
    }

    # Настройки Cloud-Init для виртуальной машины
    # VM Cloud-Init Settings
    cloud_init = true  # Включить Cloud-Init / Enable Cloud-Init
    cloud_init_storage_pool = "lvm2"  # Пул хранения для Cloud-Init / Cloud-Init storage pool

    # Команды загрузки для PACKER
    # PACKER Boot Commands
    boot_command = [
        "<esc><wait>",  # Нажать Esc и подождать / Press Esc and wait
        "e<wait>",  # Нажать e и подождать / Press e and wait
        "<down><down><down><end>",  # Перейти вниз и в конец строки / Move down and to the end of the line
        "<bs><bs><bs><bs><wait>",  # Удалить символы и подождать / Delete characters and wait
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",  # Автоустановка с использованием nocloud-net / Autoinstall using nocloud-net
        "<f10><wait>"  # Нажать F10 и подождать / Press F10 and wait
    ]
    boot = "c"  # Загрузиться с CD-ROM / Boot from CD-ROM
    boot_wait = "5s"  # Ждать 5 секунд перед загрузкой / Wait 5 seconds before booting

    # Настройки автозагрузки для PACKER
    # PACKER Autoinstall Settings
    http_directory = "./http"  # Директория для HTTP сервера / Directory for HTTP server
    #http_bind_address = "10.1.149.166"  # Привязка IP адреса для HTTP сервера / Bind IP address for HTTP server
    # (Опционально) Привязка IP адреса и порта
    # (Optional) Bind IP Address and Port
    # http_port_min = 8802  # Минимальный порт для HTTP сервера / Minimum port for HTTP server
    # http_port_max = 8802  # Максимальный порт для HTTP сервера / Maximum port for HTTP server

    ssh_username = "ansible"  # Имя пользователя для SSH / SSH username

    # (Вариант 1) Добавьте ваш пароль здесь
    # (Option 1) Add your Password here
    ssh_password = "4658dsaf**"  # Пароль для SSH / SSH password
    # - или -
    # - or -
    # (Вариант 2) Добавьте ваш приватный SSH ключ здесь
    # (Option 2) Add your Private SSH KEY file here
    # ssh_private_key_file = "~/.ssh/id_rsa"  # Путь к приватному ключу SSH / Path to the private SSH key

    # Увеличьте таймаут, если установка занимает больше времени
    # Raise the timeout if the installation takes longer
    ssh_timeout = "20m"  # Таймаут для SSH / SSH timeout
}

# Определение сборки для создания шаблона виртуальной машины
# Build Definition to create the VM Template
build {
    name = "ubuntu-server-noble"  # Имя сборки / Build name
    sources = ["proxmox-iso.ubuntu-server-noble"]  # Источники для сборки / Build sources

    # Настройка шаблона виртуальной машины для интеграции Cloud-Init в Proxmox #1
    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",  # Ждать завершения cloud-init / Wait for cloud-init to finish
            "sudo rm /etc/ssh/ssh_host_*",  # Удалить SSH ключи / Remove SSH keys
            "sudo truncate -s 0 /etc/machine-id",  # Очистить идентификатор машины / Clear machine ID
            "sudo apt -y autoremove --purge",  # Удалить неиспользуемые пакеты / Remove unused packages
            "sudo apt -y clean",  # Очистить кэш APT / Clean APT cache
            "sudo apt -y autoclean",  # Автоматически очистить кэш APT / Auto clean APT cache
            "sudo cloud-init clean",  # Очистить Cloud-Init / Clean Cloud-Init
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",  # Удалить конфигурационный файл Cloud-Init / Remove Cloud-Init configuration file
            "sudo rm -f /etc/netplan/00-installer-config.yaml",  # Удалить конфигурационный файл Netplan / Remove Netplan configuration file
            "sudo sync"  # Синхронизировать файловую систему / Synchronize filesystem
        ]
    }

    # Настройка шаблона виртуальной машины для интеграции Cloud-Init в Proxmox #2
    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"  # Источник файла для передачи / Source file to transfer
        destination = "/tmp/99-pve.cfg"  # Место назначения файла на виртуальной машине / Destination file on the virtual machine
    }

    # Настройка шаблона виртуальной машины для интеграции Cloud-Init в Proxmox #3
    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]  # Копировать файл конфигурации на место / Copy configuration file to the destination
    }
}
