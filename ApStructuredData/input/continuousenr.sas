%macro continuousenr(inset,inpop,outraw, outset ); 
     %let prog = continuousenr;
     title4 "&prog.";         
     
     ***pull continuous enrollment.  
     ** Sentinel data harmonization requires enr ge 9 m in previous year ***;
    
     data inset (rename = (patid = mrn));
          set &inset.; 
          ***drop variables where we dont want these interfering with collapsing***;
          drop MEDCOV    DRUGCOV    CHART  EligEnr Enrolled;       
     run;

     options nomacrogen nomprint nomlogic;
     
     %CollapsePeriods(Lib = work, DSet = inset, OutSet=enr,
					RecStart = enr_start, RecEnd = enr_end, 
					DaysTol = &admin_gap., Debug = 0);

     options macrogen mprint mlogic;

     proc sql;
          create table &outraw. (drop = patid) as
          select e.*, p.targetpopid
          from enr e
               inner join &inpop. p
          on p.patid  = e.mrn;
     quit;
     
     %deletefile(enr);
     
     proc sort data=&outraw.;
          by targetpopid enr_start;
     run;
     
     /***simply count months since this is restricted to one year***/
     data &outraw.;
	     set &outraw. (drop = mrn);
          by targetpopid enr_start;
          if first.targetpopid then do;
               months_enrolled = 0;
          end;
          format tenrstart tenrend date9.; 
          tenrstart = enr_start;
          tenrend = enr_end;
                   
          if  enr_start lt "&begyr."d  then tenrstart = "&begyr."d;
          if  enr_end gt "&indexdate."d  then tenrend = "&indexdate."d;
 	     
 	     months_enrolled = months_enrolled + intck('month',tenrstart,tenrend) + 1;
          if last.targetpopid then keep = 1;
          retain months_enrolled;
     run;
          
     data &outset. (keep = targetpopid EligContEnr);
          set &outraw.;
          if keep =1;
          EligContEnr =0;
          if months_enrolled ge 9 then EligContEnr = 1;
          label EligContEnr = "EligContEnr: Eligible by enrollment for at least 9 months in index year (0/1)";
	run;

     %deletefile(inset);
     proc datasets;
     run;
     
     title4;    
%mend continuousenr;
