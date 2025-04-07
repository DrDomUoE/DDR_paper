#!/usr/bin/env bash
#run this script first
#this script lists the lengths of proteins in an orthologous family
#Note that you would have to manually create Homo.txt  and place it in  the same folder 
#as this script before you  run it. 
#It is just a list of your human proteins of interest formated this way >DPOD2_HUMAN@.
#You must also have another list of human proteins in a file called the_list.txt situated in 
#a folder above the folder this script is in. The format should be \tDPOLA_HUMAN
#Be sure to copy and paste the human vs species of intrest ortholog files from orthofinder into this folder
#these can be found in /OrthoFinder/Results_*/Orthologues/Orthologues_Homo/
#they should look something like this Homo__v__SpeciesOfItrest.tsv
#written by Dominic Wiredu Boakye
rm *.1
rm *.2
rm *.3
rm *.4
rm *.5
rm *.6
rm *.7
rm *.8
rm *.9
rm *.10
rm *.13
for filename in ./Homo*.tsv
do
echo ">>>EXTRACTING HOMOLOGS FOR "$filename"<<<"
	fgrep -f ../the_list.txt < "$filename" > "$filename".DDR
echo ">>>CONVERTING TSV FILES for "$filename" TO SED FILES<<<"
	sed 's/\t/#/g' < "$filename.DDR" > "$filename".1
	sed 's/OG......./s/' < "$filename".1 > "$filename".2
	sed "s/$(printf '\r')\$//" < "$filename".2 > "$filename".3
	sed 's/$/#/' < "$filename".3 > "$filename".4
	sed 's/#\([0-9A-Z]*_HUMAN\), .*_HUMAN\(#.*#\)/#\t\1\2/' < "$filename".4 > "$filename".5
	sed 's/^s#\([0-9A-Z]*_HUMAN.*\)/s#\t\1/' < "$filename".5 > "$filename".6
	sed 's/, /@, >/'g < "$filename".6 > "$filename".7
	sed 's/HUMAN#/HUMAN#>/'g < "$filename".7 > "$filename".8
	sed 's/#$/@#/'g < "$filename".8 > "$filename".9
echo ">>>CREATING ORTHOLOG SPREADSHEET<<<"
	echo ">>>ADDING ORTHOLOGS FROM "$filename" ORTHOLOG SPREADSHEET<<<"
	sed -f "$filename".9 < ../the_list.txt > "$filename".10
	awk 'BEGIN{print "'$filename'"}1' < "$filename".10 > "$filename".11
	sed "1s#\(.*__v__\)\(.*\).tsv#\2#" < "$filename".11 > "$filename".12
	sed 's/^\t.*/0/' < "$filename".12 > "$filename".13
	mv "$filename".13 "$(head -1 "$filename".13).txt"
	rm "$filename".*
done



###############################
# Main loop over *.out.txt files
###############################
rm *out.out*
rm *.out.txt
rm *_bait_sp
rm *_template_bait_sp
rm *_template
rm *template_bait_sp_caught_prey.sedfile
for file in *.txt; do paste Homo.txt "$file" > "${file%.txt}.out.txt"; done
for file in *.out.txt
do
  ##################################
  # 0. Derive the "basename" part
  ##################################
  # E.g., if file is "myGene.basename.out.txt", base will be "myGene.basename"
  # If your file is literally named "basename.out.txt", then base="basename"
  base="${file%.out.txt}"

  echo "Processing file: $file"
  echo "Detected basename: $base"
  echo "---------------------------------------"

  ##################################
  # 1. Create 'basename_template'
  #    Extract lines where column 2 == 0,
  #    and output column 1
  ##################################
  echo "Creating ${base}_template ..."
  awk '
     BEGIN {FS="\t"}
     $2 == 0 { print $1 }
  ' "$file" > "${base}_template"

  ##################################
  # 2. From linking_file.txt:
  #    find line whose column1 == basename
  #    then put column2 into basename_bait_sp
  ##################################
  echo "Creating ${base}_bait_sp ..."
  bait_sp="$(awk -v B="$base" 'BEGIN{FS="\t"} $1 == B {print $2}' linking_file.txt)"
  # If there's a chance of multiple matches in linking_file.txt, pick the first or handle differently
  # For now we assume a single match:
  echo "$bait_sp" > "${base}_bait_sp"

  ##################################
  # 3. Create 'basename_template_bait_sp'
  #    For each entry in 'basename_template', search column5 in
  #    'human_basename_pairwise.txt.out_converted_inparalog_annot.txt'
  #    If found, put column6 in new second column; if no match, 0
  ##################################
  # We'll assume the file is named exactly:
  #    "human_<basename>_pairwise.txt.out_converted_inparalog_annot.txt"

 bait_sp_content="$(< "${base}_bait_sp")"
