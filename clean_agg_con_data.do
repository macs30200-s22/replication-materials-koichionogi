*--------------------------------------------------
* Research on wage and concentraion
* First Version: Koichi Onogi
* Last Version: Koichi Onogi
* clean_agg_con_data.do
* Date of last revision: 5/15/2022
*--------------------------------------------------

*--------------------------------------------------
* Program Setup
*--------------------------------------------------
// Set directories
global data ""
global output ""

capture log close
log using "$output/hrs_nol_hdd_1NF.log", replace
set more off
clear all               				// Start with a clean state
*--------------------------------------------------

*--------------------------------------------------

//first save raw data and drop unnecessary samples
save "/Users/koichionogi/Desktop/wage_ind_occ_Raw.dta"
use "/Users/koichionogi/Desktop/wage_ind_occ_Raw.dta"
 
drop if oincwage==99999999 & incwage==99999999
drop if oincwage==0 & incwage==0
drop if oincwage==. & incwage==.
replace oincwage = 0 if oincwage==.
//sum up earnings from wage and salaries
gen earning = oincwage + incwage
gen wt = round(asecwt)

gen sector_main == "."
replace sector_main = "Agriculture" if ind1990 >= 10 & ind1990 <= 32
replace sector_main = "Construction" if ind1990 == 60 | ind1990 == 722
replace sector_main = "Mining" if ind1990 >= 40 & ind1990 <= 50
replace sector_main = "Manufacturing" if ind1990 >= 100 & ind1990 <= 392
replace sector_main = "Utilities" if ind1990 >= 400 & ind1990 <= 472
replace sector_main = "Trade" if ind1990 >= 500 & ind1990 <= 691
replace sector_main = "Finance" if ind1990 >= 700 & ind1990 <= 721
replace sector_main = "Services" if ind1990 == 731 | ind1990 == 893
replace sector_main = "Agriculture" if ind1990 == 230
replace sector_main = "Government" if ind1990 == 900 | ind1990 == 931
replace sector_main = "Armed Force" if ind1990 == 932 | ind1990 == 960

egen subgroup = group(sector_main year)


//calculate gini coefficients
ineqdeco earning [fw=wgt], by(subgroup)
ginidesc earning [fw=wgt], by(year)

//calculate variace of natural log
generate log_earning = log(earning)
bysort year: sum log_earning
bysort subgroup: sum log_earning
bysort subgroup2: sum log_earning

save "/Users/koichionogi/Desktop/wage_ind_occ_Raw.dta", replace


//run regression b/w wage gini and sales concentraion
use "/Users/koichionogi/Downloads/agg_concent_R1 (1).dta"
drop if year < 1931
twoway (line tsh_assets_ipol_0_1pct year) (line tsh_assets_ipol_1pct year) (line tsh_assets_ipol_10pct year) (line tsh_assets_ipol_50pct year), graphregion(color(white)) bgcolor(white) ytitle("Share in market assets") xtitle("Year") title("Historical Assets Share of Top Firms")

drop if year < 1959
twoway (line tsh_receipts_ipol_0_1pct year) (line tsh_receipts_ipol_1pct year) (line tsh_receipts_ipol_10pct year) (line tsh_receipts_ipol_50pct year), graphregion(color(white)) bgcolor(white) ytitle("Share in market sales") xtitle("Year") title("Historical Sales Share of Top Firms")

drop if year < 1962
//manually add gini numbers from the wage_ind_occ_Raw
ren var14 gini_wage
twoway (line gini_wage year)

 table () ( command ) (), command(regress wage_gini tsh_receipts_ipol_0_1pct) command(regress wage_gini tsh_receipts_ipol_1pct) command(regress wage_gini tsh_receipts_ipol_10pct) command(regress wage_gini tsh_receipts_ipol_50pct)
collect label levels command 1 "top 0.1%" 2 "top 1%" 3 "top 10%" 4 "top 50%", modify
collect stars _r_b _r_se 0.01 `"***"' 0.05 `"**"' 0.1 `"*"', attach(_r_b _r_se)
collect stars _r_b _r_se .01 `"***"' .05 `"**"' .1 `"*"', shownote

