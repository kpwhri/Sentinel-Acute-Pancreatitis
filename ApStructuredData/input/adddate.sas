 %macro AddDate(updateset,varset, var); 
     
     **add non-flag variables to dataset***;
     %let program = AddDate;
     
    ***capture label to retain after max var ***;
     data _null_;  
          set  &varset.;
          format &var.Label $128.;
          &&var.Label = trim(vlabel(&var.));
          call symput('Label', &&var.Label);
      run;
     
     ***max var first to not create dupes ***;
     ***ignore missings***;
     proc sql;
          create table tpop as 
          select distinct &popidentifier., max(&var.) as Max&var. label  "&label." format date9.
          from &varset. (where = (&var. ne .))
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
          format &var. date9.;
     run;
   
     %deletefile(tpop);
     %deletefile(tpop2);

%mend AddDate;
   
    
