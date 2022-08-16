********************************************************
***Program:  ApLab.sas
***  Acute Pancreatitis Lab data Summary stats
***     Purpose:
***        Transform raw AP labs data into covariate summary file
***
***  Dependencies:
***       Raw AP labs file
***  Process:
***       1. Convert raw lab file to SAS
***       2. Complete User Inputs section
***       3. Run this program.  Check log for e*r*r*ors
***       4. You may review xls and pdf output in the Review folder
***       5. Files in the Share folder should be distributed as indicated
***                                                                          
*******************************************************
** END Modifications
********************************************************;

********************************************************************************************************************;
*                 User Inputs                          *;
********************************************************************************************************************;
     ***************************************************************************************************************;
     *** 1.  Add %let progroot to indicate path to the ApLab folder (i.e., the main folder where this program is located);
     ***  Notes:
     *         Omit final slash.  Do not enclose in quotes;     
     **        Depending on your environment, SLASHES may need TO BE FORWARD (/).  
     *              If so, please contact lead programmer as workplan will need to be altered
     *
     *         EXAMPLE  %let progroot = \\aaa\bbb\ApLab;
     *;
     ***************************************************************************************************************;    
     
     ***************************************************************************************************************;
     ***2.  Indicate location and name of raw AP lab data SAS file
     ***       EXAMPLE %let rawloc = \\aaa\bb\cc;
     ***               %let rawfilenm = xyz;  /***name of sas file, without extension***/
     ***;
     ***************************************************************************************************************;

********************************************************************************************************************;
*             END User Inputs                          *;
********************************************************************************************************************;

%put progroot &progroot.  rawloc &rawloc. rawfilenm &rawfilenm.;

options formchar='|-++++++++++=|-/|<>*' ;
options noquotelenmax errorabend;

%let proj = ApLab;
title1 "Acute Pancreatitis";
title2 "Process Lab data";
footnote1 "&proj.";	  
options macrogen mprint mlogic errorabend;

libname rawlib "&rawloc";
libname local "&progroot.\local";
libname share "&progroot.\share";

%let pdfout = &progroot.\Review;
%let xlout = &progroot.\Review;

%include "&progroot.\input\deletefile.sas";

proc contents data = rawlib.&rawfilenm.;
run;

***dedupe raw file***;
proc sort data = rawlib.&rawfilenm. noduprecs out = LabsRaw;;
   by EVENTID;
run;

***Create labeled file with all labs***;
data local.LabsAll (label = "Acute Pancreatitis Labs Deduped, All records") ;
     set LabsRaw;
     label EVENTID = "EVENTID: unique patient identifier. Similar to study ID"
          TEST_TYPE	      = "TEST_TYPE: VDW-specific classification of laboratory results"
          LOINC	      = "LOINC: Logical Observation Identifiers Names and Codes"
          PT_LOC	      = "PT_LOC: Location of the patient when the lab specimen was obtained"
          PX	           = "PX: Procedure Code"
          PX_CODETYPE	 = "PX_CODETYPE: Type of the procedure code"
          ORDER_DT_OFFSET = "ORDER_DT_OFFSET: Difference (number of days) between date lab test ordered and event date"
          LAB_DT_OFFSET   = "LAB_DT_OFFSET: Difference (number of days) between date specimen was collected and event date"
          LAB_TM	      = "LAB_TM: Time that the specimen was collected"
          RESULT_DT_OFFSET= "RESULT_DT_OFFSET: Difference (number of days) between date test was resulted and event date"
          RESULT_TM	      = "RESULT_TM: Time that the specimen was resulted"
          RESULTS	      = "RESULTS: The result of the test .  This variable works in conjunction with the Modifier variable"
          MODIFIER	      = "MODIFIER: Modifies the value stored in the Result_C field"
          RESULT_UNIT	 = "RESULT_UNIT: The units in which the result is reported after basic standardizations have been applied" 
          NORMAL_LOW_C	 = "NORMAL_LOW_C: Lowest value still considered normal for test. Works in conjunction with Modifier_Low variable"
          MODIFIER_LOW	 = "MODIFIER_LOW: Modifies the value stored in the Normal_Low_C field"
          NORMAL_HIGH_C	 = "NORMAL_HIGH_C: Highest value still considered normal for test. Works in conjunction with Modifer_High variable"
          MODIFIER_HIGH	 = "MODIFIER_HIGH: Modifies the value stored in the Normal_High_C field"
          ABN_IND	      = "ABN_IND: Indicates whether the test result is abnormal"
          ORD_DEPT	      = "ORD_DEPT: The department or specialty in which the order took place"
          FACILITY_CODE	 = "FACILITY_CODE: A code indicating the facility, hospital, or clinic in which the lab order originated" ;
