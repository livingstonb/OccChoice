#delimit ;
set more 1;

clear;

// choose main directory;

local OS mac; // windows, mac;

if 	"`OS'" == "windows" {;
	global maindir C:/Users/Brian/Documents/GitHub/OccChoice;
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
------------------------------------------------------------------------------*/

do ${build}/code/build.do;

/* -----------------------------------------------------------------------------
COMPUTE STATISTICS
------------------------------------------------------------------------------*/

// do ${stats}/code/stats.do;
