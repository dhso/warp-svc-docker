#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
PLAIN='\033[0m'

red() {
    echo -e "\033[31m\033[01m$1\033[0m"
}

green() {
    echo -e "\033[32m\033[01m$1\033[0m"
}

yellow() {
    echo -e "\033[33m\033[01m$1\033[0m"
}

# 选择客户端 CPU 架构
archAffix(){
    case "$(uname -m)" in
        i386 | i686 ) echo '386' ;;
        x86_64 | amd64 ) echo 'amd64' ;;
        armv8 | arm64 | aarch64 ) echo 'arm64' ;;
        s390x ) echo 's390x' ;;
        * ) red "不支持的CPU架构!" && exit 1 ;;
    esac
}

updateBin() {
    updateYXWarp
    updateNF
    pinput
}

updateYXWarp() {
    # 下载优选工具软件,感谢某匿名网友的分享的优选工具
    yellow "优选工具下载中: "
    wget https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/warp-yxip/warp-linux-$(archAffix) -O /usr/local/bin/yxwarp
    chmod +x /usr/local/bin/yxwarp
    yellow "优选工具下载完成！"
    echo -e " "
}

updateNF() {
    # 下载奈飞检查工具
    yellow "奈飞检查工具下载中: "
    wget https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/netflix-verify/nf-linux-$(archAffix) -O /usr/local/bin/nf
    chmod +x /usr/local/bin/nf
    yellow "奈飞检查工具下载完成！"
    echo -e " "
}

