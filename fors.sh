
#!/bin/sh

gitfiles=$(git diff-tree --no-commit-id --name-only -r 32a11fcdc063ec76bd531ed453d3e3a83f76bc18 c727b056c1fc0069d43d891f1a1dcf70041a6f2b)

echo "List of the files $gitfiles"

arr=($gitfiles)

echo "length of the array ${#arr[@]}"

for i in "${#arr[@]}"
do
  #echo "Looping ... number $i" >> sample.txt
  echo "<type>
           <memeber>${arr[*]}</member>
        </type>" >> sample.txt
  echo "${arr[0]}"
done

str="/src/classess/myclass.cls"
var=${str#%.*}
echo $var
var1=$(basename /src/classess/myclass.cls .cls)
echo "$var1"
sed -i "/<members>/a <member>$var1</member>" package.xml
#sed -e "s/.*<name>.*/<memebr>Sampleclass</memebre>\n&/" package.xml
#sed -i "${<sandhya>} i \ \ ${<name>}" package.xml
#awk '/<name>/{print "<mem>sandhya<mem>"}1' package.xml
