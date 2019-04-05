#delimit ;
set more 1;

clear;

use ${build}/input/raw_${region}.dta;

/* -----------------------------------------------------------------------------
RENAME VARIABLES
-----------------------------------------------------------------------------*/;
rename datanum dataset;
rename serial hhid;
rename wkswork1 wkswork;
rename incbus00 farmbus;
rename statefip state;
rename incwage labinc;

/* -----------------------------------------------------------------------------
SPECIAL VALUES
-----------------------------------------------------------------------------*/;
replace occ1990 = . if occ1990 == 999;
replace wkswork = . if wkswork == 0;
replace uhrswork = . if uhrswork == 0;
replace incwage = . if inlist(incwage,999998,999999);
replace farmbus = . if farmbus == 999999;

/* -----------------------------------------------------------------------------
ADJUSTMENTS
-----------------------------------------------------------------------------*/;
replace perwt = perwt / 100;

/* -----------------------------------------------------------------------------
SAMPLE SELECTION
-----------------------------------------------------------------------------*/;
keep if race == 1;
keep if sex == 1;
keep if (empstat == 1) & !inlist(empstatd,13,14,15); // exclude military;
drop if occ1990 == 991; // unemployed;
keep if (age >= 25) & (age <= 54);
keep if uhrswork >= 30;
keep if wkswork >= 48;

/* -----------------------------------------------------------------------------
GENERATE NEW VARIABLES
-----------------------------------------------------------------------------*/;
if "$region" == "state" {;
	gen metarea = .;
};
else if "$region" == "metro" {;
	gen state = .;
};

// earnings;
gen earnings = labinc + farmbus;

// years of education;
gen yrseduc = .;
replace yrseduc = 0 if educ == 0;
replace yrseduc = 4 if educ == 1;
replace yrseduc = 8 if educ == 2;
replace yrseduc = 9 if educ == 3;
replace yrseduc = 10 if educ == 4;
replace yrseduc = 11 if educ == 5;
replace yrseduc = 12 if educ == 6;
replace yrseduc = 13 if educ == 7;
replace yrseduc = 14 if educ == 8;
replace yrseduc = 15 if educ == 9;
replace yrseduc = 16 if educ == 10;
replace yrseduc = 19 if educ == 11;

// years of experience;
gen experience = age - yrseduc - 5;

// full vs part time;
gen emp_full = (empstat == 1) & (uhrswork >= 30);
gen emp_part = (empstat == 1) & (uhrswork < 30) & (uhrswork >= 15);
gen home = (emp_full != 1) & (emp_part != 1);

gen emp_full_adj = . ;							/*emp_full_adj will be the variable we use for employed counts */ 
replace emp_full_adj = 0 if home == 1 ;
replace emp_full_adj = 0.5 if emp_part == 1;
replace emp_full_adj = 1 if emp_full == 1;

gen home_adj = . ; 								/*home_adj will be the variable use for home sector counts */ 
replace home_adj = 1 if home == 1 ;
replace home_adj = 0.5 if emp_part == 1;
replace home_adj = 0 if emp_full == 1;

gen person_adj = 1;
replace person_adj = 0.5 if emp_part == 1 ; 