run;

***break into amylase and lipase files***;
data local.LabsAmylase (label = "Acute Pancreatitis Labs Deduped, AMYLASE ONLY")
     local.LabsLipase (label = "Acute Pancreatitis  Labs Deduped, LIPASE ONLY");
     set local.LabsAll;
     if tEST_TYPE = 'AMYLASE' then output local.LabsAmylase;
     else output local.LabsLipase;
run;

***create review files***;
%macro prntit(filenm);
     ods listing close;
     filename pdfall "&pdfout.\&filenm.\&filenm.Contents.pdf";  
     ods pdf file=pdfall uniform style=analysis pdftoc=1;
        proc contents data =local.&filenm.;
        run;
     ods pdf  close;
          
     %LET xlfile = &xlout.\&filenm.\&filenm.Contents.xlsx;
     ods excel file = "&XLFILE."  	style=pearl;
           ods excel 	options(sheet_name="&filenm.Contents" embedded_titles='yes');
          proc contents data =local.&filenm.;
         run;
     ods excel close;
     
     data rpt;
          set local.&filenm. (drop = LAB_TM result_tm  eventid);
     run;
     
     filename pdfall "&pdfout.\&filenm.\&filenm.Freqs.pdf";  
     ods pdf file=pdfall uniform style=analysis pdftoc=1;
        proc freq data =rpt;
        run;
     ods pdf  close;          
     
     %LET xlfile = &xlout.\&filenm.\&filenm.Freqs.xlsx;
     ods excel file = "&XLFILE."  	style=pearl;
           ods excel 	options(sheet_name="&filenm.Freqs" embedded_titles='yes');
          proc freq data =rpt;
         run;
     ods excel close;
     
         
     filename pdf "&pdfout.\&filenm.\&filenm.Means.pdf";  
     ods pdf file=pdf uniform style=analysis pdftoc=1;
          proc means data = local.&filenm. ;
          run;
     ods pdf  close;
         
         
     %LET xlfile = &xlout.\&filenm.\&filenm.Means.xlsx;
     ods excel file = "&XLFILE."  	style=pearl;
           ods excel 	options(sheet_name="&filenm.Means" embedded_titles='yes');
          proc means data =rpt;
         run;
     ods excel close;
     
     %deletefile(rpt);
     
     filename pdf "&pdfout.\&filenm.\&filenm.TenRecords.pdf";  
     ods pdf file=pdf uniform style=analysis pdftoc=1;
           proc print data = local.&filenm. (obs = 10);
            run;
     ods pdf  close;
            
     %LET xlfile = &xlout.\&filenm.\&filenm.TenRecords.xlsx;
     ods excel file = "&XLFILE."  	style=pearl;
           ods excel 	options(sheet_name="&filenm.Print" embedded_titles='yes');
            proc print data = local.&filenm. (obs = 10);
         run;
     ods excel close;
     ODS listing; 

%mend prntit;
%prntit(LabsAll);
%prntit(LabsAmylase);
%prntit(LabsLipase);

***create covariates***;