checkNF() {
    if [ ! -f "/usr/local/bin/nf" ];then
      updateNF
    fi
    netflix4=$(nf | sed -n 3p | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")
    netflix6=$(nf | sed -n 7p | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g") && [[ -n $(echo $netflix6 | grep "NF所识别的IP地域信息") ]] && netflix6=$(nf | sed -n 6p | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")
    netflix_cli=$(nf -proxy socks5://127.0.0.1:40000 | sed -n 3p | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")
    
    # 简化 Netflix 检测脚本输出结果,以便输出结果的排版
    [[ $netflix4 == "您的出口IP完整解锁Netflix,支持非自制剧的观看" ]] && netflix4="${GREEN}已解锁 Netflix${PLAIN}"
    [[ $netflix6 == "您的出口IP完整解锁Netflix,支持非自制剧的观看" ]] && netflix6="${GREEN}已解锁 Netflix${PLAIN}"
    [[ $netflix4 == "您的出口IP可以使用Netflix,但仅可看Netflix自制剧" ]] && netflix4="${YELLOW}Netflix 自制剧${PLAIN}"
    [[ $netflix6 == "您的出口IP可以使用Netflix,但仅可看Netflix自制剧" ]] && netflix6="${YELLOW}Netflix 自制剧${PLAIN}"
    [[ -z $netflix4 ]] || [[ $netflix4 == "您的网络可能没有正常配置IPv4,或者没有IPv4网络接入" ]] && netflix4="${RED}无法检测 Netflix 状态${PLAIN}"
    [[ -z $netflix6 ]] || [[ $netflix6 == "您的网络可能没有正常配置IPv6,或者没有IPv6网络接入" ]] && netflix6="${RED}无法检测 Netflix 状态${PLAIN}"
    [[ $netflix4 =~ "Netflix在您的出口IP所在的国家不提供服务"|"Netflix在您的出口IP所在的国家提供服务,但是您的IP疑似代理,无法正常使用服务" ]] && netflix4="${RED}无法解锁 Netflix${PLAIN}"
    [[ $netflix6 =~ "Netflix在您的出口IP所在的国家不提供服务"|"Netflix在您的出口IP所在的国家提供服务,但是您的IP疑似代理,无法正常使用服务" ]] && netflix6="${RED}无法解锁 Netflix${PLAIN}"
    [[ $netflix_cli == "您的出口IP完整解锁Netflix,支持非自制剧的观看" ]] && netflix_cli="${GREEN}已解锁 Netflix${PLAIN}"
    [[ $netflix_cli == "您的出口IP可以使用Netflix,但仅可看Netflix自制剧" ]] && netflix_cli="${YELLOW}Netflix 自制剧${PLAIN}"
    [[ $netflix_cli =~ "Netflix在您的出口IP所在的国家不提供服务"|"Netflix在您的出口IP所在的国家提供服务,但是您的IP疑似代理,无法正常使用服务" ]] && netflix_cli="${RED}无法解锁 Netflix${PLAIN}"
    ipv4=$(curl -s4m8 ip.p3terx.com -k | sed -n 1p)
    country4=$(curl -s4m8 ip.p3terx.com | sed -n 2p | awk -F "/ " '{print $2}')
    provider4=$(curl -s4m8 ip.p3terx.com | sed -n 3p | awk -F "/ " '{print $2}')
    echo -e "IPv4 本机地址: $ipv4"
    echo -e "地区: $country4"
    echo -e "提供商: $provider4"
    echo -e "Netflix: $netflix4"
    echo -e " "

    ipv6=$(curl -s6m8 ip.p3terx.com -k | sed -n 1p)
    country6=$(curl -s6m8 ip.p3terx.com | sed -n 2p | awk -F "/ " '{print $2}')
    provider6=$(curl -s6m8 ip.p3terx.com | sed -n 3p | awk -F "/ " '{print $2}')
    if [[ -n $ipv6 ]]; then
        echo -e "IPv6 本机地址: $ipv6"
        echo -e "地区: $country6"
        echo -e "提供商: $provider6"
        echo -e "Netflix: $netflix6"
        echo -e " "
    fi

    country_cli=$(curl -sx socks5h://localhost:40000 ip.p3terx.com -k --connect-timeout 8 | sed -n 2p | awk -F "/ " '{print $2}')
    ip_cli=$(curl -sx socks5h://localhost:40000 ip.p3terx.com -k --connect-timeout 8 | sed -n 1p)
    provider_cli=$(curl -sx socks5h://localhost:40000 ip.p3terx.com -k --connect-timeout 8 | sed -n 3p | awk -F "/ " '{print $2}')
    echo -e "WARP 代理地址: $ip_cli"
    echo -e "地区: $country_cli"
    echo -e "提供商: $provider_cli"
    echo -e "Netflix: $netflix_cli"
    echo -e " "
    pinput
}

checkGPT() {
    curl -s4m8 https://chat.openai.com/ | grep -qw "Sorry, you have been blocked" && chatgpt4="${RED}无法访问 ChatGPT${PLAIN}" || chatgpt4="${GREEN}支持访问 ChatGPT${PLAIN}"
    ipv4=$(curl -s4m8 ip.p3terx.com -k | sed -n 1p)
    country4=$(curl -s4m8 ip.p3terx.com | sed -n 2p | awk -F "/ " '{print $2}')
    provider4=$(curl -s4m8 ip.p3terx.com | sed -n 3p | awk -F "/ " '{print $2}')
    echo -e "IPv4 本机地址: $ipv4"
    echo -e "地区: $country4"
    echo -e "提供商: $provider4"
    echo -e "ChatGPT: $chatgpt4"
    echo -e " "
    
    curl -sx socks5h://localhost:40000 https://chat.openai.com/ | grep -qw "Sorry, you have been blocked" && chatgpt_cli="${RED}无法访问 ChatGPT${PLAIN}" || chatgpt_cli="${GREEN}支持访问 ChatGPT${PLAIN}"
    country_cli=$(curl -sx socks5h://localhost:40000 ip.p3terx.com -k --connect-timeout 8 | sed -n 2p | awk -F "/ " '{print $2}')
    ip_cli=$(curl -sx socks5h://localhost:40000 ip.p3terx.com -k --connect-timeout 8 | sed -n 1p)
    provider_cli=$(curl -sx socks5h://localhost:40000 ip.p3terx.com -k --connect-timeout 8 | sed -n 3p | awk -F "/ " '{print $2}')
    echo -e "WARP 代理地址: $ip_cli"
    echo -e "地区: $country_cli"
    echo -e "提供商: $provider_cli"
    echo -e "ChatGPT: $chatgpt_cli"
    echo -e " "
    pinput
}

endpointyx(){    
    if [ ! -f "/usr/local/bin/yxwarp" ];then
      updateYXWarp
    fi
    
    # 取消 Linux 自带的线程限制,以便生成优选 Endpoint IP
    ulimit -n 102400
    
    # 启动 WARP Endpoint IP 优选工具
    yxwarp >/dev/null 2>&1
    
    # 显示前十个优选 Endpoint IP 及使用方法
    green "当前最优 Endpoint IP 结果如下,并已保存至 result.csv中: "
    cat result.csv | awk -F, '$3!="timeout ms" {print} ' | sort -t, -nk2 -nk3 | uniq | head -11 | awk -F, '{print "端点 "$1" 丢包率 "$2" 平均延迟 "$3}'
    echo ""
    yellow "使用方法如下: "
    yellow "warp-cli --accept-tos set-custom-endpoint ip:port"
    best_endpoint=$(cat result.csv | awk -F, '$3!="timeout ms" {print} ' | sort -t, -nk2 -nk3 | uniq | head -11 | sed -n "2, 1p" | awk -F, '{print $1 }')
    loss=$(cat result.csv | awk -F, '$3!="timeout ms" {print} ' | sort -t, -nk2 -nk3 | uniq | head -11 | sed -n "2, 1p" | awk -F, '{print $2 }' | grep -oP '\d+' | sed -n "1, 1p")
    delay=$(cat result.csv | awk -F, '$3!="timeout ms" {print} ' | sort -t, -nk2 -nk3 | uniq | head -11 | sed -n "2, 1p" | awk -F, '{print $3 }' | grep -oP '\d+')
    if [ $loss -lt 2 ] && [ $delay -lt 500 ];then
        echo ""
        echo "正在设置优选IP"
        warp-cli --accept-tos set-custom-endpoint $best_endpoint
        echo ""
    else
        echo "延迟/丢包过高，放弃设置优选IP！"
        echo ""
    if
    # 删除 WARP Endpoint IP 优选工具及其附属文件
    # rm -f warp ip.txt
    pinput
}

endpoint4(){
    # 生成优选 WARP IPv4 Endpoint IP 段列表
    n=0
    iplist=100
    while true; do
        temp[$n]=$(echo 162.159.192.$(($RANDOM % 256)))
        n=$(($n + 1))
        if [ $n -ge $iplist ]; then
            break
        fi
        temp[$n]=$(echo 162.159.193.$(($RANDOM % 256)))
        n=$(($n + 1))
        if [ $n -ge $iplist ]; then
            break
        fi
        temp[$n]=$(echo 162.159.195.$(($RANDOM % 256)))
        n=$(($n + 1))
        if [ $n -ge $iplist ]; then
            break
        fi
        temp[$n]=$(echo 162.159.204.$(($RANDOM % 256)))
        n=$(($n + 1))
        if [ $n -ge $iplist ]; then
            break
        fi
        temp[$n]=$(echo 188.114.96.$(($RANDOM % 256)))
        n=$(($n + 1))
        if [ $n -ge $iplist ]; then
            break
        fi
        temp[$n]=$(echo 188.114.97.$(($RANDOM % 256)))
        n=$(($n + 1))
        if [ $n -ge $iplist ]; then
            break
        fi
        temp[$n]=$(echo 188.114.98.$(($RANDOM % 256)))
        n=$(($n + 1))
        if [ $n -ge $iplist ]; then
            break
        fi
        temp[$n]=$(echo 188.114.99.$(($RANDOM % 256)))
        n=$(($n + 1))
        if [ $n -ge $iplist ]; then
            break
        fi
    done
    while true; do
        if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]; then
            break
        else
            temp[$n]=$(echo 162.159.192.$(($RANDOM % 256)))
            n=$(($n + 1))
        fi
        if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]; then
            break
        else
            temp[$n]=$(echo 162.159.193.$(($RANDOM % 256)))
            n=$(($n + 1))
        fi
        if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]; then
            break
        else
            temp[$n]=$(echo 162.159.195.$(($RANDOM % 256)))
            n=$(($n + 1))
        fi
        if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]; then
            break
        else
            temp[$n]=$(echo 162.159.204.$(($RANDOM % 256)))
            n=$(($n + 1))
        fi
        if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]; then
            break
        else
            temp[$n]=$(echo 188.114.96.$(($RANDOM % 256)))
            n=$(($n + 1))
        fi
        if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]; then
            break
        else
            temp[$n]=$(echo 188.114.97.$(($RANDOM % 256)))
            n=$(($n + 1))
        fi
        if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]; then
            break
        else
            temp[$n]=$(echo 188.114.98.$(($RANDOM % 256)))
            n=$(($n + 1))
        fi
        if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]; then
            break
        else
            temp[$n]=$(echo 188.114.99.$(($RANDOM % 256)))
            n=$(($n + 1))
        fi
    done

    # 将生成的 IP 段列表放到 ip.txt 里,待程序优选
    echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u > ip.txt

    # 启动优选程序
    endpointyx
}

