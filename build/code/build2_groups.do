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
collapse 	(sum) nperson
			(median) incwage incbusfarm earnings yrseduc [fweight=perwt], 
			by(survey statefip occ_code);

// employment in base sector;
bysort survey statefip: gen temp = nperson if occ_code == `baseocc';
bysort survey statefip: egen baseemp = max(temp);
drop temp;

// median earnings in base sector;
bysort survey statefip: gen temp = earnings if occ_code == `baseocc';
bysort survey statefip: egen baseearn = max(temp);
drop temp;

// relative employment;
gen rel_emp = nperson / baseemp;
gen lrel_emp = log(rel_emp);

// relative median earnings;
gen rel_earn = earnings / baseearn;
gen lrel_earn = log(rel_earn);

/* -----------------------------------------------------------------------------
SAVE CLEANED DATASET TO OUTPUT
-----------------------------------------------------------------------------*/;
cap mkdir ${build}/output;
save ${build}/output/final_${region}.dta, replace;
