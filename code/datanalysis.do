***********************************************************
*Project: Teacher's Bias in Assessments
*Code: Replication of empirical output
*Authors: Carlos J. Gil-Hernández, Irene Pañeda-Fernández, 
*         Leire Salazar, and Jonatan Castaño-Muñoz
*Last Update: 04/07/2024
*Software: STATA/MP 17
***********************************************************

//0: Set-up

	** Please install packages if needed ***
	*set scheme tab3
	*set scheme white_brbg
	*net describe grc1leg, from(http://www.stata.com/users/vwiggins)
	* Setting up Working directory (*** ENTER YOUR WORKING DIRECTORY/ROOT HERE, that is, the path to where you save the "replication files" folder ***)
	global wkd "~/Dropbox/Teacher's Bias/Journal Submission/SS/R&R/replication files/" 
	cd "$wkd"
	clear all

	* Analysis Log
	log using "output/output.log"

	* Open clean dataset
	use "data/STATA/cleandataset.dta", clear

	* In the following do-file we will run the analyses. Sections:
	** 1) Descriptives
	** 2) Main models
	** 3) Further descriptives (in appendix)
	** 4) Further models (in appendix)

******************
*Globals & Labels*
******************

	*Outcomes' Labels
	label variable grade_essay "Essay Grade"
	label variable repit "Grade Retention Exp."
	label variable expect "Academic Track Exp."

	*Outcomes+ IVs Globals
	global outcomes grade_essay repit expect 
	global factors sex_female spanish ses_high essay_cc_high essay_good allpassed behaviour_good
	global controls q10_1 q9_i i.q11a_1_i i.q11b_1_i q12_i q13_i q14_i q15_i

********************************************************************************
********* 1) DESCRIPTIVES ******************************************************
********************************************************************************

*********
*TABLE 1*
*********

	*Individual-Level Characteristics
	sum q10_1 i.age i.q9_i i.q11b_1_i i.q12_i i.q13_i i.q14_i i.q15_i
	sum q11b_1_i if q11b_1_i!=7 // Sum BA Degree Grade in a metric 1-to-5 scale Excluding Graduated

	fre q10_1 age q9_i q11a_1_i q11b_1_i q12_i q13_i q14_i q15_i

	bys public: sum q10_1 i.age i.q9_i i.q11b_1_i i.q12_i i.q13_i i.q14_i i.q15_i
	bys public: sum q11b_1_i if q11b_1_i!=7 

	*Population Data available upon request

*********
*TABLE 3*
*********

	*Pre-test on in-service teachers: Summary Stats for Essay Grades by Essay Quality (data available upon request)
	*Experiment's on pre-service teachers: Summary Stats for Essay Grades by Essay Quality
	sum grade_essay grade_essay_bad grade_essay_good

*********
*TABLE 4*
*********

	*Outcomes' summary stats
	sum $outcomes
	sum $outcomes, d
	corr $outcomes

********************************************************************************
********* 2) MAIN MODELS  ******************************************************
********************************************************************************

