#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
Green_font="\033[32m" && Red_font="\033[31m" && Font_suffix="\033[0m"
Info="${Green_font}[Info]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"
echo -e "${Green_font}
#======================================
# Project: testrace
# Version: 1.2
# Author: nanqinlang
# Blog:   https://sometimesnaive.org
# Github: https://github.com/nanqinlang
#======================================
${Font_suffix}"

#根据系统类型(debian/ubuntu/CentOS）安装MTR
check_system(){
	if   [[ ! -z "`cat /etc/issue | grep -iE "debian"`" ]]; then
		apt-get install traceroute mtr -y
	elif [[ ! -z "`cat /etc/issue | grep -iE "ubuntu"`" ]]; then
		apt-get install traceroute mtr -y
	elif [[ ! -z "`cat /etc/redhat-release | grep -iE "CentOS"`" ]]; then
		yum install traceroute mtr -y
	else
		echo -e "${Red_font_prefix} ${Error} 系统非debian/ubuntu/CentOS，不支持! ${Font_suffix}" && exit 1
	fi
}

#检查是否是root帐户
check_root(){
	[[ "`id -u`" != "0" ]] && echo -e "${Red_font_prefix} ${Error} 当前帐户非root用户，请用root用户再试 ! ${Font_suffix}" && exit 1
}

#创建testrace文件夹
directory(){
	[[ ! -d /home/testrace ]] && mkdir -p /home/testrace
	cd /home/testrace
}
install(){
	[[ ! -d /home/testrace/besttrace ]] && wget https://cdn.ipip.net/17mon/besttrace4linux.zip && apt-get -y install unzip mtr && unzip besttrace4linux.zip -d /home/testrace/besttrace && rm besttrace4linux.zip
	[[ ! -d /home/testrace/besttrace ]] && echo -e "${Error} 下载失败，请检查!" && exit 1
	chmod -R +x /home/testrace
}


#开始菜单
start_menu(){
clear
echo && echo -e "${Green_font} 欢迎使用本路由测试脚本 ${Font_suffix}

————————————MTR测试—————————————
 ${Green_font}1.${Font_suffix} MTR测试网络链路路由测试
 ${Green_font}说明：集合ping、tracerouted的特性，功能更强大，相比traceroute只会做一次链路跟踪测试，MTR测试会对链路上的相关节点做持续探测并给出相应的统计信息。${Font_suffix}
	   
——————————南昌三网联测——————————
 ${Green_font}2.${Font_suffix} 南昌电信、联通、移动路由一键测试
 ${Green_font}说明：用traceroute做一次本机到南昌电信、联通、移动的路由测试。 ${Font_suffix}
	   	   
——————————南昌三网单测——————————
 ${Green_font}3.${Font_suffix} 南昌电信、联通、移动路由单独测试
 ${Green_font}说明：用traceroute做一次本机到南昌电信/联通/移动的路由测试。 ${Font_suffix}
	   
————————————全国四网————————————
 ${Green_font}4.${Font_suffix} 全国电信、联通、移动、教育网路由一键测试
 ${Green_font}说明：根据下一层级选择用traceroute做一次本机到全国电信/联通/移动/教育网预设节点的路由测试。${Font_suffix} 
	   
————————————自定义IP————————————
 ${Green_font}5.${Font_suffix} 自定义IP路由一键测试
 ${Green_font}说明：根据输入的IP用traceroute做一次本机到该IP的路由测试。 ${Font_suffix} 
————————————————————————————————"
echo
read -p " 请输入数字 [1-5]:" function
case "$function" in
	1)
	test_MTR
	;;
	2)
	test_NC_all
	;;
	3)
	test_NC
	;;
	4)
	test_pre_jiedian
	;;
	5)
	test_single
	;;
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-5]"
	sleep 3s
	start_menu
	;;
esac
}



#MTR测试
test_MTR(){
	select_ISP
	echo -e "${Info} MTR测试 到 ${ISP_name} 中..."
	mtr ${ip}
	echo -e "${Info} MTR测试 到 ${ISP_name} 完成！"
	echo
	echo -e "#################################################################################################################"
	echo        
	echo -e "${Green_font} 返回主菜单or其他节点MTR测试?请选择：${Font_suffix}

     ${Green_font}1.${Font_suffix} 其他节点MTR测试
 
     ${Green_font}2.${Font_suffix} 返回主菜单"
    echo
    read -p " 请输入数字 [1-2]:" function
    case "$function" in
     	1)
    	test_MTR
	    ;;
	    2)
    	start_menu
    	;;
    	*)
    	clear
    	echo -e "${Error}:请输入正确数字 [1-2]"
    	sleep 3s
    	repeat_test_NC
	    ;;
    esac	
	
}



