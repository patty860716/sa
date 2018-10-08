#!/bin/sh
courselist="1 a v off \2 green off"
classroom="0"
func()
{
	for i in "$@";do
	#echo $i
	cmd="echo \$courselist | awk -F \"\\\\\" '{print $"$i"}'"
	eval $cmd | awk -F "\"" '{print $2}' >> $selectfile
	cmd="echo \$courselist | sed 's/ o[a-z]* \\\\/ on \\\\/"$i"'"
	courselist=$(eval $cmd)
	#echo $courselist
	done
}
sedfunc()
{
	com="sed -i '"$row"s/"$col"x./\1. /1' table.txt"
	eval $com
	varo=$var
	while [ ${#var} -gt 13 ]; do
		var1=$(echo $var | cut -c 14-${#var})
		var=$(echo $var | cut -c 1-13)
		com="sed -i '"$row"s/"$col".[ \t]*/\1"$var"/1' table.txt"
		eval $com
		var=$var1
		row=$(( $row+1 ))
		done
		while [ ${#var} -lt 13 ]; do
		var=$var"."				
		done
		com="sed -i '"$row"s/"$col".[ \t]*/\1"$var"/1' table.txt"
		eval $com
		var=$varo
		return
}

parsetime()
{	
	
	for i in "$@";do
	case $i in 
	1)
	col="\(.\{4\}\)";;
	2)
	col="\(.\{18\}\)";;
	3)
	col="\(.\{32\}\)";;
	4)
	col="\(.\{46\}\)";;
	5)
	col="\(.\{60\}\)";;
	A)
	row=2
	sedfunc;;
	B)
	row=7
	sedfunc;;
	C)
	row=12
	sedfunc;;
	D)
	row=17
	sedfunc;;
	E)
	row=22
	sedfunc;;
	F)
	row=27
	sedfunc;;
	G)
	row=32
	sedfunc;;
	H)
	row=37
	sedfunc;;
	I)
	row=42
	sedfunc;;
	J)
	row=47
	sedfunc;;
	K)
	row=52
	sedfunc;;
	#sed -e '2s/\(.\{4\}\)x. /\1abc/1' table.txt
	esac
	done	
	
}
addtotable()
{	
	cat table1.txt > table.txt
	cat $selectfile | while read -r line; do
		time=$(echo $line | awk -F "" '{ for(i=1;i<NF;i++) if($i~/\-/) break ;else print $i }')
		if [ "$classroom" = "0" ];then
		var=$(echo $line | awk -F "-" '{print $3}')
		else
		var=$(echo $line | awk -F "-" '{print $2}')
		fi
		parsetime $time
	done
}
addclass()
{
	addclasscmd="dialog --clear --stdout --separate-output --buildlist \"add class\" 40 70 "$cnt" "$courselist
	selectfile=`mktemp $selectlist.XXXXXX`	
	: > $selectfile
	script=$(eval $addclasscmd)
	check=0
	case $? in
	0)
		courseselection
		func $script
		if [ -s "$selectfile" ];
		then
		for j in 1 2 3 4 5; do
		msg="Collision: "$j
		for i in A B C D E F G H I J K; do
		cmd1="cat \$selectfile | grep '"$j"[A-K]*"$i"'"	
		collision=$(eval $cmd1"| wc -l")
		if [ "$collision" != "0" ] && [ "$collision" != "1" ];then
		col_course=$(eval $cmd1" | awk -F \"-\" 'NR>1{print \$3}'")		
		check=1
		msg=$msg"$i\n"$col_course
		return
		fi
		done
		done	
		addtotable
		fi
		return ;;
	1)
		return;;
	esac
}
drawtable()
{
dialog --clear --ok-label "add class" --extra-button --extra-label "option" --help-button --help-label "exit" --textbox table.txt 60 75
}
courseselection()
{
	courselist=$(cat course.json | grep 'cos_ename\|cos_time'| awk -F "\"" 'NR<2{count=2;foo1 =NR" \""$4} NR>1{ if($4 ~ /[0-9]+/) foo1= foo1"\\ "count" \""$4 count++;else foo1=foo1"-"$4"\" off "}END{print foo1}')
}
if [ -f "course.json" ]; then
echo "exits"
else
curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data 'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crsname=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**'>course.json
sed -i 's/,/,\n/g' course.json
sed -i 's/{/{\n/g' course.json
sed -i 's/}/}\n/g' course.json  
#exit
fi
#jq . course.json > course1.json
if [ -s courselist.txt ]; then
	courselist=$(cat courselist.txt)
else
courseselection
fi
cnt=$(cat course.json | grep 'cos_ename'| wc -l)
while [ 1 -eq 1 ]; do

drawtable

case $? in
	0)
		#courseselection
		while [ 1 -eq 1 ];do
		addclass
		if [ $check = "0" ];then
		break
		else
		dialog --msgbox "$msg \n" 10 20
		fi
		done;;
	3)
		#echo $courselist > courselist.txt
		#exit;;
		if [ $classroom = "0" ];then
		classroom="1"
		else
		classroom="0"
		fi
		if [ -s $selectfile ];then
		addtotable
		fi;;
	2)
		echo $courselist > courselist.txt	
		exit ;;
esac

done