// Hurst et al. occupation codes;
gen occ_code = 0  ;  						
replace occ_code = 1  if ((occ1990 >= 3 & occ1990 <= 22) ) & emp_full_adj > 0;
replace occ_code = 2  if ((occ1990 >= 23 & occ1990 <= 37) | (occ1990 >= 303 & occ1990 <= 307) | (occ1990 == 200))& emp_full_adj > 0;
replace occ_code = 3  if (occ1990 == 43)& emp_full_adj > 0;
replace occ_code = 4  if ((occ1990 >= 44 & occ1990 <= 63) | occ1990 == 867)& emp_full_adj > 0;
replace occ_code = 5  if (occ1990 >= 64 & occ1990 <= 68)& emp_full_adj > 0 ;
replace occ_code = 6  if (occ1990 >= 69 & occ1990 <= 83)& emp_full_adj > 0;
replace occ_code = 7  if (occ1990 >= 84 & occ1990 <= 89)& emp_full_adj > 0;
replace occ_code = 8  if (occ1990 >= 95 & occ1990 <= 97)& emp_full_adj > 0;
replace occ_code = 9  if (occ1990 >= 98 & occ1990 <= 106)& emp_full_adj > 0;
replace occ_code = 10 if (occ1990 >= 113 & occ1990 <= 154)& emp_full_adj > 0;
replace occ_code = 11  if (occ1990 >= 155 & occ1990 <= 163)& emp_full_adj > 0;
replace occ_code = 12  if (occ1990 >= 164 & occ1990 <= 165)& emp_full_adj > 0;
replace occ_code = 13  if (occ1990 >= 166 & occ1990 <= 173)& emp_full_adj > 0;
replace occ_code = 14  if (occ1990 >= 174 & occ1990 <= 177)& emp_full_adj > 0;
replace occ_code = 15  if (occ1990 >= 178 & occ1990 <= 179)& emp_full_adj > 0;
replace occ_code = 16  if (occ1990 >= 183 & occ1990 <= 199)& emp_full_adj > 0;
replace occ_code = 17  if (occ1990 >= 203 & occ1990 <= 208)& emp_full_adj > 0;
replace occ_code = 18  if (occ1990 >= 213 & occ1990 <= 218)& emp_full_adj > 0;
replace occ_code = 19  if (occ1990 >= 223 & occ1990 <= 225)& emp_full_adj > 0;
replace occ_code = 20  if (occ1990 >= 226 & occ1990 <= 235)& emp_full_adj > 0;
replace occ_code = 21  if (occ1990 >= 243 & occ1990 <= 290)& emp_full_adj > 0;
replace occ_code = 22  if (occ1990 >= 313 & occ1990 <= 315)& emp_full_adj > 0;
replace occ_code = 23  if (occ1990 >= 316 & occ1990 <= 323)& emp_full_adj > 0;
replace occ_code = 24  if (occ1990 >= 325 & occ1990 <= 336)& emp_full_adj > 0;
replace occ_code = 25  if (occ1990 >= 337 & occ1990 <= 344)& emp_full_adj > 0;
replace occ_code = 26  if (occ1990 >= 345 & occ1990 <= 347)& emp_full_adj > 0;
replace occ_code = 27  if ((occ1990 >= 348 & occ1990 <= 353) | (occ1990 >= 308 & occ1990 <= 309)) & emp_full_adj > 0;
replace occ_code = 28  if (occ1990 >= 354 & occ1990 <= 357)& emp_full_adj > 0;
replace occ_code = 29  if (occ1990 >= 359 & occ1990 <= 374)& emp_full_adj > 0;
replace occ_code = 30  if (occ1990 >= 375 & occ1990 <= 378)& emp_full_adj > 0;
replace occ_code = 31  if (occ1990 >= 379 & occ1990 <= 391)& emp_full_adj > 0;
replace occ_code = 32  if (occ1990 >= 403 & occ1990 <= 408)& emp_full_adj > 0;
replace occ_code = 33  if ((occ1990 >= 416 & occ1990 <= 417) | occ1990 == 413)& emp_full_adj > 0;   
replace occ_code = 34  if ((occ1990 >= 418 & occ1990 <= 424) | occ1990 == 414)& emp_full_adj > 0;    
replace occ_code = 35  if ((occ1990 >= 425 & occ1990 <= 427) | occ1990 == 415)& emp_full_adj > 0;     
replace occ_code = 36  if (occ1990 >= 433 & occ1990 <= 444)& emp_full_adj > 0;
replace occ_code = 37  if (occ1990 >= 445 & occ1990 <= 447)& emp_full_adj > 0;
replace occ_code = 38  if (occ1990 >= 448 & occ1990 <= 455)& emp_full_adj > 0;
replace occ_code = 39  if (occ1990 >= 456 & occ1990 <= 469)& emp_full_adj > 0;
replace occ_code = 40  if (occ1990 >= 473 & occ1990 <= 476)& emp_full_adj > 0;
replace occ_code = 41  if (occ1990 >= 477 & occ1990 <= 484)& emp_full_adj > 0;
replace occ_code = 42  if (occ1990 >= 485 & occ1990 <= 489)& emp_full_adj > 0;
replace occ_code = 43  if (occ1990 >= 494 & occ1990 <= 499)& emp_full_adj > 0;
replace occ_code = 44  if (occ1990 >= 503 & occ1990 <= 519)& emp_full_adj > 0;
replace occ_code = 45  if (occ1990 >= 523 & occ1990 <= 534)& emp_full_adj > 0;
replace occ_code = 46  if (occ1990 >= 535 & occ1990 <= 549)& emp_full_adj > 0;
replace occ_code = 47  if ((occ1990 >= 553 & occ1990 <= 599) | occ1990 == 866 | occ1990 == 869)& emp_full_adj > 0;
replace occ_code = 48  if ((occ1990 >= 613 & occ1990 <= 617) | occ1990 == 868)& emp_full_adj > 0;
replace occ_code = 49  if (occ1990 == 628)& emp_full_adj > 0;
replace occ_code = 50  if (occ1990 >= 634 & occ1990 <= 655)& emp_full_adj > 0;
replace occ_code = 51  if (occ1990 >= 656 & occ1990 <= 659)& emp_full_adj > 0;
replace occ_code = 52  if (occ1990 >= 666 & occ1990 <= 674)& emp_full_adj > 0;
replace occ_code = 53  if (occ1990 >= 675 & occ1990 <= 684)& emp_full_adj > 0;
replace occ_code = 54  if (occ1990 >= 686 & occ1990 <= 688)& emp_full_adj > 0;
replace occ_code = 55  if (occ1990 >= 694 & occ1990 <= 699)& emp_full_adj > 0;
replace occ_code = 56  if (occ1990 >= 703 & occ1990 <= 717)& emp_full_adj > 0;
replace occ_code = 57  if (occ1990 >= 719 & occ1990 <= 725)& emp_full_adj > 0;
replace occ_code = 58  if (occ1990 >= 726 & occ1990 <= 733)& emp_full_adj > 0;
replace occ_code = 59  if (occ1990 >= 734 & occ1990 <= 737)& emp_full_adj > 0;
replace occ_code = 60  if (occ1990 >= 738 & occ1990 <= 749)& emp_full_adj > 0;
replace occ_code = 61  if (occ1990 >= 753 & occ1990 <= 779)& emp_full_adj > 0;
replace occ_code = 62  if ((occ1990 >= 783 & occ1990 <= 795) | occ1990 == 874) & emp_full_adj > 0 ;
replace occ_code = 63  if (occ1990 >= 796 & occ1990 <= 799 | occ1990 >= 689 & occ1990 <= 693)& emp_full_adj > 0 ;
replace occ_code = 64  if (occ1990 >= 803 & occ1990 <= 815)& emp_full_adj > 0;
replace occ_code = 65  if ((occ1990 >= 823 & occ1990 <= 834) |(occ1990 >= 843 & occ1990 <= 865)) & emp_full_adj > 0;
replace occ_code = 66  if (occ1990 >= 875 & occ1990 <= 890)& emp_full_adj > 0;