**********
*FIGURE 2*
**********

	*Figures Output
	global output_figures "output\output_figures"

	*M2
	foreach var of varlist $outcomes {
	local z: variable label `var'
	reg `var' $factors $controls, vce(cl q11a_1_i)
	estimate store `var'_m2
	}

	*UPPER PANEL: M2 - All Factors - Same Y-Axis

	*Coefplot
	coefplot (grade_essay_m2, keep(sex_female spanish ses_high essay_cc_high essay_good allpassed behaviour_good) ///
	msize(large) mfcolor(ebblue%20) mlcolor(edkblue) ciopts(lcolor(edkblue)) msymbol(T)), bylabel("Essay Grade") ///
		|| (repit_m2, keep(sex_female spanish ses_high essay_cc_high essay_good allpassed behaviour_good)), bylabel("Grade Retention Exp.") ///
		|| (expect_m2, keep(sex_female spanish ses_high essay_cc_high essay_good allpassed behaviour_good)), bylabel("Upper-Sec. Track Exp.") ///	
		|| , drop(_cons) byopts(compact cols(3) ixaxes) recast(rcap) scale(.9) ///
			 xline(0, lwidth(1pt) lcolor(red)) xlabel(-3(1)3, labsize(3)) ///
			 coeflabels(ses_high  = "High SES" sex_female= "Girl" spanish = "Native Origin" essay_good = "Good Essay" essay_cc_high = `""High" "Cultural Capital""' ///
			 allpassed = `""All Subjects" "Passed""' behaviour_good = `""Good Behavior" "+ Effort""') 	///
			 headings(sex_female = "{bf:Adscriptive Factors}" ///
					  essay_good = "{bf:Ability Factors}", labcolor(black)) ///
			 mlabsize(small) mlabel mlabformat(%9.2g) mlabposition(3) mlabgap(*2)
	graph export "$output_figures/main/FIGURE-2_M2_factors_1.png", replace
	graph save "$output_figures/main/FIGURE-2_M2_factors_1.gph", replace


	*BOTTOM PANEL: M2 - Only Ascriptive Factors - Same Y-Axis

	*Coefplot
	coefplot (grade_essay_m2, keep(sex_female spanish ses_high essay_cc_high) ///
	msize(vlarge) mfcolor(ebblue%20) mlcolor(edkblue) ciopts(lcolor(edkblue)) msymbol(T)), bylabel("Essay Grade") ///
		|| (repit_m2, keep(sex_female spanish ses_high essay_cc_high)), bylabel("Grade Retention Exp.") ///
		|| (expect_m2, keep(sex_female spanish ses_high essay_cc_high)), bylabel("Academic Track Exp.") ///	
		|| , drop(_cons) byopts(compact cols(3) ixaxes) recast(rcap) scale(.9) ///
			 xline(0, lwidth(1pt) lcolor(red)) xlabel(-.4(.2).4, labsize(3)) ///
			 coeflabels(ses_high  = "High SES" sex_female= "Girl" spanish = "Native Origin" essay_cc_high = `""High" "Cultural Capital""', labsize(msmall)) ///
			 mlabsize(small) mlabel mlabformat(%9.2g) mlabposition(6) mlabgap(*2)
	graph export "$output_figures/main/FIGURE-2_M2_factors_2.png", replace
	graph save "$output_figures/main/FIGURE-2_M2_factors_2.gph", replace

********************************
*Reversed Scale: Grade Retention
********************************

	*M2
	sum repit, mean
	generate double repit2=r(max)-repit+r(min) // Reversed Scale
	global outcomes2 grade_essay repit2 expect 

	foreach var of varlist $outcomes2 {
	local z: variable label `var'
	reg `var' $factors $controls, vce(cl q11a_1_i)
	estimate store `var'_m2
	}

	*UPPER PANEL: M2 - All Factors - Same Y-Axis

	*Coefplot
	coefplot (grade_essay_m2, keep(sex_female spanish ses_high essay_cc_high essay_good allpassed behaviour_good) ///
	msize(large) mfcolor(ebblue%20) mlcolor(edkblue) ciopts(lcolor(edkblue)) msymbol(T)), bylabel("Essay Grade") ///
		|| (repit2_m2, keep(sex_female spanish ses_high essay_cc_high essay_good allpassed behaviour_good)), bylabel("No Grade Retention Exp.") ///
		|| (expect_m2, keep(sex_female spanish ses_high essay_cc_high essay_good allpassed behaviour_good)), bylabel("Upper-Sec. Track Exp.") ///	
		|| , drop(_cons) byopts(compact cols(3) ixaxes) recast(rcap) scale(.9) ///
			 xline(0, lwidth(1pt) lcolor(red)) xlabel(0(1)3, labsize(3)) ///
			 coeflabels(ses_high  = "High SES" sex_female= "Girl" spanish = "Native Origin" essay_good = "Good Essay" essay_cc_high = `""High" "Cultural Capital""' ///
			 allpassed = `""All Subjects" "Passed""' behaviour_good = `""Good Behavior" "+ Effort""') 	///
			 headings(sex_female = "{bf:Adscriptive Factors}" ///
					  essay_good = "{bf:Ability Factors}", labcolor(black)) ///
			 mlabsize(small) mlabel mlabformat(%9.2g) mlabposition(3) mlabgap(*2)
	graph export "$output_figures/main/FIGURE-2_M2_factors_1R.png", replace
	graph save "$output_figures/main/FIGURE-2_M2_factors_1R.gph", replace


	*BOTTOM PANEL: M2 - Only Ascriptive Factors - Same Y-Axis

	*Coefplot
	coefplot (grade_essay_m2, keep(sex_female spanish ses_high essay_cc_high) ///
	msize(vlarge) mfcolor(ebblue%20) mlcolor(edkblue) ciopts(lcolor(edkblue)) msymbol(T)), bylabel("Essay Grade") ///
		|| (repit2_m2, keep(sex_female spanish ses_high essay_cc_high)), bylabel("No Grade Retention Exp.") ///
		|| (expect_m2, keep(sex_female spanish ses_high essay_cc_high)), bylabel("Academic Track Exp.") ///	
		|| , drop(_cons) byopts(compact cols(3) ixaxes) recast(rcap) scale(.9) ///
			 xline(0, lwidth(1pt) lcolor(red)) xlabel(-.4(.2).4, labsize(3)) ///
			 coeflabels(ses_high  = "High SES" sex_female= "Girl" spanish = "Native Origin" essay_cc_high = `""High" "Cultural Capital""', labsize(msmall)) ///
			 mlabsize(small) mlabel mlabformat(%9.2g) mlabposition(6) mlabgap(*2)
	graph export "$output_figures/main/FIGURE-2_M2_factors_2R.png", replace
	graph save "$output_figures/main/FIGURE-2_M2_factors_2R.gph", replace

*******************************************
*COEFFICIENTS' DIFFERENCE TEST BY OUTCOMES*
*******************************************
    
	*************
	*TABLE A.11.*
	*************    
	global outcomes2 grade_essay repit2 expect // Standardize outcomes to equate scales
	foreach var of varlist $outcomes2 {
    egen z`var'=std(`var')
	}
	sum zgrade_essay zrepit2 zexpect

	eststo e1: reg zgrade_essay $factors $controls
    eststo e2: reg zrepit2 $factors $controls
	eststo e3: reg zexpect $factors $controls

    suest e1 e3, vce(cl q11a_1_i)
	foreach var of varlist $factors {
    lincom _b[e3_mean:`var'] - _b[e1_mean:`var']
	}

	suest e2 e3, vce(cl q11a_1_i)
	foreach var of varlist $factors {
    lincom _b[e3_mean:`var'] - _b[e2_mean:`var']
	}

	**********
    *FIGURE 3*
    **********
	*ssc install lincomest 
    suest e1 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:sex_female] - _b[e1_mean:sex_female]
	estimates store e3_e1_sex
	suest e1 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:spanish] - _b[e1_mean:spanish]
	estimates store e3_e1_ethnic
	suest e1 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:ses_high] - _b[e1_mean:ses_high]
	estimates store e3_e1_ses
	suest e1 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:essay_cc_high] - _b[e1_mean:essay_cc_high]
	estimates store e3_e1_cc
	suest e1 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:essay_good] - _b[e1_mean:essay_good]
	estimates store e3_e1_essay	
	suest e1 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:allpassed] - _b[e1_mean:allpassed]
	estimates store e3_e1_allpassed
	suest e1 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:behaviour_good] - _b[e1_mean:behaviour_good]
	estimates store e3_e1_behavior

    suest e2 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:sex_female] - _b[e2_mean:sex_female]
	estimates store e3_e2_sex
	suest e2 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:spanish] - _b[e2_mean:spanish]
	estimates store e3_e2_ethnic
	suest e2 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:ses_high] - _b[e2_mean:ses_high]
	estimates store e3_e2_ses
	suest e2 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:essay_cc_high] - _b[e2_mean:essay_cc_high]
	estimates store e3_e2_cc
	suest e2 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:essay_good] - _b[e2_mean:essay_good]
	estimates store e3_e2_essay	
	suest e2 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:allpassed] - _b[e2_mean:allpassed]
	estimates store e3_e2_allpassed
	suest e2 e3, vce(cl q11a_1_i)
	lincomest _b[e3_mean:behaviour_good] - _b[e2_mean:behaviour_good]
	estimates store e3_e2_behavior

	global e3_e1_e2 e3_e1_sex e3_e2_sex e3_e1_ethnic e3_e2_ethnic e3_e1_ses e3_e2_ses e3_e1_cc e3_e2_cc ///
	e3_e1_essay e3_e2_essay e3_e1_allpassed e3_e2_allpassed e3_e1_behavior e3_e2_behavior
	
	*Coefplot
	coefplot $e3_e1_e2, xline(0) ylabel(0.5(.1)1.5) xlabel(-1(.2).4)
    graph save "$output_figures/main/FIGURE-3.gph", replace
    graph export "$output_figures/main/FIGURE-3.png", replace
	