egen subgroup = group(state district)

estpost tabstat earning [fw=wgt], listwise statistics(count mean sd min max)
esttab ., cells("count mean variance sd min max") noobs
esttab . using "/Users/koichionogi/Desktop/ClassMaterials/MACS/table7.tex", replace label title(Summary table of wage(earning)) cells("count mean variance sd min max") noobs


bysort sector_main: regress gini tsh_assets_ipol_0_1pct
estpost summarize earning [fw=wgt]


eststo: quietly regress  gini tsh_assets_ipol_0_1pct if sector_main == "Agriculture"
eststo: quietly regress  gini tsh_assets_ipol_0_1pct if sector_main == "Mining"
eststo: quietly regress  gini tsh_assets_ipol_0_1pct if sector_main == "Construction"
eststo: quietly regress  gini tsh_assets_ipol_0_1pct if sector_main == "Manufacturing"
eststo: quietly regress  gini tsh_assets_ipol_0_1pct if sector_main == "Utilities"
eststo: quietly regress  gini tsh_assets_ipol_0_1pct if sector_main == "Trade"
eststo: quietly regress  gini tsh_assets_ipol_0_1pct if sector_main == "Finance"
eststo: quietly regress  gini tsh_assets_ipol_0_1pct if sector_main == "Services"

esttab using "/Users/koichionogi/Desktop/ClassMaterials/MACS/table2.tex", replace label title(Top 0.1% asset concentration and wage inequality by industry ) nonumbers mtitles("A
> guriculture" "Mining" "Construction" "Manufacturing" "Utilities" "Trade" "Finance" "Services")

eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Agriculture"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Mining"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Construction"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Manufacturing"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Utilities"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Trade"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Finance"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Services"

esttab using "/Users/koichionogi/Desktop/ClassMaterials/MACS/table2.tex", replace label title(Top 0.1% sales concentration and wage inequality by industry ) nonumbers mtitles("Aguriculture" "Mining" "Construction" "Manufacturing" "Utilities" "Trade" "Finance" "Services")

eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Agriculture"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Mining"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Construction"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Manufacturing"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Utilities"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Trade"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Finance"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Services"

esttab using "/Users/koichionogi/Desktop/ClassMaterials/MACS/table2.tex", replace label title(Top 1% sales concentration and wage inequality by industry) nonumbers mtitles("Aguriculture" "Mining" "Construction" "Manufacturing" "Utilities" "Trade" "Finance" "Services")


eststo clear
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct
eststo: quietly regress  gini tsh_receipts_ipol_1pct
eststo: quietly regress  gini tsh_receipts_ipol_10pct
eststo: quietly regress  gini tsh_receipts_ipol_50pct

eststo clear
eststo: quietly regress  gini tsh_assets_ipol_0_1pct
eststo: quietly regress  gini tsh_assets_ipol_1pct
eststo: quietly regress  gini tsh_assets_ipol_10pct
eststo: quietly regress  gini tsh_assets_ipol_50pct

eststo: quietly regress  gin_U tsh_receipts_ipol_0_1pct if sector_main == "Utilities"
eststo: quietly regress  gin_H tsh_receipts_ipol_0_1pct if sector_main == "Utilities"
eststo: quietly regress  gin_U tsh_receipts_ipol_0_1pct if sector_main == "Trade"
eststo: quietly regress  gin_H tsh_receipts_ipol_0_1pct if sector_main == "Trade"
eststo: quietly regress  gin_U tsh_receipts_ipol_0_1pct if sector_main == "Finance"
eststo: quietly regress  gin_H tsh_receipts_ipol_0_1pct if sector_main == "Finance"
eststo: quietly regress  gin_U tsh_receipts_ipol_0_1pct if sector_main == "Services"
eststo: quietly regress  gin_H tsh_receipts_ipol_0_1pct if sector_main == "Services"
