***********************************************************
*Project: Teacher's Bias in Assessments
*Code: Replication of data cleaning and preparation
*Authors: Carlos J. Gil-Hernández, Irene Pañeda-Fernández, 
*         Leire Salazar, and Jonatan Castaño-Muñoz
*Last Update: 09/11/2023
*Software: STATA/MP 17
***********************************************************

//0: Setup

** Install packages if necessary
*ssc install fre
*ssc install dups

** Working directory (*** ENTER YOUR WORKING DIRECTORY/ROOT HERE, that is, the path to where you save the "replication files" folder ***)
global wkd "~/Dropbox/Teacher's Bias/Research Design/Experiment/replication files/" 
cd "$wkd"
clear all
** Opening dataset as directly downloaded from Qualtrics, after anoymizing the sampling institutions and respondents IDs
use "data/STATA/raw_dataset_anonymized.dta", clear

* In the following do-file we will prepare the data for analysis. Sections:
** 1) Dataset cleaning & sample selection
** 2) Preparing variables

***********************************************
*** 1) DATASET CLEANING & SAMPLE SELECTION ****
***********************************************

* Encoding variables that are in string format
    des
	foreach var of varlist q0 q4 q5 q6 q7 q8 q8b q9 q11b_1 q12 q13 q14 q15 correo nombre {
	encode `var', gen(`var'_i)
	}
    order q10_1, after(q9_i)
    order q16_1-q16_4, after(q15_i)
	
* Dropping irrelevant metadata variables
    drop distributionchannel userlanguage
	
* Dropping empty variables
	drop status recipientlastname recipientfirstname externalreference q_relevantidduplicate q_relevantidlaststartdate

* Dropping duplicated variables
    drop asignaturassuspensas comportamiento sexo q0 q4-q9 q11b_1-q15
	
* Keeping only finished responses
	keep if finished=="TRUE"
* 441 unfinished responses deleted

* Keeping only respondents who accepted informed consent
	drop if q0_i==2
* 2 obs deleted

* Correcting the sampling units (universities) IDs for a few observations
	fre q11a_1
	rename q11a_1 q11a_1_i
	order q11a_1_i, after(q9_i)
	* Insert missing university for respondent who used personalized link
	* Exactly 1 missing, corresponding to this person who filled out survey before we got rid of personalized links
	replace q11a_1_i=6 if q11a_1_i==.

	* University #1 is within #15
	replace q11a_1_i=15 if q11a_1_i==1

	* We know a few entered University #19 by mistake, they really are from #2
	replace q11a_1_i=2 if q11a_1_i==19

	* Deleting only 1 observation collected from University #9
	recode q11a_1_i 9=.
	drop if q11a_1_i==.
	* 1 obs deleted

* Drop students who are studying a different degree that's not teaching
	drop if q11b_1_i==6
	* 38 obs deleted

* Drop obs under 18 years old
	gen age=2023-q10_1
	sum age
	recode age 16/17=.
	drop if age==.
	* 2 obs deleted

*** CHECKING FOR FRAUDULENT ANSWERS ***

* Note: we show here the steps we took but due to data protection, we do not share ipaddress or email data in this replication folder, thus this section cannot be replicated.
/*
** Checking potential same respondents answering survey twice
dups
* No perfect duplicates (along all variables)
* Check for duplicates in ipaddress
* Note: ipaddress can be the same if students are answering from the same university wifi
dups ipaddress

* Create a variable (dup_id) that identifies whether obs is unique (dup_ip=0), duplicated once (dup_ip=1), twice (dup_ip=2), etc
duplicates report ipaddress
duplicates tag ipaddress, gen(dup_ip)
tab dup_ip

* Investigate further those duplicate observations that are not unique on ipaddress field
sort ipaddress startdate enddate
br ipaddress dup_ip q_relevantidduplicatescore q_relevantidfraudscore q11a_1 startdate enddate q17_2 q11b_1 q12 q13 q14 q15 ses_high sex_female spanish essay if dup_ip!=0

** No clear pattern to be discerned here. Note that in some of the cases (eg ipaddress 104.28.88.130), all email addresses given are institutional (less likely to be made up).

** Check the Fraud detection variables provided by Qualtrics. q_relevantidduplicatescore (>=75 means the response is likely a duplicate) and q_relevantidfraudscore (>=30 means the response is likely fraudulent and a bot.)
* Only in one of the 63 duplicates is flagged by both variables.
* Overall, 98.3% of dataset passes the q_relevantidduplicatescore test and 98.22% passess the q_relevantidfraudscore test
* That is, less than 2% of observations were flagged by Qualtrics

** We do not delete any of these 63 observations that are duplicate in ipaddress as there is no clear pattern or reason to think they are fraudulent.

* Check for duplicates of email variable
sort q17_2
duplicates report q17_2
duplicates tag q17_2, gen(dup_email)
sort q11a_1 q17_2
br responseid q17_2 dup_ip dup_email q_relevantidduplicatescore q_relevantidfraudscore q11a_1 q10_1 startdate enddate q17_2 q11b_1 q12 q13 q14 q15 ses_high sex_female spanish essay if (q_relevantidduplicatescore>=75 | q_relevantidfraudscore>=30 | dup_ip!=0 | dup_email!=0)
/*
From the list generated by the code above, we
1) Find & keep only first instance of observations that have emails that are the same.
responseid=R_2uPOQBbe0S8PQiK and responseid=R_ptjHn0r3FTG1WWl
responseid=R_3g1JuE8INqwa2yP and responseid=R_DSR3HCTZHcDWALL

2) Find & keep only first instance of observations whose emails are not exactly the same but are likely to correspond to the same person  (eg same name but one using capital letter, or same name but one using a diminutive of the name)
*/
*/
* Dropping one of the two duplicate emails (we keep the first response received)
drop if responseid=="R_ptjHn0r3FTG1WWl"
drop if responseid=="R_DSR3HCTZHcDWALL"
drop if responseid=="R_W70PKtrRyFcbwA1"