********************************************************************************
********* 3) FURTHER DESCRIPTIVES (IN APPENDIX)  *******************************
********************************************************************************

******************************************
*********3.0.) Factors Randomization Test*
******************************************

	*Factors
	sum $factors
	bys public: sum $factors

	corr $factors
	polychoric $factors
	foreach var of varlist $outcomes {
	reg `var' $factors
	vif
	collin $factors
	}

*************************************
********* 3.1.) PAP Power Analysis  *
*************************************

*************
*FIGURE A.1.*
*************

	*R and SAS dofiles available upon request
  
********************************************
********* 3.2.) Essay Grades' Distribution *
********************************************

*************
*FIGURE A.2.*
*************

	*Pre-test on in-service teachers: Summary Stats for Essay Grades by Essay Quality (data available upon request)
	*Experiment's on pre-service teachers: Summary Stats for Essay Grades by Essay Quality
	sum grade_essay grade_essay_bad grade_essay_good
	*Good vs Bad Essay
	sum grade_essay grade_essay_bad grade_essay_good
	twoway kdensity grade_essay_good || kdensity grade_essay_bad, title("Essay Grade - Experiment: Pre-Service Teachers (n=1,717)", size(med)) legend( label (1 "Good Essay") label (2 "Bad Essay")) ///
	legend(pos(6) col(2)) ylabel(0(.2).6) xlabel(1(1)10) xline(5.9) xline(8.7) xline(7.3) xtitle("")
	graph save "$output_figures/appendix/good_bad_essay_experiment.gph", replace
	graph export "$output_figures/appendix/good_bad_essay_experiment.png", replace

*********************************************
********* 3.3.) Cultural Capital Validation *
*********************************************

*************
*FIGURE A.3.*
*************

	*Pre-test on in-service teachers: Cultural Capital Validation (data available upon request)

*****************************************
********* 3.4.) Manipulation Checks *****
*****************************************
	tab1 signals sex_signal migrant_signal SES_signal failed_signal behaviour_signal cc_signal 

*************
*FIGURE A.4.*
*************

	catcibar sex_signal, proportion legend(position(6) col(3)) title("Sex")
	graph save "$output_figures/appendix/sex_signal.gph", replace
	graph export "$output_figures/appendix/sex_signal.png", replace
	catcibar migrant_signal, proportion legend(position(6) col(3)) title("Migrant")
	graph save "$output_figures/appendix/migrant_signal.gph", replace
	graph export "$output_figures/appendix/migrant_signal.png", replace
	catcibar SES_signal, proportion legend(position(6) col(3)) title("SES")
	graph save "$output_figures/appendix/SES_signal.gph", replace
	graph export "$output_figures/appendix/SES_signal.png", replace
	catcibar failed_signal, proportion legend(position(6) col(3)) title("Subjects Failed")
	graph save "$output_figures/appendix/failed_signal.gph", replace
	graph export "$output_figures/appendix/failed_signal.png", replace
	catcibar behaviour_signal, proportion legend(position(6) col(3)) title("Behaviour")
	graph save "$output_figures/appendix/behaviour_signal.gph", replace
	graph export "$output_figures/appendix/behaviour_signal.png", replace
	catcibar cc_signal, proportion legend(position(6) col(3)) title("Cultural Capital")
	graph save "$output_figures/appendix/cc_signal.gph", replace
	graph export "$output_figures/appendix/cc_signal.png", replace

	graph combine "$output_figures/appendix/sex_signal.gph" ///
	"$output_figures/appendix/migrant_signal.gph" ///
	"$output_figures/appendix/SES_signal.gph" ///
	"$output_figures/appendix/cc_signal.gph" ///
	"$output_figures/appendix/failed_signal.gph" ///
	"$output_figures/appendix/behaviour_signal.gph", col(6)
	graph save "$output_figures/appendix/FIGURE-A.4._signals.gph", replace
	graph export "$output_figures/appendix/FIGURE-A4.png", replace

*******************************************
********* 3.5.) Vignettes Distribution*****
*******************************************

*************
*FIGURE A.5.*
*************

	histogram vignette, discrete frequency xlabel(1(2)128, angle(vertical))
	graph save "$output_figures/appendix/FIGURE-A.5._vignettes_freq.gph", replace
	*graph export "$output_figures/appendix/FIGURE-A.5._vignettes_freq.png", replace

*************
*FIGURE A.6.*
*************

	histogram vignette_n, normal percent discrete
	graph save "$output_figures/appendix/FIGURE-A.6._vignettes_dist.gph", replace
	*graph export "$output_figures/appendix/FIGURE-A.6._vignettes_dist.png", replace

********************************************************************************
********* 4) ROBUSTNESS CHECKS (IN APPENDIX)  *********************************
********************************************************************************

****************************************************
********* 4.0.) FULL OUPTPUT************************
****************************************************

****************
*M2: TABLE S.5A*
****************

	*Word & Excel Output (Tables)
	global output_tables "output\output_tables"

	*Word Table Variables' Labels
	#delimit ;
	global label_coefr ses_high "High-SES (Low-SES)"									 								
					   sex_female "Female (Male)"
					   spanish "Native Origin (Moroccan Origin)"
					   essay_good "Good Essay (Bad Essay)"
					   essay_cc_high "High Cultural Capital (Low CC)"
					   allpassed "All Subjects Passed (3 Subjects Failed)"
					   behaviour_good "Good Behavior + Effort (Bad Behaviour + Effort)"
					   q10_1 "Year of Birth"
					   q9_i "Female Respondent (Male)"
					   2.q11b_1_i "2nd Grade (1st Grade)"
					   3.q11b_1_i "3rd Grade"
					   4.q11b_1_i "4th Grade"
					   5.q11b_1_i "5th Grade"
					   7.q11b_1_i "Graduated"
					   q12_i "Grade Retention at School (No)"
					   q13_i "Low-SES Respondent (High-SES)"
					   q14_i "Foreign-Born Respondent (Native)" 
					   q15_i "Foreign-Born Parents (Native Parents)"
						_cons "Constant" 
		;
	#delimit cr

	*Global to keep Variables in Table
	global m1_keep $factors

	*Models

	*Model 2 (M2): Factors + Individual-level Controls
	foreach var of varlist $outcomes {
	local z: variable label `var'
	reg `var' $factors $controls, vce(cl q11a_1_i)
	estimate store `var'_m2
	}

	//word
	eststo clear

	foreach var of varlist $outcomes {
	eststo: reg `var' $factors $controls, vce(cl q11a_1_i) coeflegend
	}

	//M2B: NOT showing individual-level coefficients (excluding universities due to privacy)
	#delimit ;
	esttab using "$output_tables/appendix/TABLE-S.5A_M2.rtf", replace label				 
		star(+ 0.10 * 0.05 ** 0.01 *** 0.001) b(2) se(2)								 
		keep($m1_keep)  varlabel($label_coefr) nogaps nonumbers				
		stats(N r2_a, label("Observations" "Adjusted R2")) 
		;
	#delimit cr

	//excel 
	capture erase "$output_tables/appendix/TABLE-S.5A_M2.xls"
	foreach var of varlist $outcomes {
		reg `var' $factors $controls, vce(cl q11a_1_i)
	outreg2 using "$output_tables/appendix/TABLE-S.5A_M2.xls",  label append nocons 
	}
	capture erase "$output_tables/appendix/TABLE-S.5A_M2.txt"

