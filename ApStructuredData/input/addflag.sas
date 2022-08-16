%macro AddFlag(updateset,varset, var); 
     
     **add flags of value 1 to dataset***;
     %let program = AddFlag;
     
    ***capture label to retain after max var ***;
     data _null_;  
          set  &varset. (obs = 1);
          format &var.lbl $128.;
          &&var.lbl = trim(vlabel(&var.));
          call symput('Label', &&var.lbl);
      run;
     
     %put &label.=;
          
     ***max var first to not create dupes ***;
     proc sql;
          create table flag as 
          select distinct &popidentifier., max(&var.) as Max&var. label = "&label."
          from &varset.
          group by &popidentifier.;
     quit;
      
     proc sql;
          create table flag2 as 
          select p.*, v.Max&var. as &var. 
          from &updateset. p 
          left join flag v
          on p.&popidentifier. = v.&popidentifier.;
     quit;
     
     data &updateset.;
          set flag2;
          if &var. = . then &var. = 0;
     run;
   
     %deletefile(flag);
     %deletefile(flag2);
    
%mend AddFlag;
   
    
