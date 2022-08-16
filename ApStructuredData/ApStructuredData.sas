********************************************************
***Program:  ApStructuredData.sas
***   Sentinel Acute Pancreatitis Structured Data       	
***
***     Purpose:
***        Pull AP structured data 
***
***  Dependencies:
***       Population file (Studyid, mrn and patid as identifiers)
***       Sentinel data (scdm)
***       HCSRN Vdw data 
***       files from input folder
***
***  Process:
***       1. Complete User Inputs section
***       2. Run this program.  Check log for e*r*r*ors
***       3. Return contents of Share folder 
***
********************************************************;

********************************************************************************************************************;
*                 User Inputs                          
*
*  Notes:
*      1. USE BACK-SLASHES.  Omit final slashes.  Do not enclose inputs in quotes unless indicated;     
*      2. Depending on your environment, SLASHES may need TO BE FORWARD (/).  If so, please contact lead 
*              programmer as workplan will need to be altered
********************************************************************************************************************;

     ***************************************************************************************************************;
     *** 1.  Add %let progroot to indicate path to the ApStructuredData folder (i.e., the main folder where this program is located);
     *
     *         EXAMPLE  %let progroot = \\aaa\bbb\ApStructuredData;
     ***************************************************************************************************************;

     
     ***************************************************************************************************************;
     * 2. Add %let scdm to indicate folder containing SCDM tables ;
     *    
     *    EXAMPLE   %let scdm = \\ourdata\xyz;
     ***************************************************************************************************************;
          

     ***************************************************************************************************************;
     * 3. Add %include to indicate location of vdw stdvars.  Use quotes around string ;
     *    
     *    EXAMPLE %include '\\xxx\yyy\StdVars.sas';
     ***************************************************************************************************************;
          

     ***************************************************************************************************************;
     * 4. Add %let poploc to indicate location of pre-identified population file ;    
     *
     *    EXAMPLE %let poploc =  \\aaa\bbb; ***/
     ***************************************************************************************************************;
          

     ***************************************************************************************************************;
     * 5. Add %popnm to indicate name of pre-identified population file (sas dataset.  do not include sas7bdat extension);   
     *
     *    EXAMPLE %let popnm =  AP_STRUCTURED_INPUT_DATA20211213; 
     ***************************************************************************************************************;

     ***************************************************************************************************************;
     * 6. Add %labloc to indicate location of local folder of ApLab workplan;   
     *
     *    EXAMPLE %let labloc =   \\aaa\bbb\ApLab\local; ; 
     ***************************************************************************************************************;
 
********************************************************************************************************************;
*             END User Inputs                          *;
********************************************************************************************************************;

%put progroot &progroot.  scdm= &scdm.;

options formchar='|-++++++++++=|-/|<>*' ;
options noquotelenmax ;

%let proj = Sentinel Machine Learning Algorithm Development of Acute Pancreatitis; 
%let mainprog = ApStructuredData;
title1 "&proj. ";
footnote1 "Sentinel workplan: &mainprog. For questions, contact lead programmer";	  
    
%let input =&progroot.\input;
%let phiinterim= &progroot.\local\PHI_Interim;
%let xwalk = &progroot.\local\PHI_Link;
%let basic= &progroot.\local\No_PHI\basic;
%let clean= &progroot.\local\No_PHI\clean;
%let final= &progroot.\local\No_PHI\final;
%let share= &progroot.\share;

libname input "&input.";
libname basic "&basic.";
libname clean "&clean.";
libname final "&final.";
libname local "&progroot.\local";
libname share "&progroot.\share";
libname scdm "&scdm.";
libname phiint "&phiinterim.";
libname xwalk "&xwalk."; 
libname pop "&poploc."; 
libname lab "&labloc.";
     