******************************************
*********FULL OUPTPUT M1 + M2: TABLE S.5B
******************************************

	*Word Table Variables' Labels
	#delimit ;
	global label_coefr ses_high "High-SES (Low-SES)"									 								
					   sex_female "Female (Male)"
					   spanish "Native Origin (Moroccan Origin)"
					   essay_good "Good Essay (Bad Essay)"
					   essay_cc_high "High Cultural Capital (Low CC)"
					   allpassed "All Subjects Passed (3 Subjects Failed)"
					   behaviour_good "Good Behavior + Effort (Bad Behaviour + Effort)"
					   q10_1 "Year of Birth"
					   q9_i "Female Respondent (Male)"
					   2.q11b_1_i "2nd Grade (1st Grade)"
					   3.q11b_1_i "3rd Grade"
					   4.q11b_1_i "4th Grade"
					   5.q11b_1_i "5th Grade"
					   7.q11b_1_i "Graduated"
					   q12_i "Grade Retention at School (No)"
					   q13_i "Low-SES Respondent (High-SES)"
					   q14_i "Foreign-Born Respondent (Native)" 
					   q15_i "Foreign-Born Parents (Native Parents)"
						_cons "Constant" 
		;
	#delimit cr

	*Global to keep Variables in Table
	global m1_keep $factors
	global m2_keep $factors q10_1 q9_i 2.q11b_1_i 3.q11b_1_i 4.q11b_1_i 5.q11b_1_i 7.q11b_1_i q12_i q13_i q14_i q15_i

	*Models

	*Model 1 (M1): Factors
	foreach var of varlist $outcomes {
	local z: variable label `var'
	reg `var' $factors, vce(cl q11a_1_i)
	estimate store `var'_m1 
	}

	*Model 2 (M2): Factors + Individual-level Controls
	foreach var of varlist $outcomes {
	local z: variable label `var'
	reg `var' $factors $controls, vce(cl q11a_1_i)
	estimate store `var'_m2
	}

	eststo clear

	foreach var of varlist $outcomes {
	eststo: reg `var' $factors, vce(cl q11a_1_i)
	eststo: reg `var' $factors $controls, vce(cl q11a_1_i)
	}

	//word
	#delimit ;
	esttab using "$output_tables/appendix/TABLE-A.5B._M1+M2.rtf", replace label				 
		star(+ 0.10 * 0.05 ** 0.01 *** 0.001) se(3)								 
		keep($m2_keep)  varlabel($label_coefr) nogaps nonumbers				
		stats(N r2_a, label("Observations" "Adjusted R2")) 
		;
	#delimit cr

	//excel 
	capture erase "$output_tables/appendix/TABLE-A.5B._M1+M2.xls"
	foreach var of varlist $outcomes {
		reg `var' $factors, vce(cl q11a_1_i)
	outreg2 using "$output_tables/appendix/TABLE-A.5B._M1+M2.xls",  label append nocons 	
		reg `var' $factors $controls, vce(cl q11a_1_i)
	outreg2 using "$output_tables/appendix/TABLE-A.5B._M1+M2.xls",  label append nocons 
	}
	capture erase "$output_tables/appendix/TABLE-A.5B._M1+M2.txt"

