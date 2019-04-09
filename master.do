#delimit ;
set more 1;

clear;

// choose main directory;

local OS mac; // windows, mac;

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
// define region as 'state' or 'metro';
global region state;

if "$region" == "state" {;
	global regionvar statefip;
};
else if "$region" == "metro" {;
	global regionvar metarea;
};

do ${build}/code/build1_raw.do;
do ${build}/code/build1_groups.do;

/* -----------------------------------------------------------------------------
COMPUTE STATISTICS
-----------------------------------------------------------------------------*/;
// define region as 'state' or 'metro';
global region state;

if "$region" == "state" {;
	global regionvar statefip;
};
else if "$region" == "metro" {;
	global regionvar metarea;
};
// do ${stats}/code/stats.do;