***bring in programs we will call***;
%include "&input.\AddFlag.sas" /source2;
%include "&input.\AddVar.sas" /source2;
%include "&input.\AddDate.sas" /source2;
%include "&input.\deletefile.sas" /source2;
%include "&input.\ExcelPrint.sas";
%include "&input.\MakeCount.sas";
%include "&input.\GetDemog.sas" /source2;
%include "&input.\GetDx.sas" /source2;
%include "&input.\GetVitalsigns.sas" /source2;
%include "&input.\age.sas";
%include "&input.\continuousenr.sas";
%include "&input.\GetSocialHistory.sas" /source2;
%include "&input.\GetDx.sas" /source2;
%include "&input.\createtriplet.sas" /source2;
%include "&input.\GetPx.sas" /source2;

* Destination pdf directory path and names;
filename pdffinc "&share./FinalFileContents.pdf";
filename pdffinf "&share./FinalFileFreqs.pdf";
filename pdfclnc "&share./CleanFileContents.pdf";
filename pdfclnf "&share./CleanFileFreqs.pdf";

***ODS listing for sites with environment that turn it off***;
ODS listing;

* Set date macro vars;
data _null_ ; 
     st=datetime();
     rundate = today();
     call symput ("rundate",put(rundate,date9.));
run;

%put rundate = &rundate.;

***save lst out to share***;
proc printto print="&share./&mainprog._&rundate..lst" new ;
run;	
     
%global popidentifier;
%let popidentifier = STUDYID;  /***for addflag, addvar, other macros ***/

%let outfile = FDA_AP_KPNW_Struct_Covs;

proc contents data = pop.&popnm.;
run;
                                         
***Read in identified population.  save what we need in ApStructuredData folder**;
data clean.&outfile. (drop = patid mrn)  /***begin our data file***/
     xwalk.SampleXwalk (label = "&proj. sample crosswalk (patid to studyid plus mrn)");  /***save a local version of the crosswalk***/
     set pop.&popnm.;
     ***create group to ease logic.  will not be saved to final file**;
     if group1 = 1 then Group = 1;
     else if group2 = 1 then Group = 2;
     else Group = 3;
     Label Group = "Group:  patient group (1=IP/2=ED/3=OP,AV)"
           STUDYID        = "STUDYID: Study ID"     
           EVENTDTE_START = "EVENTDTE_START: Start date of the study-qualifying encounter"
           EVENTDTE_END   = "EVENTDTE_END: End date of the study-qualifying encounter"
           GROUP1        =  "GROUP1: Is sampling group IP?  (0/1, 1=Yes)"
           GROUP2        =  "GROUP2:Is sampling group ED?  (0/1, 1=Yes)"
           GROUP3         = "GROUP3:  Is sampling group OP/AV? (0/1, 1=Yes)"      
           UPCLASS_EDIP   = "UPCLASS_EDIP: Is care setting up-classified to ED/IP? (0/1, 1=Yes)"  
           ENRLYEARS      = "ENRLYEARS: # years of continuous enrollment in Group Practice HMO prior to EVENTDTE_START";
 run;

***pull demog***;
%GetDemog(inpop = xwalk.SampleXwalk, inset= scdm.demographic, outset = basic.demog) ;

 ***add vars and flags***;
%AddVar(updateset = clean.&outfile., varset = basic.demog, var = AGE_AT_EVENT_IN_YRS);
%AddFlag(updateset = clean.&outfile., varset = basic.demog, var = SEXF);
%AddVar(updateset = clean.&outfile., varset = basic.demog, var = SEX);
%AddVar(updateset = clean.&outfile., varset = basic.demog, var = RACE);
%AddVar(updateset = clean.&outfile., varset = basic.demog, var = HISPANIC);
%AddFlag(updateset = clean.&outfile., varset = basic.demog, var = RACE_UNK);
%AddFlag(updateset = clean.&outfile., varset = basic.demog, var = RACE_AIAN);
%AddFlag(updateset = clean.&outfile., varset = basic.demog, var = RACE_ASIAN);
%AddFlag(updateset = clean.&outfile., varset = basic.demog, var = RACE_AA);
%AddFlag(updateset = clean.&outfile., varset = basic.demog, var = RACE_PI);
%AddFlag(updateset = clean.&outfile., varset = basic.demog, var = RACE_WHITE); 

