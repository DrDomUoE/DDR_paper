#!/usr/bin/env bash
#
#./make_ortholog_table_protein_lengths_averages_for_grepping.sh
#
# 1. Reorder columns in ortholog_table_protein_lengths_averages.tsv in alphabetical order
#    according to the names in the first (header) row.
# 2. Insert row 2 and row 3 of template.tsv into that file (just after the header).
# 3. Insert a 3-row gap after rows 435, 473, and 514 (in the newly modified file).
# 4. Insert column 1 of template.tsv into the modified file.

############################################################
# 1. Reorder columns by alphabetical order of the header.
############################################################

./transpose.sh ../ortholog_table_protein_lengths_averages.tsv step1.tsv

############################################################
# 2. Insert row 2 and 3 of template.tsv into the file
#    right after the header row of step1.tsv.
############################################################

# Extract the header line of step1.tsv
header_line=$(head -n1 step1.tsv)

# Extract row 2 and row 3 of template.tsv
row2=$(sed -n '2p' template.tsv)
row3=$(sed -n '3p' template.tsv)

# Remove the header line from step1.tsv (keep data only)
tail -n +2 step1.tsv > step1_data.tsv

# Build step2.tsv: header, then row2 & row3, then the rest
{
  echo "$header_line"
  echo "$row2"
  echo "$row3"
  cat step1_data.tsv
} > step2.tsv


############################################################
# 3. Insert a 3-row gap after lines 435, 473, and 514.
#    (These line counts refer to the new file step2.tsv.)
############################################################

# 3.1: Insert a 3-row gap after line 435
awk 'NR == 435 { print $0; print ""; print ""; print ""; next } { print }' step2.tsv > step3_1.tsv

# After that insertion, lines after 435 have been shifted by 3.
# So the next insertion, originally meant for line 473, is now 473 + 3 = 476.

# 3.2: Insert a 3-row gap after line 476
awk 'NR == 473 { print $0; print ""; print ""; print ""; next } { print }' step3_1.tsv > step3_2.tsv

# After the second insertion, lines after 473 are shifted by a total of 6.
# So the third insertion, originally for line 514, is now 514 + 6 = 520.

# 3.3: Insert a 3-row gap after line 520
awk 'NR == 514 { print $0; print ""; print ""; print ""; next } { print }' step3_2.tsv > step3.tsv



############################################################
# 4. Insert column 1 of template.tsv into step3.tsv.
#    (Assumes that each file has the same number of rows OR
#    that you only need to match lines 1-to-1. Adjust as needed.)
############################################################

# Extract the first column of template.tsv
cut -f1 template.tsv > template_col1.tsv

# Combine template_col1.tsv with step3.tsv side by side
paste template_col1.tsv step3.tsv > step4.tsv

sed 's/#Lifestyle#\t#Lifestyle#/#Lifestyle#/' step4.tsv > step5.tsv
sed 's/#Mitochondrial_plastid_status#\t#Mitochondrial_plastid_status#/#Mitochondrial_plastid_status#/' step5.tsv > step6.tsv
mv step6.tsv ortholog_table_protein_lengths_averages_for_grepping.tsv
############################################################
# Cleanup: (Uncomment to remove intermediate files)
rm step1.tsv step1_data.tsv step2.tsv step3.tsv template_col1.tsv
############################################################

echo "Processing complete. See ortholog_table_protein_lengths_averages_for_grepping.tsv."
###################################################################################################
############################################################
# 1. Reorder columns by alphabetical order of the header.
############################################################


./transpose.sh ../ortholog_table_domain_lengths_averages.tsv step1.tsv

############################################################
# 2. Insert row 2 and 3 of template.tsv into the file
#    right after the header row of step1.tsv.
############################################################

# Extract the header line of step1.tsv
header_line=$(head -n1 step1.tsv)

# Extract row 2 and row 3 of template.tsv
row2=$(sed -n '2p' template.tsv)
row3=$(sed -n '3p' template.tsv)

# Remove the header line from step1.tsv (keep data only)
tail -n +2 step1.tsv > step1_data.tsv

# Build step2.tsv: header, then row2 & row3, then the rest
{
  echo "$header_line"
  echo "$row2"
  echo "$row3"
  cat step1_data.tsv
} > step2.tsv


############################################################
# 3. Insert a 3-row gap after lines 435, 473, and 514.
#    (These line counts refer to the new file step2.tsv.)
############################################################

# 3.1: Insert a 3-row gap after line 435
awk 'NR == 435 { print $0; print ""; print ""; print ""; next } { print }' step2.tsv > step3_1.tsv

# After that insertion, lines after 435 have been shifted by 3.
# So the next insertion, originally meant for line 473, is now 473 + 3 = 476.

# 3.2: Insert a 3-row gap after line 476
awk 'NR == 473 { print $0; print ""; print ""; print ""; next } { print }' step3_1.tsv > step3_2.tsv

# After the second insertion, lines after 473 are shifted by a total of 6.
# So the third insertion, originally for line 514, is now 514 + 6 = 520.

