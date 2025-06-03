# Настройка Slurm-кластера

## Ручная настройка

1. Убедиться, что машины находятся в одной подсети с одним роутером
2. Настроить на всех машинах файл /etc/hosts, куда вписать адреса всех виртуальных машин и наименования, по которым они смогут связываться. Пример
``
XXX.XXX.XX.XX0	slurm-controller
XXX.XXX.XX.XX1	slurm-compute1
XXX.XXX.XX.XX2	slurm-compute2
``
3. На всех машинах прогнать `` sudo apt update ``, `` sudo apt upgrade ``.
4. Устанавливаем и настраиваем Munge на slurm-controller
   
   `` sudo apt install munge libmunge2 libmunge-dev ``

   `` munge -n | unmunge | grep STATUS ``
   
   `` nano /etc/munge/munge.key ``
   
   `` sudo chown -R munge: /etc/munge/ /var/log/munge/ /var/lib/munge/ /run/munge/ ``
   
   `` sudo chmod 0700 /etc/munge/ /var/log/munge/ /var/lib/munge/ ``
   
   `` sudo chmod 0755 /run/munge/ ``
   
   `` sudo chmod 0700 /etc/munge/munge.key ``
   
   `` sudo chown -R munge: /etc/munge/munge.key ``
   
   `` systemctl enable munge ``
   
   `` systemctl restart munge ``
   
   `` systemctl status munge ``
   
6. Устанавливаем Munge на compute
   
`` sudo apt install munge libmunge2 libmunge-dev ``

`` munge -n | unmunge | grep STATUS ``

7. Копируем munge-key с slurm-controller на compute

`` scp /etc/munge/munge.key root@slurm-compute1:/etc/munge/ ``

`` scp /etc/munge/munge.key root@slurm-compute2:/etc/munge/ ``

8. На compute проверяем ключ `` nano /etc/munge/munge.key `` и выполняем настройку munge

`` sudo chown -R munge: /etc/munge/ /var/log/munge/ /var/lib/munge/ /run/munge/ ``

`` sudo chmod 0700 /etc/munge/ /var/log/munge/ /var/lib/munge/ ``

`` sudo chmod 0755 /run/munge/ ``

`` sudo chmod 0700 /etc/munge/munge.key ``

`` sudo chown -R munge: /etc/munge/munge.key ``

`` systemctl enable munge ``

`` systemctl restart munge ``

`` systemctl status munge ``

9. Подключаемся к slurm-controller по munge

`` munge -n | ssh slurm-controller unmunge 1``

10. На всех машинах устанавливаем slurm `` sudo apt install slurm-wlm ``
11. На контроллере конфигурируем файл `` sudo cp /usr/share/doc/slurmctld/slurm-wlm-configurator.html /tmp/ ``
    
`` sudo chmod +r /tmp/slurm-wlm-configurator.html ``

12. В форме в браузере заполняем колонки
    
ClusterName(slurm-controller),

SlurmctldHost(slurm-controller),

NodeName (slurm-compute[1-2]), 

ПОСМОТРЕТЬ lscpu НА COMPUTE - CPU (4), Sockets(2), CoresPerSocket(2), ThreadsPerCore(1), 

Process Tracking - LinuxProc

13. Копируем из появившегося файла в `` /etc/slurm/slurm.conf `` на контроллере и воркерах
14. Запускаем slurm и проверяем работу на Controller. Все команды должны пройти без ошибок

`` systemctl enable slurmctld ``

`` systemctl restart slurmctld ``

`` systemctl status slurmctld ``

`` sinfo ``

`` srun -N1 -n1 hostname `` должен вывести имя одного узла

15. Запускаем slurm и проверяем работу на Compute. Все команды должны пройти без ошибок.

`` systemctl enable slurmd ``

`` systemctl restart slurmd ``

`` systemctl status slurmd ``

## Автоматизированная настройка

### Создание виртуальных машин через terraform

1. В папке terraform создаем файл terraform.tfvars, куда записываем domain_id, tenant_id, user_name, password, region для подключения к облаку.
2. В терминале из папки terraform запускаем команду `` terraform init``, смотрим, чтобы не было ошибок.
3. В терминале запускаем команду `` terraform plan ``, смотрим, чтобы не было ошибок.
4. В терминале запускаем `` terraform apply `` , вводим yes и ждем, когда в облаке создадутся виртуальные машины.

### Настройка Slurm-кластера на виртуальных машинах

1. В папке ansible в файле inventory.ini указываем адреса виртуальных машин с пометками slurm-controller или slurm-compute.
2. В терминале запускаем команду
   ``
    ansible-playbook -i inventory.ini slurm_cluster_setup.yml
   ``
### Проверка работы Slurm-кластера на виртуальных машинах

1. По ssh подключаемся к виртуальным машинам.
2. На контроллере вводим команды `` systemctl status slurmctld ``, `` sinfo ``. Команды должны пройти без ошибок, в статусе active.
3. На контроллере вводим команду `` srun -N1 -n1 hostname ``. Команда должна вывести имя одного узла.
4. На compute вводим команды `` systemctl status slurmd ``, `` sinfo ``. Команды должны пройти без ошибок, в статусе active.