label   define  occ_codelbl 0   `"Home"', add;
label	define	occ_codelbl	1	`"Executives, Administrative, and Managerial"',	add;	
label	define	occ_codelbl	2	`"Management Related"',	add;			
label	define	occ_codelbl	3	`"Architects"',	add;				
label	define	occ_codelbl	4	`"Engineers"',	add;				
label	define	occ_codelbl	5	`"Math	and	Computer Science"',	add;	
label	define	occ_codelbl	6	`"Natural Science"',	add;			
label	define	occ_codelbl	7	`"Health Diagnosing"',	add;			
label	define	occ_codelbl	8	`"Health Assessment"',	add;			
label	define	occ_codelbl	9	`"Therapists"',	add;				
label	define	occ_codelbl	10	`"Teachers,	Postsecondary"',	add;			
label	define	occ_codelbl	11	`"Teachers,	Non-Postsecondary"',	add;			
label	define	occ_codelbl	12	`"Librarians and Curators"',	add;		
label	define	occ_codelbl	13	`"Social Scientists	and	Urban Planners"',	add;
label	define	occ_codelbl	14	`"Social, Recreation, and Religious	Workers"',	add;
label	define	occ_codelbl	15	`"Lawyers and	Judges"',	add;		
label	define	occ_codelbl	16	`"Arts	and	Athletes"',	add;		
label	define	occ_codelbl	17	`"Health Technicians"',	add;			
label	define	occ_codelbl	18	`"Engineering Technicians"',	add;			
label	define	occ_codelbl	19	`"Science Technicians"',	add;			
label	define	occ_codelbl	20	`"Technicians, Other"',	add;			
label	define	occ_codelbl	21	`"Sales, all"',	add;				
label	define	occ_codelbl	22	`"Secretaries"',	add;				
label	define	occ_codelbl	23	`"Information Clerks"',	add;			
label	define	occ_codelbl	24	`"Records Processing, Non-Financial"',	add;		
label	define	occ_codelbl	25	`"Records Processing, Financial"',	add;		
label	define	occ_codelbl	26	`"Office Machine Operator"',	add;		
label	define	occ_codelbl	27	`"Computer and Communications Equipment Operator"',	add;		
label	define	occ_codelbl	28	`"Mail Distribution"',	add;			
label	define	occ_codelbl	29	`"Scheduling and Distributing Clerks"',	add;	
label	define	occ_codelbl	30	`"Adjusters	and	Investigators"',	add;		
label	define	occ_codelbl	31	`"Misc.	Admin Support"',	add;		
label	define	occ_codelbl	32	`"Private Household	Occupations"',	add;		
label	define	occ_codelbl	33	`"Firefighting"',	add;				
label	define	occ_codelbl	34	`"Police"',	add;				
label	define	occ_codelbl	35	`"Guards"',	add;				
label	define	occ_codelbl	36	`"Food Prep and Service"',	add;	
label	define	occ_codelbl	37	`"Health Service"',	add;			
label	define	occ_codelbl	38	`"Cleaning and Building	Service"',	add;	
label	define	occ_codelbl	39	`"Personal Service"',	add;			
label	define	occ_codelbl	40	`"Farm Managers"',	add;			
label	define	occ_codelbl	41	`"Farm Non-Managers"',	add;			
label	define	occ_codelbl	42	`"Related Agriculture"',	add;			
label	define	occ_codelbl	43	`"Forest, Logging, Fishers and Hunter"',	add;				
label	define	occ_codelbl	44	`"Vehicle Mechanic"',	add;			
label	define	occ_codelbl	45	`"Electronic Repairer"',	add;			
label	define	occ_codelbl	46	`"Misc.	Repairer"',	add;			
label	define	occ_codelbl	47	`"Construction Trade"',	add;			
label	define	occ_codelbl	48	`"Extractive"',	add;				
label	define	occ_codelbl	49	`"Precision	Production,	Supervisor"',	add;		
label	define	occ_codelbl	50	`"Precision	Metal"',	add;			
label	define	occ_codelbl	51	`"Precision	Wood"',	add;			
label	define	occ_codelbl	52	`"Precision, Textile"',	add;			
label	define	occ_codelbl	53	`"Precision, Other"',	add;			
label	define	occ_codelbl	54	`"Precision, Food"',	add;			
label	define	occ_codelbl	55	`"Plant	and	System Operator"',	add;	
label	define	occ_codelbl	56	`"Metal	and	Plastic	Machine	Operator"',	add;
label	define	occ_codelbl	57	`"Metal	and	Plastic	Processing	Operator"',	add;
label	define	occ_codelbl	58	`"Woodworking Machine Operator"',	add;		
label	define	occ_codelbl	59	`"Textile Machine Operator"',	add;		
label	define	occ_codelbl	60	`"Printing Machine Operator"',	add;		
label	define	occ_codelbl	61	`"Machine Operator, Other"',	add;		
label	define	occ_codelbl	62	`"Fabricators"',	add;				
label	define	occ_codelbl	63	`"Production Inspectors"',	add;			
label	define	occ_codelbl	64	`"Motor	Vehicle	Operator"',	add;		
label	define	occ_codelbl	65	`"Non Motor Vehicle Operator"',	add;		
label	define	occ_codelbl	66	`"Freight, Stock, Material	Handler"',	add;	

label values occ_code occ_codelbl;

/* -----------------------------------------------------------------------------
ADJUST TO 2012 DOLLARS, CPI-U
-----------------------------------------------------------------------------*/;
scalar cpi2007 = 207.342;

gen cpi = .;
replace cpi = 29.6 if year == 1960;
replace cpi = 38.8 if year == 1970;
replace cpi = 82.4 if year == 1980;
replace cpi = 130.7 if year == 1990;
replace cpi = 172.2 if year == 2000;
replace cpi = 218.056 if year == 2010;
replace cpi = 224.939 if year == 2011;
replace cpi = 229.594 if year == 2012;

gen earn2007 = earnings * cpi2007 / cpi;
keep if earn2007 >= 1000;

replace cpi = cpi / 229.594;

replace labinc = labinc / cpi;
replace farmbus = farmbus / cpi;
replace earnings = earnings / cpi;

/* -----------------------------------------------------------------------------
SAVE CLEANED DATASET TO OUTPUT
-----------------------------------------------------------------------------*/;
cap mkdir ${build}/output;
save ${build}/output/cleaned_${region}.dta, replace;