%GetVitalsigns(inpop = xwalk.SampleXwalk, inset= scdm.vital_sign, outset = basic.vitals) ;

%GetSocialHistory(inpop = xwalk.SampleXwalk, inset= &_vdw_social_hx, outset = basic.SocHist) ;
%AddVar(updateset = clean.&outfile., varset = basic.SocHist, var = tobacco_use);
%AddFlag(updateset = clean.&outfile., varset = basic.SocHist, var = SMOKE_FORMER_SELF_365);
%AddFlag(updateset = clean.&outfile., varset = basic.SocHist, var = SMOKE_CURR_SELF_365);

%GetDx(codelist = input.ApCodeList,inpop = xwalk.SampleXwalk, inset= scdm.diagnosis, outset = basic.dx) ;   

%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = SMOKE_DX);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = SMOKE_DX_365);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = ALC);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = APPENDIC);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = ASCITES);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = CHR_PANCR);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = CONSTIPATION);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = DIVERTICUL);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = DKA);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = ERCP);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = ESOPHAGITIS);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = FOOD_POIS);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = GAL_BIL);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = GASTRITIS);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = GASTRO);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = GB_CANCER);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = GERD);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = HEPATITIS);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = IBD);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = ILEUS);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = INFLUENZA);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = INTEST_OBS);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = MESENT_ISCH);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = MYOCARD_ISCH);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = NEPHROLITH);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = PANC_CNCR);
%AddFlag(updateset = clean.&outfile., varset = basic.dx, var = PEPTIC_ULCER);

***create clean version to manipulate before adding triplets***;
data clean.dx;
     set basic.dx;
run;
    
%createtriplet(updateset = clean.dx, var = ALC);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = ALC_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = ALC_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = ALC_PY);

%createtriplet(updateset = clean.dx, var = APPENDIC);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = APPENDIC_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = APPENDIC_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = APPENDIC_PY);

%createtriplet(updateset = clean.dx, var = ASCITES);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = ASCITES_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = ASCITES_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = ASCITES_PY);

%createtriplet(updateset = clean.dx, var = CHR_PANCR);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = CHR_PANCR_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = CHR_PANCR_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = CHR_PANCR_PY);
     
%createtriplet(updateset = clean.dx, var = CONSTIPATION);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = CONSTIPATION_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = CONSTIPATION_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = CONSTIPATION_PY);
     
%createtriplet(updateset = clean.dx, var = DIVERTICUL);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = DIVERTICUL_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = DIVERTICUL_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = DIVERTICUL_PY);
    
%createtriplet(updateset = clean.dx, var = DKA);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = DKA_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = DKA_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = DKA_PY);
              
%createtriplet(updateset = clean.dx, var = ESOPHAGITIS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = ESOPHAGITIS_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = ESOPHAGITIS_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = ESOPHAGITIS_PY);
     
%createtriplet(updateset = clean.dx, var = FOOD_POIS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = FOOD_POIS_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = FOOD_POIS_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = FOOD_POIS_PY);
     
%createtriplet(updateset = clean.dx, var = GAL_BIL);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GAL_BIL_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GAL_BIL_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GAL_BIL_PY);
     
%createtriplet(updateset = clean.dx, var = GASTRITIS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GASTRITIS_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GASTRITIS_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GASTRITIS_PY);
     
%createtriplet(updateset = clean.dx, var = GASTRO);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GASTRO_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GASTRO_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GASTRO_PY);
     
%createtriplet(updateset = clean.dx, var = GB_CANCER);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GB_CANCER_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GB_CANCER_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GB_CANCER_PY);
     
%createtriplet(updateset = clean.dx, var = GERD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GERD_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GERD_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = GERD_PY);
     
%createtriplet(updateset = clean.dx, var = HEPATITIS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = HEPATITIS_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = HEPATITIS_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = HEPATITIS_PY);
     
%createtriplet(updateset = clean.dx, var = HYPERTRIG);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = HYPERTRIG_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = HYPERTRIG_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = HYPERTRIG_PY);

%createtriplet(updateset = clean.dx, var = IBD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = IBD_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = IBD_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = IBD_PY);
     