* Dropping one of the two similar emails that are likely to be the same person (we keep the first response received)
drop if responseid=="R_2axDrPjs82hWkdR"
drop if responseid=="R_3RvUzGq5Cqe7nZN"
drop if responseid=="R_3p4iwkzGpSpRmzy"
drop if responseid=="R_31iK6mKwWA1fBK8"
drop if responseid=="R_1GyjZJAawhzShul"
/*
* Create a list of emails that are not the same, but similar using matchit and freqindex
*ssc install matchit
*ssc install freqindex
keep q17_2 q11a_1 
split q17_2, parse("@") generate(email)
drop email2
preserve
rename email1 email1_v2
rename q11a_1  q11a_1_v2
rename q17_2 q17_2_v2
tempfile email1_v2_q11a_1_v2_q17_2_v2
save `email1_v2_q11a_1_v2_q17_2_v2'
restore
cross using `email1_v2_q11a_1_v2_q17_2_v2'
drop if email1_v2>=email1
matchit email1 email1_v2
keep if similscore>0.7
save "/Users/irenepaneda/Dropbox/Teacher's Bias/Research Design/Experiment/Data/similar_emails.dta", replace
** Explore the list in this dataset to manually find potential duplicates
*/

*drop irrelevant metadata information on fraudulent responses for replication analyses
drop q_recaptchascore q_relevantidduplicatescore q_relevantidfraudscore

*** CHECKING FOR RESPONSE TIME ***

* Check for overall response time
	gen duration_min=durationinseconds/60
	tab duration_min
* Fastest response is someone doing the entire survey in 1.8 minutes.
	sum duration_min, d

* Check how long they spent seeing the student profile?
* Variables that capture seconds spent in student profile: q0a2_timer_pagesubmit (for those in PC) and q0b2_timer_pagesubmit (for those in phone)
	destring q0a2_timer_pagesubmit, gen(q0a2_timer_pagesubmit_de) force
	sum q0a2_timer_pagesubmit_de q0b2_timer_pagesubmit
	gen studentprofiletime=.
	replace studentprofiletime=q0a2_timer_pagesubmit_de if device_phone==0
	replace studentprofiletime=q0b2_timer_pagesubmit if device_phone==1
	sum studentprofiletime, d

	gen studentprofile_min=studentprofiletime/60
	sum studentprofile_min, d
	tab studentprofile_min

* Check how long they spent on the essay
	sum q0bba_timer_pagesubmit q0bbb_timer_pagesubmit q0baa_timer_pagesubmit q0bab_timer_pagesubmit q0aba_timer_pagesubmit q0abb_timer_pagesubmit q0aaa_timer_pagesubmit q0aab_timer_pagesubmit

* Need to destring: q0bba_timer_pagesubmit, q0bbb_timer_pagesubmit, q0bab_timer_pagesubmit, q0aba_timer_pagesubmit, q0aaa_timer_pagesubmit
	destring q0bba_timer_pagesubmit, gen(q0bba_timer_pagesubmit_de) force
	destring q0bbb_timer_pagesubmit, gen(q0bbb_timer_pagesubmit_de) force
	destring q0bab_timer_pagesubmit, gen(q0bab_timer_pagesubmit_de) force
	destring q0aba_timer_pagesubmit, gen(q0aba_timer_pagesubmit_de) force
	destring q0aaa_timer_pagesubmit, gen(q0aaa_timer_pagesubmit_de) force

	gen essaytime=.
	foreach var of varlist q0bba_timer_pagesubmit_de q0bbb_timer_pagesubmit_de q0baa_timer_pagesubmit q0bab_timer_pagesubmit_de q0aba_timer_pagesubmit_de q0abb_timer_pagesubmit q0aaa_timer_pagesubmit_de q0aab_timer_pagesubmit {
	replace essaytime=`var' if `var'!=.
	}
	sum essaytime, d
	gen essaytime_min=essaytime/60
	sum essaytime_min, d
	tab essaytime_min

	xtile qduration_essay_min=essaytime_min, nq(3)
	tabstat essaytime_min, by(qduration_essay_min)
	bys qduration_essay_min: sum essaytime_min, d
	label define qduration_essay_min 1 "<1.7" 2 "1.7-2.5" 3 ">2.5", replace
	label value qduration_essay_min qduration_essay_min
	fre qduration_essay_min