inparalogFile="human_${bait_sp_content}_pairwise.txt.out_converted_inparalog_annot.txt.corrected"

  echo "Creating ${base}_template_bait_sp ..."
  > "${base}_template_bait_sp"   # truncate

  while read -r proteinLine
  do
    # The lines in basename_template typically look like ">PCNA_HUMAN@"
    # We want to find lines in column5 of $inparalogFile that contain that exact string.
    # We'll do a simple "index($5,key)!=0" approach in awk.

    # If your "template" lines include ">" already, keep them as-is:
    key="$proteinLine"

    # Gather all matches in column6 (possibly multiple lines => combine with comma)
    # Use tab as the input field separator, then check if column5 has 'key'
    # Then paste -sd "," merges multiple lines with commas.
    result="$(awk -F'\t' -v k="$key" '
      index($5, k) != 0 {
        print $6
      }
    ' "$inparalogFile" | paste -sd "," -)"

    # If empty, set to 0
    if [ -z "$result" ]; then
      result=0
    fi

    # Print it out as: "<col1>\t<col2>"
    # Example: >PCNA_HUMAN@  Ecun_Q8SRV9_ENCCU
    echo -e "${proteinLine}\t${result}" >> "${base}_template_bait_sp"

  done < "${base}_template"


  ##################################
  # 4. Create 'basename_template_bait_sp_caught_prey'
  #    For each line in 'basename_template_bait_sp', look at column2 (except "0").
  #    Then search the file in subdirectory:
  #        Orthologues_<bait_sp>/<bait_sp>__v__<basename>.tsv
  #    for the string(s) in column2 (which could be comma-separated).
  #
  #    If found, record column3. If multiple entries differ, keep them all. If
  #    they are the same, just record one. If not found, 0. Then produce a 3-column file:
  #         col1, col2, col3
  ##################################
  orthoDir="Orthologues_${bait_sp}"
  orthoFile="${orthoDir}/${bait_sp}__v__${base}.tsv"

  echo "Creating ${base}_template_bait_sp_caught_prey ..."
  > "${base}_template_bait_sp_caught_prey"

  while IFS=$'\t' read -r col1 col2
  do
    # If col2 == 0, set col3=0
    if [[ "$col2" == "0" ]]; then
      echo -e "${col1}\t${col2}\t0" >> "${base}_template_bait_sp_caught_prey"
      continue
    fi

    # col2 can have comma-separated items (e.g. "Ecun_Q8SVK4_ENCCU,Ecun_Q8STY4_ENCCU")
    # We handle them individually
    # We'll remove any space after commas if present:
    col2_nospaces="$(echo "$col2" | sed 's/, */,/g')"

    IFS=',' read -ra arrVals <<< "$col2_nospaces"
    results=()

    for val in "${arrVals[@]}"
    do
      # Trim extra spaces
      val="$(echo "$val" | xargs)"

      # Search col2 of orthoFile for `val`.
      # Then gather col3 from those lines
      # The example .tsv is tab-separated, so we'll do:
      #   OG0002607    Ecun_Q8SVK4_ENCCU, Ecun_Q8STY4_ENCCU    Ecan_...
      #
      # We do a partial match approach since col2 might have multiple items separated by commas.
      # We'll do: 'index($2,val) != 0' so that if $2 contains that substring, we capture $3.
      found3="$(awk -F'\t' -v v="$val" '
        index($2,v) != 0 {
          print $3
        }
      ' "$orthoFile" | paste -sd "," -)"

      if [ -z "$found3" ]; then
        found3="0"
      fi
      results+=("$found3")
    done

    # If all the values in 'results' are identical (and not 0), return single value
    allsame=true
    firstVal="${results[0]}"
    for x in "${results[@]}"
    do
      if [ "$x" != "$firstVal" ]; then
        allsame=false
        break
      fi
    done

    if $allsame && [ "$firstVal" != "0" ]; then
      finalVal="$firstVal"
    else
      # Combine them with commas
      IFS=','; finalVal="${results[*]}"
    fi
