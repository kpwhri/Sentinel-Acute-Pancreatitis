%macro ExcelPrint(infile, xlfilestr,varstr,sheetnamestr);

    ***print excel file.  centralized code ***;
     options macrogen mprint mlogic;
     
     %put infile = &infile. xlfilestr = &xlfilestr. varstr = &varstr. sheetnamestr = &sheetnamestr.;
      
     ***count records***;
     %makecount(&infile.);
     
     proc sort data = &infile. out = printxlsincr ;
          by &varstr.;
     run;
    
     /***break into files that wont crash SAS when they are too large and wont crash on open***/
     %macro brkfile(loopxl);
          data printxls&&loopxl. printxlsincr;
                    set printxlsincr;
                    /***try no more than 2k per file or file becomes too big***/
                    if _n_ le 2000 then output printxls&&loopxl.;
                    else output printxlsincr;
          run;
          ods listing close;
          
          /***default xls file name without number suffix***/
          %LET xlfile = &xlout.\&xlfilestr..xlsx;
          
          /***only numerate files beyond 1 (rare).  This makes files usually not-numbered.***/
          %if &&loopxl. > 1 %then %do;
               /***if file large, xls file name needs number suffix***/
               %LET xlfile = &xlout.\&xlfilestr._&&loopxl..xlsx;
          %end;
          
          %put xlfile = &xlfile.;
         
          ods excel file = "&xlfile."  	style=pearl;
             
               ods excel 	options(sheet_name= "&sheetnamestr.");
               
               proc print data = printxls&&loopxl.  noobs ;
                    var &varstr.;
               run;
                
          ods excel close;
          ods listing; 
         
          %deletefile(printxls&&loopxl.); 
    
     %mend brkfile;   
     
     %let loopxl = 1;
     %makecount(printxlsincr); 
     /***loop thru and print limited-sized files, until we run out of records***/
     %do %while (&&ct. > 0);  /***keep doing as long as count of printxlsincr (from makecount macro) is > 0 ***/
          %put &loopxl.;
          %brkfile (&loopxl.);
          %makecount(printxlsincr);
          %let loopxl = %eval(&loopxl. + 1);
     %end;
     %deletefile(printxlsincr); 
      
     proc datasets;
     run;
%mend ExcelPrint;

