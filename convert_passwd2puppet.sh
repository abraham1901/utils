#!/bin/bash

OIFS=$IFS
IFS=':'

cat passwd | while read login x x x comment home shell;
do
  pass=`cat shadow |grep "^${login}:" |awk -F ":" '{print $2}'`

  if ([ "${pass}" = '!' ] || [ "${pass}" = '*' ] || [ "${pass}" = '' ]); then
    continue;
  fi

  groups=`groups $login |sed 's/^\w\{0,\} : /"/'|sed 's/ /", "/g'|sed 's/$/"/'|sed 's/^/"/'`

  echo "    '$login':
      password  => '$pass',
      home      => '$home',
      comment   => '$comment',
      groups    => '$groups', 
      shell     => '$shell';"

done

IFS=$OIFS