# If finalVal is entirely some sequence of 0's separated by commas (e.g. 0,0,0), replace with just 0
    # This pattern '^(0,)+0$' matches 0,0 or 0,0,0 or 0,0,0,0, etc.
    if [[ "$finalVal" =~ ^(0,)+0$ ]]; then
      finalVal="0"
    fi
    echo -e "${col1}\t${col2}\t${finalVal}" >> "${base}_template_bait_sp_caught_prey"

  done < "${base}_template_bait_sp"

awk 'BEGIN { OFS="\t" } { $3=$2; print }' Albugo_template_bait_sp_caught_prey > tmp && mv tmp Albugo_template_bait_sp_caught_prey
awk 'BEGIN { OFS="\t" } { $3=$2; print }' Saccharomyces_template_bait_sp_caught_prey > tmp && mv tmp Saccharomyces_template_bait_sp_caught_prey
awk 'BEGIN { OFS="\t" } { $3=$2; print }' Encephalitozoon_template_bait_sp_caught_prey > tmp && mv tmp Encephalitozoon_template_bait_sp_caught_prey
awk 'BEGIN { OFS="\t" } { $3=$2; print }' Entamoeba_template_bait_sp_caught_prey > tmp && mv tmp Entamoeba_template_bait_sp_caught_prey
awk 'BEGIN { OFS="\t" } { $3=$2; print }' Escherichia_template_bait_sp_caught_prey > tmp && mv tmp Escherichia_template_bait_sp_caught_prey
awk 'BEGIN { OFS="\t" } { $3=$2; print }' Naegleria_template_bait_sp_caught_prey > tmp && mv tmp Naegleria_template_bait_sp_caught_prey
awk 'BEGIN { OFS="\t" } { $3=$2; print }' Plasmodium_template_bait_sp_caught_prey > tmp && mv tmp Plasmodium_template_bait_sp_caught_prey
awk 'BEGIN { OFS="\t" } { $3=$2; print }' Zea_template_bait_sp_caught_prey > tmp && mv tmp Zea_template_bait_sp_caught_prey

 ##################################
  # 5. Convert 'basename_template_bait_sp_caught_prey'
  #    into a sedfile: 'basename_template_bait_sp_caught_prey.sedfile'
  #
  #    For each line, column1 is the "original >name",
  #    column3 is the "caught prey" (or 0).
  #    If col3==0, produce: s#>col1#0#
  #    Else produce: s#>col1#>col3#
  ##################################
  sedfile="${base}_template_bait_sp_caught_prey.sedfile"

  echo "Creating $sedfile ..."
  > "$sedfile"

  while IFS=$'\t' read -r c1 c2 c3
  do
    if [[ "$c3" == "0" ]]; then
      # e.g. s#>ALKB1_HUMAN@#0#
      echo "s#${c1}#0#" >> "$sedfile"
    else
      # We want to transform c3 so that each comma-separated item is wrapped with > and @
      # e.g. Ecan_ECANGB1_2537-t39_1-p1 => >Ecan_ECANGB1_2537-t39_1-p1@
      # or multiple items => >Ecan_ECANGB1_2172-t39_1-p1@, >Ecan_ECANGB1_1010-t39_1-p1@ ...

      # Remove extra spaces around commas
      c3_nospaces="$(echo "$c3" | sed 's/, */,/g')"
      IFS=',' read -ra arr3 <<< "$c3_nospaces"
      processed=""
      for val3 in "${arr3[@]}"
      do
        val3_trim="$(echo "$val3" | xargs)"
        if [ -z "$processed" ]; then
          processed=">${val3_trim}@"
        else
          processed="$processed, >${val3_trim}@"
        fi
      done

      # 1) Delete all occurrences of '>0@ ,' (including the space after the comma?)
      #    We'll interpret as any occurrence of the literal '>0@ ,' replaced with '' (deleted)
      # 2) Then replace '>0@#' with '0#'

      processed="$(echo "$processed" \
        | sed 's/>0@ ,//g; s/>0@#/0#/g')"

      echo "s#${c1}#${processed}#" >> "$sedfile"
      
    fi
  done < "${base}_template_bait_sp_caught_prey"

  tr -d '\r' < "$sedfile" > temp_file && mv temp_file "$sedfile"
 for input_file in "${base}.out.txt"
 do
 output_file="${input_file}_ready"
  # Process the file: Replace second column with first if it's "0"
    awk -F'\t' '{print ($2 != "0") ? $2 : $1}' "$input_file" > "$output_file"
    echo "Converted: $input_file → $output_file"
