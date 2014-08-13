
function closeRecord() {
  for (i=1; i<=3-curIDLineNo; i++) {
    printf(",,");
  }
  printf("\n");
}

# begin

BEGIN {
  FS=",";
  curID=0;
  curIDLineNo=0;
}
{

  if (NF != 13) {
    print "SYNTAX ERROR, Wrong number of fields,", "Filename: ", FILENAME, "line #", NR, "line: ", $0;
    exit 1;
  }

  ++curIDLineNo;
  if ( $1 == curID) {

    # Continuing record
    
      # append FOR code & % assigned
        printf(",%s,%s", $12, $13);

  } else {

    # New record
      --curIDLineNo;

      if (NR > 1) {
        
        # close last record
          if (NR > 2) {
            closeRecord()
          }

        # Write out new record
          
          printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13);
    
        # Reset curID
          curID=$1;
    
        # Reset current line-no
          curIDLineNo=1;
      }
    
  }
   
}

END {
  closeRecord()
}

