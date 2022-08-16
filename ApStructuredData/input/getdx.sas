%macro GetDx(codelist, inpop,inset, outset);
     
     %let prog = GetDx;
     title3 "&prog.";

    *proc contents data= &inset. ;
     run;

     title4 "&codelist. dx codes";  
     proc freq data = &codelist. (where = (vdwTable = 'dx'));
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
	     inner join &codelist. (where = (vdwTable = 'dx')) c
	          on b.DX_CodeType = c.codetype
	          and b.dx = c.code;
     quit;
     
     %macro setflag(var);
          &var. = 0;
          if ConditionAbbr = "&var." then do;
               &var. = 1;
          end; 
     %mend setflag;
     
     data &outset.;
          set &outset.;  
          %setflag(ALC);
          %setflag(INFLUENZA);
          %setflag(APPENDIC);
          %setflag(ASCITES);
          %setflag(CHR_PANCR);
          %setflag(CONSTIPATION);
          %setflag(DIVERTICUL);
          %setflag(DKA);
          %setflag(ERCP);
          %setflag(ESOPHAGITIS);
          %setflag(FOOD_POIS);
          %setflag(GAL_BIL);
          %setflag(GASTRITIS);
          %setflag(GASTRO);
          %setflag(GB_CANCER);
          %setflag(GERD);
          %setflag(HEPATITIS);
          %setflag(HYPERTRIG);         
          %setflag(IBD);
          %setflag(ILEUS);
          %setflag(INTEST_OBS);
          %setflag(MESENT_ISCH);
          %setflag(MYOCARD_ISCH);
          %setflag(NEPHROLITH);
          %setflag(PANC_CNCR);
          %setflag(PEPTIC_ULCER);
          %setflag(SMOKE);
          
          rename SMOKE= SMOKE_DX;
          label ALC= 'ALC: Any alcohol disorder (0/1, 1=Yes)' 
                INFLUENZA= 'INFLUENZA: Any influenza dx (0/1, 1=Yes)'
                HYPERTRIG= 'HYPERTRIG: Any familial hypertriglyceridemia dx (0/1, 1=Yes)'
                APPENDIC= 'APPENDIC: Any appendicitis dx (0/1, 1=Yes)' 
                ASCITES= 'ASCITES: Any ascites dx (0/1, 1=Yes)' 
                CHR_PANCR= 'CHR_PANCR: Any chronic pancreatitis dx (0/1, 1=Yes)' 
                CONSTIPATION= 'CONSTIPATION: Any constipation dx (0/1, 1=Yes)'                 
                DIVERTICUL= 'DIVERTICUL: Any diverticulitis disease dx (0/1, 1=Yes)'                 
                DKA= 'DKA: Any Diabetic ketoacidosis dx (0/1, 1=Yes)'                 
                ERCP= 'ERCP: Any Endoscopic Retrograde Cholangiopancreatography (0/1, 1=Yes)'                 
                ESOPHAGITIS= 'ESOPHAGITIS: Any esophagitis dx (0/1, 1=Yes)'                 
                FOOD_POIS= 'FOOD_POIS: Any food poisoning dx (0/1, 1=Yes)'                 
                GAL_BIL= 'GAL_BIL: Any gallbladder and biliary disease dx (0/1, 1=Yes)'                 
                GASTRITIS= 'GASTRITIS: Any gastritis and duodenitis dx (0/1, 1=Yes)'                 
                GASTRO= 'GASTRO: Any infectious gastroenteritis and colitis dx (0/1, 1=Yes)'                 
                GB_CANCER= 'GB_CANCER: Any cancer of gallbladder and biliary tract dx (0/1, 1=Yes)'                 
                GERD= 'GERD: Any Gastroesophageal reflux disease dx(0/1, 1=Yes)'                                                    
                HEPATITIS= 'HEPATITIS: Any hepatitis dx (0/1, 1=Yes)'                                                    
                IBD= 'IBD: Any inflammatory bowel disease dx (0/1, 1=Yes)'                                                    
                ILEUS= 'ILEUS: Any ileus dx (0/1, 1=Yes)'                                                    
                INTEST_OBS= 'INTEST_OBS: Any intestinal obstruction dx (0/1, 1=Yes)'                                                    
                MESENT_ISCH= 'MESENT_ISCH: Any mesenteric ischemia dx (0/1, 1=Yes)'                                                                 
                MYOCARD_ISCH= 'MYOCARD_ISCH: Any myocardial ischemia dx (0/1, 1=Yes)'                                                                 
                NEPHROLITH= 'NEPHROLITH: Any nephrolithiasis dx (0/1, 1=Yes)'                                                                 
                PANC_CNCR= 'PANC_CNCR: Any pancreatic cancer dx (0/1, 1=Yes)'                                                                 
                PEPTIC_ULCER= 'PEPTIC_ULCER: Any peptic ulcer disease dx (0/1, 1=Yes)'                                                                 
                SMOKE_DX= 'SMOKE_DX: Diagnosis indicating current smoker status (0/1, 1=Yes)'                                                                                          
               ;  
          ***calc special flags that dont fall into triplet fashion***;   
          SMOKE_DX_365 = 0;  
          if SMOKE_DX = 1 and ((EVENTDTE_START - 364) <= adate <=  EVENTDTE_START) then SMOKE_DX_365 = 1;
          
          label SMOKE_DX_365 = "SMOKE_DX_365: Diagnosis indicating current smoker status in the past year (0/1,1=Yes)";
                                            
     run;

     title4 'Dx data';
        
     *proc contents data = basic.dx;
     run;  
      
     proc freq data = &outset.  ;
          title5 'Actual conditioncodetype captured';
          tables conditionabbr conditioncodetype/list missing;
     run;
     
       proc datasets;
     run;
     title3;
     
%mend GetDx;