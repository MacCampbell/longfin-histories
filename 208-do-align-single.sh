#!/bin/bash -l

## usage
##

list=$1
ref=$2

wc=$(wc -l ${list} | awk '{print $1}')

x=1
while [ $x -le $wc ] 
do
	string="sed -n ${x}p ${list}" 
	str=$($string)

	var=$(echo $str | awk -F"\t" '{print $1, $2}')   
	set -- $var
	c1=$1


	echo "#!/bin/bash -l
  module load bwa/0.7.17;

	bwa mem $ref ${c1}.fq.gz | samtools view -Sb - | samtools sort - -o ${c1}.sort.bam 
  reads=\$(samtools view -c ${c1}.sort.bam)
  echo \"${c1},\${reads}\ > > ${c1}.stats" > ${c1}.sh
	sbatch -t 1-8:00:00 -p med --mem=10G ${c1}.sh

	x=$(( $x + 1 ))

done
