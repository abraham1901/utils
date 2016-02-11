#!/bin/bash

share_file=$1 

check_dir () {
  if ! [ -d $1 ]; then
    mkdir -p $1
    ret=$?
  
    if [ "$ret" != "0" ]; then
      echo "`date` Error creating directory: $1" |tee -a $LOG
      exit
    fi
  fi
}

check_dir tmp_parse


OLDIFS="$IFS";
IFS=$'\n';
file=1;
cat $share_file |while read share; do
  if `echo $share |grep -q '\['`; then
    file=$((file+1));
    echo $share >> tmp_parse/$file;
  else
    echo $share >> tmp_parse/$file;
  fi;
done;
IFS="$OLDIFS"


ls tmp_parse/|while read file;
do
  share_name=`head -1 tmp_parse/$file |sed 's/\[//'|sed 's/\]//'`
  tail -n +2 tmp_parse/$file |head -3|sed '/^$/d' |sed "s/ = /=/" |sed 's/=/="/' |sed 's/$/"/' > "tmp_parse/${share_name}";
  . "tmp_parse/${share_name}"
  if [ $writable = "yes" ]; then
    write="true";
  fi
cat << EOF
samba::server::share {'${share_name}':
  comment           => '${comment}',
  path              => '$path',
  browsable         => true,
  writable          => $writable,
  create_mask       => '0770',
  directory_mask    => '0770',
}
EOF
  rm tmp_parse/$file
  rm "tmp_parse/${share_name}"
done

rmdir tmp_parse
