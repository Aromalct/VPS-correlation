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
 ${Green_font}1.${Font_suffix} 系统升级
 ${Green_font}2.${Font_suffix} 修改时区
 ${Green_font}3.${Font_suffix} 改ssh密码
 ${Green_font}4.${Font_suffix} 改ssh端口
 ${Green_font}5.${Font_suffix} 创建密钥对及设置
 ${Green_font}6.${Font_suffix} 安装iptables-persistent工具并禁用25端口
 ${Green_font}7.${Font_suffix} 测试邮件端口（25）禁用情况
 ${Green_font}8.${Font_suffix} 路由测试
 ${Green_font}9.${Font_suffix} 安装or开启BBR
 ${Green_font}10.${Font_suffix} 查看暴力破解情况

 
————————————功能安装————————————
 ${Green_font}11.${Font_suffix} 安装acme.sh
 ${Green_font}12.${Font_suffix} 安装caddy2
 ${Green_font}13.${Font_suffix} 安装V2-UI
 ${Green_font}14.${Font_suffix} 安装X-UI
 ${Green_font}15.${Font_suffix} 安装Soga-V2Board
 
————————————————————————————————"
echo
read -p " 请输入数字 [1-10]:" function
case "$function" in
	1)
	system_update
	;;
	2)
	chang_time_zone
	;;
	3)
	chang_ssh_password
	;;
	4)
	chang_ssh_port
	;;
	5)
	Create_key_pair
	;;
	6)
	install_iptables_persistent
	;;
	7)
	Test_port_disablement
	;;
	8)
	Routing_test
	;;
	9)
	install_BBR
	;;
	10)
	Authlog_check
	;;
	11)
	install_acme
	;;
	12)
	install_caddy2
	;;
	13)
	install_V2_UI
	;;
	14)
	install_X_UI
	;;
	15)
	install_Soga_V2Board
	;;	
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-10]"
	sleep 3s
	start_menu
	;;
esac
}

