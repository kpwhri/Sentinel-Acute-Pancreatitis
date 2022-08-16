%macro GetDemog(inpop,inset,outset);  
      
     options macrogen mprint mlogic;
     %let prog = GetDemog;
     title3 "&prog.";
      
     *proc contents data= &inset. ;
      run;
      
     proc sql;
          create table &outset. as
          select p.Studyid, p.EVENTDTE_START, m.race, m.hispanic , m.sex, m.birth_date 
     	from  &inpop. p 
     	     inner join &inset.  m
               on m.patid = p.patid;
     quit;
     
     ***supplement gender where gender_identify UN***;
     data &outset.;
          set &outset.; 
          AGE_AT_EVENT_IN_YRS = .;
          label AGE_AT_EVENT_IN_YRS = "AGE_AT_EVENT_IN_YRS:  Age at EVENTDTE_START in years";
                   
          if birth_date ne . then do;
               %age(birth_date,EVENTDTE_START,n);
               AGE_AT_EVENT_IN_YRS = age;
          end; 
          if sex = 'F' then SEXF = 1;
          else  SEXF = 0;
          label SEXF ="SEXF: Sex is female (0/1, 1=Yes)";
          ****%raceit;	
          RACE_UNK = 0;
          RACE_AIAN = 0;
          RACE_ASIAN = 0;
          RACE_AA = 0;
          RACE_PI = 0;
          RACE_WHITE = 0;
          
          label RACE_UNK = "RACE_UNK: Is race unknown (0/1, 1=Yes)"
                RACE_AIAN = "RACE_AIAN: Is race known to be American Indian or Alaska Native (0/1, 1=Yes)"
                RACE_ASIAN = "RACE_ASIAN: Is race known to be Asian (0/1, 1=Yes)"
                RACE_AA = "RACE_AA: Is race known to be black or African-American (0/1, 1=Yes)"
                RACE_PI = "RACE_PI: Is race known to be Native Hawaiian or Other Pacific Islander (0/1, 1=Yes)"
                RACE_WHITE = "RACE_WHITE: Is race known to be white (0/1, 1=Yes)"
                HISPANIC= "HISPANIC: ethnicity known to be Hispanic (0/1, 1=Yes)"
                ;
          
          if race = 0 then RACE_UNK = 1;
          else if race = 1 then RACE_AIAN = 1;
          else if race = 2 then RACE_ASIAN = 1;
          else if race = 3 then RACE_AA = 1;
          else if race = 4 then RACE_PI = 1;
          else if race = 5 then RACE_WHITE = 1;

     run;
   
     proc freq;
          title4 "Creation of race variables";
          tables race*(RACE_UNK RACE_AIAN RACE_ASIAN RACE_AA RACE_PI RACE_WHITE)  /list missing;
     run;
      
     %deletefile(pop);
    
     proc datasets;
     run;
     title3;  
%mend GetDemog;
