#delimit ;
set more 1;
clear;

use ${build}/temp/cleaned_${region}.dta;


/* -----------------------------------------------------------------------------
COLLAPSE TO REGION LEVEL
-----------------------------------------------------------------------------*/;

// declare base occupation;
local baseocc 1;

gen nperson = 1;
bysort survey $regionvar ${occvar}: egen groupobs = total(nperson);

egen reg_year_id = group(survey ${regionvar});
quietly levelsof reg_year_id, local(region_year_groups);

// median earnings for all occupations in region-year;
gen grpearnings = .;
label variable grpearnings "Median earnings in year for this region";
foreach id of local region_year_groups {;
	// quietly sum earnings if reg_year_id == `id' [fweight=perwt], detail;
	// replace grpearnings = r(p50) if reg_year_id == `id';
	
	_pctile earnings if reg_year_id == `id' [fweight=perwt], p(50);
	replace grpearnings = r(r1) if reg_year_id == `id';
};
drop reg_year_id;

// total employment in all occupations in region-year;
bysort survey ${regionvar}: egen grpemp = total(perwt);
label variable grpemp "Total employment in year for this region";

collapse 	(sum) nperson
			(mean) groupobs grpearnings grpemp
			(median) incwage incbusfarm earnings yrseduc [fweight=perwt], 
			by(survey $regionvar ${occvar});
gen learnings = log(earnings);


/* -----------------------------------------------------------------------------
SAVE CLEANED DATASET TO OUTPUT
-----------------------------------------------------------------------------*/;
cap mkdir ${build}/output;
save ${build}/output/final_${region}_${occs}.dta, replace;
