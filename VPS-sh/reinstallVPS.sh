#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
Green_font="\033[32m" && Red_font="\033[31m" && Font_suffix="\033[0m"
Info="${Green_font}[Info]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"
echo -e "${Green_font}
#======================================
# Project: Reinstall VPS
# Version: 
# Author: 
# Blog:   
# Github: 
#======================================
${Font_suffix}"

#开始菜单
start_menu(){
clear
echo && echo -e "${Green_font} 欢迎使用VPS重装部署脚本 ${Font_suffix}

————————————系统相关————————————
 ${Green_font}1.${Font_suffix} 修改ssh密码
 ${Green_font}2.${Font_suffix} 修改ssh端口
 ${Green_font}3.${Font_suffix} 修改系统时区
 ${Green_font}4.${Font_suffix} 系统升级
 ${Green_font}5.${Font_suffix} 路由测试
 ${Green_font}6.${Font_suffix} 安装开启BBR
 
————————————功能安装————————————
 ${Green_font}7.${Font_suffix} 安装acme.sh
 ${Green_font}8.${Font_suffix} 安装caddy2
 ${Green_font}9.${Font_suffix} 安装V2-UI
 ${Green_font}10.${Font_suffix} 安装X-UI
————————————————————————————————"
echo
read -p " 请输入数字 [1-10]:" function
case "$function" in
	1)
	chang_ssh_password
	;;
	2)
	chang_ssh_port
	;;
	3)
	chang_time_zone
	;;
	4)
	system_update
	;;
	5)
	Routing_test
	;;
	6)
	install_BBR
	;;
	7)
	install_acme
	;;
	8)
	install_caddy2
	;;
	9)
	install_V2_UI
	;;
	10)
	install_X_UI
	;;
		
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-10]"
	sleep 3s
	start_menu
	;;
esac
}




chang_ssh_password(){
	passwd
	reto_menu_exit
}


chang_ssh_port(){
	apt-get install -y nano
	nano /etc/ssh/sshd_config
	systemctl restart ssh
	reto_menu_exit
}

chang_time_zone(){
	timedatectl set-timezone Asia/Shanghai
	apt-get install -y ntp
    systemctl enable ntp
    systemctl restart ntp
	reto_menu_exit
}

system_update(){
	apt-get update
    apt-get upgrade
	reto_menu_exit
}

Routing_test(){
	wget https://github.com/Aromalct/VPS-correlation/blob/main/VPS-sh/testrace2.sh
	bash testrace2.sh
	reto_menu_exit
}


install_BBR(){
	wget https://github.com/Aromalct/VPS-correlation/blob/main/VPS-sh/tcp.sh
	bash tcp.sh
	re_run_BBR
}
re_run_BBR(){
	echo -e "${Green_font} 返回BBR菜单or返回主菜单：${Font_suffix}

     ${Green_font}1.${Font_suffix} 返回BBR菜单
 
     ${Green_font}2.${Font_suffix} 返回主菜单
	 
	 ${Green_font}3.${Font_suffix} 退出脚本"

    echo
    read -p " 请输入数字 [1-3]:" function
    case "$function" in
	    1)
    	install_BBR
	    ;;
     	2)
    	start_menu
	    ;;
	    3)
    	exit 0
    	;;
    	*)
    	clear
    	echo -e "${Error}:请输入正确数字 [1-3]"
    	sleep 3s
    	install_BBR
	    ;;
    esac
}



install_acme(){
	echo -e "安装acme.sh"
	apt-get -y install curl sudo socat
	curl  https://get.acme.sh | sh
	. .bashrc
	bash /root/.acme.sh/acme.sh --upgrade --auto-upgrade
	echo -e "设置环境变量"
    export CF_Token="7SwQ9DMEspervzHdYmYjUnLXRsqnwaScrNKwJESS"
    export CF_Account_ID="2efe8bf5451b8ada432a5ef2b04ee7cd"
	echo -e "测试从指定服务器申请证书"
	read -p "请输入域名:" domain
	bash /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --test -d $domain --dns  dns_cf --keylength ec-256 --force
	#填加回车继续命令
	read -p "(测试申请是否通过：y/n):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
				echo -e "正式从指定服务器申请证书"
	            bash /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue -d $domain --dns dns_cf --keylength ec-256 --force
	            echo -e "安装（拷贝）证书"
	            read -p "设置证书文件夹:" ssl_filename
	            mkdir /etc/ssl/$ssl_filename
	            bash /root/.acme.sh/acme.sh --install-cert -d $domain --ecc \
                        --fullchain-file /etc/ssl/$ssl_filename/$domain.crt \
                        --key-file /etc/ssl/$ssl_filename/$domain.key
			else
			echo && echo "证书申请、安装失败..." && echo
		fi
	
	reto_menu_exit
}


install_caddy2(){
	echo -e "安装caddy2"
	sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo apt-key add -
	curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
	sudo apt update
	sudo apt install caddy
	systemctl status caddy
	reto_menu_exit
}

install_V2_UI(){
    bash <(curl -Ls https://blog.sprov.xyz/v2-ui.sh)
	v2-ui
}

install_X_UI(){
    bash <(curl -Ls https://raw.githubusercontent.com/sprov065/x-ui/master/install.sh) 0.2.0
	x-ui
	
}


reto_menu_exit(){

	echo -e "${Green_font} 返回主菜单or退出脚本：${Font_suffix}

     ${Green_font}1.${Font_suffix} 返回主菜单
 
     ${Green_font}2.${Font_suffix} 退出脚本"
    echo
    read -p " 请输入数字 [1-2]:" function
    case "$function" in
     	1)
    	start_menu
	    ;;
	    2)
    	exit 0
    	;;
    	*)
    	clear
    	echo -e "${Error}:请输入正确数字 [1-2]"
    	sleep 3s
    	start_menu
	    ;;
    esac

}


start_menu















	





