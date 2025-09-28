set name $argv[1]
set sourcePath /tmp/modpacks/$name
set targetPath /www/public/mc/$name/data/modpacks
tar -czf $sourcePath.tar.gz -C $sourcePath .
scp -r $sourcePath.tar.gz smaiHost:$targetPath
rm $sourcePath.tar.gz