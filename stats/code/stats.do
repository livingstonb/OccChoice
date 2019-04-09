#delimit ;
set more 1;

clear;
use ${build}/output/final_${region}.dta;

/* -----------------------------------------------------------------------------
REGRESSIONS
-----------------------------------------------------------------------------*/;
gen groupid = group(occ_code ${regionvar});
xtset groupid spec1;

forvalues occnum = 1/66 {;
	reg d.lrel_emp d.learnings d.lrel_earn 
		if occ_code == `occnum', robust;
		
	matrix beta = _b[name1];
	matrix se_beta = _se[name1];
	matrix theta = _b[name2];
	matrix se_theta = _se[name2];
	
	local row: label (occ_code) `occnum';
	foreach mat in beta se_beta theta se_theta {;
		// matrix rownames `mat' = `row';
	};
		
	if `occnum' == 1 {;
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