data ap;
     set local.LabsAll (keep = eventid lab_dt_offset results test_type);
     label LIPASE_3XULN_7BEF_7AFT_DTL = "LIPASE_3XULN_7BEF_7AFT_DTL: Lip >= 3x ULN (ULN=300; 3x300=900) 7d before-7d after Index (tot 15d pd. Detail. 0/1, 1=Yes)"
          LIPASE_3XULN_14BEF_14AFT_DTL = "LIPASE_3XULN_14BEF_14AFT_DTL:  Lip >= 3x ULN (ULN=300; 3x300=900) 14d before-14d after Index (tot 29d pd. Detail. 0/1, 1=Yes)"          
          AMYL_3XULN_7BEF_7AFT_DTL = "AMYL_3XULN_7BEF_7AFT_DTL: amylase >= 3x ULN (300) 7d before-7d after Index (in all, a 15-day pd. Detail. 0/1, 1=Yes)"
          AMYL_3XULN_14BEF_14AFT_DTL = "AMYL_3XULN_14BEF_14AFT_DTL: amylase >= 3x ULN (300) 14d before-14d after Index (in all, a 29-day pd. Detail. 0/1, 1=Yes)"
          APLAB_3XULN_7BEF_7AFT_DTL = "APLAB_3XULN_7BEF_7AFT_DTL: amyl or lip >= 3x ULN 7d before-7d after Index (in all, a 15-day pd. Detail. 0/1, 1=Yes)"
          APLAB_3XULN_14BEF_14AFT_DTL = "APLAB_3XULN_14BEF_14AFT_DTL: amyl or lip >= 3x ULN 14d before-14d after Index (in all, a 29-day pd. Detail. 0/1, 1=Yes)"
	     ;
     LIPASE_3XULN_7BEF_7AFT_DTL = 0;
     LIPASE_3XULN_14BEF_14AFT_DTL = 0;
     AMYL_3XULN_7BEF_7AFT_DTL = 0;
     AMYL_3XULN_14BEF_14AFT_DTL = 0;
     APLAB_3XULN_7BEF_7AFT_DTL =0;
     APLAB_3XULN_14BEF_14AFT_DTL =0;
      
     if test_type= 'LIPASE' then do;
          if results ge 900 then do;
               if -7 le lab_dt_offset le 7 then LIPASE_3XULN_7BEF_7AFT_DTL = 1; /***7 days before to 7 days after Index ***/
               if -14 le lab_dt_offset le 14 then LIPASE_3XULN_14BEF_14AFT_DTL = 1;
          end;
     end;
     if test_type= 'AMYLASE' then do;
          if results ge 300 then do;
               if -7 le lab_dt_offset le 7 then AMYL_3XULN_7BEF_7AFT_DTL = 1; /***7 days before to 7 days after Index ***/
               if -14 le lab_dt_offset le 14 then AMYL_3XULN_14BEF_14AFT_DTL = 1;
          end;
     end;
     if LIPASE_3XULN_7BEF_7AFT_DTL = 1 or AMYL_3XULN_7BEF_7AFT_DTL = 1 then APLAB_3XULN_7BEF_7AFT_DTL = 1;
     if LIPASE_3XULN_14BEF_14AFT_DTL = 1 or AMYL_3XULN_14BEF_14AFT_DTL = 1 then APLAB_3XULN_14BEF_14AFT_DTL = 1;
run; 

%macro MakeSumFlags(var);  /***create summary flags for sum file***/
     proc sql;
          create table Sum&var. as
          select distinct eventid, &var._DTL as &var.
          from ap
          where &var._DTL = 1
          group by eventid;
     quit;
     proc sql;
          create table ap2 as
          select a.*, m.&Var.
          from ap a
          left join Sum&var. m
          on a.eventid = m.eventid;
     quit;
     
     data ap;
          set ap2;
          if &var. = . then &var. = 0;
     run;
     %deletefile(ap2);
     %deletefile(Sum&var.);
   
