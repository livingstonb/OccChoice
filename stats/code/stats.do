#delimit ;
set more 1;

clear;
use ${build}/output/final_${region}.dta;



/* -----------------------------------------------------------------------------
DECLARE BASE OCCUPATION AND TIME SPECIFICATION
-----------------------------------------------------------------------------*/;
local baseocc 1;

/*
spec1 - 20ish year changes
spec2 - 30ish year changes
spec3 - long-run changes
*/;
local timevar spec1;

/* -----------------------------------------------------------------------------
COMPUTE RELATIVE EMPLOYMENT AND RELATIVE EARNINGS
-----------------------------------------------------------------------------*/;

// employment in base sector;
bysort survey ${regionvar}: gen temp = nperson if occ_code == `baseocc';
bysort survey ${regionvar}: egen baseemp = max(temp);
drop temp;

// median earnings in base sector;
bysort survey ${regionvar}: gen temp = earnings if occ_code == `baseocc';
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
egen groupid = group(occ_code ${regionvar});
xtset groupid `timevar';

scalar io = 0;
forvalues occnum = 1/66 {;
	scalar io = io + 1;
	
	quietly reg d.lrel_emp d.learnings d.lrel_earn 
		if occ_code == `occnum', robust;
		
	if `occnum' == `baseocc' {;
		matrix beta = .;
		matrix se_beta = .;
		matrix theta = .;
		matrix se_theta = .;
	};
	else {;
		matrix beta = _b[d.learnings];
		matrix se_beta = _se[d.learnings];
		matrix theta = _b[d.lrel_earn];
		matrix se_theta = _se[d.lrel_earn];
	};
	
	local row: label (occ_code) `occnum';
	local row = stritrim("`row'");
	local row = strtrim("`row'");
	local row = abbrev("`row'",29);
	local row = subinstr("`row'",".","",5);
	foreach mat in beta se_beta theta se_theta {;
		matrix rownames `mat' = "`occnum' `row'";
	};
		
	if io == 1 {;
		matrix betas = beta;
		matrix se_betas = se_beta;
		matrix thetas = theta;
		matrix se_thetas = se_theta;
	};
	else {;
		matrix betas = betas\beta;
		matrix se_betas = se_betas\se_beta;
		matrix thetas = thetas\theta;
		matrix se_thetas = se_thetas\se_theta;
	};
};

matrix coeffs = betas,se_betas,thetas,se_thetas;
mat colnames coeffs = "beta_j" "se(beta_j)" "theta_j" "se(theta_j)";
