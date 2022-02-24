/*
Title:      	Who Stays Involved? A Longitudinal Study on Adolescents' Participation in Voluntary Associations in Germany*
Authors:		Kasimir Dederichs, Nuffiled College - University of Oxford (corresponding author)
				Hanno Kruse, University of Amsterdam
Data analyses:	Kasimir Dederichs
Journal:		European Sociological Review
Data:			CILS4EU and CILS4EU-DE (Kalter, F., Dollmann, J., Kogan, I. (2018). Children of Immigrants Longitudinal Survey in Four European Countries—Germany (CILS4EU-DE)—Reduced Version. Reduced data file for download and off‐site use. GESIS Data Archive, Cologne,  ZA6656 Data File Version 4.0.0.
				Kalter, F., Heath, A. F., Hewstone, M., Jonsson, J. O., Kalmijn, M., Kogan, I., van Tubergen, F. (2016a). Children of Immigrants Longitudinal Survey in Four European Countries (CILS4EU)—Reduced Version. Reduced data file for download and off‐site use. GESIS Data Archive, Cologne, ZA5656 Data File Version 1.2.0.
				Kalter, F., Heath, A. F., Hewstone, M., Jonsson, J. O., Kalmijn, M., Kogan, I., van Tubergen, F. (2016b). Children of Immigrants Longitudinal Survey in Four European Countries (CILS4EU)—Reduced Version. Reduced data file for download and off‐site use. GESIS Data Archive, Cologne, ZA5656 Data File Version 2.3.0.
				Kalter, F., Heath, A. F., Hewstone, M., Jonsson, J. O., Kalmijn, M., Kogan, I., van Tubergen, F. (2016c). Children of Immigrants Longitudinal Survey in Four European Countries (CILS4EU)—Reduced Version. Reduced data file for download and off‐site use. GESIS Data Archive, Cologne, ZA5656 Data File Version 3.3.0.)
				German Survey on Volunteering: (only for additional analyses)
				FWS (2014). German Survey on Volunteering (FWS), German Centre of Gerontology. DOI: 10.5156/FWS.2014.M.004.
*/			

/*
CONTENTS OF THE DO-FILE:
1. Set up working environment
2. Compile the dataset
3. Dep. Variable: Participation in voluntary associaitons
4. Indep. Variable
4.1. Age in months
4.2. Current situation (in terms of education)
4.3. Parents' Socio-economic Status
4.4. Sex
4.5. Copying time-constant variables to later observations
4.6. Classmates' participation
5. Imputations
6. Identify educational transitions
7. Identify final sample
8. Descriptive results
8.1. Table 1: Descriptives
8.2. Figure 2
8.3. Figure S4
9. Fixed-effects models 
9.1. Table 2: Main results
9.2. Separated by Sex
9.3. Table S1: Ordinal Fixed-effects models
10. Structural Equation Modelling 
10.1. Demeaning
10.2. Table 3: Moderated Mediation Analysis (higher tert. educ.)
10.3. Table S2: Moderated Mediation Analysis (all transitions)
10.4 Sensitivity analysis
11. Additional analyses based on the German Survey on Volunteering
*/

***********************************
***1. SET UP WORKING ENVIRONMENT***
***********************************
*install packages:
*ssc install center
*ssc install estout
*ssc install egenmore
*ssc install mediate
*ssc install feologit

version 16.1
clear all
set showbaselevels on
set more off
set logtype text
capture log close
log using participation_in_voluntary_associations_2022_01_19.log, replace
set seed 19960909

*Set global working directory
global workdir "..." 
global dofile "${workdir}\dofile"
global figures "${workdir}\figures"
global data "${workdir}\data"

*****************************
***2. COMPILE THE DATASET ***
*****************************
**extract relevant variables from different datasets for each wave (some of them for imputations): 

**Wave 1
*Parents questionnaire
use $data\w1_p_ge_v1.2.0_rv.dta, clear
keep youthid  p1_sex p1_iseiG p1_piseiG
save $data\w1_p_relvars.dta, replace

*Youth questionnaire
use $data\w1_ym_ge_v1.2.0_rv.dta, clear
keep youthid schoolid stratum y1_lta5 classid schtype_geRV ///
y1_sex y1_iseimG y1_iseifG ///
y1_doby y1_dobm y1_intdat_ymRV ///
y1_penc3 y1_pmonwRV y1_fact y1_cash1 //last 4 for imputations

*recode dependent variable (Participation in voluntary associations)
recode y1_lta5 (1=4) (2=3) (3=2) (4=1) (5=0) (-99=.) (-88=.) (-77=.) (-66=.) (-55=.) (-44=.) ///
(-33=.) (-22=.)
label def cipanew 0"never" 1"less often" 2"once or several times a month" ///
3"once or several times a week" 4"every day"
label val y1_lta5 cipanew

save $data\w1_ym_relvars.dta, replace

merge 1:1 youthid using $data\w1_p_relvars.dta
rename _merge mergeparents_w1
save $data\w1_ym_p_relvars.dta, replace

gen wave=1
save $data\w1_ym_p_yc_relvars.dta, replace


**Wave 2
*Youth questionnaire
use $data\w2_ym_ge_v2.3.0_rv.dta, clear
keep youthid y2_lta5 ///
y2_sl_csit3CS y2_csit1 y2_selfc1 y2_selfc2 y2_selfc3 ///
y2_doby y2_dobm y2_intdat_ymRV

*recode dependent variable  (Participation in voluntary associations)
recode y2_lta5 (1=4) (2=3) (3=2) (4=1) (5=0) (-99=.) (-88=.) (-77=.) (-66=.) (-55=.) (-44=.) ///
(-33=.) (-22=.)
label def cipanew 0"never" 1"less often" 2"once or several times a month" ///
3"once or several times a week" 4"every day"
label val y2_lta5 cipanew

gen wave=2
save $data\w2_ym_relvars.dta, replace
	
	
**Wave 3
*Youth questionnaire
use $data\w3_ym_ge_v3.3.0_rv.dta, clear
keep youthid y3_lta5 y3_csit3CS ///
y3_s_csit1 y3_doby y3_dobm y3_intdat_ymRV

*recode dependent variable  (Participation in voluntary associations)
recode y3_lta5 (1=4) (2=3) (3=2) (4=1) (5=0) (-99=.) (-88=.) (-77=.) (-66=.) (-55=.) (-44=.) ///
(-33=.) (-22=.)
label def cipanew 0"never" 1"less often" 2"once or several times a month" ///
3"once or several times a week" 4"every day"
label val y3_lta5 cipanew
	
gen wave=3
save $data\w3_ym_relvars.dta, replace


**Wave 4
*Youth questionnaire
use $data\w4_ym_ge_v4.0.0_rv.dta, clear
keep youthid y4_lta5 y4_csit3CS y4_s_csit2CS y4_intdat_ymRV

*recode dependent variable  (Participation in voluntary associations)
recode y4_lta5 (1=4) (2=3) (3=2) (4=1) (5=0) (-99=.) (-88=.) (-77=.) (-66=.) (-55=.) (-44=.) ///
(-33=.) (-22=.)
label def cipanew 0"never" 1"less often" 2"once or several times a month" ///
3"once or several times a week" 4"every day"
label val y4_lta5 cipanew

gen wave=4
save $data\w4_ym_relvars.dta, replace


**Wave 6
*Youth questionnaire
use $data\w6_ym_ge_v4.0.0_rv.dta, clear
keep if y6_sample==1 // keep only cases that are part of the panel samply, drop all refreshment cases
keep youthid y6_lta5 y6_csit3CS y6_s_csit2CS ///
y6_doby y6_dobm y6_intdat_ymRV

*recode dependent variable  (Participation in voluntary associations)
recode y6_lta5 (1=4) (2=3) (3=2) (4=1) (5=0) (-99=.) (-88=.) (-77=.) (-66=.) (-55=.) (-44=.) ///
(-33=.) (-22=.)
label def cipanew 0"never" 1"less often" 2"once or several times a month" ///
3"once or several times a week" 4"every day"
label val y6_lta5 cipanew

gen wave=6	
save $data\w6_ym_relvars.dta, replace


