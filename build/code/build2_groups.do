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
bysort survey $regionvar occ_code: egen groupobs = count(nperson);

collapse 	(sum) nperson
			(mean) groupobs spec*
			(median) incwage incbusfarm earnings yrseduc [fweight=perwt], 
			by(survey $regionvar occ_code);
gen learnings = log(earnings);

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
SAVE CLEANED DATASET TO OUTPUT
-----------------------------------------------------------------------------*/;
cap mkdir ${build}/output;
save ${build}/output/final_${region}.dta, replace;
