//first save raw data and drop unnecessary samples
save "/Users/koichionogi/Desktop/wage_ind_occ_Raw.dta"
use "/Users/koichionogi/Desktop/wage_ind_occ_Raw.dta"
 
drop if oincwage==99999999 & incwage==99999999
drop if oincwage==0 & incwage==0
drop if oincwage==. & incwage==.
replace oincwage = 0 if oincwage==.
//sum up earnings from wage and salaries
gen earning = oincwage + incwage
gen weight = round(asecwt)

//calculate gini coefficients
ineqdeco earning [fw=weight], by(year)
ginidesc earning [fw=weight], by(year)

save "/Users/koichionogi/Desktop/wage_ind_occ_Raw.dta", replace


//run regression b/w wage gini and sales concentraion
use "/Users/koichionogi/Downloads/agg_concent_R1 (1).dta"

drop if year < 1959
twoway (line tsh_receipts_ipol_0_1pct year) (line tsh_receipts_ipol_1pct year) (line tsh_receipts_ipol_10pct year) (line tsh_receipts_ipol_50pct year)

//add gini numbers

 table () ( command ) (), command(regress wage_gini tsh_receipts_ipol_0_1pct) command(regress wage_gini tsh_receipts_ipol_1pct
> ) command(regress wage_gini tsh_receipts_ipol_10pct) command(regress wage_gini tsh_receipts_ipol_50pct)
collect label levels command 1 "top 0.1%" 2 "top 1%" 3 "top 10%" 4 "top 50%", modify
collect stars _r_b _r_se 0.01 `"***"' 0.05 `"**"' 0.1 `"*"', attach(_r_b _r_se)
collect stars _r_b _r_se .01 `"***"' .05 `"**"' .1 `"*"', shownote

