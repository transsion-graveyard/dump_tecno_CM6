#!/system/bin/sh

# "alloc_iptables,-A wlan0 10236 1073741934"
caller=${1%%,*}

case $caller in
    "multilink")
        ${1#*,} ;;
    "networkalloc")
        ${1#*,} ;;
    "alloc_tc")
        variables=${1#*,}
        #IFS=' ' read -r interface markId <<< "$variables"
        
        interface="${variables%% *}"
        variables="${variables#* }"
        markId="${variables}"
        echo "interface: $interface"
        echo "markId: $markId"

        tc qdisc add dev $interface root handle 1: htb default 12
        tc class add dev $interface parent 1: classid 1:11 htb rate 5Kbps ceil 50Mbps
        tc class add dev $interface parent 1: classid 1:12 htb rate 240Kbps ceil 50Mbps
        tc filter add dev $interface parent 1: protocol ip handle $markId fw classid 1:11
        ;;
    "alloc_iptables")
        variables=${1#*,}
        act="${variables%% *}"
        variables="${variables#* }"
        interface="${variables%% *}"
        variables="${variables#* }"
        uid="${variables%% *}"
        variables="${variables#* }"
        markId="${variables}"

        echo "act: $act"
        echo "interface: $interface"
        echo "uid: $uid"
        echo "markId: $markId"
        
        echo "Adding iptables rule: actiont=$act, Interface=$interface, UID=$uid, MarkId=$markId"
        iptables -t mangle $act OUTPUT -o $interface -m owner --uid-owner $uid -j MARK --set-mark $markId
        ip6tables -t mangle $act OUTPUT -o $interface -m owner --uid-owner $uid -j MARK --set-mark $markId
        ;;
esac
