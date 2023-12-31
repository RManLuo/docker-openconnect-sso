# Build pyqt6
FROM debian:12 as builder

WORKDIR /
RUN apt-get update
RUN apt-get install -y python3-pip libxkbcommon-x11-0 libxcb-cursor0 '^libxcb.*-dev' libglib2.0-0 libgl1 libnss3 libxcomposite-dev libxdamage1 libfontconfig1 libxrender1 libxrandr2 libxtst6 libxi6 libasound2 libdbus-1-3 libxkbfile-dev libegl1 wget qt6-base-dev qtchooser libgl-dev qt6-webengine-dev
RUN pip install --break-system-packages --upgrade pip
RUN qtchooser -install qt6 $(which qmake6)
ENV QT_SELECT=qt6 
RUN pip3 install --break-system-packages PyQt-builder
# Download source code
RUN wget https://files.pythonhosted.org/packages/17/dc/969e2da415597b328e6a73dc233f9bb4f2b312889180e9bbe48470c957e7/PyQt6-6.6.0.tar.gz
RUN tar -zxvf PyQt6-6.6.0.tar.gz
RUN wget https://files.pythonhosted.org/packages/49/9a/69db3a2ab1ba43f762144a66f0375540e195e107a1049d7263ab48ebc9cc/PyQt6_WebEngine-6.6.0.tar.gz
RUN tar -zxvf PyQt6_WebEngine-6.6.0.tar.gz
RUN cd PyQt6_WebEngine-6.6.0  && cp -r ../PyQt6-6.6.0/sip/* sip/ && sip-wheel --verbose --qmake-setting 'QMAKE_LIBS_LIBATOMIC = -latomic'
RUN cd PyQt6-6.6.0 && sip-wheel --confirm-license --verbose --qmake-setting 'QMAKE_LIBS_LIBATOMIC = -latomic'

# Build dev image
FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update
RUN apt-get install -y python3-pip libxkbcommon-x11-0 libxcb-cursor0 '^libxcb.*-dev' openconnect dante-server iptables libglib2.0-0 libgl1 libnss3 libxcomposite-dev libxdamage1 libfontconfig1 libxrender1 libxrandr2 libxtst6 libxi6 libasound2 libdbus-1-3 libxkbfile-dev libegl1 sudo supervisor expect qt6-base-dev qt6-webengine-dev curl
RUN apt-get install -y locales && \
locale-gen zh_CN && \
locale-gen zh_CN.utf8 && \
apt-get install -y ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy

RUN update-alternatives --set iptables /usr/sbin/iptables-legacy

COPY --from=builder /PyQt6-6.6.0/PyQt6-6.6.0*.whl /
COPY --from=builder /PyQt6_WebEngine-6.6.0/PyQt6_WebEngine-6.6.0*.whl /
RUN pip3 install --break-system-packages PyQt6-6.6.0*.whl PyQt6_WebEngine-6.6.0*.whl
RUN pip3 install --break-system-packages "openconnect-sso[full]"

RUN chmod 1777 /dev/shm

COPY danted.conf.sample /etc/danted.conf
COPY program.conf /etc/supervisor/conf.d/program.conf
COPY openssl.cnf /openssl.cnf
COPY start_danted.sh /start_danted.sh
COPY keep_alive.sh /keep_alive.sh
COPY start.sh /start.sh
COPY start.exp /start.exp

CMD [ "/usr/bin/expect", "-f", "/start.exp" ]