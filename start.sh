#!/bin/bash

iptables -I INPUT -p tcp --dport 1080 -j ACCEPT && iptables-save

/usr/bin/supervisord

sudo QT_QUICK_BACKEND=software OPENSSL_CONF=/openssl.cnf QTWEBENGINE_DISABLE_SANDBOX=1 openconnect-sso --server ${SERVER_NAME} --user ${USER_NAME} --authgroup ${AUTHGROUP}