****************************************************
********* 4.1.) SIGNALS ****************************
****************************************************

	* ---------------------------------------------------------------------------- *
	* M2a + M2b (all factors right)
	* ---------------------------------------------------------------------------- *

	fre signals

	*Tables

	eststo clear

	foreach var of varlist $outcomes {
	eststo: reg `var' $factors $controls, vce(cl q11a_1_i)
	eststo: reg `var' $factors $controls if signals==1, vce(cl q11a_1_i)
	}

************
*TABLE A.6.*
************

	//word
	#delimit ;
	esttab using "$output_tables/appendix/TABLE-A.6._M2+M2_signals.rtf", replace label				 
		star(+ 0.10 * 0.05 ** 0.01 *** 0.001) se(3)								 
		keep($m1_keep)  varlabel($label_coefr) nogaps nonumbers				
		stats(N r2_a, label("Observations" "Adjusted R2")) 
		;
	#delimit cr

	//excel 
	capture erase "$output_tables/appendix/TABLE-A.6._M2+M2_signals.xls"
	foreach var of varlist $outcomes {
		reg `var' $factors $controls, vce(cl q11a_1_i)
	outreg2 using "$output_tables/appendix/TABLE-A.6._M2+M2_signals.xls",  label append nocons 	
		reg `var' $factors $controls if signals==1, vce(cl q11a_1_i)
	outreg2 using "$output_tables/appendix/TABLE-A.6._M2+M2_signals.xls",  label append nocons 
	}
	capture erase "$output_tables/appendix/TABLE-A.6._M2+M2_signals.txt"