done
for input_file in "${base}.out.txt_ready"
do
  sed -f "${base}_template_bait_sp_caught_prey.sedfile" < "$input_file" > "$input_file"_done
done
  echo "Done with $base"
  echo "---------------------------------------"

done

echo "updated ${base}.txt files are in the ${base}.out.txt_ready_done files!"



echo ">>>Creating ortholog name table<<<"
paste Acanthamoeba.out.txt_ready_done Albugo.out.txt_ready_done Allomyces.out.txt_ready_done Anopheles.txt Aphanomyces.out.txt_ready_done Aspergillus.out.txt_ready_done Babesia.out.txt_ready_done Blastocystis.out.txt_ready_done Blechomonas.out.txt_ready_done Botrytis.out.txt_ready_done Caenorhabditis.txt Carpediemonas.out.txt_ready_done Chromera.out.txt_ready_done Coprinopsis.out.txt_ready_done Crithidia.out.txt_ready_done Cryptococcus.out.txt_ready_done Cryptosporidium.out.txt_ready_done Cyclospora.out.txt_ready_done Cytauxzoon.out.txt_ready_done Danio.txt > temp1.txt
paste temp1.txt Drosophila.txt Eimeria.out.txt_ready_done Encephalitozoon.out.txt_ready_done Endotrypanum.out.txt_ready_done Entamoeba.out.txt_ready_done Enterospora.out.txt_ready_done Eriocheir.txt Escherichia.out.txt_ready_done Giardia.out.txt_ready_done Glossina.txt Gregarina.out.txt_ready_done Hyaloperonospora.out.txt_ready_done Homo.txt Leishmania.out.txt_ready_done Leptomonas.out.txt_ready_done Magnaporthe.out.txt_ready_done Mastigmoeba.out.txt_ready_done Melampsora.out.txt_ready_done Mitosporidium.out.txt_ready_done Monocercomonoides.out.txt_ready_done > temp2.txt
paste temp2.txt Naegleria.out.txt_ready_done Nakaseomyces.out.txt_ready_done Neospora.out.txt_ready_done Nucleospora.out.txt_ready_done Oncorhynchus.txt Oryza.out.txt_ready_done Paramicrosporidium.out.txt_ready_done Paramikrocytos.out.txt_ready_done Phytophthora.out.txt_ready_done Plasmodium.out.txt_ready_done Pneumocystis.out.txt_ready_done Pythium.out.txt_ready_done Rhizopus.out.txt_ready_done Rozella.out.txt_ready_done Saccharomyces.out.txt_ready_done Saprolegnia.out.txt_ready_done Schizosaccharomyces.out.txt_ready_done Spironucleus.out.txt_ready_done Spizellomyces.out.txt_ready_done > temp3.txt
paste temp3.txt Sporisorium.out.txt_ready_done Theileria.out.txt_ready_done Toxoplasma.out.txt_ready_done Trichomonas.out.txt_ready_done Trypanosoma.out.txt_ready_done Ustilago.out.txt_ready_done Vitrella.out.txt_ready_done Xenopus.txt Zea.out.txt_ready_done > ortholog_table.tsv