#南昌三网联测
test_NC_all(){
	result_NC_all	'117.41.185.1'	    '南昌电信'
	result_NC_all	'59.63.232.237'	    '南昌天翼'
	result_NC_all	'219.158.116.214'	'南昌联通'
	result_NC_all	'117.169.65.1'		'南昌移动'
	echo -e "#################################################################################################################"
	echo        
	echo -e "${Green_font} 返回主菜单or再南昌三网联测?请选择：${Font_suffix}

     ${Green_font}1.${Font_suffix} 再南昌三网联测
 
     ${Green_font}2.${Font_suffix} 返回主菜单"
    echo
    read -p " 请输入数字 [1-2]:" function
    case "$function" in
     	1)
    	test_NC_all
	    ;;
	    2)
    	start_menu
    	;;
    	*)
    	clear
    	echo -e "${Error}:请输入正确数字 [1-2]"
    	sleep 3s
    	test_NC_all
	    ;;
    esac	
}
result_NC_all(){
	ISP_name=$2
	echo -e "${Info} 测试路由 到 ${ISP_name} 中..."
	echo
	./besttrace -q 1 -g cn $1
	echo -e "${Info} 测试路由 到 ${ISP_name} 完成！"
	echo
	echo "*****************************************************************************"
	echo
}


#南昌三网单测
test_NC(){
	node_NC
	echo -e "#################################################################################################################"
    echo -e "${Info} 测试路由 到 ${ISP_name} 中..."
	echo
	./besttrace -q 1 -g cn $ip
	echo -e "${Info} 测试路由 到 ${ISP_name} 完成！"
	echo
	echo -e "#################################################################################################################"
	echo        
	echo -e "${Green_font} 返回主菜单or再单测南昌三网?请选择：${Font_suffix}

     ${Green_font}1.${Font_suffix} 再单测南昌三网
 
     ${Green_font}2.${Font_suffix} 返回主菜单"
    echo
    read -p " 请输入数字 [1-2]:" function
    case "$function" in
     	1)
    	test_NC
	    ;;
	    2)
    	start_menu
    	;;
    	*)
    	clear
    	echo -e "${Error}:请输入正确数字 [1-2]"
    	sleep 3s
    	test_NC
	    ;;
    esac
}




#全国四网测试
test_pre_jiedian(){
	select_ISP
	echo -e "#################################################################################################################"
    echo -e "${Info} 测试路由 到 ${ISP_name} 中..."
	echo
	./besttrace -q 1 -g cn $ip
	echo -e "${Info} 测试路由 到 ${ISP_name} 完成！"
	echo
	echo -e "#################################################################################################################"
	echo        
	echo -e "${Green_font} 返回主菜单or测试其他运营商/目的地?请选择：${Font_suffix}

     ${Green_font}1.${Font_suffix} 测试其他运营商/目的地

     ${Green_font}2.${Font_suffix} 返回主菜单"
    echo
    read -p " 请输入数字 [1-2]:" function
    case "$function" in
     	1)
    	test_pre_jiedian
	    ;;
	    2)
    	start_menu
    	;;
    	*)
    	clear
    	echo -e "${Error}:请输入正确数字 [1-2]"
    	sleep 3s
    	test_pre_jiedian
	    ;;
    esac

}



#自定义IP单测
test_single(){
	echo -e "${Info} 请输入你要测试的目标 ip :"
	read -p "输入 ip 地址:" ip
    result_test_single
}
result_test_single(){
	ISP_name=$ip
	echo -e "${Info} 测试路由 到 ${ISP_name} 中..."
	echo
	./besttrace -q 1 -g cn $ip
	echo -e "${Info} 测试路由 到 ${ISP_name} 完成！"
    echo
	echo -e "#################################################################################################################"
	echo        
	echo -e "${Green_font} 返回主菜单or再测试一次?请选择：${Font_suffix}

     ${Green_font}1.${Font_suffix} 再测试一次
 
     ${Green_font}2.${Font_suffix} 返回主菜单"
    echo
    read -p " 请输入数字 [1-2]:" function
    case "$function" in
     	1)
    	result_test_single
	    ;;
	    2)
    	start_menu
    	;;
    	*)
    	clear
    	echo -e "${Error}:请输入正确数字 [1-2]"
    	sleep 3s
    	test_NC
	    ;;
    esac		
	
}



#选择运营商
select_ISP(){
echo && echo -e "#################################################################################################################"
echo
echo -e "${Green_font}请选择运营商${Font_suffix}

 ${Green_font}1.${Font_suffix} 中国电信
	   
 ${Green_font}2.${Font_suffix} 中国联通
	   
 ${Green_font}3.${Font_suffix} 中国移动
	   
 ${Green_font}4.${Font_suffix} 教育网"
echo
read -p " 请输入数字 [1-4]:" ISP
case "$ISP" in
	1)
	node_1
	;;
	2)
	node_2
	;;
	3)
	node_3
	;;
	4)
	node_4
	;;
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-4]"
	sleep 3s
	select_ISP
	;;
esac
}