* Check how long they spent on the other outcomes (teacher expectations for grade retention and making it to bachillerato)
	sum q3bba_timer_pagesubmit q3bbb_timer_pagesubmit q3baa_timer_pagesubmit q3bab_timer_pagesubmit q3aba_timer_pagesubmit q3abb_timer_pagesubmit q3aaa_timer_pagesubmit q3aab_timer_pagesubmit

* Need to destring q3baa_timer_pagesubmit
	destring q3baa_timer_pagesubmit, gen(q3baa_timer_pagesubmit_de) force

	gen otheroutcomestime=.
	foreach var of varlist q3bba_timer_pagesubmit q3bbb_timer_pagesubmit q3baa_timer_pagesubmit_de q3bab_timer_pagesubmit q3aba_timer_pagesubmit q3abb_timer_pagesubmit q3aaa_timer_pagesubmit q3aab_timer_pagesubmit {
	replace otheroutcomestime=`var' if `var'!=.
	}

	gen otheroutcomestime_min=otheroutcomestime/60
	sum otheroutcomestime_min, d
     
	order duration_min-otheroutcomestime_min, after(recordeddate)
	
*************************************************
***** 2) PREPARING VARIABLES FOR ANALYSIS *******
*************************************************

* Naming variables from Spanish to English
rename ensayo_cc_alto essay_cc_high // 1=high cultural capital; 0=low cultural capital
rename ensayo_bueno essay_good // 1=good essay 0=bad essay
rename aprobado allpassed // 1=all subjects passed; 3=3subjects failed
rename correo_i father_mail
rename nombre_i student_name
drop correo nombre
order sex_female ses_high spanish essay_good essay_cc_high allpassed behaviour_good, after(device_phone)

* Labelling variables that are missing a clear name label *

*Respondent's Survey Info & ID
label variable responseid "Anonymized Respondent ID"
label variable q0_i "Informed Consent"
label variable finished "Complete Cases"
label variable device_phone "Device Used"
order duration_min, before(durationinseconds)

*Survey Timing
label variable duration_min        "Total Duration (Minutes)"
label variable studentprofiletime  "Screen 1 Duration: Student File"
label variable studentprofile_min  "Screen 1 Duration: Student File (Minutes)"
label variable essaytime           "Screen 2 Duration: Essay + Outcome 1" 
label variable essaytime_min       "Screen 2 Duration: Essay + Outcome 1 (Minutes)" 
label variable qduration_essay_min "Q3 - Screen 2 Duration: Essay + Outcome 1 (Minutes)"
label variable otheroutcomestime   "Screen 3 Duration: File + Outcomes 2-3" 
label variable otheroutcomestime_min "Screen 3 Duration: File + Outcomes 2-3 (Minutes)" 
order responseid q0_i finished device_phone, before(startdate)

* Main manipulation variables (indicating vignette dimensions or factors). All dummy vars
label variable student_name "Student File: Name"
label variable father_mail "Student File: Father's Email"
label variable essay "Essay Type: Quality; Cultural Capital; SES"
label variable sex_female "Factor: Gender (1=Girl)"
label variable ses_high "Factor: Father's SES (1=High)"
label variable spanish "Factor: Ethnic Origin (1=Native)"
label variable essay_good "Factor: Essay Quality (1=High)"
label variable essay_cc_high "Factor: Essay Cultural Capital Signal (1=High)"
label variable allpassed "Factor: Number of Subjects Passed/Failed (1=All Passed)"
label variable behaviour_good "Factor: Behaviour and Effort (1=Good)"
order sex_female-behaviour_good, after(essay)
order student_name father_mail, before(essay)

* Manipulation Checks
label variable q4_i  "Gender-Check"
label variable q5_i  "Ethnic-Check"
label variable q6_i  "SES-Check" 
label variable q7_i  "Subjects Failed-Check" 
label variable q8_i  "Behaviour-Check" 
label variable q8b_i "Cultural Capital-Check" 
order q4_i-q8b_i, after(q16_4)