# 3.3: Insert a 3-row gap after line 520
awk 'NR == 514 { print $0; print ""; print ""; print ""; next } { print }' step3_2.tsv > step3.tsv

############################################################
# 4. Insert column 1 of template.tsv into step3.tsv.
#    (Assumes that each file has the same number of rows OR
#    that you only need to match lines 1-to-1. Adjust as needed.)
############################################################

# Extract the first column of template.tsv
cut -f1 template.tsv > template_col1.tsv

# Combine template_col1.tsv with step3.tsv side by side
paste template_col1.tsv step3.tsv > step4.tsv

sed 's/#Lifestyle#\t#Lifestyle#/#Lifestyle#/' step4.tsv > step5.tsv
sed 's/#Mitochondrial_plastid_status#\t#Mitochondrial_plastid_status#/#Mitochondrial_plastid_status#/' step5.tsv > step6.tsv
mv step6.tsv ortholog_table_domain_lengths_averages_for_grepping.tsv
############################################################
# Cleanup: (Uncomment to remove intermediate files)
rm step1.tsv step1_data.tsv step2.tsv step3.tsv template_col1.tsv
############################################################
echo "Processing complete. See ortholog_table_domain_lengths_averages_for_grepping.tsv."
###################################################################################################

############################################################
# 1. Reorder columns by alphabetical order of the header.
############################################################

./transpose.sh ../ortholog_table_interdomain_lengths_averages.tsv step1.tsv
############################################################
# 2. Insert row 2 and 3 of template.tsv into the file
#    right after the header row of step1.tsv.
############################################################

# Extract the header line of step1.tsv
header_line=$(head -n1 step1.tsv)

# Extract row 2 and row 3 of template.tsv
row2=$(sed -n '2p' template.tsv)
row3=$(sed -n '3p' template.tsv)

# Remove the header line from step1.tsv (keep data only)
tail -n +2 step1.tsv > step1_data.tsv

# Build step2.tsv: header, then row2 & row3, then the rest
{
  echo "$header_line"
  echo "$row2"
  echo "$row3"
  cat step1_data.tsv
} > step2.tsv


############################################################
# 3. Insert a 3-row gap after lines 435, 473, and 514.
#    (These line counts refer to the new file step2.tsv.)
############################################################

# 3.1: Insert a 3-row gap after line 435
awk 'NR == 435 { print $0; print ""; print ""; print ""; next } { print }' step2.tsv > step3_1.tsv

# After that insertion, lines after 435 have been shifted by 3.
# So the next insertion, originally meant for line 473, is now 473 + 3 = 476.

# 3.2: Insert a 3-row gap after line 476
awk 'NR == 473 { print $0; print ""; print ""; print ""; next } { print }' step3_1.tsv > step3_2.tsv

# After the second insertion, lines after 473 are shifted by a total of 6.
# So the third insertion, originally for line 514, is now 514 + 6 = 520.

# 3.3: Insert a 3-row gap after line 520
awk 'NR == 514 { print $0; print ""; print ""; print ""; next } { print }' step3_2.tsv > step3.tsv

############################################################
# 4. Insert column 1 of template.tsv into step3.tsv.
#    (Assumes that each file has the same number of rows OR
#    that you only need to match lines 1-to-1. Adjust as needed.)
############################################################

# Extract the first column of template.tsv
cut -f1 template.tsv > template_col1.tsv

# Combine template_col1.tsv with step3.tsv side by side
paste template_col1.tsv step3.tsv > step4.tsv

sed 's/#Lifestyle#\t#Lifestyle#/#Lifestyle#/' step4.tsv > step5.tsv
sed 's/#Mitochondrial_plastid_status#\t#Mitochondrial_plastid_status#/#Mitochondrial_plastid_status#/' step5.tsv > step6.tsv
mv step6.tsv ortholog_table_interdomain_lengths_averages_for_grepping.tsv
############################################################
# Cleanup: (Uncomment to remove intermediate files)
rm step1.tsv step1_data.tsv step2.tsv step3.tsv template_col1.tsv
############################################################

echo "Processing complete. See ortholog_table_interdomain_lengths_averages_for_grepping.tsv."
###################################################################################################
############################################################
# 1. Reorder columns by alphabetical order of the header.
############################################################

./transpose.sh ../ortholog_table_full_protein_lengths_averages.tsv step1.tsv
############################################################
# 2. Insert row 2 and 3 of template.tsv into the file
#    right after the header row of step1.tsv.
############################################################

# Extract the header line of step1.tsv
header_line=$(head -n1 step1.tsv)

# Extract row 2 and row 3 of template.tsv
row2=$(sed -n '2p' template.tsv)
row3=$(sed -n '3p' template.tsv)

# Remove the header line from step1.tsv (keep data only)
tail -n +2 step1.tsv > step1_data.tsv

# Build step2.tsv: header, then row2 & row3, then the rest
{
  echo "$header_line"
  echo "$row2"
  echo "$row3"
  cat step1_data.tsv
} > step2.tsv


