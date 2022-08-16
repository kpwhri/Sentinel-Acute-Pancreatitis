%macro createtriplet(updateset, var); 
     
     %let prog = createtriplet;
     title3 "&prog.";

     **add flags of value 1 to dataset***;
     %let program = createtriplet;
     
     ***capture label to retain after max var ***;
     data _null_;  
          set  &updateset. (obs = 1);
          format &var.Label &var.Label_SD &var.Label_CS &var.Label_PY $128.;
          ***pick up label of var***;
          &&var.Label = trim(vlabel(&var.));
          
          ***trim label so we can use it for time-specific vars ***;
          ***remove (0/1, 1=Yes) ending of label***; 
          &&var.Label = transtrn(&&var.Label,"(0/1, 1=Yes)",trimn(''));
          ***remove var: Any beginning of label***; 
          &&var.Label = transtrn(&&var.Label,"&var.: Any",trimn(''));

          ***use remaining label to build time-specific triplet***;         
          &&var.Label_SD = "&var._SD:";
          &&var.Label_SD = left(trim(&&var.Label_SD)) || " " || left(trim(&&var.Label)) || " " || "same day (0/1, 1=Yes)";
          &&var.Label_SD = left(compbl(&&var.Label_SD));
          put &&var.Label_SD=;          
          call symput('Label_SD', &&var.Label_SD);
               
          &&var.Label_CS = "&var._CS:";
          &&var.Label_CS = left(trim(&&var.Label_CS)) || " " || left(trim(&&var.Label)) || " " || "contemporaneous (0/1, 1=Yes)";
          &&var.Label_CS = left(compbl(&&var.Label_CS));
          put &&var.Label_CS=;         
          call symput('Label_CS', &&var.Label_CS);
          
          &&var.Label_PY = "&var._PY:";
          &&var.Label_PY = left(trim(&&var.Label_PY)) || " " || left(trim(&&var.Label)) || " " || "past year (0/1, 1=Yes)";
          &&var.Label_PY = left(compbl(&&var.Label_PY));
          put &&var.Label_PY=;         
          call symput('Label_PY', &&var.Label_PY);     

     run;
     %put &Label_SD.= &Label_PY.= &Label_CS.=;
     
     ***identify triplets***;
     data &updateset.;
          set &updateset.; 
          &var._SD = 0;
          &var._CS = 0;
          &var._PY = 0;
                   
          /***SAME DAY VARIABLES (SD): 1 day before through 1 day after
          /***      If GROUP 2 or GROUP 3, set to true if the relevant codes appear on 
          /***            EVENTDTE_START, the day before EVENTDTE_START, or the day after EVENTDTE_START;
          /***      if GROUP 1, set to true if the relevant codes appear any time during the period beginning 
          /***           one day before EVENTDTE_START through the EVENTDTE_END. 
          /***           Do not include the day after EVENTDTE_END  ***/
          
          /*** CONTEMPORANEOUS VARIABLES (CS): 2 to 7 days before through 2 to 7 days after ***/
          /***      Group 2 or 3, set to true if 2 to 7 days before EVENTDTE_START 
          /***           or 2 to 7 days after EVENTDTE_START
          /***      Group 1, set to true if 2 to 7 days before EVENTDTE_START or 1 to 7 days after EVENTDTE_END.  
          /*** Note that CS excludes days included in SD variables (i.e. they are mutually exclusive periods). ***/
                              
          /***PAST YEAR VARIABLES (PY): set to true if 365 days before EVENTDTE_START through 8 days before EVENTDTE_START. ***/ 

          if &var. = 1 then do;
               /***Triplets are mutually exclusive so assign as hierarchy***/
               if group = 1 then do;
                    if ((EVENTDTE_START -1) <= ADate <=  (EVENTDTE_END)) then &var._SD = 1; 
                    else if ((EVENTDTE_START - 7) <= ADate <=(EVENTDTE_START - 2)) 
                         or ( (EVENTDTE_END + 1) <= ADate <= (EVENTDTE_END + 7)) 
                         then &var._CS = 1; 
                    else if ((EVENTDTE_START - 365) <= ADate <=  (EVENTDTE_START - 8)) then &var._PY = 1; 
               end;
               else do;
                    if ((EVENTDTE_START - 1) <= ADate <=  (EVENTDTE_END + 1)) then &var._SD = 1; 
                    else if ((EVENTDTE_START - 7) <= ADate <=(EVENTDTE_START - 2)) 
                         or ( (EVENTDTE_END + 2) <= ADate <=  (EVENTDTE_END + 7)) 
                         then &var._CS = 1; 
                    else if ((EVENTDTE_START - 365) <= ADate <=  (EVENTDTE_START - 8)) then &var._PY = 1; 
               end;
          end;
          
          label &var._SD = "&Label_SD."
                &var._CS = "&Label_CS."
                &var._PY = "&Label_PY.";        
     run;  

     proc datasets;
     run;
     
     title3;
%mend createtriplet;
   
    