%createtriplet(updateset = clean.dx, var = ILEUS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = ILEUS_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = ILEUS_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = ILEUS_PY);

%createtriplet(updateset = clean.dx, var = INFLUENZA);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = INFLUENZA_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = INFLUENZA_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = INFLUENZA_PY);
   
%createtriplet(updateset = clean.dx, var = INTEST_OBS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = INTEST_OBS_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = INTEST_OBS_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = INTEST_OBS_PY);
     
%createtriplet(updateset = clean.dx, var = MESENT_ISCH);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = MESENT_ISCH_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = MESENT_ISCH_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = MESENT_ISCH_PY);
     
%createtriplet(updateset = clean.dx, var = MYOCARD_ISCH);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = MYOCARD_ISCH_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = MYOCARD_ISCH_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = MYOCARD_ISCH_PY);
     
%createtriplet(updateset = clean.dx, var = NEPHROLITH);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = NEPHROLITH_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = NEPHROLITH_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = NEPHROLITH_PY);
     
%createtriplet(updateset = clean.dx, var = PANC_CNCR);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = PANC_CNCR_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = PANC_CNCR_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = PANC_CNCR_PY);
     
%createtriplet(updateset = clean.dx, var = PEPTIC_ULCER);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = PEPTIC_ULCER_SD);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = PEPTIC_ULCER_CS);
%AddFlag(updateset = clean.&outfile., varset = clean.dx, var = PEPTIC_ULCER_PY);
     
%GetPx(codelist = input.ApCodeList,inpop = xwalk.SampleXwalk, inset= scdm.procedure, outset = basic.px) ;   
%AddFlag(updateset = clean.&outfile., varset = basic.px, var = SMOKE_PX);
%AddFlag(updateset = clean.&outfile., varset = basic.px, var = SMOKE_PX_365);
%AddFlag(updateset = clean.&outfile., varset = basic.px, var = ABDIMG_CT);
%AddFlag(updateset = clean.&outfile., varset = basic.px, var = ABDIMG_MR);
%AddFlag(updateset = clean.&outfile., varset = basic.px, var = ABDIMG_CT_14);
%AddFlag(updateset = clean.&outfile., varset = basic.px, var = ABDIMG_MR_14);

data clean.&outfile.;
     set clean.&outfile.;
     SMOKE_DX_PX_365 = 0;
     if SMOKE_PX_365 = 1 or SMOKE_DX_365 = 1 then SMOKE_DX_PX_365 = 1;
     label SMOKE_DX_PX_365 = "SMOKE_DX_PX_365: Diagnosis or procedure indicating current smoker status in the past year (0/1, 1=Yes)";
run;


***add Ap lab fields***;
**proc contents data = lab.labscovariates;
title4 'Labs covariates file, raw';
run;
title4;

data basic.labscovariates;
     set lab.labscovariates (keep = eventid APLAB_MAX_PCT_ULN_14BEF_14AFT);
     rename eventid = STUDYID
            APLAB_MAX_PCT_ULN_14BEF_14AFT=APLAB_MAX_ULN_14BEF_14AFT;
run;
data basic.labscovariates;
     set basic.labscovariates ;
     APLAB_MAX_GT3_14BEF_14AFT = 0;
     format APLAB_MAX_ULN_14BEF_14AFT 6.2;  /***format to just two decimal places***/
     if APLAB_MAX_ULN_14BEF_14AFT > 3 then APLAB_MAX_GT3_14BEF_14AFT = 1;
     label APLAB_MAX_GT3_14BEF_14AFT = "APLAB_MAX_GT3_14BEF_14AFT: max lip or amyl lab normalized to ULN >3 from 14d before-14d after EVENTDTE_START (0/1, 1=Yes)" 
          APLAB_MAX_ULN_14BEF_14AFT = "APLAB_MAX_ULN_14BEF_14AFT: max lip or amyl lab (normalized to the upper limit of normal) for all labs +/-14 days from EVENTDTE_START";    
run;

