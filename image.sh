#!/bin/sh
set -e

if [ -n "$1" ]; then
  IMAGE_NV=$1
else
  echo "错误：没有设置镜像名称和版本，例如 file:1"
  exit 1
fi

if [ -n "$2" ]; then
  IMAGE_PORTS=$2
else
  echo "错误：没有设置镜像暴露端口，例如 40000"
  exit 1
fi

##
# 设置镜像标签
IMAGE_TAG="registry.cn-shanghai.aliyuncs.com/xm69/${IMAGE_NV}"
##

# # 指定结构构建 注意：只有--push推送模式时才支持同时构建多个平台，--load只能单个平台
# docker buildx build --platform linux/amd64 -t ${IMAGE_TAG} . --load

#普通构建
docker build --build-arg PORTS=${IMAGE_PORTS} -t ${IMAGE_TAG} .

#清理文件
rm -rf code resource

#推送镜像
# docker login --username=alx696@gmail.com registry.cn-shanghai.aliyuncs.com
docker push ${IMAGE_TAG}
echo "成功：已经构建推送 ${IMAGE_TAG}"