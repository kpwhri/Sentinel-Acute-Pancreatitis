**************************************************************************
   Age macro, borrowed from local programmer
**************************************************************************;
%MACRO AGE(BDATE,ATDATE,aohtaltz);    
  Age=INTCK('YEAR',&BDATE,&ATDATE);       
  IF ((MONTH(&BDATE)*100)+DAY(&BDATE)) >  
     ((MONTH(&ATDATE)*100)+DAY(&ATDATE))  
     THEN AGE=AGE-1;                      
  %IF %UPCASE(&aohtaltz) ^= N %then %do;  
  IF AGE < 0 THEN AGE=AGE+100;            
  %END;                                   
%MEND AGE;                                 