endpoint6(){
    # 生成优选 WARP IPv6 Endpoint IP 段列表
    n=0
    iplist=100
    while true; do
        temp[$n]=$(echo [2606:4700:d0::$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2)))])
        n=$(($n + 1))
        if [ $n -ge $iplist ]; then
            break
        fi
        temp[$n]=$(echo [2606:4700:d1::$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2)))])
        n=$(($n + 1))
        if [ $n -ge $iplist ]; then
            break
        fi
    done
    while true; do
        if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]; then
            break
        else
            temp[$n]=$(echo [2606:4700:d0::$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2)))])
            n=$(($n + 1))
        fi
        if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]; then
            break
        else
            temp[$n]=$(echo [2606:4700:d1::$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2)))])
            n=$(($n + 1))
        fi
    done

    # 将生成的 IP 段列表放到 ip.txt 里,待程序优选
    echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u > ip.txt

    # 启动优选程序
    endpointyx
}

pinput(){
    echo ""
    read -rp "请输入选项 [0-6]: " menuInput
    echo ""
    case $menuInput in
        6 ) clear && menu ;;
        5 ) updateBin ;;
        4 ) checkGPT ;;
        3 ) checkNF ;;
        2 ) endpoint6 ;;
        1 ) endpoint4 ;;
        0 ) exit 1 ;;
        * ) pinput ;;
    esac
}

menu(){
    echo "#############################################################"
    echo -e "#               ${RED}WARP Endpoint IP 一键优选脚本${PLAIN}               #"
    echo "#############################################################"
    echo ""
    echo -e " ${GREEN}1.${PLAIN} WARP IPv4 Endpoint IP 优选"
    echo -e " ${GREEN}2.${PLAIN} WARP IPv6 Endpoint IP 优选"
    echo -e " ${GREEN}3.${PLAIN} 检查奈飞联通状态"
    echo -e " ${GREEN}4.${PLAIN} 检查GPT联通状态"
    echo -e " ${GREEN}5.${PLAIN} 更新检测程序"
    echo -e " ${GREEN}6.${PLAIN} 清理屏幕"
    echo " -------------"
    echo -e " ${GREEN}0.${PLAIN} 退出脚本"
    pinput
}

clear
menu