**Wave 7 (for retrospective information on educational transitions
use $data\w7_ym_ge_v4.0.0_rv.dta, clear
keep youthid y7_s_startm y7_s_starty y7_a_startm y7_a_starty ///
y7_u_startm y7_u_starty y7_w_startm y7_w_starty
gen wave=7
save $data\w7_ym_relvars.dta, replace


*append waves 1, 2, 3, 4 and 6 (7 is only supplementary information, will be used later)
use $data\w1_ym_p_yc_relvars.dta, clear
append using $data\w2_ym_relvars.dta
append using $data\w3_ym_relvars.dta
append using $data\w4_ym_relvars.dta
append using $data\w6_ym_relvars.dta
save $data\allwaves_ym_relvars.dta, replace //This is the dataset, our analyses rely on.
*Each individual appears up to 5 times in the dataset (once per wave), plus possibly in wave 7 for retrospective information.

*dataset with all relevant variables from all waves
use $data\allwaves_ym_relvars.dta, clear
label var wave "Wave" //Wave Indicator
gen ltait=wave //Indicator for all waves including lta5 (main DV)
recode ltait (5=.) (6=5)
label var ltait "lta 5 iteration"


***************************************************************
***3. DEP. VARIABLE: PARTICIPATION IN VOLUNTARY ASSOCIATIONS***
***************************************************************

*The variable that indicates participation in voluntary associations is called "cipa" in this do-file
gen cipa=. //new variable for civic participation
forvalues x=1/4 {
replace cipa=y`x'_lta5 if ltait==`x'
} 
replace cipa=y6_lta5 if ltait==5 

label var cipa "Participation in voluntary associations"
label val cipa cipanew //use value label from wave-specific variables (y1_lta5, etc.) 

*for the Online Supplement, we generate a variable which distinguishes between no participation and participation:
gen dcipa = .
replace dcipa = 0 if cipa==0
replace dcipa = 1 if cipa==1 | cipa==2 | cipa==3 | cipa==4
*identify those adolescents who did participate at wave 1:
gen w1cipa = .
replace w1cipa = 0 if wave==1 & dcipa==0
replace w1cipa = 1 if wave==1 & dcipa==1


*************************
***4. INDEP. VARIABLES***
*************************

***4.1. AGE IN MONTHS***
************************
*The age is calculated as the difference between the date of interview and the date of birth.
*Date of interview:
gen din=.
label var din "Date of interview"
replace din=y1_intdat_ymRV if wave==1
replace din=y2_intdat_ymRV if wave==2
replace din=y3_intdat_ymRV if wave==3
replace din=y4_intdat_ymRV if wave==4
replace din=y6_intdat_ymRV if wave==6
tab din, m
format din %tm
tab din, m
*Date of birth
*years
recode y1_doby (-88=.) (-55=.), gen(yob)
recode y2_doby (-88=.) (-66=.) (-55=.) (-44=.)
recode y3_doby (-88=.) (-55=.)
recode y3_doby (-88=.) (-44=.)
replace yob=y2_doby if yob==.
replace yob=y3_doby if yob==.
replace yob=y6_doby if yob==.
bysort youthid (wave): replace yob = yob[1]
bysort youthid (wave): replace yob = yob[2] if yob==.
tab yob, m
label var yob "Year of Birth"
*months
recode y1_dobm (-88=.) (-55=.), gen(yom)
recode y2_dobm (-88=.) (-66=.) (-55=.) (-44=.)
recode y3_dobm (-88=.) (-55=.)
recode y3_dobm (-88=.) (-44=.)
replace yom=y2_dobm if yom==.
replace yom=y3_dobm if yom==.
replace yom=y6_dobm if yom==.
bysort youthid (wave): replace yom = yom[1]
bysort youthid (wave): replace yom = yom[2] if yom==.
tab yom, m
label var yom "Month of Birth"
*time-format variable for date of birth
gen mbday = ym(yob,yom)
format mbday %tm
tab mbday, nol
*calculate age in months (date of interview - birth)
gen agem=.
label var agem "Age in months"
replace agem=din - mbday
replace agem=. if agem<168 //exclude everyone younger than 14 years from the analysis
replace agem=. if agem>288 //exclude everyone older than 23 years from the analysis
tab agem wave, m

*categorized age variables (Different ones for different purposes/figures)
gen agem_cat=.
replace agem_cat=14 if agem>=168 & agem<180
replace agem_cat=15 if agem>=180 & agem<192
replace agem_cat=16 if agem>=192 & agem<204
replace agem_cat=17 if agem>=204 & agem<216
replace agem_cat=18 if agem>=216 & agem<228
replace agem_cat=19 if agem>=228 & agem<240
replace agem_cat=20 if agem>=240 & agem<252
replace agem_cat=21 if agem>=252 & agem<264
replace agem_cat=22 if agem>=264 & agem<276
replace agem_cat=23 if agem>=276 & agem<288
//everyone under age 14 and above age 23 are excluded from the analyses. 

gen agem_cat2=agem_cat
replace agem_cat2=21 if agem_cat>=21 & agem_cat!=.
label def agem_cat2 14"14" 15"15" 16"16" 17"17" 18"18" 19"19" 20"20" 21"21+"
label val agem_cat2 agem_cat2
*alternative agem_cat variable3
gen agem_cat3=agem_cat
replace agem_cat3=20 if agem_cat>=20 & agem_cat!=.
//replace agem_cat3=. if agem_cat==13
label def agem_cat3 14"14" 15"15" 16"16" 17"17" 18"18" 19"19" 20"20+"
label val agem_cat3 agem_cat3

***4.2. CURRENT SITUATION (IN TERMS OF EDUCATION)***
****************************************************
*labels for different school tracks:
label def schtype_geRVnew 1"Lower track" 2"Combined tracks" 3"Intermediate track" ///
	4"Comprehensive track" 5"Upper track" 6"Special needs track"
label val schtype_geRV schtype_geRVnew

***What is an adolescent's current situation (csit) in terms of education at a given time point?
*generate a harmonized current situation indicator
gen csia=.
label var csia "current situation indicator all waves"
label def csia 1"school" 2"apprenticeship" 3"vocational preparation year" 4"working" ///
	5"internship" 6"nothing" 7"something else" 8"studying" 
*generate variables for single waves:
*Wave 1:
gen csi1=1 if wave==1 // all individuals are in school in wave 1, (That was the precondition to be part of the sample.)
*Wave 2:
recode y2_sl_csit3CS (-88=.) (-77=1) (-66=1) (-44=.) (1=2) (2=2) (3=3) (4=4) (5=5) (6=6) (7=7), gen(csi2)
//individuals who particpated in the school survey are pupils and those who completed the 
//home questionnaire and skipped the question ("not applicable") are pupils, too.
*Wave 3:
recode y3_csit3CS (-88=.) (5=1) (6=2) (7=2) (8=3) (9=4) (10=5) (11=6) (12=7), gen(csi3)
*Wave 4:
recode y4_csit3CS (-88=.) (-55=.) (-44=.) (5=1) (6=2) (7=2) (8=3) (9=4) (10=5) (11=6) (12=7), gen(csi4)
*Wave 6:
recode y6_csit3CS (-88=.) (-66=.) (-55=.) (-44=.) (5=1) (6=2) (7=2) (8=8) (9=4) (10=3) (11=5) (12=6) (13=7), gen(csi6) 

replace csia=csi1 if wave==1
replace csia=csi2 if wave==2
replace csia=csi3 if wave==3
replace csia=csi4 if wave==4
replace csia=csi6 if wave==6
label val csia csia
tab csia wave, m
drop csi1 csi2 csi3 csi4 csi6

*Use information from wave 7 for missings in wave 6:
merge m:1 youthid using $data\w7_ym_relvars.dta
drop if _merge==2 // drop all observations from wave 7 only
drop _merge
*recode variables that indicate the beginning of an educational programme
recode y7_a_startm (-88=.) (-77=.) (-55=.) (-44=.)
recode y7_a_starty (-88=.) (-77=.) (-55=.) (-44=.)
recode y7_u_startm (-88=.) (-77=.) (-55=.) (-44=.)
recode y7_u_starty (-88=.) (-77=.) (-55=.) (-44=.)
recode y7_w_startm (-88=.) (-77=.) (-55=.) (-44=.)
recode y7_w_starty (-88=.) (-77=.) (-55=.) (-44=.)

*time-format variable for date of start
gen start_a = ym(y7_a_starty,y7_a_startm)
format start_a %tm
tab start_a, nol m
gen start_u = ym(y7_u_starty,y7_u_startm)
format start_u %tm
tab start_u, nol m
gen start_w = ym(y7_w_starty,y7_w_startm)
format start_w %tm
tab start_w, nol m

*replace missing values for wave 6:
replace csia=2 if csia==. & wave==6 & start_a!=. & start_a<din
replace csia=4 if csia==. & wave==6 & start_w!=. & start_w<din
replace csia=8 if csia==. & wave==6 & start_u!=. & start_u<din

*generate dummy variables that indicate the current situation
*School
gen d_scho=0
replace d_scho=. if csia==.
replace d_scho=1 if csia==1
*Apprenticeship
gen d_appr=0
replace d_appr=. if csia==.
replace d_appr=1 if csia==2
*Vocational or practical training
gen d_vopr=0
replace d_vopr=. if csia==.
replace d_vopr=1 if csia==3
*Work
gen d_work=0
replace d_work=. if csia==.
replace d_work=1 if csia==4
*Internship
gen d_inte=0
replace d_inte=. if csia==.
replace d_inte=1 if csia==5
*Nothing
gen d_noth=0
replace d_noth=. if csia==.
replace d_noth=1 if csia==6
*Something else
gen d_soel=0
replace d_soel=. if csia==.
replace d_soel=1 if csia==7
*Studying
gen d_stud=0
replace d_stud=. if csia==.
replace d_stud=1 if csia==8
label var d_scho "School"
label var d_appr "Apprenticeship"
label var d_vopr "Vocational preparation year"
label var d_work "Working"
label var d_inte "Internship"
label var d_noth "Nothing"
label var d_soel "Something else"
label var d_stud "Studying"

*simplified version of current situation variable and transition indicators:
*four different states: School ("scho"), trainigng on the job ("work"), orientation ("orie"), and studying ("stud"))
gen csia2=.
replace csia2=1 if csia==1 //school
replace csia2=2 if csia==2 | csia==4 //training on the job
replace csia2=3 if csia==3 | csia==5 | csia==6 | csia==7 //orientation
replace csia2=4 if csia==8 //studying
label def csia2 1"school" 2"training on the job" 3"orientation" 4"studying"
label val csia2 csia2
*generate Dummy-Variables:
gen d_scho2=0
replace d_scho2=. if csia2==.
replace d_scho2=1 if csia2==1
gen d_totj2=0
replace d_totj2=. if csia2==.
replace d_totj2=1 if csia2==2
gen d_orie2=0
replace d_orie2=. if csia2==.
replace d_orie2=1 if csia2==3
gen d_stud2=0
replace d_stud2=. if csia2==.
replace d_stud2=1 if csia2==4
label var d_scho2 "School"
label var d_totj2 "Training on the job"
label var d_orie2 "Orientation"
label var d_stud2 "Studying"