%mend MakeSumFlags;
%MakeSumFlags(AMYL_3XULN_7BEF_7AFT);
%MakeSumFlags(AMYL_3XULN_14BEF_14AFT);
%MakeSumFlags(LIPASE_3XULN_7BEF_7AFT);
%MakeSumFlags(LIPASE_3XULN_14BEF_14AFT);
%MakeSumFlags(APLAB_3XULN_7BEF_7AFT);
%MakeSumFlags(APLAB_3XULN_14BEF_14AFT);

data ap;
     set ap;
     label LIPASE_3XULN_7BEF_7AFT = "LIPASE_3XULN_7BEF_7AFT: Lip >= 3x ULN (ULN=300; 3x300=900) 7d before-7d after Index (tot 15d pd. 0/1, 1=Yes)"
          LIPASE_3XULN_14BEF_14AFT = "LIPASE_3XULN_14BEF_14AFT:  Lip >= 3x ULN (ULN=300; 3x300=900) 14d before-14d after Index (tot 29d pd. 0/1, 1=Yes)"          
          AMYL_3XULN_7BEF_7AFT = "AMYL_3XULN_7BEF_7AFT: amylase >= 3x ULN (300) 7d before-7d after Index (in all, a 15-day pd. 0/1, 1=Yes)"
          AMYL_3XULN_14BEF_14AFT = "AMYL_3XULN_14BEF_14AFT: amylase >= 3x ULN (300) 14d before-14d after Index (in all, a 29-day pd. 0/1, 1=Yes)"
          APLAB_3XULN_7BEF_7AFT = "APLAB_3XULN_7BEF_7AFT: amyl or lip >= 3x ULN 7d before-7d after Index (in all, a 15-day pd. 0/1, 1=Yes)"
          APLAB_3XULN_14BEF_14AFT = "APLAB_3XULN_14BEF_14AFT: amyl or lip >= 3x ULN 14d before-14d after Index (in all, a 29-day pd. 0/1, 1=Yes)"
	     ;
run;
     

%macro CalcMinMaxOffset(MaxVar,MinVar);
     ***calc max Lab_dt_offset and min Lab_dt_offset, for lipase amylase and aplabs***;
     proc sql;
          create table &MaxVar. as
          select eventid, max(lab_dt_offset) as &MaxVar.
          from ap&test_type.
          group by eventid;
     quit;
     
     proc sql;
          create table &MinVar. as
          select eventid, min(lab_dt_offset) as &MinVar.
          from ap&test_type.
          group by eventid;
     quit;
     
     proc sql;
          create table ap2 as
          select a.*, m.&MaxVar., n.&MinVar.
          from ap a
          left join &MaxVar. m
          on a.eventid = m.eventid
          left join &MinVar. n
          on a.eventid = n.eventid;
     quit;
     
     data ap;
          set ap2;
     run;
     %deletefile(ap2);
     %deletefile(&MaxVar.);
     %deletefile(&MinVar.);
     
%mend CalcMinMaxOffset;

%let test_type = ;
%CalcMinMaxOffset(MaxVar = APLAB_LAB_DT_OFFSET_MAX, MinVar = APLAB_LAB_DT_OFFSET_MIN);

%let test_type =LIPASE ;
data ap&test_type.;
     set ap;
     where test_type= "&test_type.";
run;
%CalcMinMaxOffset(MaxVar=LIPASE_LAB_DT_OFFSET_MAX, MinVar= LIPASE_LAB_DT_OFFSET_MIN);

%let test_type = AMYLASE;
data ap&test_type.;
     set ap;
     where test_type= "&test_type.";
run;

%CalcMinMaxOffset(MaxVar=AMYLASE_LAB_DT_OFFSET_MAX, MinVar= AMYLASE_LAB_DT_OFFSET_MIN);