#中国电信运营商
node_1(){
echo && echo -e "#################################################################################################################"
echo
echo -e "${Green_font}请选择目的地节点 ${Font_suffix}

 ${Green_font}1.${Font_suffix} 上海天翼
	   
 ${Green_font}2.${Font_suffix} 厦门电信
	   
 ${Green_font}3.${Font_suffix} 襄阳电信
	   
 ${Green_font}4.${Font_suffix} 南昌天翼
 
 ${Green_font}5.${Font_suffix} 南昌电信1
  
 ${Green_font}6.${Font_suffix} 南昌电信2

 ${Green_font}7.${Font_suffix} 深圳电信

 ${Green_font}8.${Font_suffix} 广州天翼 "
echo
read -p " 请输入数字 [1-8]:" node
case "$node" in
	1)
	ISP_name="上海天翼"    && ip=101.227.255.45
	;;
	2)
	ISP_name="厦门电信"	   && ip=117.28.254.129
	;;
	3)
	ISP_name="襄阳电信"	   && ip=58.51.94.106
	;;
	4)
	ISP_name="南昌天翼"	   && ip=59.63.232.237
	;;
	5)
	ISP_name="南昌电信1"   && ip=117.41.185.1
	;;	
	6)
	ISP_name="南昌电信2"   && ip=182.98.238.226
	;;	
	7)
	ISP_name="深圳电信"	   && ip=119.147.52.35
	;;	
	8)
	ISP_name="广州天翼"    && ip=14.215.116.1
	;;	
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-8]"
	sleep 3s
	node_1
	;;
esac

}


#中国联通运营商
node_2(){
echo && echo -e "#################################################################################################################"
echo
echo -e "${Green_font}请选择目的地节点 ${Font_suffix}

 ${Green_font}1.${Font_suffix} 拉萨联通
	   
 ${Green_font}2.${Font_suffix} 重庆联通
	   
 ${Green_font}3.${Font_suffix} 郑州联通
	   
 ${Green_font}4.${Font_suffix} 合肥联通
 
 ${Green_font}5.${Font_suffix} 南京联通
  
 ${Green_font}6.${Font_suffix} 杭州联通"
echo
read -p " 请输入数字 [1-6]:" node
case "$node" in
	1)
	ISP_name="拉萨联通"    && ip=221.13.70.244
	;;
	2)
	ISP_name="重庆联通"	   && ip=113.207.32.65
	;;
	3)
	ISP_name="郑州联通"	   && ip=61.168.23.74
	;;
	4)
	ISP_name="合肥联通"	   && ip=112.122.10.26
	;;
	5)
	ISP_name="南京联通"   && ip=58.240.53.78
	;;	
	6)
	ISP_name="杭州联通"   && ip=101.71.241.238
	;;	
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-6]"
	sleep 3s
	node_2
	;;
esac

}


#中国移动运营商
node_3(){
echo && echo -e "#################################################################################################################"
echo
echo -e "${Green_font}请选择目的地节点 ${Font_suffix}

 ${Green_font}1.${Font_suffix} 上海移动
	   
 ${Green_font}2.${Font_suffix} 成都移动
	   
 ${Green_font}3.${Font_suffix} 合肥移动
	   
 ${Green_font}4.${Font_suffix} 合肥联通"
echo
read -p " 请输入数字 [1-4]:" node
case "$node" in
	1)
	ISP_name="上海移动"    && ip=221.130.188.251
	;;
	2)
	ISP_name="成都移动"	   && ip=183.221.247.9
	;;
	3)
	ISP_name="合肥移动"	   && ip=120.209.140.60
	;;
	4)
	ISP_name="杭州移动"	   && ip=112.17.0.106
	;;
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-4]"
	sleep 3s
	node_3
	;;
esac

}


#教育网运营商
node_4(){
echo && echo -e "#################################################################################################################"
echo
echo -e "${Green_font}请选择目的地节点 ${Font_suffix}

 ${Green_font}1.${Font_suffix} 北京教育网"
echo
read -p " 请输入数字 [1]:" node
case "$node" in
	1)
	ISP_name="北京教育网"    && ip=202.205.6.30
	;;
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1]"
	sleep 3s
	node_4
	;;
esac

}


#南昌三网
node_NC(){
echo && echo -e "#################################################################################################################"
echo
echo -e "${Green_font}请选择目的地节点 ${Font_suffix}

 ${Green_font}1.${Font_suffix} 南昌电信
 
 ${Green_font}2.${Font_suffix} 南昌天翼

 ${Green_font}3.${Font_suffix} 南昌联通

 ${Green_font}4.${Font_suffix} 南昌移动"
echo
read -p " 请输入数字 [1-4]:" node
case "$node" in
	1)
	ISP_name="南昌电信"    && ip=117.41.185.1
	;;
	2)
	ISP_name="南昌天翼"    && ip=59.63.232.237
	;;
	3)
	ISP_name="南昌联通"    && ip=219.158.116.214
	;;
	4)
	ISP_name="南昌移动"    && ip=117.169.65.1
	;;
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-4]"
	sleep 3s
	node_NC
	;;
esac

}

check_system
check_root
directory
install
cd besttrace
start_menu















	





