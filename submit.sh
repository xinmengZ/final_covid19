#!/bin/bash
if [ "$#" -ne 2 ] ; then
	echo "two arguments needed:inputfile  outputdirectory"
	exit
fi
echo "inputfile=$1 , outputdirectory=$2"
spark-submit     --master k8s://https://10.212.96.128:6443 --deploy-mode cluster     --name energy     --conf spark.executor.instances=3 --conf spark.kubernetes.container.image=python/spark-py:1.0 --conf spark.kubernetes.driver.volumes.hostPath.workdir.mount.path=/work --conf spark.kubernetes.driver.volumes.hostPath.workdir.mount.readOnly=false  --conf spark.kubernetes.driver.volumes.hostPath.workdir.options.path=/home/cc/work/spark_work  --conf spark.kubernetes.executor.volumes.hostPath.workdir.mount.path=/work --conf spark.kubernetes.executor.volumes.hostPath.workdir.mount.readOnly=false  --conf spark.kubernetes.executor.volumes.hostPath.workdir.options.path=/home/cc/work/spark_work local:///work/energy.py -i file:///work/$1  -o file:///work/$2

# local & file: inside pod
# HDFS: http://
# work/spark_work
# vm3 /dev/vdb1 ( teame2-storge volume) -> mount vm3 /home/cc/storage
# vm3 ln -s /home/cc/work /home/cc/storage
# vm3 /etc/exports export /home/cc/storage as nfs 
# vm2 mount  nfs vm3://home/cc/storage  /home/cc/work
# vm1 mount  nfs vm3://home/cc/storage  /home/cc/work
#
# mount 
# df


