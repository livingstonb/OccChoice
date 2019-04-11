#delimit ;
set more 1;

/* -----------------------------------------------------------------------------
DECLARE BASE OCCUPATION AND TIME SPECIFICATION
-----------------------------------------------------------------------------*/;
global baseocc 1;

/* 
for occ19:
spec1 - 20ish year changes
spec2 - long-run changes

for occ67:
spec1 - 20ish year changes
spec2 - 30ish year changes
spec3 - long-run changes
*/;

foreach var of newlist occ19 occ66 {;
	global occs `var';
	
	if "$occs" == "occ19" {;
		global occvar occ_broad;
		global occnums 1/19;
		local specs spec1 spec2;
	};
	else if "$occs" == "occ66" {;
		global occvar occ_code;
		global occnums 1/66;
		local specs spec1 spec2 spec3;
	};

foreach sp of local specs {;
	global timevar `sp';
	
	clear;
	use ${build}/output/final_${region}_${occs}.dta;
	
	// define time variable;
	if "$occs" == "occ19" {;	
		// 20-year changes;
		gen spec1 = 1 if survey == 1980;
		replace spec1 = 2 if survey == 2000;
		replace spec1 = 3 if survey == 2010;
		
		// long-run changes;
		gen spec2 = 1 if survey == 1980;
		replace spec2 = 2 if survey == 2010;
	};
	else if "$occs" == "occ66" {;
		// 20-year changes;
		gen spec1 = 1 if survey == 1960;
		replace spec1 = 2 if survey == 1980;
		replace spec1 = 3 if survey == 2000;
		replace spec1 = 4 if survey == 2010;

		// 30-year changes;
		gen spec2 = 1 if survey == 1960;
		replace spec2 = 2 if survey == 1990;
		replace spec2 = 3 if survey == 2010;

		// long-run changes;
		gen spec3 = 1 if survey == 1980;
		replace spec3 = 2 if survey == 2010;
	};

	/* -----------------------------------------------------------------------------
	COMPUTE RELATIVE EMPLOYMENT AND RELATIVE EARNINGS
	-----------------------------------------------------------------------------*/;

	// employment in base sector;
	bysort survey ${regionvar}: gen temp = nperson if ${occvar} == ${baseocc};
	bysort survey ${regionvar}: egen baseemp = max(temp);
	drop temp;

	// median earnings in base sector;
	bysort survey ${regionvar}: gen temp = earnings if ${occvar} == ${baseocc};
	bysort survey ${regionvar}: egen baseearn = max(temp);
	gen lbaseearn = log(baseearn);
	drop temp;

	// relative employment;
	gen rel_emp = nperson / baseemp;
	gen lrel_emp = log(rel_emp);

	// relative median earnings;
	gen rel_earn = earnings / baseearn;
	gen lrel_earn = log(rel_earn);
	
	/* -----------------------------------------------------------------------------
	REGRESSIONS
	-----------------------------------------------------------------------------*/;
	do ${stats}/code/stats_regressions.do;
};
};
