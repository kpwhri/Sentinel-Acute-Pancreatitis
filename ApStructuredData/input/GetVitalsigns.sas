%macro GetVitalsigns(inpop,inset,outset);  
           
     %let prog = GetVitalsigns;
     title3 "&prog.";

      options macrogen mprint mlogic;
      
     **proc contents data= &inset. ;
      run;
      
     proc sql;
          create table &outset. (drop = patid) as
          select p.Studyid, p.EVENTDTE_START, m.*
     	from  &inpop. p 
     	     inner join &inset.  m
               on m.patid = p.patid;
     quit;    
    
     proc datasets;
     run; 
     title3; 
%mend GetVitalsigns;
