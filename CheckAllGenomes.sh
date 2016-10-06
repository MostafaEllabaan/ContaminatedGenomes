

mainDir=$(pwd)/Genomes
cd $mainDir; 
ls */ -d  | while read  folder; do

ls $folder/*/ -d  | while read folder2; do

echo $mainDir/$folder2/  ;
done
done | awk -F"\t" '{print "checkGenome16SrRNAForContamination.sh "$0}' > ../job.file.job 

cd ..

mkdir splitFolder

split -l 6000 job.file.job splitFolder/AAA -a 10

mkdir jobFolder


for i in ` ls splitFolder/ `; do echo "MachineManagerBashScript.sh $(pwd)/splitFolder/$i 10" > jobFolder/job.$i.job; done

cd jobFolder;

ls job.*.job | while read jobFile; do $SubmitJob $jobFile; done



##

ls Genomes/*/*/ -d | cut -f1,2,3 -d/ | xargs -I {} echo $(pwd)"/"{} > All.genomes 

find Genomes -name 'cluster.repr*' | cut -f1,2,3 -d/ | xargs -I {} echo $(pwd)"/"{} > SuccessfullyRun.job

diff <( sort -u All.genomes ) <( sort -u SuccessfullyRun.job ) | grep "<" | sed 's/< //g' > Jobs.toRerun

awk -F"\t" '{ print "checkGenome16SrRNAForContamination.sh "$1}' Jobs.toRerun > Jobs.toRerun.jobs
	
##echo "MachineManagerBashScript.sh $(pwd)/Jobs.toRerun.jobs 28 &> $(pwd)/Jobs.toRerun.jobs.result " > toRerun.hpc.job


rm splitFolder/*
rm jobFolder/*

split -l 2000 Jobs.toRerun.jobs splitFolder/AAA -a 10

for i in ` ls splitFolder/ `; do echo "MachineManagerBashScript.sh $(pwd)/splitFolder/$i 28" > jobFolder/job.$i.job; done


cd jobFolder;

ls job.*.job | while read jobFile; do $SubmitJob $jobFile; done