* Respondent's Socio-demographic Characteristics
label variable q9_i     "Gender-Respondent"
label variable q10_1    "Birth year-Respondent" 
label variable age       "Age Groups"
label variable q11a_1_i "University/Faculty Anonymized ID"
label variable q11b_1_i "BA Grade-Respondent"
label variable q12_i    "Grade retention-Respondent"  
label variable q13_i    "SES-Respondent" 
label variable q14_i    "Migrant-Respondent" 
label variable q15_i    "Parental migrants-Respodent"
order age, after(q10_1)
order q11a_1_i, before(responseid)

* Respondent's Attitudes towards Educational Inequality
label variable q16_1 "Cognitive-Success"
label variable q16_2 "SES-Success"
label variable q16_3 "Effort-Success"
label variable q16_4 "Luck-Success"

*Variable Blocks
gen ID=.
label variable ID "---------------"
order ID, before(q11a_1_i)
gen TIMING=.
label variable TIMING "---------------"
order TIMING, after(device_phone)
gen FACTORS=.
label variable FACTORS "---------------"
order FACTORS, after(otheroutcomestime_min)
gen MANIPULATION_CHECKS=.
label variable MANIPULATION_CHECKS "---------------"
order MANIPULATION_CHECKS, after(q16_4)
gen RESPONDENT_VARIABLES=.
label variable RESPONDENT_VARIABLES "---------------"
order RESPONDENT_VARIABLES, after(behaviour_good)
gen RESPONDENT_ATTITUDES=.
label variable RESPONDENT_ATTITUDES "---------------"
order RESPONDENT_ATTITUDES, after(q15_i)

* Creating a unique variable for each of the three variables (outcome measures are captured in different variables per treatment group in raw data)

* Outcome 1: essay grade
gen grade_essay=.
foreach var of varlist q1bba_1 q1bbb_1 q1baa_1 q1bab_1 q1aba_1 q1abb_1 q1aaa_1 q1aab_1 {
replace grade_essay=`var' if `var'!=.
}
label variable grade_essay "Outcome 1: Essay Grade"

	* Good Essay
	gen grade_essay_good=.
	foreach var of varlist q1aba_1 q1abb_1 q1aaa_1 q1aab_1 {
	replace grade_essay_good=`var' if `var'!=.
	}
	label variable grade_essay_good "Good Essay Grade"

	* Bad Essay
	gen grade_essay_bad=.
	foreach var of varlist q1bba_1 q1bbb_1 q1baa_1 q1bab_1 {
	replace grade_essay_bad=`var' if `var'!=.
	}
	label variable grade_essay_bad "Bad Essay Grade"

* Outcome 2: grade retention recommendation
gen repit=.
foreach var of varlist q2bba_pc_1 q2bba_phone_1 q2bbb_pc_1 q2bbb_phone_1 q2baa_pc_1 q2baa_phone_1 q2bab_pc_1 q2bab_phone_1 q2aba_pc_1 q2aba_phone_1 q2abb_pc_1 q2abb_phone_1 q2aaa_pc_1 q2aaa_phone_1 q2aab_pc_1 q2aab_phone_1 {
replace repit=`var' if `var'!=.
}
label variable repit "Outcome 2: Grade Retention"

* Outcome 3: educational expectations
gen expect=.
foreach var of varlist q3bba_1 q3bbb_1 q3baa_1 q3bab_1 q3aba_1 q3abb_1 q3aaa_1 q3aab_1 {
replace expect=`var' if `var'!=.
}
label variable expect "Outcome 3: Edu. Expectations Acad. Track"

* Mediator: respondent's assessment of how much interest and support the family provides to the student
gen psupport=.
foreach var of varlist q3bba_2_1 q3bbb_2_1 q3baa_2_1 q3bab_2_1 q3aba_2_1 q3abb_2_1 q3aaa_2_1 q3aab_2_1 {
replace psupport=`var' if `var'!=.
}
label variable psupport "Mechanism: Parental Support"

* Drop irrelevant/redundant information
drop q0a2_timer_firstclick-q3aab_2_timer_clickcount progress 
	
gen OUTCOMES=.
label variable OUTCOMES "---------------"
order OUTCOMES, after(behaviour_good)
order grade_essay-psupport, after(OUTCOMES)

*Right/Wrong Manipulation Checks by each Experimental Factor
fre q4_i q5_i q6_i q7_i q8_i q8b_i

*Sex
tab sex_female q4_i, row
fre q4_i
gen sex_signal=.
replace sex_signal=0 if sex_female==1 & q4_i==2
replace sex_signal=0 if sex_female==0 & q4_i==1
replace sex_signal=1 if sex_female==1 & q4_i==1
replace sex_signal=1 if sex_female==0 & q4_i==2
replace sex_signal=2 if q4_i==3
tab sex_signal q4_i
tab sex_signal sex_female
label define sex_signal 0 "Wrong" 1 "Right" 2 "Don't Recall", replace
label value sex_signal sex_signal
fre sex_signal
tab sex_female q4_i, row