install_Soga_V2Board(){
    echo -e "${Info}:安装宝塔面板"
	wget -O install.sh http://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh
	
	echo -e "${Info}:请登录宝塔进行环境安装
    #选择使用LNMP的环境安装方式勾选如下信息
     Nginx 1.18.0
     MySQL 5.6 （或者更高版本，根据vps性能选择安装）
     PHP-7.4
     PM2管理器
    #选择 Fast 快速编译后进行安装。"
	
	echo -e "${Info}:在宝塔面板安装redis
	#上述软件安装完成后，在 BTPanel面板 > 软件商店 > 找到PHP 7.4 > 点击设置 > 安装扩展 > 选择redis进行安装
	#一定要确定redis安装完成，可能出现界面提示安装完成，但实际并没有安装的bug"

	echo -e "${Info}:在宝塔面板解除被禁止的函数
	在 BTPanel面板 > 软件商店 > 找到PHP 7.4 > 点击设置 > 禁用函数 中将 putenv proc_open pcntl_alarm pcntl_signal 从列表中删除
	至此，所有依赖软件都安装完成，下面配置网站"
	
	echo -e "${Info}:在宝塔面板添加站点
	#BTPanel面板 > 网站 > 添加站点
	 在 域名 填入你指向服务器的域名
	 在 数据库 选择MySQL
	 在 数据库设置 填写数据库 用户名 密码
	 在 PHP Verison 选择PHP-74"
	
	echo -e "${Info}:安装V2Board"
	  #通过SSH登录到服务器后访问站点路径如：/www/wwwroot/你的站点域名。
	  #以下命令都需要在站点目录进行执行。
    read -p "请输入域名:" domain
	cd /www/wwwroot/$domain
	echo -e "${Info}:删除目录下文件" 
    chattr -i .user.ini && rm -rf .htaccess 404.html index.html
	echo -e "${Info}:下载v2broad到自己的网站目录" 
	git clone -b master https://github.com/v2board/v2board.git tmp && mv tmp/.git . && rm -rf tmp && git reset --hard
	echo -e "${Info}:下载composer并安装" 
    wget https://getcomposer.org/download/1.9.0/composer.phar && php composer.phar install
	echo -e "${Info}:正式安装v2broad，根据提示输入自己数据库的相应信息，共5项" 
    php artisan v2board:install
	 
	echo -e "${Info}:网站配置
	BTPanel面板 > 网站 > 点击网站 > 网站目录 
	 取消防跨站攻击，运行目录选择/public，最后点击保存

	BTPanel面板 > 网站 > 点击网站 > 伪静态  
	 填入下面代码
location /downloads {
}

location / {  
    try_files $uri $uri/ /index.php$is_args$query_string;  
}

location ~ .*\.(js|css)?$
{
    expires      1h;
    error_log off;
    access_log /dev/null; 
}"	 

	echo -e "${Info}:配置定时任务和添加守护队列
	BTPanel面板 > 计划任务 
	 在 任务类型 选择“Shell脚本”
	 在 任务名称 填写 任务名称
	 在 执行周期 选择好执行时间周期
	 在 脚本内容 栏填写以下代码
	 */1 * * * * php /www/wwwroot/网站目录/artisan schedule:run
	 
	 在BTPanel面板 > 软件商店 找到安装的 PM2管理器 ，点击设置 安装下面所示添加对应项
	 在 项目列表 选择路径“/www/wwwroot/网站目录/”
	 pm2.yaml
	 任务名称
	  "


	 
	 
	 ##配置站点目录及伪静态
	  #添加完成后编辑添加的站点 > Site directory > Running directory 选择 /public 保存。
	  #添加完成后编辑添加的站点 > URL rewrite 填入伪静态信息。(注意删除下面代码前的“#”号）	
#location /downloads {
#}

#location / {  
#    try_files $uri $uri/ /index.php$is_args$query_string;  
#}

#location ~ .*\.(js|css)?$
#{
#    expires      1h;
#    error_log off;
#    access_log /dev/null; 
#}	

	 ##配置定时任务
	  #aaPanel 面板 > Cron。
	  #在 Type of Task 选择 Shell Script
	  #在 Name of Task 填写 v2board
	  #在 Period 选择 N Minutes 1 Minute
	  #在 Script content 填写 php /www/wwwroot/路径/artisan schedule:run
	  #根据上述信息添加每1分钟执行一次的定时任务。

	 ##启动队列服务
	  #V2board的邮件系统强依赖队列服务，你想要使用邮件验证及群发邮件必须启动队列服务。下面以aaPanel中nodejs的PM2服务来守护队列服务作为演示。
	  #aaPanel 面板 > App Store > Deployment
	  #找到PM2 Manager 4.2.2进行安装，安装完成后按照如下填写
	  #在 Project root directory 选择站点目录
	  #在 Startup file name 填写 pm2.yaml
	  #在 project name 填写 v2board
	  #填写后点击Add添加即可运行。当然你也可以使用supervisor进行守护。
	  #aaPanel在安装PM2的时候可能会造成问题无法安装，你可以手动进行PM2安装。如何安装可以参考Google

	 ##常见问题
	  #Q：500错误
	  #A：检查站点根目录权限，递归755，保证目录有可写文件的权限，也有可能是Redis扩展没有安装或者Redis没有按照造成的。你可以通过查看storage/logs下的日志来排查错误或者开启debug模式。	
}







system_update(){
	apt-get update
        apt-get upgrade
	apt-get -y install curl sudo
	reto_menu_exit
}

