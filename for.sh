#!/bin/sh

for i in 1 2 3 4 5
do
  #echo "Looping ... number $i" >> sample.txt
  echo "<type>
           <memeber>$i</member>
        </type>" >> sample.txt
done