*Migrant
gen migrant=.
replace migrant=1 if spanish==0
replace migrant=0 if spanish==1
tab spanish migrant
tab migrant q5_i, row
fre q5_i
gen migrant_signal=.
replace migrant_signal=0 if migrant==1 & q5_i==1
replace migrant_signal=0 if q5_i==2
replace migrant_signal=0 if q5_i==4
replace migrant_signal=0 if migrant==0 & q5_i==5
replace migrant_signal=1 if migrant==1 & q5_i==5
replace migrant_signal=1 if migrant==0 & q5_i==1
replace migrant_signal=2 if q5_i==3
tab migrant_signal q5_i
tab migrant_signal migrant
label define migrant_signal 0 "Wrong" 1 "Right" 2 "Don't Recall", replace
label value migrant_signal migrant_signal
fre migrant_signal
tab migrant q5_i, row

*SES
tab ses_high q6_i, row
fre q6_i
gen SES_signal=.
replace SES_signal=0 if q6_i==1
replace SES_signal=0 if q6_i==2
replace SES_signal=0 if ses_high==1 & q6_i==5
replace SES_signal=0 if ses_high==0 & q6_i==4
replace SES_signal=1 if ses_high==1 & q6_i==4
replace SES_signal=1 if ses_high==0 & q6_i==5
replace SES_signal=2 if q6_i==3
tab SES_signal q6_i
tab SES_signal ses_high
label define SES_signal 0 "Wrong" 1 "Right" 2 "Don't Recall", replace
label value SES_signal SES_signal
fre SES_signal
tab ses_high q6_i, row

*Subjects Failed
gen failed=.
replace failed=0 if allpassed==1
replace failed=1 if allpassed==0
tab allpassed failed
tab failed q7_i, row
fre q7_i
gen failed_signal=.
replace failed_signal=0 if failed==0 & q7_i>=1 & q7_i<=3
replace failed_signal=0 if failed==1 & q7_i==4
replace failed_signal=1 if failed==0 & q7_i==4
replace failed_signal=1 if failed==1 & q7_i==3
replace failed_signal=2 if q7_i==5
tab failed_signal q7_i
tab failed_signal failed
label define failed_signal 0 "Wrong" 1 "Right" 2 "Don't Recall", replace
label value failed_signal failed_signal
fre failed_signal
tab failed q7_i, row

*Behaviour
tab behaviour_good q8_i, row
fre q8_i
gen behaviour_signal=.
replace behaviour_signal=0 if behaviour_good==1 & q8_i==3
replace behaviour_signal=0 if behaviour_good==0 & q8_i==2
replace behaviour_signal=1 if behaviour_good==0 & q8_i==3
replace behaviour_signal=1 if behaviour_good==1 & q8_i==2
replace behaviour_signal=2 if q8_i==1
tab behaviour_signal q8_i
tab behaviour_signal behaviour_good
label define behaviour_signal 0 "Wrong" 1 "Right" 2 "Don't Recall", replace
label value behaviour_signal behaviour_signal
fre behaviour_signal
tab behaviour_good q8_i, row

*Cultural Capital
tab essay_cc_high q8b_i, row
fre q8b_i
gen cc_signal=.
replace cc_signal=0 if essay_cc_high==1 & q8b_i==2
replace cc_signal=0 if essay_cc_high==0 & q8b_i==3
replace cc_signal=1 if essay_cc_high==0 & q8b_i==2
replace cc_signal=1 if essay_cc_high==1 & q8b_i==3
replace cc_signal=2 if q8b_i==1
tab cc_signal q8_i
tab cc_signal essay_cc_high
label define cc_signal 0 "Wrong" 1 "Right" 2 "Don't Recall", replace
label value cc_signal cc_signal
fre cc_signal
tab essay_cc_high q8b_i, row

*All Signals
gen signals=.
replace signals=1 if sex_signal==1 & migrant_signal==1 & SES_signal==1 & failed_signal==1 & behaviour_signal==1 & cc_signal==1
replace signals=0 if sex_signal==0 & migrant_signal==0 & SES_signal==0 & failed_signal==0 & behaviour_signal==0 & cc_signal==0
replace signals=2 if sex_signal==2 & migrant_signal==2 & SES_signal==2 & failed_signal==2 & behaviour_signal==2 & cc_signal==2
replace signals=3 if signals==.
label define signals 1 "All Signals Right" 0 "All Signals Wrong" 2 "Don't Recall Any Signal" 3 "Some Right/Wrong/Don't Recall", replace
label value signals signals
fre signals