%macro CalcMax(var,MaxVar,CtVar);
     proc sql;
          create table max&var. as
          select eventid, max(results) as &MaxVar.
          from ap
          where &var. = 1
          group by eventid;
     quit;
     proc sql;
          create table ap2 as
          select a.*, m.&MaxVar.
          from ap a
          left join max&var. m
          on a.eventid = m.eventid;
     quit;
     
     data ap;
          set ap2;
     run;
     %deletefile(ap2);
     %deletefile(max&var.);
     proc sort data = ap (where = (&var. = 1)) nodupkey out = ct;
          by eventid lab_dt_offset;
     run;
     proc sql;
          create table ct&var. as
          select eventid, count(lab_dt_offset) as &CtVar.
          from ct         
          group by eventid;
     quit;
     proc sql;
          create table ap2 as
          select a.*, m.&CtVar.
          from ap a
          left join ct&var. m
          on a.eventid = m.eventid;
     quit;
     
     data ap;
          set ap2;
          if &CtVar. = . then &CtVar. = 0;
     run;
  
     %deletefile(ap2);
     %deletefile(ct&var.);
     %deletefile(ct);
     
%mend CalcMax;
%CalcMax(AMYL_3XULN_7BEF_7AFT,AMYL_MAX_7BEF_7AFT,AMYL_NDAYS_3XULN_7BEF_7AFT);
%CalcMax(AMYL_3XULN_14BEF_14AFT,AMYL_MAX_14BEF_14AFT,AMYL_NDAYS_3XULN_14BEF_14AFT);
%CalcMax(LIPASE_3XULN_7BEF_7AFT,LIPASE_MAX_7BEF_7AFT,LIPASE_NDAYS_3XULN_7BEF_7AFT);
%CalcMax(LIPASE_3XULN_14BEF_14AFT,LIPASE_MAX_14BEF_14AFT,LIPASE_NDAYS_3XULN_14BEF_14AFT);
%CalcMax(APLAB_3XULN_7BEF_7AFT,APLAB_MAX_7BEF_7AFT,APLAB_NDAYS_3XULN_7BEF_7AFT);
%CalcMax(APLAB_3XULN_14BEF_14AFT,APLAB_MAX_14BEF_14AFT,APLAB_NDAYS_3XULN_14BEF_14AFT);

