## 构建使用RocksDB的Golang应用

自行构建apline apk形式的RocksDB，关闭SSE4.2支持老CPU。比起直接[通过源码编译使用共享库](源码共享库-Dockerfile)的方式，apk的体积是共享库的百分之一。

## 说明

### rocksdb构建脚本

来自 https://git.alpinelinux.org/aports/tree/testing/rocksdb?h=master

### RocksDB编译说明

参考 https://github.com/facebook/rocksdb/blob/master/INSTALL.md#compilation

make时先设置了`PORTABLE=1`时会关闭SSE4.2，防止CPU不支持sse4_2指令集而无法运行。[ceph.com上关于此问题的讨论](https://tracker.ceph.com/issues/20529#note-14), 执行`$ lscpu`查看标记中是否有`sse4_2`以确认CPU是否支持。