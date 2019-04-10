


/* -----------------------------------------------------------------------------
REGRESSIONS
-----------------------------------------------------------------------------*/;
egen groupid = group(occ_code ${regionvar});
xtset groupid ${timevar};

scalar io = 0;
forvalues occnum = 1/66 {;
	scalar io = io + 1;
	
	quietly reg d.lrel_emp d.learnings d.lrel_earn 
		if occ_code == `occnum', robust;
		
	if `occnum' == `baseocc' {;
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
mat colnames coeffs = "beta_j" "se(beta_j)" "p(beta_j>|t|)" "theta_j" "se(theta_j)" "p(theta_j>|t|)";

cap mkdir ${stats}/output;
putexcel set ${stats}/output/fdregressions_${timevar}.xlsx, replace;
putexcel A1=matrix(coeffs), names;