*Labels
label variable sex_signal  "Gender-MC Result"
label variable migrant_signal "Ethnic-MC Result" 
label variable SES_signal   "SES-MC Result" 
label variable failed_signal  "Subjects Failed-MC Result" 
label variable behaviour_signal   "Behaviour-MC Result" 
label variable cc_signal "Cultural Capital-MC Result" 
label variable signals "All Manipulation Checks Results"

gen MANIPULATION_RIGHT_WRONG=.
label variable MANIPULATION_RIGHT_WRONG "---------------"
order MANIPULATION_RIGHT_WRONG, after(q8b_i)
order sex_signal-signals, after(MANIPULATION_RIGHT_WRONG)

*Vignettes of the Full Factorial Design: 128 Student's Vignettes/Profiles
sum essay_cc_high essay_good allpassed behaviour_good ses_high sex_female spanish
fre essay_cc_high essay_good allpassed behaviour_good ses_high sex_female spanish
sum sex_female migrant ses_high behaviour_good essay_good essay_cc_high failed

gen vignette=.
replace vignette=1 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=2 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=3 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=4 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=5 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=6 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=7 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=8 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=9 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=10 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=11 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=12 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=13 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=14 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=15 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=16 if sex_female==0 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=17 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=18 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=19 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=20 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=21 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=22 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=23 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=24 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=25 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=26 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=27 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=28 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=29 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=30 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=31 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=32 if sex_female==0 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=33 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=34 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=35 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=36 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=37 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=38 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=39 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=40 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=41 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=42 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=43 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=44 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=45 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=46 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=47 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=48 if sex_female==0 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=49 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=50 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=51 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=52 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=53 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=54 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=55 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=56 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=57 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=58 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=59 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=60 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=61 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=62 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=63 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=64 if sex_female==0 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=65 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=66 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=67 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=68 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=69 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=70 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=71 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=72 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=73 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=74 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=75 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=76 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=77 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=78 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=79 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=80 if sex_female==1 & migrant==0 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=81 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=82 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=83 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=84 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=85 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=86 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=87 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=88 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=89 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=90 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=91 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=92 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=93 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=94 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=95 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=96 if sex_female==1 & migrant==0 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=97 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=98 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=99 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=100 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=101 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=102 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=103 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=104 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=105 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=106 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=107 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=108 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=109 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=110 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=111 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=112 if sex_female==1 & migrant==1 & ses_high==1 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=113 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=114 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=115 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=116 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=117 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=118 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=119 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=120 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==1 & essay_good==0 & essay_cc_high==0 & failed==1
replace vignette=121 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==0
replace vignette=122 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==1 & failed==1
replace vignette=123 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==0
replace vignette=124 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==1 & essay_cc_high==0 & failed==1
replace vignette=125 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==0
replace vignette=126 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==1 & failed==1
replace vignette=127 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==0
replace vignette=128 if sex_female==1 & migrant==1 & ses_high==0 & behaviour_good==0 & essay_good==0 & essay_cc_high==0 & failed==1