data local.LabsCovariates (label = "Acute Pancreatitis Labs with Covariates, all records") ;;
     set ap;
     label LIPASE_MAX_7BEF_7AFT = "LIPASE_MAX_7BEF_7AFT: Max lip lab 7d before-7d after Index (tot 15d pd)"
          LIPASE_MAX_14BEF_14AFT = "LIPASE_MAX_14BEF_14AFT: Max lip lab 14d before-14d after Index (tot 29d pd)"
          LIPASE_NDAYS_3XULN_7BEF_7AFT= "LIPASE_NDAYS_3XULN_7BEF_7AFT: # of distinct collection dates (calendar) from 7d before-7d after Index Date with lip labs >= 3x ULN."
          LIPASE_NDAYS_3XULN_14BEF_14AFT= "LIPASE_NDAYS_3XULN_14BEF_14AFT: # of distinct collection dates (calendar) from 14d before-14d after Index Date with lip labs >= 3x ULN."
          AMYL_MAX_7BEF_7AFT = "AMYL_MAX_7BEF_7AFT: Max amyl lab 7d before-7d after Index (tot 15d pd)"
          AMYL_MAX_14BEF_14AFT = "AMYL_MAX_14BEF_14AFT: Max amyl lab 14d before-14d after Index (tot 29d pd)"
          AMYL_NDAYS_3XULN_7BEF_7AFT= "AMYL_NDAYS_3XULN_7BEF_7AFT: # of distinct collection dates (calendar) from 7d before-7d after Index Date with amyl labs >= 3x ULN."
          AMYL_NDAYS_3XULN_14BEF_14AFT= "AMYL_NDAYS_3XULN_14BEF_14AFT: # of distinct collection dates (calendar) from 14d before-14d after Index Date with amyl labs >= 3x ULN."
          APLAB_MAX_7BEF_7AFT = "APLAB_MAX_7BEF_7AFT: Max amyl or lip lab 7d before-7d after Index (tot 15d pd)"
          APLAB_MAX_14BEF_14AFT = "APLAB_MAX_14BEF_14AFT: Max amyl or lip lab 14d before-14d after Index (tot 29d pd)"
          APLAB_NDAYS_3XULN_7BEF_7AFT= "APLAB_NDAYS_3XULN_7BEF_7AFT: # of distinct collection dates (calendar) from 7d before-7d after Index Date with amyl or lip labs >= 3x ULN."
          APLAB_NDAYS_3XULN_14BEF_14AFT= "APLAB_NDAYS_3XULN_14BEF_14AFT: # of distinct collection dates (calendar) from 14d before-14d after Index Date with amyl or lip labs >= 3x ULN."
          APLAB_LAB_DT_OFFSET_MAX  = "APLAB_LAB_DT_OFFSET_MAX: Maximum Lab_dt_offset, any amyl or lip lab"
          APLAB_LAB_DT_OFFSET_MIN  = "APLAB_LAB_DT_OFFSET_MIN: Minimum Lab_dt_offset, any amyl or lip lab"
          LIPASE_LAB_DT_OFFSET_MAX = "LIPASE_LAB_DT_OFFSET_MAX: Maximum Lab_dt_offset, any lip lab"
          LIPASE_LAB_DT_OFFSET_MIN = "LIPASE_LAB_DT_OFFSET_MIN: Minimum Lab_dt_offset, any lip lab" 
          AMYLASE_LAB_DT_OFFSET_MAX= "AMYLASE_LAB_DT_OFFSET_MAX: Maximum Lab_dt_offset, any amyl lab"
          AMYLASE_LAB_DT_OFFSET_MIN= "AMYLASE_LAB_DT_OFFSET_MIN: Minimum Lab_dt_offset, any amyl lab" 
;    
run;

%macro prntit(filenm);
     ods listing close;
     filename pdfall "&pdfout.\&filenm.\&filenm.Contents.pdf";  
     ods pdf file=pdfall uniform style=analysis pdftoc=1;
        proc contents data =local.&filenm.;
        run;
     ods pdf  close;
          
     %LET xlfile = &xlout.\&filenm.\&filenm.Contents.xlsx;
     ods excel file = "&XLFILE."  	style=pearl;
           ods excel 	options(sheet_name="&filenm.Contents" embedded_titles='yes');
          proc contents data =local.&filenm.;
         run;
     ods excel close;
     
     data rpt;
          set local.&filenm. (drop = eventid results lab_dt_offset);
     run;
     
     filename pdfall "&pdfout.\&filenm.\&filenm.Freqs.pdf";  
     ods pdf file=pdfall uniform style=analysis pdftoc=1;
        proc freq data =rpt;
        run;
     ods pdf  close;          
     
     %LET xlfile = &xlout.\&filenm.\&filenm.Freqs.xlsx;
     ods excel file = "&XLFILE."  	style=pearl;
           ods excel 	options(sheet_name="&filenm.Freqs" embedded_titles='yes');
          proc freq data =rpt;
         run;
     ods excel close;    
         
     filename pdf "&pdfout.\&filenm.\&filenm.Means.pdf";  
     ods pdf file=pdf uniform style=analysis pdftoc=1;
          proc means data = local.&filenm. ;
          run;
     ods pdf  close;
         
     %LET xlfile = &xlout.\&filenm.\&filenm.Means.xlsx;
     ods excel file = "&XLFILE."  	style=pearl;
           ods excel 	options(sheet_name="&filenm.Means" embedded_titles='yes');
          proc means data =rpt;
         run;
     ods excel close;
     
     %deletefile(rpt);
     
     proc sort data = local.&filenm. out = rpt2;
          by eventid lab_dt_offset;
     run;
            
     filename pdf "&pdfout.\&filenm.\&filenm.100Records.pdf";  
     ods pdf file=pdf uniform style=analysis pdftoc=1;
           proc print data = rpt2 (obs = 100);
               by eventid;
            run;
     ods pdf  close;
            
     %LET xlfile = &xlout.\&filenm.\&filenm.100Records.xlsx;
          ods excel file = "&XLFILE."  	style=pearl;
          ods excel options(sheet_name='#byval1');
          proc print data = rpt2 (obs = 100);
               by eventid;
          run;
     ods excel close;
     ODS listing; 

