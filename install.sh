echo "Este script instala o cups e o samba para compartilhar a impressora pdf e com seus respectivos drivers e grupos"

echo "aperte qualquer tecla para continuar para continuar"

read

#checa se o script esta sendo executado como root e se nao estiver ele envia uma mensagem de erro e sai do script

if [ "$(whoami)" != "root" ]; then
	echo "Este script precisa ser executado como root"
	exit
fi

#update pacotes

apt-get update

# Instala o cups e o samba

apt-get install cups samba -y

# Cria o grupo de trabalho REDES2022

groupadd REDES2022

#criar o diretorio arquivos no /home e compartilha-lo com o grupo redes2022 com as permissoes de leitura e escrita

mkdir /home/arquivos

chmod 777 /home/arquivos

chown root:REDES2022 /home/arquivos

# Cria o usuario "usuario1" e adiciona-o ao grupo redes2022

adduser --system usuario1

usermod -a -G REDES2022 usuario1

# Cria o usuario "usuario2" e adiciona-o ao grupo redes2022

adduser --system usuario2

usermod -a -G REDES2022 usuario2

# inicia o samaba

systemctl start smb

echo "digite a senha do usuario1"

smbpasswd -a usuario1

echo "digite a senha do usuario2"

smbpasswd -a usuario2

chown usuario1:REDES2022 -R /home/arquivos

chown usuario2:REDES2022 -R /home/arquivos

chcon -Rt samba_share_t /home/arquivos

# Cria o arquivo de configuração do samba

echo "[arquivos]
path = /home/arquivos
valid users = usuario1, usuario2
read list = @REDES2022
write list = usuario1
browseable = yes" > /etc/samba/smb.conf

# cria a impressora pdf com o cups-pdf

apt-get install cups-pdf

# cria o arquivo de configuração do cups-pdf

sudo chmod +s /usr/lib/cups/backend/cups-pdf

#restart dos serviços

systemctl restart cups smb nmb

echo "Fim do script"