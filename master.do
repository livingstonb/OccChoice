#delimit ;
set more 1;

clear;

// choose main directory;

local OS windows; // windows, mac;

if 	"`OS'" == "windows" {;
	global maindir D:/GitHub/OccChoice;
};
else if "`OS'" == "windows2" {;
	global maindir C:/Users/Brian-laptop/Documents/GitHub/OccChoice;
};
else if "`OS'" == "mac" {;
	global maindir /Users/brianlivingston/Documents/GitHub/OccChoice;
};

global build ${maindir}/build;
global stats ${maindir}/stats;

/* -----------------------------------------------------------------------------
BUILD DATASET
-----------------------------------------------------------------------------*/;
#delimit ;
// define region as 'state' or 'metro';
global region state;

if "$region" == "state" {;
	global regionvar statefip;
};
else if "$region" == "metro" {;
	global regionvar metarea;
};

do ${build}/code/build1_raw.do;

foreach var of varlist occ_code occ_broad {;
	global occvar `var';
	if "`var'" == "occ_broad" {;
		global occs occ19;
	};
	else if "`var'" == "occ_code" {;
		global occs occ66;
	};

	do ${build}/code/build2_groups.do;
};

/* -----------------------------------------------------------------------------
COMPUTE STATISTICS
-----------------------------------------------------------------------------*/;
#delimit ;
// define region as 'state' or 'metro';
global region state;

if "$region" == "state" {;
	global regionvar statefip;
};
else if "$region" == "metro" {;
	global regionvar metarea;
};
do ${stats}/code/stats.do;
