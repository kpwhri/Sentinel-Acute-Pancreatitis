%macro deletefile(filenm,lib=work);     
    %if %sysfunc(exist(&lib..&filenm.)) %then %do;  
          proc datasets lib= &lib. nolist;
               delete &filenm.;
          run;
    %end;
%mend;
 