chang_time_zone(){
	timedatectl set-timezone Asia/Shanghai
	apt-get install -y ntp
    systemctl enable ntp
    systemctl restart ntp
	reto_menu_exit
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

Create_key_pair(){
	cd .ssh
	ssh-keygen -t rsa -b 4096  #-b 参数，指定了长度，也可以不加-b参数，直接使用ssh-keygen -t rsa，执行密钥生成命令，基本上是一路回车既可以了，但是需要注意的是：执行命令的过程中是会提示呢输入密钥文件名和密码，文件名建议用VPS的IP，密码要输入两次相同的进行确认，不需要密码直接回车就行。
	cat id_rsa.pub >> authorized_keys
	cd /etc/ssh/
	cat RSAAuthentication yes >> /etc/ssh/sshd_config
	cat PubkeyAuthentication yes >> /etc/ssh/sshd_config 
#	cat "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config 
	reto_menu_exit
}

install_iptables_persistent(){
	iptables -I FORWARD -p tcp --dport 25 -j DROP
	iptables -I INPUT -p tcp --dport 25 -j DROP
	iptables -I OUTPUT -p tcp --dport 25 -j DROP
	echo -e "${Green_font}安装过程中会询问您是否要保存当前IPv4规则、IPv6规则，全选YES${Font_suffix}"
	apt-get install -y iptables-persistent
	echo -e "${Green_font}已在/etc目录下生成/iptables目录，并生成rules.v4文件用于存放IPv4规则，rules.v6文件用于存放IPv6规则。${Font_suffix}"
    read -p "(是否测试生效情况：y/n):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
			nc -vz smtp-relay.gmail.com 25
		fi
	reto_menu_exit	
}

Test_port_disablement(){
#	read -p "请输入端口:" port
	nc -vz smtp-relay.gmail.com $port
	reto_menu_exit
}


Routing_test(){
	bash <(curl -Ls https://raw.githubusercontent.com/Aromalct/VPS-correlation/main/VPS-sh/testrace2.sh)
	reto_menu_exit
}


install_BBR(){
	echo -e "${Green_font} 根据系统是否自带BBR选择（1.安装：不带或想重装自选的BBR；2.系统自带仅开启）${Font_suffix}

     ${Green_font}1.${Font_suffix} 安装或重装自选BBR
 
     ${Green_font}2.${Font_suffix} 系统自带仅开启"
    echo
    read -p " 请输入数字 [1-2]:" function
	if [[ ${function} == [1] ]]; then
	          bash <(curl -Ls https://raw.githubusercontent.com/Aromalct/VPS-correlation/main/VPS-sh/tcp.sh)
			else
              echo -e "${Green_font}========修改系统变量，下面显示的内容为修改后的系统变量========${Font_suffix}"
		      echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
              echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
	          #保存生效
	          sysctl -p
			  echo -e "${Green_font}====查看内核是否已开启BBR，显示以下即已开启：
net.ipv4.tcp_available_congestion_control = bbr cubic reno${Font_suffix}"		
		      sysctl net.ipv4.tcp_available_congestion_control
			  echo -e "${Green_font}====查看BBR是否启动，显示以下即启动成功：
tcp_bbr                xxxxx  xx${Font_suffix}"		
		      lsmod | grep bbr	
		fi
	reto_menu_exit
}




Authlog_check(){
    echo -e "${Green_font}用密码登陆成功的IP地址及次数:${Font_suffix}"
	grep "Accepted password for root" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr | more
	echo -e "${Green_font}	${Font_suffix}"
	echo -e "${Green_font}用密码登陆失败的IP地址及次数（下面无IP等数字代表未受到暴力破解密码攻击）:${Font_suffix}"
	grep "Failed password for root" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr | more
	echo -e "${Green_font}	${Font_suffix}"
	echo -e "${Green_font}猜用户名失败的IP地址及次数（下面无IP等数字代表未受到猜用户名攻击）:${Font_suffix}"
	grep "Failed password for invalid user" /var/log/auth.log | awk '{print $13}' | sort | uniq -c | sort -nr | more
	echo -e "${Green_font}
	
	${Font_suffix}"
    reto_menu_exit
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
#	            read -p "设置证书文件夹:" ssl_filename
#	            mkdir /etc/ssl/$ssl_filename
	            mkdir /etc/ssl/$domain
	            bash /root/.acme.sh/acme.sh --install-cert -d $domain --ecc \
                        --fullchain-file /etc/ssl/$domain/$domain.crt \
                        --key-file /etc/ssl/$domain/$domain.key
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
    #bash <(curl -Ls https://raw.githubusercontent.com/sprov065/x-ui/master/install.sh)
	bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
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

