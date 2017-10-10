#!/bin/bash

projectRoot="$PWD"
echo "current project root path:"$projectRoot

users=(manjunathm3@gmail.com)

if [ -d $projectRoot/plugins ]; then
        cd $projectRoot/plugins
else
        echo "please put the sh file in project root directory and re run..."
        exit 1
fi

if [ -z ${1} ]; then
	echo "please enter a date to pick the commits from, please enter in format yyyy-mm-dd"
	exit 1
fi

echo "provided date: ${1}"

echo "plugin,user,code,message" > ${projectRoot}/messages.csv

uniqueMsgCodesString=""

for d in */ ; do
	cd ${projectRoot}/plugins/${d}
	for user in "${users[@]}";
	do
		#echo ${d}+" by user: "+${user}
		#echo -n "."
		#echo "looking for messages.properties changes under plugin ${d} for user ${user}"
		git log --since=${1} --pretty="%H" --author=$user grails-app/i18n/messages.properties > commits.txt
		while IFS= read -r i
		do
			git diff $i^ $i grails-app/i18n/messages.properties > ${i}.txt
			awk '/^\+.*=.*/{print}' ${i}.txt > ${i}.tmp && mv ${i}.tmp ${i}.txt
			sed 's/+//' ${i}.txt > ${i}.tmp && mv ${i}.tmp ${i}.txt
			while IFS= read -r var
			do
				IFS='='; codeAndMsg=($var); IFS= ;
				if [[ $uniqueMsgCodesString != *${codeAndMsg[0]}* ]]; then
          if grep -q ${codeAndMsg[0]} "grails-app/i18n/messages.properties"; then
					       echo "${d},${user},${codeAndMsg[0]},\"${codeAndMsg[1]}\"" >> ${projectRoot}/messages.csv
					            uniqueMsgCodesString+=${codeAndMsg[0]}
          fi
				fi
			done < "${i}.txt"
			rm -f ${i}.txt
		done < "commits.txt"
		rm -f commits.txt
	done
done

cd ${projectRoot}



echo ""
echo "messages.csv generated, please have a look... :)"