title4 'APLAB_MAX_ULN_14BEF_14AFT Diagnostics, before add to clean outfile';
title5 'LAB DATA';
proc freq;
tables APLAB_MAX_ULN_14BEF_14AFT;
run;
title4;

%AddVar(updateset = clean.&outfile., varset = basic.labscovariates, var = APLAB_MAX_ULN_14BEF_14AFT);

data clean.&outfile.;
     set clean.&outfile.;
     ***formatting seems to have gotten lost. reestablish***;
     format APLAB_MAX_ULN_14BEF_14AFT 6.2;  /***format to just two decimal places***/
run;

title4 'APLAB_MAX_ULN_14BEF_14AFT Diagnostics, after add to clean outfile';
title5 'CLEAN OUTFILE';
proc freq data = clean.&outfile.;
tables APLAB_MAX_ULN_14BEF_14AFT;
run;
title4;

%AddFlag(updateset = clean.&outfile., varset = basic.labscovariates, var = APLAB_MAX_GT3_14BEF_14AFT);

title3 "&mainprog.";
title4 'Clean file';

ods pdf file=pdfclnc uniform style=analysis pdftoc=1;
     proc contents data = clean.&outfile. ;
     run;
ods pdf  close;
    
ods listing close;
ods pdf file=pdfclnf uniform style=analysis pdftoc=1;
     proc freq data = clean.&outfile. ;
     run;
ods pdf  close;
ods listing;

title5 'Showing some vars before they are dropped for final';
proc freq data = clean.&outfile. ;
    tables tobacco_use group SEX RACE HISPANIC SMOKE_PX_365 SMOKE_DX_365 ALC APPENDIC ASCITES CHR_PANCR 
          CONSTIPATION DIVERTICUL DKA ESOPHAGITIS FOOD_POIS GAL_BIL GASTRITIS 
          GASTRO GB_CANCER GERD HEPATITIS IBD ILEUS INTEST_OBS MESENT_ISCH MYOCARD_ISCH NEPHROLITH PANC_CNCR PEPTIC_ULCER ;
run;
title4;

data final.&outfile.;
     set clean.&outfile.;
     drop tobacco_use group SEX RACE SMOKE_PX_365 SMOKE_DX_365 SMOKE_DX
          ALC APPENDIC ASCITES CHR_PANCR CONSTIPATION DIVERTICUL DKA  
          ESOPHAGITIS FOOD_POIS GAL_BIL GASTRITIS GASTRO GB_CANCER GERD HEPATITIS 
          IBD ILEUS INTEST_OBS MESENT_ISCH MYOCARD_ISCH NEPHROLITH PANC_CNCR PEPTIC_ULCER 
          SMOKE_PX INFLUENZA ABDIMG_CT ABDIMG_MR;
run;

title4 'Final file';

ods pdf file=pdffinc uniform style=analysis pdftoc=1;
     proc contents data = final.&outfile. ;
     run;
ods pdf  close;

***summarize dates for review***;
proc sql;
create table maxmins as 
select max(EVENTDTE_START) as MaxEventStart format date9.
     , min(EVENTDTE_START) as MinEventStart format date9.
     , max(EVENTDTE_END) as MaxEventEnd format date9.
     , min(EVENTDTE_END) as MinEventEnd format date9.
     , max(AGE_AT_EVENT_IN_YRS) as MaxAge  
     , min(AGE_AT_EVENT_IN_YRS) as MinAge 
from final.&outfile.;
quit;

proc print data = maxmins ;
     title5 'Max and mins';
     var MinEventStart MaxEventStart MinEventEnd MaxEventEnd MinAge MaxAge;
run;
title5;

proc freq data = final.&outfile. (drop = studyid EVENTDTE_START EVENTDTE_END AGE_AT_EVENT_IN_YRS) ;
     title5 'Partial list of variables';
     title6 'Excluding studyid EVENTDTE_START EVENTDTE_END AGE_AT_EVENT_IN_YRS';
run;
title5;

ods listing close;
ods pdf file=pdffinf uniform style=analysis pdftoc=1;
     proc freq data = final.&outfile. ;
     run;
ods pdf  close;
ods listing;
