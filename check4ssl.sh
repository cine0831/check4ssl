#!/bin/bash
# -*-Shell-script-*-
#
#/**
# * Title    : check for ssl certificate with OpenSSL
# * Auther   : by Alex, Lee
# * Created  : 11-16-2015
# * Modified :
# * E-mail   : cine0831@gmail.com
#**/
#
#set -e
#set -x

if [ -z "${2}" ]
then 
    echo "ex) ${0} -l <list-file> -p <port> -m <ssl method>"
    exit 1
fi

if [ -z "${4}" ]
then
    _port="443"
else
    _port=${4}
fi

if [ -z "${6}" ]
then
    # ssl2
    # ssl3
    # tls1_2
    # tls1_1
    # tls1

    _sslmethod="tls1_2"
else
    _sslmethod=${6}
fi

exec < $2

while read line
do
    _ipaddr=`dig $line | grep -A1 '^;; ANSWER SECTION' | grep -v '^;; ANSWER' | awk '{print $NF}'`

    #result_ssl=`echo | openssl s_client -connect ${ipaddr}:443 -servername ${line} -showcerts -tls1_2 | \openssl x509 -noout -text | egrep 'Not Before|Not After|CN=|DNS:'`

    _result_ssl=`echo | openssl s_client -connect ${_ipaddr}:${_port} -servername ${line} -showcerts -${_sslmethod} < /dev/null 2>/dev/null | \openssl x509 -noout -text | egrep 'Not Before|Not After|CN=|DNS:'`

    _before=$(echo "${_result_ssl}" | grep 'Not Before' | sed -e 's/^ *//g')
    _after=$(echo "${_result_ssl}" | grep 'Not After' | sed -e 's/^ *//g')
    _CN=$(echo "${_result_ssl}" | grep 'Subject' | sed -e 's/^ *//g' | awk '{print $NF}')
    _DNS=$(echo "${_result_ssl}" | grep 'DNS:' | sed -e 's/^ *//g')
   
    echo "============================================"
    echo "  Domain    : ${line}"
    echo "  IP Addr   : ${_ipaddr}"
    echo "  ${_CN}"
    echo "  ${_DNS}"
    echo "  ${_before}"
    echo "  ${_after}"
    echo -e "============================================\n"


    echo "============================================" >> my_result.log
    echo "  Domain    : ${line}" >> my_result.log
    echo "  IP Addr   : ${_ipaddr}" >> my_result.log
    echo "  ${_CN}" >> my_result.log
    echo "  ${_DNS}" >> my_result.log
    echo "  ${_before}" >> my_result.log
    echo "  ${_after}" >> my_result.log
    echo -e "============================================\n" >> my_result.log
done
