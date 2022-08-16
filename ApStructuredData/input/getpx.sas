%macro GetPx(codelist, inpop,inset, outset);
     
     %let prog = GetPx;
     title3 "&prog.";
        
     ***proc contents data= &inset. ;
     run;
     
     title4 "&codelist. px codes";  
 
     proc freq data = &codelist. (where = (vdwTable = 'px'));
          tables conditionabbr conditioncodetype/list missing;
     run;    
 
     /***two steps is faster than a where on adate***/
     proc sql;
          create table &outset. (where =( (EVENTDTE_START -365) <= ADate <=  (EVENTDTE_END + 7))
                     drop = patid code codetype) as
          select p.Studyid, p.EVENTDTE_START,p.EVENTDTE_END,p.Group, b.*, c.*
          from &inpop. p
	     inner join &inset.   b 
	     on p.patid=b.patid
	     inner join &codelist. (where = (vdwTable = 'px')) c
	          on b.px_CodeType = c.codetype
	          and b.px = c.code;
     quit;
     
     %macro setflag(var);
          &var. = 0;
          if ConditionAbbr = "&var." then do;
               &var. = 1;
          end; 
     %mend setflag;
        
     data &outset.;
          set &outset.;   
          %setflag(SMOKE);   
          %setflag(ABDIMG_CT);
          %setflag(ABDIMG_MR);
       
          rename SMOKE= SMOKE_PX;
          label SMOKE_DX= 'SMOKE_PX: Procedure indicating current smoker status (0/1, 1=Yes)'                                                                                          
     
          ***calc special flag that doesnt fall into triplet fashion***;   
          SMOKE_PX_365 = 0;  
          if condition = 'Smoke' and ((EVENTDTE_START - 364) <= adate <=  EVENTDTE_START) then SMOKE_PX_365 = 1;
          
          ABDIMG_CT_14 = 0;         
          if ABDIMG_CT = 1 and ((EVENTDTE_START - 14) <= adate <=  (EVENTDTE_START + 14)) then ABDIMG_CT_14 = 1;
          ABDIMG_MR_14 = 0;   
          if ABDIMG_MR = 1 and ((EVENTDTE_START - 14) <= adate <=  (EVENTDTE_START + 14)) then ABDIMG_MR_14 = 1;

          label SMOKE_PX_365 = "SMOKE_PX_365: Procedure indicating current smoker status in the past year (0/1,1=Yes)"
                ABDIMG_CT = "ABDIMG_CT: Abdominal imaging - CT scan (0/1, 1=Yes)"
                ABDIMG_MR = "ABDIMG_MR: Abdominal imaging - MRI (0/1, 1=Yes)"
                ABDIMG_CT_14 = "ABDIMG_CT_14:  Abdominal imaging - CT scan from 14d before to 14d after EVENTDTE_START (0/1,1=Yes)"                                    
                ABDIMG_MR_14 = "ABDIMG_MR_14:  Abdominal imaging - MRI from 14d before to 14d after EVENTDTE_START (0/1,1=Yes)";
     run;
     
     title4 'Px data';
  
     proc freq data = &outset.  ;
          title5 'Actual conditioncodetype captured';
          tables conditionabbr conditioncodetype /list missing;
     run;
    
     proc datasets;
     run;
     title3;
%mend GetPx;