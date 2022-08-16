%macro GetSocialHistory(inpop,inset,outset);  
      
      %let prog = GetSocialHistory;
      title3 "&prog.";
 
       options macrogen mprint mlogic;
      
     *proc contents data= &inset. ;
     run;
      
     proc sql;
          create table &outset. (drop = mrn) as
          select p.Studyid, p.EVENTDTE_START, m.*
     	from  &inpop. p 
     	     inner join &inset.  m
               on m.mrn = p.mrn;
     quit;    
     
     data &outset ;
          set &outset.;
          format SmokeStatusDate date9.;
          SmokeStatusDate = contact_date;
          if ((EVENTDTE_START - 364) <= contact_date <=  EVENTDTE_START); 
          SMOKE_FORMER_SELF_365 = 0;
          if tobacco_use = 'Q' then SMOKE_FORMER_SELF_365 = 1;
          SMOKE_CURR_SELF_365 = 0;
          if tobacco_use = 'Y' then SMOKE_CURR_SELF_365 = 1;
          label SMOKE_FORMER_SELF_365 = "SMOKE_FORMER_SELF_365: Patient is a former smoker per self-report during the past year (0/1, 1=Yes)"
               SMOKE_CURR_SELF_365 = "SMOKE_CURR_SELF_365: Patient is a current smoker per self-report during the past year (0/1, 1=Yes)";
     run;
    
     proc datasets;
     run; 
     title3; 
%mend GetSocialHistory;
