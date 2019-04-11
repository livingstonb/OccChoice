#delimit ;
set more 1;

cap mkdir ${stats}/temp;
cap mkdir ${stats}/output;

/* -----------------------------------------------------------------------------
REGRESSIONS
-----------------------------------------------------------------------------*/;
egen groupid = group(${occvar} ${regionvar});
xtset groupid ${timevar};

scalar io = 0;

forvalues occnum = $occnums {;
	scalar io = io + 1;
	
	quietly reg d.lrel_emp d.learnings d.lrel_earn
		if ${occvar} == `occnum', robust;
		
	if `occnum' == $baseocc {;
		matrix beta = .;
		matrix se_beta = .;
		matrix p_beta = .;
		matrix theta = .;
		matrix se_theta = .;
		matrix p_theta = .;
	};
	else {;
		matrix outtable = r(table);
		matrix beta = _b[d.learnings];
		matrix se_beta = _se[d.learnings];
		matrix p_beta = outtable[4,1];
		matrix theta = _b[d.lrel_earn];
		matrix se_theta = _se[d.lrel_earn];
		matrix p_theta = outtable[4,2];
	};
	
	local row: label (${occvar}) `occnum';
	local row = stritrim("`row'");
	local row = strtrim("`row'");
	local row = substr("`row'",1,29);
	local row = subinstr("`row'",".","",5);
	foreach mat in beta se_beta theta se_theta {;
		matrix rownames `mat' = "`occnum' `row'";
	};
		
	if io == 1 {;
		matrix betas = beta;
		matrix se_betas = se_beta;
		matrix p_betas = p_beta;
		matrix thetas = theta;
		matrix se_thetas = se_theta;
		matrix p_thetas = p_theta;
	};
	else {;
		matrix betas = betas\beta;
		matrix se_betas = se_betas\se_beta;
		matrix p_betas = p_betas\p_beta;
		matrix thetas = thetas\theta;
		matrix se_thetas = se_thetas\se_theta;
		matrix p_thetas = p_thetas\p_theta;
	};
};

matrix coeffs = betas,se_betas,p_betas,thetas,se_thetas,p_thetas;
mat colnames coeffs = "beta_j" "se_beta_j" "p_beta_j" "theta_j" "se_theta_j" "p_theta_j";

putexcel set ${stats}/temp/fdregressions_${timevar}_${occs}.xlsx, replace;
putexcel A1=matrix(coeffs), names;
drop groupid;

// replace xlsx output with csv for python;
clear;
import excel ${stats}/temp/fdregressions_${timevar}_${occs}.xlsx, firstrow;
rename A Occupations;
export delimited using ${stats}/temp/fdregressions_${timevar}_${occs}.csv, replace;
erase ${stats}/temp/fdregressions_${timevar}_${occs}.xlsx;
