# Copyright (C) 2016 PerfectlySoft Inc.
# Author: Shao Miller <swiftcode@synthetel.com>

FROM perfectlysoft/ubuntu1510
RUN /usr/src/Perfect-Ubuntu/install_swift.sh --sure
RUN git clone https://github.com/sam-w/newsbot.git /usr/src/newsbot
WORKDIR /usr/src/newsbot
RUN apt-get install libmysqlclient-dev
RUN swift build
CMD .build/debug/newsbot --port 8181
EXPOSE 8181
