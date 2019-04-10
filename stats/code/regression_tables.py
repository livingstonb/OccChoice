import numpy as np
import pandas as pd

os = 'windows'

if os == 'mac':
	outdir = '/Users/brianlivingston/Documents/GitHub/OccChoice/stats/output/'
elif os == 'linux':
	outdir = '/media/hdd/GitHub/OccChoice/stats/output/'
elif os == 'windows':
	outdir = 'D:/GitHub/OccChoice/stats/output/'

tab = pd.read_csv(outdir+'fdregressions_spec1.csv',index_col=0)
tab = tab.applymap(lambda x: np.round(x,3))
cols = tab.columns
newcols = ["beta","se_beta","p_beta","theta","se_theta","p_theta"]
tab.rename(columns={cols[0]:"beta",
	cols[1]:"se_beta",
	cols[2]:"p_beta",
	cols[3]:"theta",
	cols[4]:"se_theta",
	cols[5]:"p_theta"},inplace=True)
	
sigbeta95 = (tab["p_beta"] < 0.05) & (tab["p_beta"] >= 0.01)
sigbeta99 = tab["p_beta"] < 0.01

sigtheta95 = (tab["p_theta"] < 0.05) & (tab["p_theta"] >= 0.01)
sigtheta99 = tab["p_theta"] < 0.01
	
tab = tab.astype(str)
tab.loc[sigbeta95==True,"beta"] = tab.loc[sigbeta95==True,"beta"] + "*"
tab.loc[sigbeta99==True,"beta"] = tab.loc[sigbeta99==True,"beta"] + "**"
tab.loc[sigtheta95==True,"theta"] = tab.loc[sigtheta95==True,"theta"] + "*"
tab.loc[sigtheta99==True,"theta"] = tab.loc[sigtheta99==True,"theta"] + "**"

tab["beta"] = tab["beta"] + ' (' + tab["se_beta"] + ')'
tab["theta"] = tab["theta"] + ' (' + tab["se_theta"] + ')'
tab = tab[["beta","theta"]]
print(tab.head())
