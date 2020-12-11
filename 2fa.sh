#!/bin/bash

# Root
[[ $(id -u) != 0 ]] && echo -e "\n 哎呀……请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt"
# 笨笨的检测方法
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then

        if [[ $(command -v yum) ]]; then

                cmd="yum"

        fi

else

        echo -e " 
        哈哈……这个 ${red}辣鸡脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

        备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
        " && exit 1

fi
#设置时区
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true
echo "已将主机设置为Asia/Shanghai时区并通过systemd-timesyncd自动同步时间。"
#安装2fa
if [[ $cmd == "yum" ]]; then
        echo "开始安装依赖"
        yum install gcc make pam-devel libpng-devel libtool wget git autoconf automake qrencode -y
        rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
        yum install google-authenticator -y
        #CentOS 7系统
        sed -i "/auth[ ]*substack[ ]*pass*/a\auth required pam_google_authenticator.so" /etc/pam.d/sshd
else
        $cmd update && $cmd install libpam-google-authenticator -y
        echo 'auth required pam_google_authenticator.so' >>/etc/pam.d/sshd
fi
#修改sshd配置
sed -i -r 's#(ChallengeResponseAuthentication) no#\1 yes#g' /etc/ssh/sshd_config

echo "安装完成，请执行google-authenticator进行配置"

echo "selinux状态：" && getenforce

echo "如果状态非disabled则运行sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 关闭SELINUX"