%mend prntit;
%prntit(LabsCovariates);


***create covariates summary***;
proc sort data = local.LabsCovariates (drop = lab_dt_offset results test_type AMYL_3XULN_7BEF_7AFT_DTL 
     AMYL_3XULN_14BEF_14AFT_DTL LIPASE_3XULN_7BEF_7AFT_DTL LIPASE_3XULN_14BEF_14AFT_DTL APLAB_3XULN_7BEF_7AFT_DTL APLAB_3XULN_14BEF_14AFT_DTL) nodupkey 
     out = share.LabsCovariatesSum (label = "Acute Pancreatitis Labs Covariate Summary (one record per eventid)") ;;
     by eventid;
run; 

%macro prntit(filenm);
     ods listing close;
     filename pdfall "&pdfout.\&filenm.\&filenm.Contents.pdf";  
     ods pdf file=pdfall uniform style=analysis pdftoc=1;
        proc contents data =share.&filenm.;
        run;
     ods pdf  close;
          
     %LET xlfile = &xlout.\&filenm.\&filenm.Contents.xlsx;
     ods excel file = "&XLFILE."  	style=pearl;
           ods excel 	options(sheet_name="&filenm.Contents" embedded_titles='yes');
          proc contents data =share.&filenm.;
         run;
     ods excel close;
     
     data rpt;
          set share.&filenm. (drop = eventid);
     run;
     
     filename pdfall "&pdfout.\&filenm.\&filenm.Freqs.pdf";  
     ods pdf file=pdfall uniform style=analysis pdftoc=1;
        proc freq data =rpt;
        run;
     ods pdf  close;          
     
     %LET xlfile = &xlout.\&filenm.\&filenm.Freqs.xlsx;
     ods excel file = "&XLFILE."  	style=pearl;
           ods excel 	options(sheet_name="&filenm.Freqs" embedded_titles='yes');
          proc freq data =rpt;
         run;
     ods excel close;    
         
     filename pdf "&pdfout.\&filenm.\&filenm.Means.pdf";  
     ods pdf file=pdf uniform style=analysis pdftoc=1;
          proc means data = share.&filenm. ;
          run;
     ods pdf  close;
         
     %LET xlfile = &xlout.\&filenm.\&filenm.Means.xlsx;
     ods excel file = "&XLFILE."  	style=pearl;
           ods excel 	options(sheet_name="&filenm.Means" embedded_titles='yes');
          proc means data =rpt;
         run;
     ods excel close;
     
     %deletefile(rpt);
     
     proc sort data = share.&filenm. out = rpt2;
          by eventid;
     run;
            
     filename pdf "&pdfout.\&filenm.\&filenm.100Records.pdf";  
     ods pdf file=pdf uniform style=analysis pdftoc=1;
           proc print data = rpt2 (obs = 100);
            run;
     ods pdf  close;
            
     %LET xlfile = &xlout.\&filenm.\&filenm.100Records.xlsx;
          ods excel file = "&XLFILE."  	style=pearl;
          ods excel options(sheet_name='#byval1');
          proc print data = rpt2 (obs = 100);
          run;
     ods excel close;
     ODS listing; 

%mend prntit;
%prntit(LabsCovariatesSum);




