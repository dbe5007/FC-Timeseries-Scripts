#! /bin/bash

####Notes & Comments####
howtouse() {
echo ""
echo "Create Directories for Jackknife GIMME"
echo "Daniel Elbich"
echo "Created: 1/10/18"
echo ""
echo ""
echo " Creates/copies multiple directories containing timeseries to use with Jackknife GIMME procedure."
echo " Directories are copied from source into a separate folder, with one subject being removed from each"
echo " new directory iterative. Result is set of folders with a single unique subject removed from each."
echo ""
echo ""
echo "Usage:"
echo "sh createBootstrapDirectories.sh --source </path/to/source> --subjNum <number>"
echo ""
echo "Required arguments:"
echo ""
echo "      -tr         Enter TR of scan"
echo "      -lngths     Length of timeseries"
echo "      -cond       Condition to be created"
echo "      -proj       Project "
echo "      -rand       Flag for if timeseries is random (yes, no)"
echo "      -subj       Text file containing list of subject IDs"
echo "      -rois       Text file containing individual ROI labels for all included regions"
echo ""
echo "Optional arguments (You may optionally specify one or more of): "
echo ""
echo "      -condfile   Text file of condition for non-randomized series. Required if -rand is no"
echo ""
echo ""
exit 1
}
[ "$1" = "--help" ] && howtouse

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
--source) source="$2"
shift # past argument
shift # past value
;;
--subjNum) subjNum="$2"
shift # past argument
shift # past value
;;
*)    # unknown option
POSITIONAL+=("$1") # save it in an array for later
shift # past argument
;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
fi

# Make jackknife analysis folder
mkdir $source/jackknifeAnalysis

# Copy source folder containing all time series into jackknife folder
cp -r $source $source/jackknifeAnalysis/set01

# Move to jackknife folder
cd $source/jackknifeAnalysis

# Create new set of time series source folders
for (( i=1; i<=$subjNum; i++ ));
do
    echo cp -r set01 set0$subjNum
done

# List all folders
folders=(*)
echo ${folders[@]}
len=${#folders[@]}

# Remove single unique subject from each directory
for ((i=0; i<$len; i++ ))
do
    cd ${folders[$i]}
    files=(*)
    rm ${files[$i]}
    cd ..

done

echo "Done"
