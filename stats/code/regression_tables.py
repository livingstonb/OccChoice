import numpy as np
import pandas as pd

# file directory
os = 'mac'

if os == 'mac':
	maindir = '/Users/brianlivingston/Documents/GitHub/OccChoice/stats/'
elif os == 'linux':
	maindir = '/media/hdd/GitHub/OccChoice/stats/'
elif os == 'windows':
	maindir = 'D:/GitHub/OccChoice/stats/'
	
tempdir = maindir + 'temp/'
outdir = maindir + 'output/'
	
# occupation code (occ19, occ66)
occs = "occ19"

outname = outdir + 'fdregressions.xlsx'
writer = pd.ExcelWriter(outname,engine='xlsxwriter')

def clean(timevar,occs):
	fname = 'fdregressions_' + timevar + '_' + occs +'.csv'

	tab = pd.read_csv(tempdir+fname,index_col=0)
	tab = tab.applymap(lambda x: np.round(x,3))
	cols = tab.columns
	newcols = ["beta","se_beta","p_beta","theta","se_theta","p_theta"]
	tab.rename(columns={cols[0]:"beta",
		cols[1]:"se_beta",
		cols[2]:"p_beta",
		cols[3]:"theta",
		cols[4]:"se_theta",
		cols[5]:"p_theta"},inplace=True)
		
	sigbeta10 = (tab["p_beta"] < 0.1) & (tab["p_beta"] >= 0.05)
	sigbeta5 = tab["p_beta"] < 0.05

	sigtheta10 = (tab["p_theta"] < 0.1) & (tab["p_theta"] >= 0.05)
	sigtheta5 = tab["p_theta"] < 0.05
		
	tab = tab.astype(str)
	tab.loc[sigbeta10==True,"beta"] = tab.loc[sigbeta10==True,"beta"] + "*"
	tab.loc[sigbeta5==True,"beta"] = tab.loc[sigbeta5==True,"beta"] + "**"
	tab.loc[sigtheta10==True,"theta"] = tab.loc[sigtheta10==True,"theta"] + "*"
	tab.loc[sigtheta5==True,"theta"] = tab.loc[sigtheta5==True,"theta"] + "**"

	tab["beta"] = tab["beta"] + ' (' + tab["se_beta"] + ')'
	tab["theta"] = tab["theta"] + ' (' + tab["se_theta"] + ')'
	tab = tab[["beta","theta"]]

	if occs == "occ19":
		occ_codes = ["01 Executives, Administrative, and Managerial",
					"02 Management Related",
					"03 Architects, Engineers, Math, and Computer Science",
					"04 Natural and Social Scientists, Recreation, Religious, Arts, Athletes",
					"05 Doctors and Lawyers",
					"06 Nurses, Therapists, and Other Health Service",
					"07 Teachers, Postsecondary",
					"08 Teachers, Non-Postsecondary and Librarians",
					"09 Health and Science Technicians",
					"10 Sales, All",
					"11 Administrative Support, Clerks, Record Keepers",
					"12 Fire, Police, and Guards",
					"13 Food, Cleaning, and Personal Services and Private Household",
					"14 Farm, Related Agrigulture, Logging, and Extraction",
					"15 Mechanics and Construction",
					"16 Precision Manufacturing",
					"17 Manufacturing Operators",
					"18 Fabricators, Inspectors, and Material Handlers",
					"19 Vehicle Operators"]
	elif occs == "occ66":
		occ_codes = ["01 Executives, Administrative, and Managerial",
					"02 Management Related",
					"03 Architects",
					"04 Engineers",
					"05 Math and Computer Science",
					"06 Natural Science",
					"07 Health Diagnosing",
					"08 Health Assessment",
					"09 Therapists",
					"10 Teachers, Postsecondary",
					"11 Teachers, Non-Postsecondary",
					"12 Librarians and Curators",
					"13 Social Scientists and Urban Planners",
					"14 Social, Recreation, and Religious Workers",
					"15 Lawyers and	Judges",
					"16 Arts and Athletes",
					"17 Health Technicians",
					"18 Engineering Technicians",
					"19 Science Technicians",
					"20 Technicians, Other",
					"21 Sales, all",
					"22 Secretaries",
					"23 Information Clerks",
					"24 Records Processing, Non-Financial",
					"25 Records Processing, Financial",
					"26 Office Machine Operator",
					"27 Computer and Communications Equipment Operator",
					"28 Mail Distribution",
					"29 Scheduling and Distributing Clerks",
					"30 Adjusters and Investigators",
					"31 Misc Admin Support",
					"32 Private Household Occupations",
					"33 Firefighting",
					"34 Police",
					"35 Guards",
					"36 Food Prep and Service",
					"37 Health Service",
					"38 Cleaning and Building	Service",
					"39 Personal Service",
					"40 Farm Managers",
					"41 Farm Non-Managers",
					"42 Related Agriculture",
					"43 Forest, Logging, Fishers and Hunter",
					"44 Vehicle Mechanic",
					"45 Electronic Repairer",
					"46 Misc. Repairer",
					"47 Construction Trade",
					"48 Extractive",
					"49 Precision Production, Supervisor",
					"50 Precision Metal",
					"51 Precision	Wood",
					"52 Precision, Textile",
					"53 Precision, Other",
					"54 Precision, Food",
					"55 Plant and System Operator",
					"56 Metal and Plastic Machine Operator",
					"57 Metal and Plastic Processing Operator",
					"58 Woodworking Machine Operator",
					"59 Textile Machine Operator",
					"60 Printing Machine Operator",
					"61 Machine Operator, Other",
					"62 Fabricators",
					"63 Production Inspectors",
					"64 Motor Vehicle Operator",
					"65 Non Motor Vehicle Operator",
					"66 Freight, Stock, Material Handler"]
					
	index = list(tab.index);
	newind = []
	for name in index:
		ii = int(name[0:2])
		newind.append(occ_codes[ii-1])
		
	tab['newind'] = newind
	tab.set_index('newind',inplace=True)
	tab.index.name = "Occupation"

	tab.loc[tab["beta"]=="nan (nan)","beta"] = "-"
	tab.loc[tab["theta"]=="nan (nan)","theta"] = "-"
	
	# reorder according to betas
	tab.sort_values(by=['beta'],ascending=False,inplace=True)
	
	sh = timevar + '_' + occs
	fname = outdir + 'fdregressions_' + timevar + '_' + occs + '.xlsx'
	# tab.to_excel(fname,sheet_name=sh)
	
	if occs == 'occ19':
		if timevar == 'spec1':
			sh = '20ish year changes'
		elif timevar == 'spec2':
			sh = 'long-run changes'
	elif occs == 'occ66':
		if timevar == 'spec1':
			sh = '20ish year changes'
		elif timevar == 'spec2':
			sh = '30ish year changes'
		elif timevar == 'spec3':
			sh = 'long-run changes'
			
	sh = occs + ', ' + sh
	tab.to_excel(writer,sheet_name=sh)

for occs in ['occ19','occ66']:
	if occs == "occ19":
		specs = ['spec1','spec2']
	elif occs == "occ66":
		specs = ['spec1','spec2','spec3']
		
	for timevar in specs:
		clean(timevar,occs)
		
writer.save()