****************************************************
********* 4.2.) WEIGHTING **************************
****************************************************

	fre q9_i age q13_i q14_i

	*Baseline weights=1
	gen pw=1

	*Raking Weights using Population Absolute Numbers / Shares
	svycal rake i.q9_i i.age i.q13_i [pw=pw], gen(weight) ///
	totals( _cons=59084 ///
	1.q9_i=18450 /// Hombre
	2.q9_i=40634 /// Mujer
	1.age=43341  /// 18-25
	2.age=15743  /// ≥26
	1.q13_i=30097.06889 /// College
	2.q13_i=28986.93111) /// <College

	*Non and Weighted Summary Stats
	sum i.q9_i q10_1 i.age i.q13_i i.q14_i
	sum i.q9_i q10_1 i.age i.q13_i i.q14_i [aw=weight]

************
*TABLE A.7.*
************

* ---------------------------------------------------------------------------- *
* M1 + M2 + M1W + M2W
* ---------------------------------------------------------------------------- *

	*IVs Globals
	global controls_w q10_1 q9_i i.q11a_1_i i.q11b_1_i q12_i q13_i q14_i q15_i

	*Word Table Variables' Labels
	#delimit ;
	global label_coefr_w ses_high "High-SES (Low-SES)"									 								
					   sex_female "Female (Male)"
					   spanish "Native Origin (Moroccan Origin)"
					   essay_good "Good Essay (Bad Essay)"
					   essay_cc_high "High Cultural Capital (Low CC)"
					   allpassed "All Subjects Passed (3 Subjects Failed)"
					   behaviour_good "Good Behavior + Effort (Bad Behaviour + Effort)"
					   q10_1 "Year of Birth"
					   q9_i "Female Respondent (Male)"
					   2.q11b_1_i "2nd Grade (1st Grade)"
					   3.q11b_1_i "3rd Grade"
					   4.q11b_1_i "4th Grade"
					   5.q11b_1_i "5th Grade"
					   7.q11b_1_i "Graduated"
					   q12_i "Grade Retention at School (No)"
					   q13_i "Low-SES Respondent (High-SES)"
					   q14_i "Foreign-Born Respondent (Native)" 
					   q15_i "Foreign-Born Parents (Native Parents)"
						_cons "Constant" 
		;
	#delimit cr

	*Global to keep Variables in Table
	global m1_keep_w $factors
	global m2_keep_w $factors q10_1 q9_i 2.q11b_1_i 3.q11b_1_i 4.q11b_1_i 5.q11b_1_i 7.q11b_1_i q12_i q13_i q14_i q15_i

	eststo clear

	foreach var of varlist $outcomes {
	eststo: reg `var' $factors $controls_w, vce(cl q11a_1_i)
	eststo: reg `var' $factors $controls_w [pw=weight], vce(cl q11a_1_i)
	}

	//word
	#delimit ;
	esttab using "$output_tables/appendix/TABLE-A.7._M2+M2_weighted.rtf", replace label				 
		star(+ 0.10 * 0.05 ** 0.01 *** 0.001) se(3)								 
		keep($m2_keep_w)  varlabel($label_coefr_w) nogaps nonumbers				
		stats(N r2_a, label("Observations" "Adjusted R2")) 
		;
	#delimit cr

	//excel 
	capture erase "$output_tables/appendix/TABLE-A.8._M2+M2_weighted.xls"
	foreach var of varlist $outcomes {
		reg `var' $factors $controls_w, vce(cl q11a_1_i)
	outreg2 using "$output_tables/appendix/TABLE-A.8._M2+M2_weighted.xls",  label append nocons 
		reg `var' $factors $controls_w [pw=weight], vce(cl q11a_1_i)
	outreg2 using "$output_tables/appendix/TABLE-A.8._M2+M2_weighted.xls",  label append nocons 
	}
	capture erase "$output_tables/appendix/TABLE-A.8._M2+M2_weighted.txt"

