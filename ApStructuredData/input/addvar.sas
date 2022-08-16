 %macro AddVar(updateset,varset, var); 
     
     **add non-flag variables to dataset***;
     %let program = AddVar;
     
     ***capture label to retain after max var ***;
     data _null_;  
          set  &varset.;
          format &var.lbl $128.;
          &&var.lbl = trim(vlabel(&var.));
          call symput('Label', &&var.lbl);
     run;
     
     ***max var first to not create dupes ***;
     proc sql;
          create table tpop as 
          select distinct &popidentifier., max(&var.) as Max&var. label = "&label."
          from &varset.
          group by &popidentifier.;
     quit;
     
     proc sql;
          create table tpop2 as 
          select p.*, v.Max&var. as &var. 
          from &updateset. p 
          left join tpop v
          on p.&popidentifier. = v.&popidentifier.;
     quit;

     data &updateset.;
          set tpop2;
     run;
         
     %deletefile(tpop);
     %deletefile(tpop2);
   
%mend AddVar;
   
    
