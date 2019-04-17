#delimit ;
set more 1;

/*
Creates a table of occupations by regions for each year with the number of non-
missing observations in each occupation-region-year group. May need to be updated
since code was changed to use different occupation codings
*/

foreach occ of newlist occ19 occ66 {;
	if "`occ'" == "occ19" {;
		local occvar occ_broad;
		local years 1980 1990 2000 2010;
	};
	else if "`occ'" == "occ66" {;
		local occvar occ_code;
		local years 1960 1970 1980 1990 2000 2010;
	};
	
	clear;
	use ${build}/output/final_${region}_`occ'.dta;
	cap mkdir ${stats}/output;

	foreach syear of local years {;
		preserve;
		keep if survey == `syear';
		keep `occvar' statefip groupobs;
		
		levelsof statefip, local(states);
		foreach istate of local states {;
			local state`istate': label (statefip) `istate';
		};
		
		reshape wide groupobs, i(`occvar') j(statefip);
		
		set varabbrev off;
		foreach istate of local states {;
			local statename `state`istate'';
			local statename = subinstr("`statename'"," ","",10);
			rename groupobs`istate' `statename';
		};
		set varabbrev on;
		export delimited using ${stats}/output/groupobs`syear'_`occ'.csv, replace;
		restore;
	};
};
