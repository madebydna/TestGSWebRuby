#!/usr/bin/env python

import pandas as pd

# reading in a tab separated text file with the list of schools needed to update
tx_preschools_df = pd.read_csv("TX_preschools.txt",
					sep='\t')

# using .values (which produces each line as a list) to create the sql statements and write them to the sql file	
with open("DXT-3601_Deactivate_TX_Preschools.sql", 'w') as sql_file:
	for line in tx_preschools_df.values:
		sql_file.write("update _tx.school set active = 0 where id = {} and name = \'{}\' and level_code = \'{}\' and type = \'{}\' and active = {};\n".format(line[0],line[1].replace("'", "\\'"),line[3],line[4],line[5]))