echo ">>>joining all fasta protein files used in analyses from various species into one file<<<"
cat *fasta > combined.fast 
echo ">>>linearise combined.fasta<<<"
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < combined.fast > combined.fa
sed 's/\(>.*\)/\1@/' < combined.fa > combined.fas1
sed 's/:/_/'g < combined.fas1 > combined.fas
for filename in ./ortholog_table.tsv
do
echo ">>>deleting first line from "$filename"<<<"
sed '1d' < "$filename" > "$filename".1
echo ">>>replacing tabs with new line from "$filename"<<<"
tr '\t' '\n' < "$filename".1 > "$filename".2
tr ' ' '\n' < "$filename".2 > "$filename".3
echo ">>>deleting commas from "$filename"<<<"
sed 's/,//'g < "$filename".3 > "$filename".4 
echo ">>>deleting lines with 0s from "$filename"<<<"
sed 's/^0$//'g < "$filename".4 > "$filename".5
echo ">>>appending # to end of line in "$filename"<<<"
sed '/^$/d' < "$filename".5 > "$filename".6
sort "$filename".6 > "$filename".7
echo ">>>split grep file into several grep files! Like a lot of grep files!!"$filename"<<<"
split -l 100 "$filename".7 splitgrepfile.
done
echo ">>>THE NEXT STEPS COULD TAKE VERY LONG TO COMPLETE. SAY 8 HOURS IF YOUR ORIGINAL FASTA FILE WAS APPROX 500 MB<<<"
for filename in splitgrepfile.*
do
echo ">>>Grepping from tiny "$filename" grep file<<<"
fgrep -A 1 -f "$filename" < combined.fas > fa_"$filename"
done
echo ">>>concatenating fasta files from tiny grep files<<<"
cat fa_splitgrepfile.* > combinedDHHorthologs.fa
echo ">>>THE LONG GREPPING PROCESS IS NOW COMPLETE<<<"
echo ">>>getting protein lengths<<<"
sed 's/^--.*//'g < combinedDHHorthologs.fa > temp_length.txt
sed '/^$/d' < temp_length.txt > temp_length1.txt
awk '{print length($0);}' temp_length1.txt  > temp_length2.txt
paste temp_length1.txt temp_length2.txt > temp_length3.txt
echo ">>>creating sed file from temp_length3.txt<<<"
sed 's/^[A-Za-z]*\t\([0-9]*\)/\1£/' < temp_length3.txt > temp_length4.txt
sed 's/\(>.*\)@\t[0-9]*/s#\1@#/'g < temp_length4.txt > temp_length5.txt
tr -d '\n' < temp_length5.txt > temp_length6.txt
tr '£' '\n' < temp_length6.txt > temp_length7.txt
sed 's/$/#g/'g < temp_length7.txt > sed_file.txt
echo ">>>Substituting protein names in ortholog_table.tsv with their respective lengths<<<"
sed -f sed_file.txt < ortholog_table.tsv > ortholog_table_protein_lengths.tsv
num_cols=$(head -n 1 ortholog_table_protein_lengths.tsv | awk -F'\t' '{print NF}')

for ((i=1; i<=num_cols; i++)); do
    cut -f"$i" ortholog_table_protein_lengths.tsv > "column$i.txt"
done
echo "Extracted $num_cols columns into separate files."
for filename in ./column*.txt
do
awk -F',' 'NR==1 {print $0} NR>1 {sum=0; for(i=1; i<=NF; i++) sum+=$i; print sum/NF}' < "$filename" > "$filename".average
done
paste column*.average > ortholog_table_protein_lengths_averages.tsv
#mkdir ExtractedFastaSeqs
#mv fa_* ExtractedFastaSeqs
#mkdir splitgrepfileDir
#mv splitgrepfile.* splitgrepfileDir
rm splitgrepfile.*
rm fa_splitgrepfile.*
rm temp_length*
rm combined.fast
rm combined.fa
rm column*.txt.average
rm temp*.txt
#rm ortholog_table.tsv*
rm column*.txt
sed 's/^--//g' < combinedDHHorthologs.fa > combinedDHHorthologs.fas
