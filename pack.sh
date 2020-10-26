#/usr/bin/env bash
# -lcommit builds last commit
# -prevrsa last commit to master
 
#read command line args
while getopts l:p: option
do
        case "${option}"
        in
                l) LCOMMIT=${OPTARG};;
                p) PREVRSA=${OPTARG};;
        esac
done
 
echo Last Commit: $LCOMMIT
echo Previous Commit: $PREVRSA
 
DIRDEPLOY=build/deploy
if [ -d "$DIRDEPLOY" ]; then
    echo Removing deploy folder
    rm -rf "$DIRDEPLOY"
fi
mkdir -p $DIRDEPLOY
cd src
echo changing directoy to src
cp package.xml{,.bak} &&
echo Backing up package.xml to package.xml.bak &&
read -d '' NEWPKGXML <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Package>
EOF
      
echo ===PKGXML===
echo $NEWPKGXML
echo Creating new package.xml
echo $NEWPKGXML > package.xml

echo List of changes
echo DIFF: `git diff-tree --no-commit-id --name-only -r $LCOMMIT $PREVRSA`
 
git diff-tree --no-commit-id --name-only -r $LCOMMIT $PREVRSA | \
while read -r CFILE; do
 
        if [[ $CFILE == *"src/"*"."* ]]
        then
           tar cf - "../$CFILE"* | (cd ../$DIRDEPLOY; tar xf -)
        fi        
        if [[ $CFILE == *".cls" ]] || [[ $CFILE == *".triggers" ]]
        then
                ADDFILE="${CFILE}-meta.xml"
                #ADDFILE1="${ADDFILE%-meta.xml*}"
                tar cfP - ../$ADDFILE | (cd ../$DIRDEPLOY; tar xfP -)
                echo "deployment2"
        fi
        if [[ $CFILE == *"/aura/"*"."* ]]
        then
                DIR=$(dirname "$CFILE")
                tar cf - ../$DIR | (cd ../$DIRDEPLOY; tar xf -)
                echo "deployment3"
        fi
 
        case "$CFILE"
        in
                        *.cls*) TYPENAME="ApexClass";;
                        *.page*) TYPENAME="ApexPage";;
                        *.component*) TYPENAME="ApexComponent";;
                        *.trigger*) TYPENAME="ApexTrigger";;
                        *.app*) TYPENAME="CustomApplication";;
                        *.labels*) TYPENAME="CustomLabels";;
                        *.object*) TYPENAME="CustomObject";;
                        *.tab*) TYPENAME="CustomTab";;
                        *.resource*) TYPENAME="StaticResource";;
                        *.workflow*) TYPENAME="Workflow";;
                        *.remoteSite*) TYPENAME="RemoteSiteSettings";;
                        *.pagelayout*) TYPENAME="Layout";;
                        *) TYPENAME="UNKNOWN TYPE";;
        esac
 
        if [[ "$TYPENAME" != "UNKNOWN TYPE" ]]
        then
 
                case "$CFILE"
                in
                        src/email/*)  ENTITY="${CFILE#src/email/}";;
                        src/documents/*)  ENTITY="${CFILE#src/documents/}";;
                        src/aura/*)  ENTITY="${CFILE#src/aura/}" ENTITY="${ENTITY%/*}";;
                        *) ENTITY=$(basename "$CFILE");;
                esac
 
                if [[ $ENTITY == *"-meta.xml" ]]
                then
                        ENTITY="${ENTITY%%.*}"
                        ENTITY="${ENTITY%-meta*}"
                else
                        ENTITY="${ENTITY%.*}"
                fi
 
                #if grep -Fq "$TYPENAME" package.xml
                #then
                #        xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" package.xml
                #else
                #        xmlstarlet ed -L -s /Package -t elem -n types -v "" package.xml
                #       xmlstarlet ed -L -s '/Package/types[not(*)]' -t elem -n name -v "$TYPENAME" package.xml
                #        xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" package.xml
                #fi*/
				
		if grep -Fq "$TYPENAME" package.xml
                then
		   echo "type name $TYPENAME"
                   var=$(basename $CFILE .cls)
                   sed -i "/<memebers>/a <memebers>$var</memebers>" package.xml
	        else
                       echo "else type name $TYPENAME"                       
                       var=$(basename $CFILE .cls)
                       echo "<type>
                           <memebers>$var</memebers>
                           <name>$TYPENAME</name>
                          </type>" >> package.xml        
		fi
					
							
				
        fi
done
 
echo "Cleaning up Package.xml"
sed -i '$ a </Package>' package.xml

#xmlstarlet ed -L -i /Package -t attr -n xmlns -v "http://soap.sforce.com/2006/04/metadata" package.xml
 
echo ====FINAL PACKAGE.XML=====
cat package.xml
tar cf - package.xml | (cd ../$DIRDEPLOY/src; tar xf -)