***4.3. PARENTS' SOCIO-ECONOMIC STATUS***
*****************************************
//recode missings in original variables
recode p1_iseiG (-88=.) (-77=.) (-55=.) (-44=.) //ISEI of parent who fills out the questionnaire
recode p1_piseiG (-88=.) (-77=.) (-55=.) (-44=.) //ISEI of partner of the parent who fills out the questionnaire
*If the parents did not answer the questions or the entire questionnaire alltogether, we will impute missing values with childrens' answers about their parents' occupation(s)
*we also recode the missings in the original variables here:
recode y1_iseimG (-88=.) (-66=.) (-77=.) (-55=.) //mother's ISEI
recode y1_iseifG (-88=.) (-66=.) (-77=.) (-55=.) //father's ISEI
*New (empty) variables that indicate father's ISEI-score (iseif):
gen iseif=.
label var iseif "ISEI Father"
*Replace with parents' answers 
replace iseif=p1_iseiG if p1_sex==1 
replace iseif=p1_piseiG if p1_sex==2
sum iseif, detail
*Replace with children's answers if parents' answers were missing
replace iseif=y1_iseifG if iseif==. 
sum iseif, detail //percentiles, mean and standard deviation do not differ substantively before and after the imputation

*New (empty) variables that indicate father's ISEI-score (iseif):
gen iseim=.
label var iseim "ISEI Mother"
*Replace with parents' answers
replace iseim=p1_iseiG if p1_sex==2
replace iseim=p1_piseiG if p1_sex==1
sum iseim, detail
*Replace with children's answers if parents' answers were missing
replace iseim=y1_iseimG if iseim==.
sum iseim, detail //percentiles, mean and standard deviation do not differ substantively before and after the imputation

*Average ISEI-Score of an adolescent's parents
gen pisei=. // generate new variable (average ISEI-score of both parents)
replace pisei=(iseim+iseif)/2 if iseim!=. & iseif!=.
replace pisei=iseim if iseim!=. & iseif==. //if only one ISEI score available, we take just that one
replace pisei=iseif if iseif!=. & iseim==.
label var pisei "Parents' average Internat. Socio-Economic Index (ISEI)"

***4.4. SEX***
**************
recode y1_sex (2=1) (1=0), gen(sex)
label var sex "Sex"
label def sex 0"male" 1"female"
label val sex sex
drop y1_sex 

***4.5. COPYING TIME-CONSTANT VARIABLES TO LATER OBSERVATIONS***
****************************************************************
bysort youthid (wave): replace sex = sex[1]
bysort youthid (wave): replace schtype_geRV = schtype_geRV[1]
bysort youthid (wave): replace classid = classid[1]
bysort youthid (wave): replace schoolid = schoolid[1]
bysort youthid (wave): replace pisei = pisei[1]
bysort youthid (wave): replace classid = classid[1]
bysort youthid (wave): replace stratum = stratum[1]
bysort youthid (wave): replace w1cipa = w1cipa[1]

***4.6. CLASSMATES' PARTICIPATION***
************************************
*for all classmates (using class-mean technique)
sort classid wave
by classid wave: egen cmcipa=mean(cipa) //assign the each adolescent the mean of her (former) classmates' participation (including herself)
label var cmcipa "Class mean civic participation"
by classid wave: egen nr=count(cipa) //count the number of individuals in a class
label var nr "Number of students with nonmissing cipa values in this class-wave combination"
gen cpcipa=(cmcipa*nr-cipa)/(nr-1) //exclude the focal individual from the measure of classmates' participation
label var cpcipa "Class peers cipa"

save $data\allwaves_ym_p_yc_relvars.dta, replace //This is the data before imputatations.


********************
***5. IMPUTATIONS*** 
********************
*stepwise, because some variables are time-constant and were collected in different waves

use $data\allwaves_ym_p_yc_relvars.dta, clear
**preparation of imputation:
*Prepare some variables that serve as predictors for the imputation:
recode y1_penc3 (-88=.) (-55=.)
recode y1_fact (-88=.) (-55=.)
bysort youthid (wave): replace y1_penc3=y1_penc3[1]
bysort youthid (wave): replace y1_fact=y1_fact[1]
*One's current situation in the previous wave is assumed to be a good predictor for the current situation in the following wave in the imputation models
gen csitlw=.
label var csitlw "Current situation last wave"
bysort youthid (wave): replace csitlw=csia[_n-1]
*Prepare empty dummy variables for one's current situation 
foreach k in appr vopr work inte noth soel stud scho totj2 orie2 stud2{
gen tra_`k'=.
gen s_`k'=.
}
gen trans=.
gen trans_t=.

*beginning of imputation: Display patterns of missingness
mi set flong
mi misstable patterns cipa agem cpcipa d_appr stratum pisei sex schtype_geRV y1_penc3 y1_fact if cipa!=.
mi misstable sum cipa agem d_appr stratum pisei sex schtype_geRV y1_penc3 y1_fact if cipa!=.

*approximative estimation of percentage of missings: (Figures in the paper)
mi misstable sum cipa agem d_appr d_vopr d_work d_inte d_noth d_soel d_stud stratum pisei sex schtype_geRV ///
	y1_penc3 y1_fact if cipa!=. & agem!=. & cpcipa!=. & stratum!=. & sex!=. ///
	& schtype!=. & y1_fact!=. & y1_penc3!=.
dis 1062+14667 // this mirrors approximately the final sample (15185 obs in final sample, 15729 under study here)
dis 1062 / 15729 //6.75% missing on current situation variable
dis 762 / 15729 //4.84% missing on SES variable

*Declare imputed and regular variables:	
mi register imputed csia pisei d_scho d_appr d_vopr d_work d_inte d_noth d_soel d_stud
mi register regular agem sex schtype_geRV y1_penc3 y1_fact csitlw stratum
mi register passive trans trans_t cpcipa

*for the dummies indicating the current educational situation
*Impute dummy variables that indicate educational situation after school:
mi impute chained (logit) d_appr d_vopr d_work d_inte d_noth d_soel d_stud = i. csitlw agem sex i.schtype_geRV ///
y1_penc3 y1_fact i.stratum, replace force add(40) augment rseed(19960909)
//augmented regression because of perfect collinearity of dep. vars
*Impute dummy variable that indicates whether or not one is still in school
mi impute chained (logit) d_scho = i. csitlw agem sex i.schtype_geRV ///
y1_penc3 y1_fact i.stratum, replace force rseed(19960909)

*Impute ISEI-scores (bound between 10 and 84, based on the existing values in the sample)
gen pisei_l=cond(pisei==., 10, pisei)
gen pisei_u=cond(pisei==., 84, pisei)
set seed 19960909
mi impute chained (intreg, ll(pisei_l) ul(pisei_u)) pisei = agem sex i.schtype_geRV ///
y1_penc3 y1_fact i.stratum if wave==1, replace force rseed(19960909) //only for wave 1, 
//since the ISEI variable is time-constant and is copied to later observations in a next step. 
bysort youthid _mi_m (wave): replace pisei=pisei[1]

*describe and update imputed values:
mi describe
mi update
mi describe
save $data\forresultspart_allwaves_ym_p_yc_relvars.dta, replace //data with imputed values
use $data\forresultspart_allwaves_ym_p_yc_relvars.dta, clear

*****************************************
***6. IDENTIFY EDUCATIONAL TRANSITIONS***
*****************************************
*Building on the imputed data, we now derive educational transitions based on the current situation variables. 
***educational transitions:
sort youthid _mi_m wave
*A transition is defined as the first instance in a new situation (e.g., studying) while being in a different situation before
foreach k in appr vopr work inte noth soel stud stud2 totj2 orie2{
by youthid _mi_m (wave): replace tra_`k'=0 if d_`k'!=. //default assumption: nobody made a given transition.
by youthid _mi_m (wave): replace tra_`k'=1 if d_`k'==1 & d_`k'[_n-1]==0 //replace all people who are currently in a given situation (e.g. studying) but were not in the previous wave.
}
by youthid _mi_m (wave): replace tra_scho=0 if d_scho!=.
by youthid _mi_m (wave): replace tra_scho=1 if d_scho==0 & d_scho[_n-1]==1

*generate a general transition variable: (Does ANY transition take place at a given time?)
replace trans=0 if tra_appr==0 & tra_vopr==0 & tra_work==0 & tra_inte==0 & tra_noth==0 & tra_soel==0 & tra_stud==0
replace trans=1 if tra_appr==1 | tra_vopr==1 | tra_work==1 | tra_inte==1 | tra_noth==1 | tra_soel==1 | tra_stud==1

*number of transitions per individual:
drop trans_t
by youthid _mi_m (wave): egen trans_t=total(trans)
tab trans_t if wave==1, m
mi update


******************************
***7. IDENTIFY FINAL SAMPLE***
******************************
*declare panel structure:
mi xtset youthid wave

*define final sample:
*est1:
set seed 19960909
eststo: mi estimate, imputations(1/40)  esample(finsam): ///
	xtreg cipa c.agem##c.pisei tra_totj2 tra_orie2 tra_stud2 cpcipa, fe vce(cluster schoolid)
tab finsam wave if _mi_m==1 //sample across waves (one imputation shown)
codebook youthid if _mi_m==1 & finsam == 1 //display number of individuals in the final sample (4,821)


*mean-center PISEI variable and make it more readable for the outputs later on:
gen pisei_unc=pisei //save original ISEI variable as "uncentered"
label var pisei_unc "Parents' ISEI Score, uncentered" 
sort youthid _mi_m wave 
bysort youthid _mi_m: gen obsid = _n //obsid counts the observations per id.
summarize pisei if obsid==1 & finsam==1
dis r(mean) //mean of ISEI (excluding multile observations for each adolescent in this mean-calculation)
replace pisei=pisei-r(mean)
sum pisei if wave==1 & finsam==1
bysort youthid _mi_m (wave): replace pisei = pisei[1] //copy value to observations in later waves
label var pisei "Parents' ISEI Score, centered"
replace pisei=pisei/10 //divide pisei variable by 10 for visibility of interaction effect and readability of effects in general:


*********************************************
***8. IDENTIFY REDUCTIONS IN PARTICIPATION***
*********************************************

sort youthid _mi_m wave 
generate rdcipa = .
//by youthid _mi_m (wave): replace rdcipa = 0 if cipa[_n-1]>0 & cipa>=cipa[_n-1] & wave>1
by youthid _mi_m (wave): replace rdcipa = 0 if cipa[_n-1]>0 & cipa<cipa[_n-1] & wave>1
by youthid _mi_m (wave): replace rdcipa = 1 if cipa[_n-1]>0 & cipa<cipa[_n-1] & cipa==0 & wave>1

label def rdcipanew 0"reduction but still active" 1"reduction and quit altogether"
label val rdcipa rdcipanew
label var rdcipa "Type of reduction"

save $data\forresultspart_allwaves_ym_p_yc_relvars.dta, replace //Final dataset for anaylses
use $data\forresultspart_allwaves_ym_p_yc_relvars.dta, clear


****************************
***8. DESCRIPTIVE RESULTS***
****************************

***8.1. TABLE 1: DESCRIPTIVES***
********************************
estpost tabstat cipa agem trans tra_stud2 tra_totj2 tra_orie2 cpcipa pisei_unc if ///
	finsam==1 & wave==1, statistics(mean sd min max) columns(statistics) 
esttab . using descriptives_w1.rtf, replace cells("mean(fmt(3)) sd(fmt(3)) min(fmt(0)) max(fmt(0))") nonumbers title("Wave 1")
estpost tabstat cipa agem trans tra_stud2 tra_totj2 tra_orie2 cpcipa pisei_unc if ///
	finsam==1 & wave==2, statistics(mean sd min max) columns(statistics)
esttab . using descriptives_w2.rtf, replace cells("mean(fmt(3)) sd(fmt(3)) min(fmt(0)) max(fmt(0))") nonumbers title("Wave 2")
estpost tabstat cipa agem trans tra_stud2 tra_totj2 tra_orie2 cpcipa pisei_unc if ///
	finsam==1 & wave==3, statistics(mean sd min max) columns(statistics)
esttab . using descriptives_w3.rtf, replace cells("mean(fmt(3)) sd(fmt(3)) min(fmt(0)) max(fmt(0))") nonumbers title("Wave 3")
estpost tabstat cipa agem trans tra_stud2 tra_totj2 tra_orie2 cpcipa pisei_unc if ///
	finsam==1 & wave==4, statistics(mean sd min max) columns(statistics)
esttab . using descriptives_w4.rtf, replace cells("mean(fmt(3)) sd(fmt(3)) min(fmt(0)) max(fmt(0))") nonumbers title("Wave 4")
estpost tabstat cipa agem trans tra_stud2 tra_totj2 tra_orie2 cpcipa pisei_unc if ///
	finsam==1 & wave==6, statistics(mean sd min max) columns(statistics)
esttab . using descriptives_w6.rtf, replace cells("mean(fmt(3)) sd(fmt(3)) min(fmt(0)) max(fmt(0))") nonumbers title("Wave 6")
estpost tabstat cipa agem trans tra_stud2 tra_totj2 tra_orie2 cpcipa pisei_unc if ///
	finsam==1 , statistics(mean sd min max) columns(statistics)
esttab . using descriptives_wall.rtf, replace cells("mean(fmt(3)) sd(fmt(3)) min(fmt(0)) max(fmt(0))") nonumbers title("All waves")

***8.2. FIGURE 2 ***
********************
***Figure 2: Participation in voluntary associations by age and before and after educational transitions
*Left panel: Interaction effect between Age and ISEI on Participation
*Prepare: Identify High SES individuals vs low SES individuals (Those with >=mean ISEI and those with <mean ISEI) (only for one imputation)
gen hses=. 
label var hses "High SES"
label def hses 0"Low SES" 1"High SES" 
label val hses hses
summarize(pisei) if _mi_m==1 & finsam==1 & pisei!=., d
replace hses=1 if pisei>= r(mean) & pisei!=. & _mi_m==1 & finsam==1
replace hses=0 if pisei< r(mean) & pisei!=. & _mi_m==1 & finsam==1
*calculate means by age group and by SES
egen mcipa7 = mean(cipa) if finsam==1 & agem_cat3!=. & pisei!=., by(agem_cat3)
egen mcipa6 = mean(cipa) if finsam==1 & agem_cat3!=. & pisei!=., by(agem_cat3 hses)

*Plot left panel of figure 2: (all SES groups, low SES, and high SES)
twoway dot mcipa7 agem_cat3 if finsam==1 & _mi_m==1 & agem_cat>13, lpattern(solid) lcolor(gs0) sort msymbol(D) msize(*1.4) ///
	|| dot mcipa6 agem_cat3 if finsam==1 & _mi_m==1 & agem_cat>13 & hses==0, lpattern(dash) lcolor(gs0) sort msymbol(O) msize(*1.8) ///
	|| dot mcipa6 agem_cat3 if finsam==1 & _mi_m==1 & agem_cat>13 & hses==1, lpattern(longdash) lcolor(gs0) sort msymbol(T) msize(*1.5) ///
	ytitle("Participation in voluntary associations", size(medium)) xtitle("Age in years", size(medium)) ///
	ylabel(1 "Less often" 2 "Monthly" 3 "Weekly", angle(0) labsize(medium)) yscale(range(1/3)) ///
	xlabel(14"14" 15"15" 16"16" 17"17" 18"18" 19"19" 20"20+", labsize(medium)) ///
	legend(colgap(3) symxsize(9) keygap(1) order(3 "Higher SES only (> mean ISEI)" 1 "All adolescents" 2 "Lower SES only (< mean ISEI)") rows(3) justification(centre)) scheme(s1mono) ///
	name(Figure2a, replace)
	
*Right panel: Particiaption before, during, and after educational transitions
*Prepare: Variable that indicates time relative to transition 
sort youthid _mi_m wave
foreach k in totj2 orie2 stud2 {
gen tt_`k'=.
by youthid _mi_m (wave): replace tt_`k'=10 if tra_`k'==1
by youthid _mi_m (wave): replace tt_`k'=11 if tra_`k'[_n-1]==1
by youthid _mi_m (wave): replace tt_`k'=12 if tra_`k'[_n-2]==1
by youthid _mi_m (wave): replace tt_`k'=13 if tra_`k'[_n-3]==1
by youthid _mi_m (wave): replace tt_`k'=14 if tra_`k'[_n-4]==1
by youthid _mi_m (wave): replace tt_`k'=15 if tra_`k'[_n-5]==1
by youthid _mi_m (wave): replace tt_`k'=9 if tra_`k'[_n+1]==1
by youthid _mi_m (wave): replace tt_`k'=8 if tra_`k'[_n+2]==1
by youthid _mi_m (wave): replace tt_`k'=7 if tra_`k'[_n+3]==1
by youthid _mi_m (wave): replace tt_`k'=6 if tra_`k'[_n+4]==1
by youthid _mi_m (wave): replace tt_`k'=5 if tra_`k'[_n+5]==1
} 

*variable that distinguishes before/transition/after
*auxilary variable:
gen tt_total2=max(tt_totj2, tt_orie2, tt_stud2)
label def tt_total2 9"before transition" 10"transition" 11"after transition"
label val tt_total2 tt_total2
*final variable that distinguishes before/transition/after:
gen tt_total3 = .
replace tt_total3 = 1 if tt_total2<10 & tt_total2!=.
replace tt_total3 = 2 if tt_total2==10
replace tt_total3 = 3 if tt_total2>10 & tt_total2!=.
foreach k in totj2 orie2 stud2 {
gen tt_3`k' = .
replace tt_3`k' = 1 if tt_`k'<10 & tt_`k'!=.
replace tt_3`k' = 2 if tt_`k'==10
replace tt_3`k' = 3 if tt_`k'>10 & tt_`k'!=.
}
label def tt_total3 1"Before transition" 2"Transition" 3"After transition"
label val tt_total3 tt_total3
label val tt_3totj2 tt_total3
label val tt_3orie2 tt_total3
label val tt_3stud2 tt_total3
*calculate means by agegroups and educational transition
egen mcipa10 = mean(cipa) if cipa!=. & agem_cat2!=. & tt_total3!=., by(tt_total3)
egen mcipa10_totj2 = mean(cipa) if cipa!=. & finsam==1 & tt_3totj2!=., by(tt_3totj2)
egen mcipa10_orie2 = mean(cipa) if cipa!=. & finsam==1 & tt_3orie2!=., by(tt_3orie2)
egen mcipa10_stud2 = mean(cipa) if cipa!=. & finsam==1 & tt_3stud2!=., by(tt_3stud2)

*Plot right panel of figure 2 (transition to work, orientation and studying)
twoway dot mcipa10_totj2 tt_3totj2 if _mi_m==1 & finsam==1, sort msymbol(D) msize(*1.4)|| ///
	dot mcipa10_orie2 tt_3orie2 if _mi_m==1 & finsam==1, sort msymbol(O) msize(*1.8) || ///
	dot mcipa10_stud2 tt_3stud2 if _mi_m==1 & finsam==1, sort msymbol(T) msize(*1.5) ytitle("Participation in voluntary associations", size(medium)) xtitle(" ", size(medium)) ///
	scheme(s1mono) xlabel(1 "Before transition" 2 "Transition" 3"After transition", labsize(medium)) ///
	ylabel(1 "Less often" 2 "Monthly" 3 "Weekly", angle(0) labsize(medium)) yscale(range(1/3)) xscale(range(0.5/3.5)) ///
	legend(colgap(3) symxsize(9) keygap(1) order(3 "Higher tertiary education" 1 "Work" 2 "Orientation" ) rows(3) justification(centre)) name(Figure2b, replace) 
	