****************************************************
********* 4.3.) OUTCOMES' NON-NORMALITY ************
****************************************************

	*Distribution Test of Outcomes: Skewness & Kurtosis

	foreach var of varlist  $outcomes {
	kdensity `var', xlabel(1(1)10) xscale(range(0 10)) 
	histogram `var', normal percent xlabel(0(1)10)
	}

	sktest grade_essay_bad grade_essay_good grade_essay repit expect
	sum grade_essay_bad grade_essay_good grade_essay repit expect
	sum grade_essay_bad grade_essay_good grade_essay repit expect, d
	tab1 grade_essay repit expect

************
*TABLE A.8.*
************

	*Generating Dummy Outcomes below/above the Median, rounding up the Median
	xtile grade_essay_d=grade_essay, nq(2) // Median=7.5
	tab grade_essay_d
	tab grade_essay grade_essay_d
	recode grade_essay_d 1=0 2=1
	tab grade_essay_d

	xtile repit_d=repit, nq(2) // Median=2
	tab repit_d
	tab repit repit_d
	recode repit_d 1=0 2=1
	tab repit_d

	xtile expect_d=expect, nq(2) // Median=7.7
	tab expect_d 
	tab expect expect_d 
	recode expect_d 1=0 2=1
	tab expect_d 

	*Tables
	global outcomes_dummies grade_essay grade_essay_d repit repit_d expect expect_d
	global outcomes_dummies2 grade_essay_d repit_d expect_d

	eststo clear

	*M2 Linear Outcomes vs. M2 Dummy Outcomes
	foreach var of varlist $outcomes_dummies {
	eststo: reg `var' $factors $controls, vce(cl q11a_1_i) // LPM
	}

	//word
	#delimit ;
	esttab using "$output_tables/appendix/TABLE-A.8._M2+M2_dummies.rtf", replace label				 
		star(+ 0.10 * 0.05 ** 0.01 *** 0.001) se(3)								 
		keep($m1_keep)  varlabel($label_coefr) nogaps nonumbers				
		stats(N r2_a, label("Observations" "Adjusted R2")) 
		;
	#delimit cr

	//excel 
	foreach var of varlist $outcomes_dummies {
		reg `var' $factors $controls, vce(cl q11a_1_i)
	outreg2 using "$output_tables/appendix/TABLE-A.8._M2+M2_dummies.xls",  label append nocons 	
	}
	capture erase "$output_tables/appendix/TABLE-A.8._M2+M2_dummies.txt"

*************
*FIGURE A.7.*
*************

	*Figure
	reg grade_essay $factors $controls if essay_good==0, vce(cl q11a_1_i)
	estimate store grade_essay_ma 
	reg grade_essay $factors $controls if essay_good==1, vce(cl q11a_1_i) // Larger (positive) gender discrimination among student's writing a good essay
	estimate store grade_essay_mb 

	*Coefplot: M2A+M2B (All Factors)
	foreach var of varlist  $outcomes {
	local z: variable label `var' 
	coefplot(grade_essay_ma,  lab("Bad Essay") mfcolor(ebblue)) ///
	(grade_essay_mb,  lab("Good Essay") mfcolor(orange) ms(smdiamond)), /// 			
	mfcolor(white) msize(medlarge)												 ///
				 xscale(range(-1(.25)1)) 										 ///
				 xlabel(-1(.25)1,  valuelabel labsize(small) angle(90))					 ///
	drop(_cons ) keep(sex_female spanish ses_high essay_cc_high) xline(0)					 ///
	coeflabels(ses_high  = "High SES" sex_female= "Girl" spanish = "Native Origin" essay_cc_high = `""High" "Cultural Capital""') ///
	mlabsize(small) mlabel mlabformat(%9.2g) mlabposition(6) mlabgap(*2) ///
	title ("Essay Grade by Objective Essay Quality", size(medium)) legend(rows(1)) name(grade_essay_magrade_essay_mb, replace) 
	}
	*Graph combine m1+m2
	grc1leg  grade_essay_magrade_essay_mb, col(3) saving("$output_figures/appendix/FIGURE-A7_grade_essay_magrade_essay_mb.gph", replace) 
	graph export "$output_figures/appendix/FIGURE-A7_grade_essay_magrade_essay_mb.png", replace