############################################################
# 3. Insert a 3-row gap after lines 435, 473, and 514.
#    (These line counts refer to the new file step2.tsv.)
############################################################

# 3.1: Insert a 3-row gap after line 435
awk 'NR == 435 { print $0; print ""; print ""; print ""; next } { print }' step2.tsv > step3_1.tsv

# After that insertion, lines after 435 have been shifted by 3.
# So the next insertion, originally meant for line 473, is now 473 + 3 = 476.

# 3.2: Insert a 3-row gap after line 476
awk 'NR == 473 { print $0; print ""; print ""; print ""; next } { print }' step3_1.tsv > step3_2.tsv

# After the second insertion, lines after 473 are shifted by a total of 6.
# So the third insertion, originally for line 514, is now 514 + 6 = 520.

# 3.3: Insert a 3-row gap after line 520
awk 'NR == 514 { print $0; print ""; print ""; print ""; next } { print }' step3_2.tsv > step3.tsv

############################################################
# 4. Insert column 1 of template.tsv into step3.tsv.
#    (Assumes that each file has the same number of rows OR
#    that you only need to match lines 1-to-1. Adjust as needed.)
############################################################

# Extract the first column of template.tsv
cut -f1 template.tsv > template_col1.tsv

# Combine template_col1.tsv with step3.tsv side by side
paste template_col1.tsv step3.tsv > step4.tsv

sed 's/#Lifestyle#\t#Lifestyle#/#Lifestyle#/' step4.tsv > step5.tsv
sed 's/#species#\t#species#/#species#/' step5.tsv > step6.tsv
sed 's/#Mitochondrial_plastid_status#\t#Mitochondrial_plastid_status#/#Mitochondrial_plastid_status#/' step6.tsv > step7.tsv
mv step7.tsv ortholog_table_full_protein_lengths_averages_for_grepping.tsv
############################################################
# Cleanup: (Uncomment to remove intermediate files)
#rm step1.tsv step1_data.tsv step2.tsv step3.tsv template_col1.tsv
############################################################

echo "Processing complete. See ortholog_table_full_protein_lengths_averages_for_grepping.tsv."
###################################################################################################
############################################################
# 1. Reorder columns by alphabetical order of the header.
############################################################

./transpose.sh ../ortholog_table_domain_count_averages.tsv step1.tsv

############################################################
# 2. Insert row 2 and 3 of template.tsv into the file
#    right after the header row of step1.tsv.
############################################################

# Extract the header line of step1.tsv
header_line=$(head -n1 step1.tsv)

# Extract row 2 and row 3 of template.tsv
row2=$(sed -n '2p' template.tsv)
row3=$(sed -n '3p' template.tsv)

# Remove the header line from step1.tsv (keep data only)
tail -n +2 step1.tsv > step1_data.tsv

# Build step2.tsv: header, then row2 & row3, then the rest
{
  echo "$header_line"
  echo "$row2"
  echo "$row3"
  cat step1_data.tsv
} > step2.tsv


############################################################
# 3. Insert a 3-row gap after lines 435, 473, and 514.
#    (These line counts refer to the new file step2.tsv.)
############################################################

# 3.1: Insert a 3-row gap after line 435
awk 'NR == 435 { print $0; print ""; print ""; print ""; next } { print }' step2.tsv > step3_1.tsv

# After that insertion, lines after 435 have been shifted by 3.
# So the next insertion, originally meant for line 473, is now 473 + 3 = 476.

# 3.2: Insert a 3-row gap after line 476
awk 'NR == 473 { print $0; print ""; print ""; print ""; next } { print }' step3_1.tsv > step3_2.tsv

# After the second insertion, lines after 473 are shifted by a total of 6.
# So the third insertion, originally for line 514, is now 514 + 6 = 520.

# 3.3: Insert a 3-row gap after line 520
awk 'NR == 514 { print $0; print ""; print ""; print ""; next } { print }' step3_2.tsv > step3.tsv

############################################################
# 4. Insert column 1 of template.tsv into step3.tsv.
#    (Assumes that each file has the same number of rows OR
#    that you only need to match lines 1-to-1. Adjust as needed.)
############################################################

# Extract the first column of template.tsv
cut -f1 template.tsv > template_col1.tsv

# Combine template_col1.tsv with step3.tsv side by side
paste template_col1.tsv step3.tsv > step4.tsv

sed 's/#Lifestyle#\t#Lifestyle#/#Lifestyle#/' step4.tsv > step5.tsv
sed 's/#Mitochondrial_plastid_status#\t#Mitochondrial_plastid_status#/#Mitochondrial_plastid_status#/' step5.tsv > step6.tsv
mv step6.tsv ortholog_table_domain_count_averages_for_grepping.tsv
############################################################
# Cleanup: (Uncomment to remove intermediate files)
rm step1.tsv step1_data.tsv step2.tsv step3.tsv template_col1.tsv
############################################################
echo "Processing complete. See ortholog_table_domain_count_averages_for_grepping.tsv"
###################################################################################################