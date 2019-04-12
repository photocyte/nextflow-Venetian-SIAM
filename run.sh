bsub -o out.log -e err.log "nextflow run Venetian-SIAM.nf -resume -with-trace -with-report -with-dag dag.svg"
