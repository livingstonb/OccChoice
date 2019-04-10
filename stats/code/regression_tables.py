import pandas as pd
outdir = '/Users/brianlivingston/Documents/GitHub/OccChoice/stats/output/'

tab = pd.read_csv(outdir+'fdregressions_spec1.csv',index_col=0)
print(tab.head())
