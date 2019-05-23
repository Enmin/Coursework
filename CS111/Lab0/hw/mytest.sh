#!/bin/sh
out="=fd1"
res=$(./lab0 --input=fd0 --output=$out)
if [[ -z $res ]];then
echo "success"
else
echo "failure"
fi
$(rm $out)
res=$(./lab0 --asdf)
if [[ -z $res ]];then
echo "success"
else
echo "failure"
fi
res=$(./lab0 -input)
if [[ -z $res ]];then
echo "success"
else
echo "failure"
fi
