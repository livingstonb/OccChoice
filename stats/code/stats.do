#delimit ;
set more 1;

/* -----------------------------------------------------------------------------
DECLARE BASE OCCUPATION AND TIME SPECIFICATION
-----------------------------------------------------------------------------*/;
global baseocc 1;

/*
spec1 - 20ish year changes
spec2 - 30ish year changes
spec3 - long-run changes
*/;
foreach sp of newlist spec1 spec2 spec3 {;
	global timevar `sp';

	/* -----------------------------------------------------------------------------
	COMPUTE RELATIVE EMPLOYMENT AND RELATIVE EARNINGS
	-----------------------------------------------------------------------------*/;
	
	clear;
	use ${build}/output/final_${region}.dta;

	// employment in base sector;
	bysort survey ${regionvar}: gen temp = nperson if occ_code == ${baseocc};
	bysort survey ${regionvar}: egen baseemp = max(temp);
	drop temp;

	// median earnings in base sector;
	bysort survey ${regionvar}: gen temp = earnings if occ_code == ${baseocc};
	bysort survey ${regionvar}: egen baseearn = max(temp);
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