*combine left and right panel and plot figure 2
graph combine Figure2a Figure2b, ycommon scheme(s1mono) ysize(20) xsize(40) name(Figure2)


***8.3. FIGURE S3***
********************
*reproduce Figure 2a only for those observations that show a reduction in participation:
egen redmcipa9 = mean(rdcipa) if finsam==1 & agem_cat3!=. & pisei!=., by(agem_cat3)
egen redmcipa8 = mean(rdcipa) if finsam==1 & agem_cat3!=. & pisei!=., by(agem_cat3 hses)
*Plot left panel of Figure S3 (age categories)
twoway dot redmcipa9 agem_cat3 if finsam==1 & _mi_m==1 & agem_cat>14, lpattern(solid) lcolor(gs0) sort msymbol(D) msize(*1.4) ///
	|| dot redmcipa8 agem_cat3 if finsam==1 & _mi_m==1 & agem_cat>14 & hses==0, lpattern(dash) lcolor(gs0) sort msymbol(O) msize(*1.8) ///
	|| dot redmcipa8 agem_cat3 if finsam==1 & _mi_m==1 & agem_cat>14 & hses==1, lpattern(longdash) lcolor(gs0) sort msymbol(T) msize(*1.5) ///
	ytitle("Share of adolescents who quit altogether", size(medium)) xtitle("Age in years", size(medium)) ///
	ylabel(.3 "30 %" .4 "40%" .5 "50%" .6 "60%", angle(0) labsize(medium)) yscale(range(0.5/0.95)) ///
	xlabel(15"15" 16"16" 17"17" 18"18" 19"19" 20"20+", labsize(medium)) ///
	legend(colgap(3) symxsize(9) keygap(1) order(3 "Higher SES only (> mean ISEI)" 1 "All adolescents" 2 "Lower SES only (< mean ISEI)") rows(3) justification(centre)) scheme(s1mono) ///
	name(FigureS3a, replace)
	
*Figure S3b:
*reproduce Figure 2b only for those observations that show a reduction in participation:
egen redmcipa10 = mean(rdcipa) if cipa!=. & agem_cat2!=. & tt_total3!=., by(tt_total3)
egen redmcipa10_totj2 = mean(rdcipa) if cipa!=. & w1cipa==1 & finsam==1 & tt_3totj2!=., by(tt_3totj2)
egen redmcipa10_orie2 = mean(rdcipa) if cipa!=. & w1cipa==1 & finsam==1 & tt_3orie2!=., by(tt_3orie2)
egen redmcipa10_stud2 = mean(rdcipa) if cipa!=. & w1cipa==1 & finsam==1 & tt_3stud2!=., by(tt_3stud2)

*Plot right panel of figure S3 (transition to work, orientation and studying)
twoway dot redmcipa10_totj2 tt_3totj2 if _mi_m==1 & w1cipa==1 & finsam==1, sort msymbol(D) msize(*1.4)|| ///
	dot redmcipa10_orie2 tt_3orie2 if _mi_m==1 & w1cipa==1 & finsam==1, sort msymbol(O) msize(*1.8) || ///
	dot redmcipa10_stud2 tt_3stud2 if _mi_m==1 & w1cipa==1 & finsam==1, sort msymbol(T) msize(*1.5) ytitle("Share of adolescents who quit altogether", size(medium)) xtitle(" ", size(medium)) ///
	scheme(s1mono) xlabel(1 "Before transition" 2 "Transition" 3"After transition", labsize(medium)) ///
	ylabel(.3 "30 %" .4 "40%" .5 "50%" .6 "60%", angle(0) labsize(medium)) yscale(range(0.6/1)) xscale(range(0.5/3.5)) ///
	legend(colgap(3) symxsize(9) keygap(1) order(3 "Higher tertiary education" 1 "Work" 2 "Orientation" ) rows(3) justification(centre)) name(FigureS3b, replace) 

*combine left and right panel and plot figure S4 in online supplement
graph combine FigureS3a FigureS3b, ycommon scheme(s1mono) ysize(20) xsize(40) name(FigureS3)


*What share of reductions were reductions down to 0 (i.e., "never participates")?
tab rdcipa if finsam==1
*And how does that develop across waves?
tab wave rdcipa if finsam == 1, row
*And how does that develop across age categories?
tab agem_cat3 rdcipa if finsam==1, row


*****************************
***9. FIXED-EFFECTS MODELS***
*****************************