label define vignette ///
1 "Male Spanish High-SES Good Behaviour Good Essay High Essay-CC All passed" ///	
2 "Male Spanish High-SES Good Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
3 "Male Spanish High-SES Good Behaviour Good Essay Low Essay-CC All passed" ///	
4 "Male Spanish High-SES Good Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
5 "Male Spanish High-SES Good Behaviour Bad Essay High Essay-CC All passed" ///	
6 "Male Spanish High-SES Good Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
7 "Male Spanish High-SES Good Behaviour Bad Essay Low Essay-CC All passed" ///	
8 "Male Spanish High-SES Good Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
9 "Male Spanish High-SES Bad Behaviour Good Essay High Essay-CC All passed" ///	
10 "Male Spanish High-SES Bad Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
11 "Male Spanish High-SES Bad Behaviour Good Essay Low Essay-CC All passed" ///	
12 "Male Spanish High-SES Bad Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
13 "Male Spanish High-SES Bad Behaviour Bad Essay High Essay-CC All passed" ///	
14 "Male Spanish High-SES Bad Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
15 "Male Spanish High-SES Bad Behaviour Bad Essay Low Essay-CC All passed" ///	
16 "Male Spanish High-SES Bad Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
17 "Male Spanish Low-SES Good Behaviour Good Essay High Essay-CC All passed" ///	
18 "Male Spanish Low-SES Good Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
19 "Male Spanish Low-SES Good Behaviour Good Essay Low Essay-CC All passed" ///	
20 "Male Spanish Low-SES Good Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
21 "Male Spanish Low-SES Good Behaviour Bad Essay High Essay-CC All passed" ///	
22 "Male Spanish Low-SES Good Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
23 "Male Spanish Low-SES Good Behaviour Bad Essay Low Essay-CC All passed" ///	
24 "Male Spanish Low-SES Good Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
25 "Male Spanish Low-SES Bad Behaviour Good Essay High Essay-CC All passed" ///	
26 "Male Spanish Low-SES Bad Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
27 "Male Spanish Low-SES Bad Behaviour Good Essay Low Essay-CC All passed" ///	
28 "Male Spanish Low-SES Bad Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
29 "Male Spanish Low-SES Bad Behaviour Bad Essay High Essay-CC All passed" ///	
30 "Male Spanish Low-SES Bad Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
31 "Male Spanish Low-SES Bad Behaviour Bad Essay Low Essay-CC All passed" ///	
32 "Male Spanish Low-SES Bad Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
33 "Male Moroccan High-SES Good Behaviour Good Essay High Essay-CC All passed" ///	
34 "Male Moroccan High-SES Good Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
35 "Male Moroccan High-SES Good Behaviour Good Essay Low Essay-CC All passed" ///	
36 "Male Moroccan High-SES Good Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
37 "Male Moroccan High-SES Good Behaviour Bad Essay High Essay-CC All passed" ///	
38 "Male Moroccan High-SES Good Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
39 "Male Moroccan High-SES Good Behaviour Bad Essay Low Essay-CC All passed" ///	
40 "Male Moroccan High-SES Good Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
41 "Male Moroccan High-SES Bad Behaviour Good Essay High Essay-CC All passed" ///	
42 "Male Moroccan High-SES Bad Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
43 "Male Moroccan High-SES Bad Behaviour Good Essay Low Essay-CC All passed" ///	
44 "Male Moroccan High-SES Bad Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
45 "Male Moroccan High-SES Bad Behaviour Bad Essay High Essay-CC All passed" ///	
46 "Male Moroccan High-SES Bad Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
47 "Male Moroccan High-SES Bad Behaviour Bad Essay Low Essay-CC All passed" ///	
48 "Male Moroccan High-SES Bad Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
49 "Male Moroccan Low-SES Good Behaviour Good Essay High Essay-CC All passed" ///	
50 "Male Moroccan Low-SES Good Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
51 "Male Moroccan Low-SES Good Behaviour Good Essay Low Essay-CC All passed" ///	
52 "Male Moroccan Low-SES Good Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
53 "Male Moroccan Low-SES Good Behaviour Bad Essay High Essay-CC All passed" ///	
54 "Male Moroccan Low-SES Good Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
55 "Male Moroccan Low-SES Good Behaviour Bad Essay Low Essay-CC All passed" ///	
56 "Male Moroccan Low-SES Good Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
57 "Male Moroccan Low-SES Bad Behaviour Good Essay High Essay-CC All passed" ///	
58 "Male Moroccan Low-SES Bad Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
59 "Male Moroccan Low-SES Bad Behaviour Good Essay Low Essay-CC All passed" ///	
60 "Male Moroccan Low-SES Bad Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
61 "Male Moroccan Low-SES Bad Behaviour Bad Essay High Essay-CC All passed" ///	
62 "Male Moroccan Low-SES Bad Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
63 "Male Moroccan Low-SES Bad Behaviour Bad Essay Low Essay-CC All passed" ///	
64 "Male Moroccan Low-SES Bad Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
65 "Female Spanish High-SES Good Behaviour Good Essay High Essay-CC All passed" ///	
66 "Female Spanish High-SES Good Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
67 "Female Spanish High-SES Good Behaviour Good Essay Low Essay-CC All passed" ///	
68 "Female Spanish High-SES Good Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
69 "Female Spanish High-SES Good Behaviour Bad Essay High Essay-CC All passed" ///	
70 "Female Spanish High-SES Good Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
71 "Female Spanish High-SES Good Behaviour Bad Essay Low Essay-CC All passed" ///	
72 "Female Spanish High-SES Good Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
73 "Female Spanish High-SES Bad Behaviour Good Essay High Essay-CC All passed" ///	
74 "Female Spanish High-SES Bad Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
75 "Female Spanish High-SES Bad Behaviour Good Essay Low Essay-CC All passed" ///	
76 "Female Spanish High-SES Bad Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
77 "Female Spanish High-SES Bad Behaviour Bad Essay High Essay-CC All passed" ///	
78 "Female Spanish High-SES Bad Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
79 "Female Spanish High-SES Bad Behaviour Bad Essay Low Essay-CC All passed" ///	
80 "Female Spanish High-SES Bad Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
81 "Female Spanish Low-SES Good Behaviour Good Essay High Essay-CC All passed" ///	
82 "Female Spanish Low-SES Good Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
83 "Female Spanish Low-SES Good Behaviour Good Essay Low Essay-CC All passed" ///	
84 "Female Spanish Low-SES Good Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
85 "Female Spanish Low-SES Good Behaviour Bad Essay High Essay-CC All passed" ///	
86 "Female Spanish Low-SES Good Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
87 "Female Spanish Low-SES Good Behaviour Bad Essay Low Essay-CC All passed" ///	
88 "Female Spanish Low-SES Good Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
89 "Female Spanish Low-SES Bad Behaviour Good Essay High Essay-CC All passed" ///	
90 "Female Spanish Low-SES Bad Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
91 "Female Spanish Low-SES Bad Behaviour Good Essay Low Essay-CC All passed" ///	
92 "Female Spanish Low-SES Bad Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
93 "Female Spanish Low-SES Bad Behaviour Bad Essay High Essay-CC All passed" ///	
94 "Female Spanish Low-SES Bad Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
95 "Female Spanish Low-SES Bad Behaviour Bad Essay Low Essay-CC All passed" ///	
96 "Female Spanish Low-SES Bad Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
97 "Female Moroccan High-SES Good Behaviour Good Essay High Essay-CC All passed" ///	
98 "Female Moroccan High-SES Good Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
99 "Female Moroccan High-SES Good Behaviour Good Essay Low Essay-CC All passed" ///	
100 "Female Moroccan High-SES Good Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
101 "Female Moroccan High-SES Good Behaviour Bad Essay High Essay-CC All passed" ///	
102 "Female Moroccan High-SES Good Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
103 "Female Moroccan High-SES Good Behaviour Bad Essay Low Essay-CC All passed" ///	
104 "Female Moroccan High-SES Good Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
105 "Female Moroccan High-SES Bad Behaviour Good Essay High Essay-CC All passed" ///	
106 "Female Moroccan High-SES Bad Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
107 "Female Moroccan High-SES Bad Behaviour Good Essay Low Essay-CC All passed" ///	
108 "Female Moroccan High-SES Bad Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
109 "Female Moroccan High-SES Bad Behaviour Bad Essay High Essay-CC All passed" ///	
110 "Female Moroccan High-SES Bad Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
111 "Female Moroccan High-SES Bad Behaviour Bad Essay Low Essay-CC All passed" ///	
112 "Female Moroccan High-SES Bad Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
113 "Female Moroccan Low-SES Good Behaviour Good Essay High Essay-CC All passed" ///	
114 "Female Moroccan Low-SES Good Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
115 "Female Moroccan Low-SES Good Behaviour Good Essay Low Essay-CC All passed" ///	
116 "Female Moroccan Low-SES Good Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
117 "Female Moroccan Low-SES Good Behaviour Bad Essay High Essay-CC All passed" ///	
118 "Female Moroccan Low-SES Good Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
119 "Female Moroccan Low-SES Good Behaviour Bad Essay Low Essay-CC All passed" ///	
120 "Female Moroccan Low-SES Good Behaviour Bad Essay Low Essay-CC 3 failed subjects" ///	
121 "Female Moroccan Low-SES Bad Behaviour Good Essay High Essay-CC All passed" ///	
122 "Female Moroccan Low-SES Bad Behaviour Good Essay High Essay-CC 3 failed subjects" ///	
123 "Female Moroccan Low-SES Bad Behaviour Good Essay Low Essay-CC All passed" ///	
124 "Female Moroccan Low-SES Bad Behaviour Good Essay Low Essay-CC 3 failed subjects" ///	
125 "Female Moroccan Low-SES Bad Behaviour Bad Essay High Essay-CC All passed" ///	
126 "Female Moroccan Low-SES Bad Behaviour Bad Essay High Essay-CC 3 failed subjects" ///	
127 "Female Moroccan Low-SES Bad Behaviour Bad Essay Low Essay-CC All passed" ///	
128 "Female Moroccan Low-SES Bad Behaviour Bad Essay Low Essay-CC 3 failed subjects", replace
labe value vignette vignette
label variable vignette "Vignette ID"

drop migrant failed

gen factor=vignette
sum vignette
tab vignette
tab vignette, nolab
bysort factor: egen vignette_n = count(vignette)
label variable vignette_n "n Respondents by Vignette"
drop factor
order vignette vignette_n, after(FACTORS)

*Public vs. Private Universities
fre q11a_1_i
gen public=q11a_1_i
recode public 3 5 7 8 10 11 12 13 14 15 16 17 20 21 22=0 2 4 6 18=1
tab q11a_1_i public
label define public 0 "Public" 1 "Private", replace
label value public public
fre public
label variable public "Public/Private Institution"
order public, after(q11a_1_i)

*Respondent's Aggregate Age Groups for Weighting vs. Population Categories
recode age 19/25=1 26/59=2
label define age 1 "18-25" 2 ">=26", replace
label value age age
tab age

*analytical n=1,717

save "data/STATA/cleandataset.dta", replace
outsheet using "data/CSV/cleandataset.csv", comma nolabel replace