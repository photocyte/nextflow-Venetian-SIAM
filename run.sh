if [[ `hostname` == "tak" ]]
then
source /lab/solexa_weng/testtube/miniconda3/bin/activate
bsub -o out.log -e err.log "nextflow run Venetian-SIAM.nf -resume -with-trace -with-report -with-dag dag.svg"
else
echo "not implemented"
fi