*************
*FIGURE A.8.*
*************

	*Grade Retention by Subjects Failed/Passed
	sum repit, d
	bys allpassed: sum repit
	bys allpassed: sum repit, d // Much less skewed distribution among those failing 3 subjects
	sktest repit if allpassed==0
	sktest repit if allpassed==1

	twoway kdensity repit || kdensity repit if allpassed==0  || kdensity repit if allpassed==1, ///
	title("Grade Retention Expectations Distribution", ///
	size(med)) xtitle("") ytitle("") xline(2) legend( label (1 "All") label (2 "3 Subjects Failed") label (3 "All Subjects Passed") position(6) row(1))
	graph save "$output_figures/appendix/FIGURE-A8_repit_kernel.gph", replace
	graph export "$output_figures/appendix/FIGURE-A8_repit_kernel.png", replace

*************
*FIGURE A.9.*
*************

	*Figure
	reg repit $factors $controls if allpassed==0, vce(cl q11a_1_i) // Larger (positive) gender and ethnic discrimination among bad students failing 3 subjects
	estimate store repit_ma 
	reg repit $factors $controls if allpassed==1, vce(cl q11a_1_i)
	estimate store repit_mb 

	*Coefplot: M2A+M2B (All Factors)
	foreach var of varlist  $outcomes {
	local z: variable label `var' 
	coefplot(repit_ma,  lab("3 Core Subjects Failed") mfcolor(ebblue)) ///
	(repit_mb,  lab("All Subjects Passed") mfcolor(orange) ms(smdiamond)), /// 			
	mfcolor(white) msize(medlarge)												 ///
				 xscale(range(-1(.25)1)) 										 ///
				 xlabel(-1(.25)1,  valuelabel labsize(small) angle(90))					 ///
	drop(_cons ) keep(sex_female spanish ses_high essay_cc_high) xline(0)					 ///
	coeflabels(ses_high  = "High SES" sex_female= "Girl" spanish = "Native Origin" essay_cc_high = `""High" "Cultural Capital""') ///
	mlabsize(small) mlabel mlabformat(%9.2g) mlabposition(6) mlabgap(*2) ///
	title ("Grade Retention Expectations by Subjects Failed", size(medium)) legend(rows(1)) name(repit_marepit_mb, replace) 
	}
	*Graph combine m1+m2
	grc1leg  repit_marepit_mb, col(3) saving("$output_figures/appendix/FIGURE-A9_repit_marepit_mb.gph", replace) 
	graph export "$output_figures/appendix/FIGURE-A9_repit_marepit_mb.png", replace

********************************************************************************
********* 5) ADDITIONAL ANALYSIS (IN APPENDIX)  ********************************
********************************************************************************

****************************************************
********* 5.1.) MECHANISM: PARENTAL SUPPORT ********
****************************************************

	*M2: Factors -> Parental Support

	*Table

*************
*TABLE A.9.*
*************

	//word
	eststo clear
	eststo: regress psupport $factors $controls, vce(cl q11a_1_i)
	#delimit ;
	esttab using "$output_tables/appendix/TABLE-A.9._M2_psupport.rtf", replace label				 
		star(+ 0.10 * 0.05 ** 0.01 *** 0.001) se(3)								 
		keep($m1_keep)  varlabel($label_coefr) nogaps nonumbers				
		stats(N r2_a, label("Observations" "Adjusted R2")) 
		;
	#delimit cr

	//excel 
	capture erase "$output_tables/appendix/TABLE-A.9._M2_psupport.xls"
	regress psupport $factors $controls, vce(cl q11a_1_i)
	outreg2 using "$output_tables/appendix/TABLE-A.9._M2_psupport.xls",  label append nocons 	
	capture erase "$output_tables/appendix/TABLE-A.9._M2_psupport.txt"


*************
*TABLE A.10.*
*************

	*M3: Factors -> Parental Support -> Outcomes (KHB Mediation)

	khb regress grade_essay $factors || psupport, c($controls) vce(cl q11a_1_i) summary disentangle
	eststo m2_khb_grades
	khb regress repit $factors || psupport, c($controls) vce(cl q11a_1_i) summary disentangle
	eststo m2_khb_repit
	khb regress expect $factors || psupport, c($controls) vce(cl q11a_1_i) summary disentangle
	eststo m2_khb_expect
	eststo dir
	#delimit ;
	esttab m2_khb_grades m2_khb_repit m2_khb_expect using "$output_tables/appendix/TABLE-A.10._KHB_psupport.rtf", replace label	
	scalars("ratio_essay_cc_high Conf.-Ratio" "pct_essay_cc_high Conf.-Perc.") se b(a3)mtitles("Essay Grade" "Grade Retention Exp." "Academic Track Exp.")
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) 
	;
	#delimit cr		

*********
log close
