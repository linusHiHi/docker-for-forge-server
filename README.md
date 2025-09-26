## 构建过程
1. 将包解压到packs文件夹
2. 修改`.env`文件修改为对应的版本
3. 运行脚本`./build_and_push.fish <image_version>` 

## 部署
1. 将`server_config`复制到服务器
2. 按需修改`data\modified_files/user_jvm_args.txt`
3. `docker-compose up -d`
