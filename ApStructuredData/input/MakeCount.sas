%macro MakeCount (inset  );

     ***macro to count projects, using file that is one record per project ***;
     options macrogen mprint mlogic;
     
     %global ct;
     %let ct = 0;
     proc sql;
               create table ct as
               select distinct count(*) as ct 
               from &inset.;
     quit;
    
     data _null_;
               set ct;
               call symput('ct',left(trim(put(ct,8.0)))); /***convert num to char***/
     run;
     %put ct = &ct.;
     %deletefile(ct);
     
%mend MakeCount;