***9.1. TABLE 2: MAIN RESULTS***
********************************
***Model 1: age-effect
mi estimate, post: xtreg cipa agem if finsam==1, fe vce(cluster schoolid)
est sto m1tra
***Model 2: age-effect controlling for classmates' participation
mi estimate, post: xtreg cipa agem cpcipa if finsam==1, fe vce(cluster schoolid)
est sto m2tra
***Model 3: age-effect and educ. trans. in general
mi estimate, post: xtreg cipa agem trans cpcipa if finsam==1, fe vce(cluster schoolid)
est sto m3tra
***Model 4: age-effect and different educ. trans.
mi estimate, post: xtreg cipa agem tra_totj2 tra_orie2 tra_stud2 cpcipa if finsam==1, fe vce(cluster schoolid) 
est sto m4tra
*t-test: Are coefficients of different educational transitions significantly different?	
dis (_b[tra_totj2] - _b[tra_stud2])/sqrt((_se[tra_totj2]^2) + (_se[tra_stud2]^2)) 	//t-value
dis (2 * ttail(e(df_r), abs(_b[tra_totj2] - _b[tra_stud2])/sqrt((_se[tra_totj2]^2) + (_se[tra_stud2]^2)))) //p-value
dis (_b[tra_orie2] - _b[tra_stud2])/sqrt((_se[tra_orie2]^2) + (_se[tra_stud2]^2)) //t-value
dis (2 * ttail(e(df_r), abs(_b[tra_orie2] - _b[tra_stud2])/sqrt((_se[tra_orie2]^2) + (_se[tra_stud2]^2))))	//p-value
*-> Yes!
***Model 5: age-effect and SES-differences
mi estimate, post: xtreg cipa c.agem##c.pisei cpcipa if finsam==1, fe vce(cluster schoolid)		
est sto m5tra
***Model 6: age-effect and SES-differences
mi estimate, post: xtreg cipa c.agem##c.pisei tra_totj2 tra_orie2 tra_stud2 cpcipa if finsam==1, fe vce(cluster schoolid)
est sto m6tra
esttab m1tra m2tra m3tra m4tra m5tra m6tra, b(4) se(4)
*export estimates to word-document
esttab m1tra m2tra m3tra m4tra m5tra m6tra using fe_results.rtf, replace b(4) se(4) wide nogaps ///
	mtitle("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6") nonumbers ///
	title("Results from Fixed Effects Regression") ///
	addnote(Results from 40 multiply-imputed datasets combined using Rubin's rules (Rubin 1987). Standard errors are cluster-corrected at the school level.)  ///
	order(agem  trans tra_stud2 tra_totj2 tra_orie2 pisei c.agem#c.pisei cpcipa _cons) ///
	coeflabels(agem "Age (in months)" trans "Any transition" tra_stud2 "Higher tertiary education" ///
	tra_totj2 "Work" tra_orie2 "Orientation" pisei "ISEI" ///
	c.agem#c.pisei "Age X Parents' ISEI" cpcipa "Classmates' participation" _cons "Constant")

***9.2. SEPARATED BY SEX***
***************************
***Model 1: age-effect
mi estimate, post: xtreg cipa agem if finsam==1 & sex==0, fe vce(cluster schoolid)
est sto m1tra_m
***Model 2: age-effect and cipa
mi estimate, post: xtreg cipa agem cpcipa if finsam==1 & sex==0, fe vce(cluster schoolid)
est sto m2tra_m
***Model 3: age-effect and educ. trans. in general
mi estimate, post: xtreg cipa agem trans cpcipa if finsam==1 & sex==0, fe vce(cluster schoolid)
est sto m3tra_m
***Model 4: age-effect and different educ. trans.
mi estimate, post: xtreg cipa agem tra_totj2 tra_orie2 tra_stud2 cpcipa if finsam==1 & sex==0, fe vce(cluster schoolid) 
est sto m4tra_m
***Model 5: age-effect and SES-differences
mi estimate, post: xtreg cipa c.agem##c.pisei cpcipa if finsam==1 & sex==0, fe vce(cluster schoolid)		
est sto m5tra_m
***Model 6: age-effect and SES-differences
mi estimate, post: xtreg cipa c.agem##c.pisei tra_totj2 tra_orie2 tra_stud2 cpcipa if finsam==1 & sex==0, fe vce(cluster schoolid)
est sto m6tra_m
esttab m1tra_m m2tra_m m3tra_m m4tra_m m5tra_m m6tra_m, b(4) se(4) //results for boys only
***Model 1: age-effect
mi estimate, post: xtreg cipa agem if finsam==1 & sex==1, fe vce(cluster schoolid)
est sto m1tra_f
***Model 2: age-effect and cipa
mi estimate, post: xtreg cipa agem cpcipa if finsam==1 & sex==1, fe vce(cluster schoolid)
est sto m2tra_f
***Model 3: age-effect and educ. trans. in general
mi estimate, post: xtreg cipa agem trans cpcipa if finsam==1 & sex==1, fe vce(cluster schoolid)
est sto m3tra_f
***Model 4: age-effect and different educ. trans.
mi estimate, post: xtreg cipa agem tra_totj2 tra_orie2 tra_stud2 cpcipa if finsam==1 & sex==1, fe vce(cluster schoolid) 
est sto m4tra_f
***Model 5: age-effect and SES-differences
mi estimate, post: xtreg cipa c.agem##c.pisei cpcipa if finsam==1 & sex==1, fe vce(cluster schoolid)		
est sto m5tra_f
***Model 6: age-effect and SES-differences
mi estimate, post: xtreg cipa c.agem##c.pisei tra_totj2 tra_orie2 tra_stud2 cpcipa if finsam==1 & sex==1, fe vce(cluster schoolid)
est sto m6tra_f
esttab m1tra_f m2tra_f m3tra_f m4tra_f m5tra_f m6tra_f, b(4) se(4) //results for girls only


*************************************************
***9.3. TABLE S1: ORDINAL FIXED-EFFECTS MODELS***
*************************************************
*ordinal models based on one imputation and with proper feologit procedure:
feologit cipa c.agem##c.pisei tra_totj2 tra_orie2 tra_stud2 cpcipa if finsam==1 & _mi_m==1, group(youthid) cluster(schoolid) threshold seed(19960909) 
predict ordsam1
gen ordsample=1 if ordsam1!=. 
tab ordsample //show sample on which the ordered logit models will be based.

*final models with one imputation only:
***Model 1: age-effect
feologit cipa agem if finsam==1 & _mi_m==1 & ordsample==1, group(youthid) cluster(schoolid) threshold seed(19960909)
est sto om1
***Model 2: age-effect
feologit cipa agem cpcipa if finsam==1 & _mi_m==1 & ordsample==1, group(youthid) cluster(schoolid) threshold seed(19960909)
est sto om2
***Model 3: age-effect and educ. trans.
feologit cipa agem trans cpcipa if finsam==1 & _mi_m==1 & ordsample==1, group(youthid) cluster(schoolid) threshold seed(19960909)
est sto om3
***Model 4: age-effect and educ. trans.
feologit cipa agem tra_totj2 tra_orie2 tra_stud2 cpcipa if finsam==1 & _mi_m==1 & ordsample==1, group(youthid) cluster(schoolid) threshold seed(19960909)
est sto om4
***Model 5: age-effect and SES-differences
feologit cipa c.agem##c.pisei if finsam==1 & _mi_m==1 & ordsample==1, group(youthid) cluster(schoolid) threshold seed(19960909)
est sto om5
***Model 6: age-effect and SES-differences
feologit cipa c.agem##c.pisei tra_totj2 tra_orie2 tra_stud2 cpcipa if finsam==1 & _mi_m==1 & ordsample==1, group(youthid) cluster(schoolid) threshold seed(19960909)
est sto om6

esttab om1 om2 om3 om4 om5 om6, b(4) se(4)
*export estimates to word-document
esttab om1 om2 om3 om4 om5 om6 ///
	using ologit_models.rtf, replace b(4) se(4) wide nogaps ///
	mtitle("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6") nonumbers ///
	title("Results from Ordinal Fixed Effects Regression") ///
	addnote(Note: Standard errors in parentheses. Standard errors are cluster-corrected at the school level. * p < 0.05, ** p < 0.01, *** p < 0.001. Estimates are obtained using the BUC-r-estimator feologit command with the threshold option in order to assume constant thresholds across individuals as the standard ordinal logit model does (see Baetschmann et al., 2020). The sample size is inflated because the estimation procedure requires cloning observations. While all models rely on the same reference sample (N = 628,720), the reported sample sizes vary across models because only those observations with change on the included variables are used for the estimation. Standard errors are cluster-corrected at the school level. For improved readability of the coefficients, age and ISEI are mean-centered and ISEI is divided by 10.) ///
	order(agem trans tra_stud2 tra_totj2 tra_orie2 pisei c.agem#c.pisei cpcipa _cons) ///
	coeflabels(agem "Age (in months)" trans "Any transition" tra_totj2 "Work" ///
	tra_stud2 "Higher tertiary education" tra_orie2 "Orientation" ///
	cpcipa "Classmates' participation" pisei "ISEI" ///
	c.agem#c.pisei "Age X Parents' ISEI" _cons "Constant")

	
***************************************
***10. STRUCTURAL EQUATION MODELLING***
***************************************

***10.1. DEMEANING***
*********************
*just do the SEM modelling with one imputation.
keep if _mi_m==1 //only keep one imputation 
keep if finsam==1 // only keep observations of final sample for correct demeaning.
summarize pisei
global m=r(mean)
global s=r(sd)
generate agem_pisei = agem * pisei 
xtreg cipa agem tra_totj2 tra_orie2 tra_stud2 cpcipa if finsam==1, fe vce(cluster schoolid)
xtreg cipa agem trans cpcipa if finsam==1, fe vce(cluster schoolid) 

*Demean all relevant variables with center command:
bysort youthid (wave): center cipa agem d_totj2 d_orie2 d_stud2 tra_totj2 tra_orie2 tra_stud2 trans cpcipa agem_pisei
drop cipa agem d_totj2 d_orie2 d_stud2 tra_totj2 tra_orie2 tra_stud2 trans cpcipa agem_pisei // drop original variables
rename (c_cipa c_agem c_d_totj2 c_d_orie2 c_d_stud2 c_tra_totj2 c_tra_orie2 c_tra_stud2 c_trans c_cpcipa c_agem_pisei) ///
(cipa agem d_totj2 d_orie2 d_stud2 tra_totj2 tra_orie2 tra_stud2 trans cpcipa agem_pisei)

*These regressions show the same results as the xtreg commands above.
reg cipa agem tra_totj2 tra_orie2 tra_stud2 cpcipa if finsam==1, vce(cluster schoolid)
reg cipa agem trans cpcipa if finsam==1, vce(cluster schoolid)

save $data\forresultspart_allwaves_ym_p_yc_relvars_only_one_imputation_demeaned.dta, replace //demeaned data
use $data\forresultspart_allwaves_ym_p_yc_relvars_only_one_imputation_demeaned.dta, clear

***10.2. TABLE 3: MODERATED MEDIATION ANALYSIS (HIGHER TERT. EDUC.)***
**********************************************************************
*reference point for different SES groups
summarize pisei if obsid==1 
global m=r(mean)
global s=r(sd)

*total effects for all transition-variable model specifications
sem (cipa <- agem agem_pisei cpcipa), vce(cluster schoolid)
est sto app_tot
nlcom(($m-$s)*_b[cipa:agem_pisei]+_b[cipa:agem]) //mean - 1 sd
nlcom(($m)*_b[cipa:agem_pisei]+_b[cipa:agem]) //mean  
nlcom(($m+$s)*_b[cipa:agem_pisei]+_b[cipa:agem]) //mean + 1 sd 
capture program drop bootm3
program bootm3, rclass
sem (cipa <- agem agem_pisei cpcipa, vce(cluster schoolid))
return scalar ses_low = (($m-$s)*_b[cipa:agem_pisei]+_b[cipa:agem])
return scalar ses_mean = (($m)*_b[cipa:agem_pisei]+_b[cipa:agem])
return scalar ses_high = (($m+$s)*_b[cipa:agem_pisei]+_b[cipa:agem])
end

bootstrap r(ses_high) r(ses_mean) r(ses_low), reps(10000) nodots: bootm3
estat boot, bc percentile
est sto s4_tot

dis (_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)) // t-value (difference in total effects high vs low SES)
dis (2 * ttail(15352, abs((_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)))))	//p-value

***Transition to higher tertiary education***
*direct effects for higher tertiary education 
sem (tra_stud2 <- agem agem_pisei cpcipa) (cipa <- tra_stud2 agem agem_pisei cpcipa), vce(cluster schoolid)
est sto app_stud2
nlcom(($m-$s)*_b[cipa:agem_pisei])+_b[cipa:agem] //mean - 1 sd
nlcom(($m)*_b[cipa:agem_pisei])+_b[cipa:agem] //mean  
nlcom(($m+$s)*_b[cipa:agem_pisei])+_b[cipa:agem] //mean + 1 sd 
capture program drop bootm3
program bootm3, rclass
sem (tra_stud2 <- agem agem_pisei cpcipa) (cipa <- agem tra_stud2 agem_pisei cpcipa, vce(cluster schoolid))
return scalar ses_low = (($m-$s)*_b[cipa:agem_pisei]+_b[cipa:agem])
return scalar ses_mean = (($m)*_b[cipa:agem_pisei]+_b[cipa:agem])
return scalar ses_high = (($m+$s)*_b[cipa:agem_pisei]+_b[cipa:agem])
end

bootstrap r(ses_high) r(ses_mean) r(ses_low), reps(10000) nodots: bootm3
estat boot, bc percentile
est sto s4_tra_stud2_dir

dis (_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)) // t-value (difference in direct effects high vs low SES)
dis (2 * ttail(15352, abs((_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)))))	//p-value

*indirect effects for higher tertiary education
sem (tra_stud2 <- agem agem_pisei cpcipa) (cipa <- tra_stud2 agem agem_pisei cpcipa), vce(cluster schoolid)
nlcom(_b[tra_stud2:agem]+($m-$s)*_b[tra_stud2:agem_pisei])*_b[cipa:tra_stud2] //mean - 1 sd
nlcom(_b[tra_stud2:agem]+($m)*_b[tra_stud2:agem_pisei])*_b[cipa:tra_stud2] //mean  
nlcom(_b[tra_stud2:agem]+($m+$s)*_b[tra_stud2:agem_pisei])*_b[cipa:tra_stud2] //mean + 1 sd 
capture program drop bootm3
program bootm3, rclass
sem (tra_stud2 <- agem agem_pisei cpcipa) (cipa <- agem tra_stud2 agem_pisei cpcipa, vce(cluster schoolid))
return scalar ses_low = (_b[tra_stud2:agem]+($m-$s)*_b[tra_stud2:agem_pisei])*_b[cipa:tra_stud2]
return scalar ses_mean = (_b[tra_stud2:agem]+($m)*_b[tra_stud2:agem_pisei])*_b[cipa:tra_stud2]
return scalar ses_high = (_b[tra_stud2:agem]+($m+$s)*_b[tra_stud2:agem_pisei])*_b[cipa:tra_stud2]
end

bootstrap r(ses_high) r(ses_mean) r(ses_low), reps(10000) nodots: bootm3
estat boot, bc percentile
est sto s4_tra_stud2_ind

dis (_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)) // t-value (difference in indirect effects high vs low SES)
dis (2 * ttail(15352, abs((_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)))))	//p-value

