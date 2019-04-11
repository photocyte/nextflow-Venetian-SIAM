
Channel.fromPath("/Users/tim/Desktop/heavy_cysteine_alone_rep*_pos_20uL.mzML").into{ raws_ch1 ; raws_ch2 }
Channel.fromPath("Pos_Profile_to_mzTab.xml").set{ batch_xml_ch }

raws_ch1.combine(batch_xml_ch).set{ raw_and_batch_cmd_ch }

process PosProfile_mzML_to_mzTab {
  executor 'local'
  publishDir "mzTab_results",mode:"copy"
  input:
     set file(ms_data),file(batch_xml) from raw_and_batch_cmd_ch
  output:
     file "${ms_data}.mzTab" into mzTab_ch
  script:
    """
    THEWD=\$(pwd)
    ABSPATHDATA=\$(readlink -f $ms_data)
    python -c "import re; read_handle = open('$batch_xml','r'); data = read_handle.read(); read_handle.close(); data=re.sub('input.mzML','\$ABSPATHDATA',data); data=re.sub('/OUTPUTPATH','\$THEWD',data); write_handle = open('modified_batch.xml','w'); write_handle.write(data); write_handle.close()"
    /Applications/MZmine-2.38/startMZmine_MacOSX.command `readlink -f modified_batch.xml`    
    cat output.mzTab | sed 's/FILTERED//g' > ${ms_data}.mzTab
    """
}
Channel.fromPath("join_mzTab.xml").set{ join_xml_ch }

process loadMzTabs_join {
  executor 'local'
input:
  file mzTabs from mzTab_ch.collect()
  file mzRaws from raws_ch2.collect()
  file join_xml from join_xml_ch
output:
  file "merged.mzTab"
script:
"""
THEWD=\$(pwd)
python -c "import re; import glob; import os; l1 = glob.glob('*.mzTab'); l2 = [os.path.abspath(s) for s in l1]; l3 = [s + '</file>' for s in l2]; l4 = ['<file>' + s for s in l3]; replacement = '\\n'.join(l4); read_handle = open('$join_xml','r'); data = read_handle.read(); read_handle.close(); data=re.sub('<file>REPLACEME</file>',replacement,data); data=re.sub('/OUTPUTPATH','\$THEWD',data); write_handle = open('modified_batch.xml','w'); write_handle.write(data); write_handle.close()"
/Applications/MZmine-2.38/startMZmine_MacOSX.command `readlink -f modified_batch.xml`
"""
}



