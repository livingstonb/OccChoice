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
bysort survey $regionvar ${occvar}: egen groupobs = count(nperson);

collapse 	(sum) nperson
			(mean) groupobs
			(median) incwage incbusfarm earnings yrseduc [fweight=perwt], 
			by(survey $regionvar ${occvar});
gen learnings = log(earnings);


/* -----------------------------------------------------------------------------
SAVE CLEANED DATASET TO OUTPUT
-----------------------------------------------------------------------------*/;
cap mkdir ${build}/output;
save ${build}/output/final_${region}_${occs}.dta, replace;