*Produce Table 3
esttab s4_tra_stud2_dir s4_tra_stud2_ind s4_tot, b(4) se(4)
esttab s4_tra_stud2_dir s4_tra_stud2_ind s4_tot using mediationanalysis_maintext.rtf, ///
 replace b(4) se(4) wide nogaps ///
 mtitle("Direct effect of age" "Indirect effect of age via transition to higher tertiary education" "Total effect of age") nonumbers ///
 title("Results from moderated mediation analyses (dependent var.: participation in voluntary association)") ///
 coeflabels(_bs_1 "High SES" _bs_2 "Mean SES" _bs_3 "Low SES") ///
 addnote(Results from the first of the 40 multiply-imputed datasets (Rubin, 1987). Coefficients were obtained using 10,000 bootstrapping estimates. Standard errors are cluster-corrected at the school level. High SES = mean + 1 SD, Low SES = mean – 1 SD. In order to carry out these analyses in Stata's structural equation modelling framework, we demeaned the data.)
 
***10.3. Table S2: Moderated Mediation Analysis (all transitions) ***
*********************************************************************

***Transition to Training on the job / work***
*direct effects for work
sem (tra_totj2 <- agem agem_pisei cpcipa) (cipa <- tra_totj2 agem agem_pisei cpcipa), vce(cluster schoolid)
est sto app_totj2
nlcom(($m-$s)*_b[cipa:agem_pisei])+_b[cipa:agem] //mean - 1 sd
nlcom(($m)*_b[cipa:agem_pisei])+_b[cipa:agem] //mean  
nlcom(($m+$s)*_b[cipa:agem_pisei])+_b[cipa:agem] //mean + 1 sd 
capture program drop bootm3
program bootm3, rclass
sem (tra_totj2 <- agem agem_pisei cpcipa) (cipa <- agem tra_totj2 agem_pisei cpcipa, vce(cluster schoolid))
return scalar ses_low = (($m-$s)*_b[cipa:agem_pisei]+_b[cipa:agem])
return scalar ses_mean = (($m)*_b[cipa:agem_pisei]+_b[cipa:agem])
return scalar ses_high = (($m+$s)*_b[cipa:agem_pisei]+_b[cipa:agem])
end

bootstrap r(ses_high) r(ses_mean) r(ses_low), reps(10000) nodots: bootm3
estat boot, bc percentile
est sto s4_tra_totj2_dir

dis (_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)) // t-value (difference in direct effects high vs low SES)
dis (2 * ttail(15352, abs((_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)))))	//p-value 

*indirect effects for work
sem (tra_totj2 <- agem agem_pisei cpcipa) (cipa <- tra_totj2 agem agem_pisei cpcipa), vce(cluster schoolid)
nlcom(_b[tra_totj2:agem]+($m-$s)*_b[tra_totj2:agem_pisei])*_b[cipa:tra_totj2] //mean - 1 sd
nlcom(_b[tra_totj2:agem]+($m)*_b[tra_totj2:agem_pisei])*_b[cipa:tra_totj2] //mean  
nlcom(_b[tra_totj2:agem]+($m+$s)*_b[tra_totj2:agem_pisei])*_b[cipa:tra_totj2] //mean + 1 sd 
capture program drop bootm3
program bootm3, rclass
sem (tra_totj2 <- agem agem_pisei cpcipa) (cipa <- agem tra_totj2 agem_pisei cpcipa, vce(cluster schoolid))
return scalar ses_low = (_b[tra_totj2:agem]+($m-$s)*_b[tra_totj2:agem_pisei])*_b[cipa:tra_totj2]
return scalar ses_mean = (_b[tra_totj2:agem]+($m)*_b[tra_totj2:agem_pisei])*_b[cipa:tra_totj2]
return scalar ses_high = (_b[tra_totj2:agem]+($m+$s)*_b[tra_totj2:agem_pisei])*_b[cipa:tra_totj2]
end

bootstrap r(ses_high) r(ses_mean) r(ses_low), reps(10000) nodots: bootm3
estat boot, bc percentile
est sto s4_tra_totj2_ind

dis (_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)) // t-value (difference in indirect effects high vs low SES)
dis (2 * ttail(15352, abs((_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)))))	//p-value

esttab s4_tra_totj2_dir s4_tra_totj2_ind s4_tot, b(4) se(4)
*Produce Table S2: Moderated mediation
esttab s4_tra_totj2_dir s4_tra_totj2_ind s4_tot using mediationanalysis_appendix_work.rtf, ///
 replace b(4) se(4) wide nogaps ///
 mtitle("Direct effect of age" "Indirect effect of age via transition to work" "Total effect of age") nonumbers ///
 title("Results from moderated mediation analyses (dependent var.: participation in voluntary association)") ///
 coeflabels(_bs_1 "High SES" _bs_2 "Mean SES" _bs_3 "Low SES") ///
 addnote(Results from the first of the 40 multiply-imputed datasets (Rubin, 1987). Coefficients were obtained using 10,000 bootstrapping estimates. Standard errors are cluster-corrected at the school level. High SES = mean + 1 SD, Low SES = mean – 1 SD. In order to carry out these analyses in Stata's structural equation modelling framework, we demeaned the data.)

***Transition to Orientation***
*direct effects for orientation
sem (tra_orie2 <- agem agem_pisei cpcipa) (cipa <- tra_orie2 agem agem_pisei cpcipa), vce(cluster schoolid)
est sto app_orie2
nlcom(($m-$s)*_b[cipa:agem_pisei])+_b[cipa:agem] //mean - 1 sd
nlcom(($m)*_b[cipa:agem_pisei])+_b[cipa:agem] //mean  
nlcom(($m+$s)*_b[cipa:agem_pisei])+_b[cipa:agem] //mean + 1 sd 
capture program drop bootm3
program bootm3, rclass
sem (tra_orie2 <- agem agem_pisei cpcipa) (cipa <- agem tra_orie2 agem_pisei cpcipa, vce(cluster schoolid))
return scalar ses_low = (($m-$s)*_b[cipa:agem_pisei]+_b[cipa:agem])
return scalar ses_mean = (($m)*_b[cipa:agem_pisei]+_b[cipa:agem])
return scalar ses_high = (($m+$s)*_b[cipa:agem_pisei]+_b[cipa:agem])
end

bootstrap r(ses_high) r(ses_mean) r(ses_low), reps(10000) nodots: bootm3
estat boot, bc percentile
est sto s4_tra_orie2_dir

dis (_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)) // t-value (difference in direct effects high vs low SES)
dis (2 * ttail(15352, abs((_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)))))	//p-value

*indirect effects for orientation
sem (tra_orie2 <- agem agem_pisei cpcipa) (cipa <- tra_orie2 agem agem_pisei cpcipa), vce(cluster schoolid)
nlcom(_b[tra_orie2:agem]+($m-$s)*_b[tra_orie2:agem_pisei])*_b[cipa:tra_orie2] //mean - 1 sd
nlcom(_b[tra_orie2:agem]+($m)*_b[tra_orie2:agem_pisei])*_b[cipa:tra_orie2] //mean  
nlcom(_b[tra_orie2:agem]+($m+$s)*_b[tra_orie2:agem_pisei])*_b[cipa:tra_orie2] //mean + 1 sd 
capture program drop bootm3
program bootm3, rclass
sem (tra_orie2 <- agem agem_pisei cpcipa) (cipa <- agem tra_orie2 agem_pisei cpcipa, vce(cluster schoolid))
return scalar ses_low = (_b[tra_orie2:agem]+($m-$s)*_b[tra_orie2:agem_pisei])*_b[cipa:tra_orie2]
return scalar ses_mean = (_b[tra_orie2:agem]+($m)*_b[tra_orie2:agem_pisei])*_b[cipa:tra_orie2]
return scalar ses_high = (_b[tra_orie2:agem]+($m+$s)*_b[tra_orie2:agem_pisei])*_b[cipa:tra_orie2]
end

bootstrap r(ses_high) r(ses_mean) r(ses_low), reps(10000) nodots: bootm3
estat boot, bc percentile
est sto s4_tra_orie2_ind

dis (_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)) // t-value (difference in indirect effects high vs low SES)
dis (2 * ttail(15352, abs((_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)))))	//p-value

