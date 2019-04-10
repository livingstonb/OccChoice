#delimit ;
set more 1;

clear;

use ${build}/input/raw_${region}.dta;

/* -----------------------------------------------------------------------------
RENAME VARIABLES
-----------------------------------------------------------------------------*/;
rename datanum dataset;
rename serial hhid;
replace year = multyear if !missing(multyear);
drop multyear;

/* -----------------------------------------------------------------------------
BUSINESS AND FARM INCOME, DIFFERENT DEFS ACROSS YEARS
-----------------------------------------------------------------------------*/;
rename incbusfm busfarm; // bus and farm income for yr 1960;
rename incbus00 newincbus; // bus and farm income for yr >= 2000;

foreach var of varlist busfarm newincbus incfarm incbus {;
	drop if `var' == 999999;
};

replace busfarm = incfarm + incbus if (year >= 1970) & (year <= 1990);
replace busfarm = newincbus if year >= 2000;
drop newincbus incfarm incbus;
rename busfarm incbusfarm;

/* -----------------------------------------------------------------------------
SAMPLE SELECTION
-----------------------------------------------------------------------------*/;
drop if (occ1990 == 999) | (wkswork2 == 0);
drop if (uhrswork == 0 & year >= 1980) | (hrswork2 == 0 & year <= 1970);
drop if inlist(incwage,999998,999999);

keep if race == 1;
keep if sex == 1;
keep if (empstat == 1) & !inlist(empstatd,13,14,15); // exclude military;
drop if occ1990 == 991; // unemployed;
keep if (age >= 25) & (age <= 54);
drop if (uhrswork < 30) & (year >= 1980);
drop if (hrswork2 <= 3) & (year <= 1970);
keep if (wkswork2 >= 5);

/* -----------------------------------------------------------------------------
GENERATE NEW VARIABLES
-----------------------------------------------------------------------------*/;
if "$region" == "state" {;
	gen metarea = .;
};
else if "$region" == "metro" {;
	gen statefip = .;
};

// survey year;
gen survey = year;
replace survey = 2010 if inlist(year,2011,2012,2013,2014);

/* CPI-U annual averages, using previous year's CPI because of survey wording
ACS surveys for 2010-2014 are already inflation adjusted to 2014 dollars */;
gen cpi = .;
replace cpi = 29.1 if year == 1960;
replace cpi = 36.7 if year == 1970;
replace cpi = 72.6 if year == 1980;
replace cpi = 124.0 if year == 1990;
replace cpi = 166.6 if year == 2000;

// earnings;
gen earnings = incwage + incbusfarm;

// rescale cpi so 2014 index is 1;
scalar cpi2014 = 236.736;
replace cpi = cpi / cpi2014;

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

// Hurst et al. 66 occupation codes;
gen occ_code = .;					
replace occ_code = 1  if ((occ1990 >= 3 & occ1990 <= 22) ) ;
replace occ_code = 2  if ((occ1990 >= 23 & occ1990 <= 37) | (occ1990 >= 303 & occ1990 <= 307) | (occ1990 == 200));
replace occ_code = 3  if (occ1990 == 43);
replace occ_code = 4  if ((occ1990 >= 44 & occ1990 <= 63) | occ1990 == 867);
replace occ_code = 5  if (occ1990 >= 64 & occ1990 <= 68) ;
replace occ_code = 6  if (occ1990 >= 69 & occ1990 <= 83);
replace occ_code = 7  if (occ1990 >= 84 & occ1990 <= 89);
replace occ_code = 8  if (occ1990 >= 95 & occ1990 <= 97);
replace occ_code = 9  if (occ1990 >= 98 & occ1990 <= 106);
replace occ_code = 10 if (occ1990 >= 113 & occ1990 <= 154);
replace occ_code = 11  if (occ1990 >= 155 & occ1990 <= 163);
replace occ_code = 12  if (occ1990 >= 164 & occ1990 <= 165);
replace occ_code = 13  if (occ1990 >= 166 & occ1990 <= 173);
replace occ_code = 14  if (occ1990 >= 174 & occ1990 <= 177);
replace occ_code = 15  if (occ1990 >= 178 & occ1990 <= 179);
replace occ_code = 16  if (occ1990 >= 183 & occ1990 <= 199);
replace occ_code = 17  if (occ1990 >= 203 & occ1990 <= 208);
replace occ_code = 18  if (occ1990 >= 213 & occ1990 <= 218);
replace occ_code = 19  if (occ1990 >= 223 & occ1990 <= 225);
replace occ_code = 20  if (occ1990 >= 226 & occ1990 <= 235);
replace occ_code = 21  if (occ1990 >= 243 & occ1990 <= 290);
replace occ_code = 22  if (occ1990 >= 313 & occ1990 <= 315);
replace occ_code = 23  if (occ1990 >= 316 & occ1990 <= 323);
replace occ_code = 24  if (occ1990 >= 325 & occ1990 <= 336);
replace occ_code = 25  if (occ1990 >= 337 & occ1990 <= 344);
replace occ_code = 26  if (occ1990 >= 345 & occ1990 <= 347);
replace occ_code = 27  if ((occ1990 >= 348 & occ1990 <= 353) | (occ1990 >= 308 & occ1990 <= 309)) ;
replace occ_code = 28  if (occ1990 >= 354 & occ1990 <= 357);
replace occ_code = 29  if (occ1990 >= 359 & occ1990 <= 374);
replace occ_code = 30  if (occ1990 >= 375 & occ1990 <= 378);
replace occ_code = 31  if (occ1990 >= 379 & occ1990 <= 391);
replace occ_code = 32  if (occ1990 >= 403 & occ1990 <= 408);
replace occ_code = 33  if ((occ1990 >= 416 & occ1990 <= 417) | occ1990 == 413);   
replace occ_code = 34  if ((occ1990 >= 418 & occ1990 <= 424) | occ1990 == 414);    
replace occ_code = 35  if ((occ1990 >= 425 & occ1990 <= 427) | occ1990 == 415);     
replace occ_code = 36  if (occ1990 >= 433 & occ1990 <= 444);
replace occ_code = 37  if (occ1990 >= 445 & occ1990 <= 447);
replace occ_code = 38  if (occ1990 >= 448 & occ1990 <= 455);
replace occ_code = 39  if (occ1990 >= 456 & occ1990 <= 469);
replace occ_code = 40  if (occ1990 >= 473 & occ1990 <= 476);
replace occ_code = 41  if (occ1990 >= 477 & occ1990 <= 484);
replace occ_code = 42  if (occ1990 >= 485 & occ1990 <= 489);
replace occ_code = 43  if (occ1990 >= 494 & occ1990 <= 499);
replace occ_code = 44  if (occ1990 >= 503 & occ1990 <= 519);
replace occ_code = 45  if (occ1990 >= 523 & occ1990 <= 534);
replace occ_code = 46  if (occ1990 >= 535 & occ1990 <= 549);
replace occ_code = 47  if ((occ1990 >= 553 & occ1990 <= 599) | occ1990 == 866 | occ1990 == 869);
replace occ_code = 48  if ((occ1990 >= 613 & occ1990 <= 617) | occ1990 == 868);
replace occ_code = 49  if (occ1990 == 628);
replace occ_code = 50  if (occ1990 >= 634 & occ1990 <= 655);
replace occ_code = 51  if (occ1990 >= 656 & occ1990 <= 659);
replace occ_code = 52  if (occ1990 >= 666 & occ1990 <= 674);
replace occ_code = 53  if (occ1990 >= 675 & occ1990 <= 684);
replace occ_code = 54  if (occ1990 >= 686 & occ1990 <= 688);
replace occ_code = 55  if (occ1990 >= 694 & occ1990 <= 699);
replace occ_code = 56  if (occ1990 >= 703 & occ1990 <= 717);
replace occ_code = 57  if (occ1990 >= 719 & occ1990 <= 725);
replace occ_code = 58  if (occ1990 >= 726 & occ1990 <= 733);
replace occ_code = 59  if (occ1990 >= 734 & occ1990 <= 737);
replace occ_code = 60  if (occ1990 >= 738 & occ1990 <= 749);
replace occ_code = 61  if (occ1990 >= 753 & occ1990 <= 779);
replace occ_code = 62  if ((occ1990 >= 783 & occ1990 <= 795) | occ1990 == 874)  ;
replace occ_code = 63  if (occ1990 >= 796 & occ1990 <= 799 | occ1990 >= 689 & occ1990 <= 693) ;
replace occ_code = 64  if (occ1990 >= 803 & occ1990 <= 815);
replace occ_code = 65  if ((occ1990 >= 823 & occ1990 <= 834) |(occ1990 >= 843 & occ1990 <= 865)) ;
replace occ_code = 66  if (occ1990 >= 875 & occ1990 <= 890);

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

// Hurst et al. 20 occupation codes;
gen occ_broad = .  ;  						
replace occ_broad = 1  if ((occ1990 >= 3 & occ1990 <= 22) );
replace occ_broad = 2  if ((occ1990 >= 23 & occ1990 <= 37) | (occ1990 == 200));
replace occ_broad = 3  if ((occ1990 >= 43 & occ1990 <= 68) | occ1990 == 867);
replace occ_broad = 4  if ((occ1990 >= 69 & occ1990 <= 83) | (occ1990 >= 166 & occ1990 <= 177) | (occ1990 >= 183 & occ1990 <= 199));
replace occ_broad = 5  if ((occ1990 >= 84 & occ1990 <= 89) | (occ1990 >= 178 & occ1990 <= 179)) ;
replace occ_broad = 6  if ((occ1990 >= 95 & occ1990 <= 106) | (occ1990 >= 445 & occ1990 <= 447)) ;
replace occ_broad = 7  if (occ1990 >= 113 & occ1990 <= 154);
replace occ_broad = 8  if (occ1990 >= 155 & occ1990 <= 165);
replace occ_broad = 9  if (occ1990 >= 203 & occ1990 <= 235);
replace occ_broad = 10 if (occ1990 >= 243 & occ1990 <= 290);
replace occ_broad = 11 if (occ1990 >= 303 & occ1990 <= 391);
replace occ_broad = 12 if (occ1990 >= 413 & occ1990 <= 427);
replace occ_broad = 13 if ((occ1990 >= 403 & occ1990 <= 408) | (occ1990 >= 433 & occ1990 <= 444)| (occ1990 >= 448 & occ1990 <= 469));
replace occ_broad = 14  if ((occ1990 >= 473 & occ1990 <= 499) | (occ1990 >= 613 & occ1990 <= 617) | (occ1990 == 868));
replace occ_broad = 15  if ((occ1990 >= 503 & occ1990 <= 599)| (occ1990 == 866) | (occ1990 == 869));
replace occ_broad = 16  if (occ1990 >= 628 & occ1990 <= 688);
replace occ_broad = 17  if (occ1990 >= 694 & occ1990 <= 779);
replace occ_broad = 18  if ((occ1990 >= 783 & occ1990 <= 799) | (occ1990 >= 689 & occ1990 <= 693) |(occ1990 >= 875 & occ1990 <= 890) | (occ1990 == 874));
replace occ_broad = 19  if ((occ1990 >= 803 & occ1990 <= 815) | (occ1990 >= 823 & occ1990 <= 834) |(occ1990 >= 843 & occ1990 <= 865));
replace occ_broad = . if survey < 1980;

label	define	occ_broadlbl	1	`"Executives, Administrative, and Managerial"',	add;	
label	define	occ_broadlbl	2	`"Management Related"',	add;			
label	define	occ_broadlbl	3	`"Architects, Engineers, Math, and Computer Science"',	add;				
label	define	occ_broadlbl	4	`"Natural and Social Scientists, Recreation, Religious, Arts, Athletes"',	add;	
label	define	occ_broadlbl	5	`"Doctors and Lawyers"',	add;				
label	define	occ_broadlbl	6	`"Nurses, Therapists, and Other Health Service"',	add;	
label	define	occ_broadlbl	7	`"Teachers, Postsecondary"',	add;			
label	define	occ_broadlbl	8	`"Teachers, Non-Postsecondary and Librarians"',	add;			
label	define	occ_broadlbl 	9	`"Health and Science Technicians"',	add;			
label	define	occ_broadlbl	10	`"Sales, All"',	add;				
label	define	occ_broadlbl	11	`"Administrative Support, Clerks, Record Keepers"',	add;			
label	define	occ_broadlbl	12	`"Fire, Police, and Guards"',	add;			
label	define	occ_broadlbl	13	`"Food, Cleaning, and Personal Services and Private Household"',	add;		
label	define	occ_broadlbl	14	`"Farm, Related Agrigulture, Logging, and Extraction"',	add;
label	define	occ_broadlbl	15	`"Mechanics and Construction"',	add;
label	define	occ_broadlbl	16	`"Precision Manufacturing"',	add;		
label	define	occ_broadlbl	17	`"Manufacturing Operators"',	add;		
label	define	occ_broadlbl	18	`"Fabricators, Inspectors, and Material Handlers"',	add;			
label	define	occ_broadlbl	19 `"Vehicle Operators"',	add;	

label variable occ_broad occ_broadlbl;

/* -----------------------------------------------------------------------------
VARIABLE ADJUSTMENTS
-----------------------------------------------------------------------------*/;
// perwt = perwt / 100;
local nomvars incwage incbusfarm earnings;

// convert to 2014 dollars;
foreach var of local nomvars {;
	replace `var' = `var' / cpi if year <= 2000;
};

/* -----------------------------------------------------------------------------
DROP OBSERVATIONS WITH LOW 2007 EARNINGS
-----------------------------------------------------------------------------*/;
scalar cpi2007 = 207.342;
scalar cpi2014 = 236.736;
gen earn2007 = earnings * cpi2007 / cpi2014;
keep if earn2007 >= 1000;
drop earn2007;

/* -----------------------------------------------------------------------------
SAVE CLEANED DATASET TO TEMP
-----------------------------------------------------------------------------*/;
cap mkdir ${build}/temp;
save ${build}/temp/cleaned_${region}.dta, replace;

