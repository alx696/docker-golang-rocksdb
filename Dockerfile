#
# 编译应用阶段
#
FROM registry.cn-shanghai.aliyuncs.com/xm69/alpine-rocksdb-apk AS app
WORKDIR /home
COPY code .
ENV GOPROXY=https://goproxy.cn
RUN set -eux && \
  #设置源
  echo "http://mirrors.ustc.edu.cn/alpine/edge/main/" > /etc/apk/repositories && \
  echo "http://mirrors.ustc.edu.cn/alpine/edge/community/" >> /etc/apk/repositories && \
  echo "http://mirrors.ustc.edu.cn/alpine/edge/testing/" >> /etc/apk/repositories && \
  apk update && \
  #安装RocksDB
  apk add --allow-untrusted /rocksdb.apk /rocksdb-dev.apk && \
  #打印编译环境
  echo "编译环境：$(uname -a)" && \
  #安装Golang环境
  apk add build-base go && \
  #下载并校验Golang模块
  go mod download && go mod verify && \
  #编译Golang应用
  # https://github.com/linxGnu/grocksdb/issues/24#issuecomment-752988851
  CGO_CFLAGS="-I/usr/include/rocksdb" \
  CGO_LDFLAGS="-L/usr/lib -lrocksdb -lstdc++ -lm -lz -lsnappy -llz4 -lzstd" \
  go build -o /home/main
################

#
# 封装镜像
#
FROM alpine:3
WORKDIR /home
RUN set -eux && \
  #设置源
  echo "http://mirrors.ustc.edu.cn/alpine/edge/main/" > /etc/apk/repositories && \
  echo "http://mirrors.ustc.edu.cn/alpine/edge/community/" >> /etc/apk/repositories && \
  echo "http://mirrors.ustc.edu.cn/alpine/edge/testing/" >> /etc/apk/repositories && \
  apk update && \
  \
  #设置时区
  apk add tzdata && \
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  echo "Asia/Shanghai" > /etc/timezone && \
  apk del tzdata

#从编译RocksDB阶段中复制apk并安装
#(不考虑支持老CPU时直接安装rocksdb包即可)
COPY --from=app /rocksdb.apk .
RUN set -eux && \
  apk add --allow-untrusted rocksdb.apk && \
  rm rocksdb.apk

#从编译应用阶段中复制程序
COPY --from=app /home/main .

#从资源目录中复制资源
COPY resource .

ENTRYPOINT ["./main"]

ARG PORTS=40000
EXPOSE ${PORTS}