esttab s4_tra_orie2_dir s4_tra_orie2_ind s4_tot, b(4) se(4)
*Produce Table S2: Moderated mediation
esttab s4_tra_orie2_dir s4_tra_orie2_ind s4_tot using mediationanalysis_appendix_orientation.rtf, ///
 replace b(4) se(4) wide nogaps ///
 mtitle("Direct effect of age" "Indirect effect of age via transition to orientation" "Total effect of age") nonumbers ///
 title("Results from moderated mediation analyses (dependent var.: participation in voluntary association)") ///
 coeflabels(_bs_1 "High SES" _bs_2 "Mean SES" _bs_3 "Low SES") ///
 addnote(Results from the first of the 40 multiply-imputed datasets (Rubin, 1987). Coefficients were obtained using 10,000 bootstrapping estimates. Standard errors are cluster-corrected at the school level. High SES = mean + 1 SD, Low SES = mean – 1 SD. In order to carry out these analyses in Stata's structural equation modelling framework, we demeaned the data.)

***Any transition***
*direct effects for any transition (trans)
sem (trans <- agem agem_pisei cpcipa) (cipa <- trans agem agem_pisei cpcipa), vce(cluster schoolid)
est sto app_trans
nlcom(($m-$s)*_b[cipa:agem_pisei])+_b[cipa:agem] //mean - 1 sd
nlcom(($m)*_b[cipa:agem_pisei])+_b[cipa:agem] //mean  
nlcom(($m+$s)*_b[cipa:agem_pisei])+_b[cipa:agem] //mean + 1 sd 
capture program drop bootm3
program bootm3, rclass
sem (trans <- agem agem_pisei cpcipa) (cipa <- agem trans agem_pisei cpcipa, vce(cluster schoolid))
return scalar ses_low = (($m-$s)*_b[cipa:agem_pisei]+_b[cipa:agem])
return scalar ses_mean = (($m)*_b[cipa:agem_pisei]+_b[cipa:agem])
return scalar ses_high = (($m+$s)*_b[cipa:agem_pisei]+_b[cipa:agem])
end

bootstrap r(ses_high) r(ses_mean) r(ses_low), reps(10000) nodots: bootm3
estat boot, bc percentile
est sto s4_trans_dir

dis (_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)) // t-value (difference in indirect effects high vs low SES)
dis (2 * ttail(15352, abs((_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)))))	//p-value

*indirect effects for any transition (trans)
sem (trans <- agem agem_pisei cpcipa) (cipa <- trans agem agem_pisei cpcipa), vce(cluster schoolid)
nlcom(_b[trans:agem]+($m-$s)*_b[trans:agem_pisei])*_b[cipa:trans] //mean - 1 sd
nlcom(_b[trans:agem]+($m)*_b[trans:agem_pisei])*_b[cipa:trans] //mean  
nlcom(_b[trans:agem]+($m+$s)*_b[trans:agem_pisei])*_b[cipa:trans] //mean + 1 sd 
capture program drop bootm3
program bootm3, rclass
sem (trans <- agem agem_pisei cpcipa) (cipa <- agem trans agem_pisei cpcipa, vce(cluster schoolid))
return scalar ses_low = (_b[trans:agem]+($m-$s)*_b[trans:agem_pisei])*_b[cipa:trans]
return scalar ses_mean = (_b[trans:agem]+($m)*_b[trans:agem_pisei])*_b[cipa:trans]
return scalar ses_high = (_b[trans:agem]+($m+$s)*_b[trans:agem_pisei])*_b[cipa:trans]
end

bootstrap r(ses_high) r(ses_mean) r(ses_low), reps(10000) nodots: bootm3
estat boot, bc percentile
est sto s4_trans_ind

dis (_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)) // t-value (difference in indirect effects high vs low SES)
dis (2 * ttail(15352, abs((_b[_bs_1] - _b[_bs_3])/(sqrt(_se[_bs_1]^2 + _se[_bs_3]^2)))))	//p-value

esttab s4_trans_dir s4_trans_ind s4_tot, b(4) se(4)
*Produce Table S2: Moderated mediation
esttab s4_trans_dir s4_trans_ind s4_tot using mediationanalysis_appendix_any_transition.rtf, ///
 replace b(4) se(4) wide nogaps ///
 mtitle("Direct effect of age" "Indirect effect of age via any transition" "Total effect of age") nonumbers ///
 title("Results from moderated mediation analyses (dependent var.: participation in voluntary association)") ///
 coeflabels(_bs_1 "High SES" _bs_2 "Mean SES" _bs_3 "Low SES") ///
 addnote(Results from the first of the 40 multiply-imputed datasets (Rubin, 1987). Coefficients were obtained using 10,000 bootstrapping estimates. Standard errors are cluster-corrected at the school level. High SES = mean + 1 SD, Low SES = mean – 1 SD. In order to carry out these analyses in Stata's structural equation modelling framework, we demeaned the data.)
 
*Full models for Moderated Mediation 
esttab app_stud2 app_totj2 app_orie2 app_trans app_tot, b(4) se(4)
esttab app_stud2 app_totj2 app_orie2 app_trans app_tot using fullmodels_mediation.rtf, ///
	replace b(4) se(4) wide nogaps ///
	mtitle("M1: via higher educ." "M2: via work" "M3: via orientation" "M4: via any transitions" "M5: without mediation") nonumbers ///
	title("Moderated mediation analysis - full models") ///
	addnote(Add notes here) ///
	order(agem agem_pisei cpcipa tra_stud2 tra_totj2 tra_orie2 trans _cons var(e.cipa)) ///
	coeflabels(agem "Age (in months)" trans "Any transition" tra_totj2 "Work" ///
	tra_stud2 "Higher tertiary education" tra_orie2 "Orientation" ///
	cpcipa "Classmates' participation" ///
	agem_pisei "Age X Parents' ISEI" _cons "Constant")


***10.4. Figure S3: Sensitivity analysis***
*******************************************
set scheme s1mono
*run sensitivity analysis:
medsens(regress tra_stud2 agem cpcipa) (regress cipa agem tra_stud2 cpcipa), mediate(tra_stud2) treat(agem) sims(100) graph 
est sto sens_main
*plot Figure S3:
twoway rarea _med_updelta0 _med_lodelta0 _med_rho if _med_rho>=-0.2 & _med_rho<=0.2, bcolor(gs14) xscale(range(-0.1 0.1)) || line _med_delta0 _med_rho if _med_rho>=-0.2 & _med_rho<=0.2, lcolor(black) ytitle("ACME") xtitle("Sensitivity parameter: {&rho}") legend(off) title("ACME({&rho})") xscale(range(-0.1 0.1)) lstyle(solid) || scatteri 0 -0.1 0 0.1, recast(line) lc(red) lstyle(solid) || scatteri -0.0033 0 0.0013 0, recast(line) lc(red) lstyle(solid) name(FigureS1, replace)


************************************************************************
***11. ADDITIONAL ANALYSES BASED ON THE GERMAN SURVEY ON VOLUNTEERING***
************************************************************************

*FWS (2014). German Survey on Volunteering (FWS), German Centre of Gerontology. DOI: 10.5156/FWS.2014.M.004.
*load data:
use $data\SUF_FWS_2014_V1-3.dta, clear

*keep only adolescents
keep if w4_alter<22

*relabel and recode variables of interest: involved in different fields of participation
label def dummy 0"Not involved" 1"Involved"
foreach k of varlist w4_201_01 - w4_201_14 {
	recode `k' (1=1) (2=0)
	label val `k' dummy
}

*to get a first idea of the data - tabulate the distributions across age groups
foreach k of varlist w4_201_01 - w4_201_14 {
	tab w4_alter `k'
}


*identify the most important sectors young people are active in: (all results from now on are weighted)
tabstat w4_201_01 - w4_201_14 [aw=w4_pgew] 
*-> The most important (out-of-school) sectors where young people are actively involved in are: Sports (66%), Music/Culture (26%), Religious (20%), Youth (13%), and Leisure (12%).
*We exclude the category School/Kindergarten (19%) because our paper specifically focuses on out-of-school contexts.

*Generate variables that summarize the weighted means for each age group for the most popular fields of participation
generate sport = .
quietly forvalues k = 14/21 {
	summarize w4_201_01 [aw=w4_pgew] if w4_alter== `k'
	replace sport = r(mean) if w4_alter==`k'
}
generate music_culture = .
quietly forvalues k = 14/21 {
	summarize w4_201_02 [aw=w4_pgew] if w4_alter== `k'
	replace music_culture = r(mean) if w4_alter==`k'
}
generate leisure = .
quietly forvalues k = 14/21 {
	summarize w4_201_03 [aw=w4_pgew] if w4_alter== `k'
	replace leisure = r(mean) if w4_alter==`k'
}

generate youth = .
quietly forvalues k = 14/21 {
	summarize w4_201_06 [aw=w4_pgew] if w4_alter== `k'
	replace youth = r(mean) if w4_alter==`k'
}
generate religious = .
quietly forvalues k = 14/21 {
	summarize w4_201_11 [aw=w4_pgew] if w4_alter== `k'
	replace religious = r(mean) if w4_alter==`k'
}

tab sport w4_alter //Number of observations

*Plot Figure S2
twoway  line sport w4_alter, lpattern(solid) lcolor(gs0) sort ///
		|| line music_culture w4_alter, lpattern("_") lcolor(gs0) sort ///
		|| line leisure w4_alter, lpattern("-") lcolor(gs0) sort ///
		|| line youth w4_alter, lpattern("..._...") lcolor(gs0) sort ///
		|| line religious w4_alter, lpattern("..") lcolor(gs0) sort ///
	ytitle("Actively participate", size(medium)) xtitle("Age in years", size(medium)) ///
	ylabel(0 "0 %" 0.2 "20 %" 0.4 "40 %" 0.6 "60 %" 0.8 "80 %", angle(0) labsize(medium)) ///
	xlabel(14"14" 15"15" 16"16" 17"17" 18"18" 19"19" 20"20" 21"21", labsize(medium)) ///
	legend(colgap(3) symxsize(9) keygap(1) order(1 "Sports" 2 "Music/Culture" 3 "Leisure" 4 "Youth" 5 "Religious") rows(2) justification(centre)) scheme(s1mono) ///
	name(FigureS2, replace)
	

log close
