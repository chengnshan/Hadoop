#!/bin/bash

#set  java  env
export JAVA_HOME=/usr/local/java/jdk1.8.0_151
export JRE_HOME=${JAVA_HOME}/jre
export CLASS_PATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH

#set  hadoop  env
export HADOOP_HOME=/usr/local/hadoop/hadoop-2.7.6
export PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:$PATH

#日志文件存放的目录
log_src_dir=/root/logs/log/

#待上传文件存放的目录
log_toupload_dir=/root/logs/toupload/

#日志文件上传到hdfs的根路径
date=`date -d last-day +%Y_%m_%d`

#打印环境变量信息
echo "envs:hadoop_home:$HADOOP_HOME"

#读取日志文件的目录，判断是否有需要上传的文件
echo "log_src_dir:"$log_src_dir
ls $log_src_dir | while read fileName
do
   if [["$fileName" == access.log.*]];  then
       date = `date +%Y_%m_%d_%H_%M_%s`
       #将文件移动到待上传目录并重命名
       #打印信息
echo "moving  $log_src_dir$fileName to $log_toupload_dir"xxx_click_log_$fileName"$date"
     mv $log_src_dir$fileName  $log_toupload_dir"xxx_click_log_$fileName"$date
     #将待上传的文件Path写一个列表文件willDoing
     echo $log_toupload_dir"xxx_click_log_$fileName"$date >> $log_toupload_dir"willDoing."$date
    fi
done

#找到列表文件willDoing
ls $log_toupload_dir | grep will | grep -v "_COPY_" | grep -v "_DONE_" | while read line
do
   #打印信息
   echo "toupload is in file:"$line
   #将待上传文件列表willDoing改名为willDoing_COPY_
   mv $log_toupload_dir$line  $log_toupload_dir$line"_COPY_"
  #读列表文件的内容（一个一个的待上传文件名），此处的Line就是列表中的一个待上传文件的path
   cat $log_toupload_dir"_COPY_" | while read line
   do
      #打印信息
      echo "puting...$line to hdfs path......$dfs_root_dir"
      hadoop  fs -mkdir  -p  $hdfs_root_dir
      hadoop fs -put $line  $ddfs_root_dir
   done
   mv  $log_toupload_dir$line"_COPY_" $log_toupload_dir$line"_DONE_"
done
