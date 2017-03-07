#!/bin/bash

DIR=$1
OUTPUT=$2

find $DIR -type f|awk '{print "echo -e `stat --format=_q_%a %U:%G_q_ " $1 "` `md5sum " $1 "` " $1 }' |sed "s/_q_/'/g"|sh >./tmp.txt
echo -e "require 'spec_helper'\n" > ./$OUTPUT
echo -e "describe 'ファイル内容確認' do\n" >> ./$OUTPUT

while read line
do

    PERM=`echo $line |awk '{print $1}'`
    USER=`echo $line |awk '{print $2}' |awk -F":" '{print $1}'`
    GROUP=`echo $line |awk '{print $2}' |awk -F":" '{print $2}'`
    MD5SUM=`echo $line |awk '{print $3}'`
    FILENAME=`echo $line |awk '{print $4}'`
    #echo $PERM $USER $GROUP $MD5SUM $FILENAME

    echo -e "  describe file('$FILENAME') do\n    it { should be_file }\n    it { should be_owned_by '$USER'}\n    it { should be_grouped_into '$GROUP'}\n    it { should be_mode $PERM}\n    its(:md5sum) { should eq '$MD5SUM'}\n  end\n" >> ./$OUTPUT

done < ./tmp.txt

rm -f ./tmp.txt

echo -e "end\n" >> ./$OUTPUT

echo -e "describe 'サービス確認' do\n" >> ./$OUTPUT

for i in `ls  /etc/systemd/system/multi-user.target.wants/`
do
  SERVICE=`echo $i | cut -d "." -f 1`
  echo -e "    describe service('$SERVICE') do\n      it { should be_enabled }\n      it { should be_running }\n    end\n\n" >> ./$OUTPUT 
done

echo -e "end\n" >> ./$OUTPUT

echo -e "describe 'ポート番号チェック' do\n" >> ./$OUTPUT

for i in `netstat -an -A inet | grep LISTEN | grep -v unix | awk '{print $4}' | cut -d ":" -f 2`
do

echo -e "  describe port($i) do\n    it { should be_listening }\n  end\n" >> ./$OUTPUT

done

echo -e "end\n" >> ./$OUTPUT


