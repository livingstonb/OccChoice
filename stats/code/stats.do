#delimit ;
set more 1;

clear;
use ${build}/output/final_${region}.dta;

/* -----------------------------------------------------------------------------
REGRESSIONS
-----------------------------------------------------------------------------*/;
egen groupid = group(occ_code ${regionvar});
xtset groupid spec1;

scalar io = 1;
forvalues occnum = 2/66 {;
	quietly reg d.lrel_emp d.learnings d.lrel_earn 
		if occ_code == `occnum', robust;
		
	matrix beta = _b[d.learnings];
	matrix se_beta = _se[d.learnings];
	matrix theta = _b[d.lrel_earn];
	matrix se_theta = _se[d.lrel_earn];
	
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
	scalar io = io + 1;
};
