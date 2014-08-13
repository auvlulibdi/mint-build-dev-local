
# In
# 01 - ID
# 02 - Family_Name
# 03 - Given_Name
# 04 - Other_Names
# 05 - Honorific
# 06 - Email
# 07 - ctype
# 08 - lcurrent
# 09 - sidnum
# 10 - sStudid
# 11 - sGender
# 12 - ANZSRC_FOR_1
# 13 - ANZSRC_FOR_1_PCT
# 14 - ANZSRC_FOR_2
# 15 - ANZSRC_FOR_2_PCT
# 16 - ANZSRC_FOR_3
# 17 - ANZSRC_FOR_3_PCT

# Out

# NN = to-omit

# 01 - ID
# 03 - Given_Name
# 04 - Other_Names
# 02 - Family_Name
# NN - Pref_Name
# 05 - Honorific
# 06 - Email
# NN - Job_Title
# NN - GroupID_1
# NN - GroupID_2
# NN - GroupID_3
# 12 - ANZSRC_FOR_1
# 14 - ANZSRC_FOR_2
# 16 - ANZSRC_FOR_3
# NN - URI
# NN - NLA_Party_Identifier
# NN - ResearcherID
# NN - openID
# NN - Personal_URI
# NN - Personal_Homepage
# NN - Staff_Profile_Homepage
# NN - Description
# 07 - ctype
# 08 - lcurrent
# 09 - sidnum
# 10 - sStudid
# 11 - sGender
# 13 - ANZSRC_FOR_1_PCT
# 15 - ANZSRC_FOR_2_PCT
# 17 - ANZSRC_FOR_3_PCT

function closeRecord() {
  for (i=0; i<3-curIDLineNo; ++i) {
    printf(",,");
  }
  printf("\n");
}

# begin

BEGIN {
  FS=",";
  curID=0;
  curIDLineNo=0;
  printf("ID,Given_Name,Other_Names,Family_Name,Pref_Name,Honorific,Email,Job_Title,GroupID_1,GroupID_2,GroupID_3,ANZSRC_FOR_1,ANZSRC_FOR_2,ANZSRC_FOR_3,URI,NLA_Party_Identifier,ResearcherID,openID,Personal_URI,Personal_Homepage,Staff_Profile_Homepage,Description,ctype,lcurrent,sidnum,sStudid,sGender,ANZSRC_FOR_1_PCT,ANZSRC_FOR_2_PCT,ANZSRC_FOR_3_PCT\n");
}
{

  # Check number of fields in record
    if (NF != 17) {
      print "SYNTAX ERROR, Wrong number of fields,", "Filename: ", FILENAME, "line #", NR, "line: ", $0;
      exit 1;
    }

  # Write out new record
    printf("%s,%s,%s,%s,,%s,%s,,,,,%s,%s,%s,,,,,,,,,%s,%s,%s,%s,%s,%s,%s,%s\n", $1, $3, $4, $2, $5, $6, $12, $14, $16, $7, $8, $9, $10, $11, $13, $15, $17);

}

END {
}

