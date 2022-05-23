*--------------------------------------------------
* Research on wage and concentraion
* First Version: Koichi Onogi
* Last Version: Koichi Onogi
* clean_agg_con_data.do
* Date of last revision: 5/22/2022
*--------------------------------------------------

*--------------------------------------------------
* Program Setup
*--------------------------------------------------
// Set directories
global data "/Users/koichionogi/Dropbox/Concentration_wage inequality/Data"
global output "/Users/koichionogi/Dropbox/Concentration_wage inequality/Out"

capture log close
log using "$output/Concentraion_wage_2022.log", replace
set more off
clear all               				
// Start with a clean state
*--------------------------------------------------
//Measurement used here

//calculate gini coefficients
ineqdeco earning [fw=wt], by(subgroup)
ginidesc earning [fw=wt], by(year)

drop if year < 1968

//calculate variace of natural log
generate log_earning = log(earning)
bysort year: sum log_earning
bysort subgroup: sum log_earning
bysort subgroup2: sum log_earning

//Industry names
"Agriculture"  "Mining" "Construction"  "Manufacturing" "Utilities" "Trade" "Finance" "Services"
*--------------------------------------------------
cd "$data"
do cps_00004.do

//first save raw data and drop unnecessary samples
save "$data/IPUS_raw.dta", replace
use "$data/IPUS_raw.dta", clear

gen wt = round(asecwt)
replace wt = 0 if wt < 0

//sum up earnings from wage and salaries
gen earning = incwage
replace earning = 0 if incwage == 99999999 | incwage == 99999998
replace oincwage = 0 if oincwage == 99999999
replace inclongj = 0 if inclongj == 99999999
replace earning = oincwage + inclongj if incwage == 99999999 | incwage == 99999998
drop if earning ==. | earning <=0
summarize earning [fw=wt]

//check gini coefficients
ineqdeco earning [fw=wt], by(year)

save "$output/IPUS_cleaned.dta", replace
use "$output/IPUS_cleaned.dta", clear

//categorize industries
gen sector_main = "."
replace sector_main = "Agriculture" if ind1990 >= 10 & ind1990 <= 32
replace sector_main = "Construction" if ind1990 == 60 | ind1990 == 722
replace sector_main = "Mining" if ind1990 >= 40 & ind1990 <= 50
replace sector_main = "Manufacturing" if ind1990 >= 100 & ind1990 <= 392
replace sector_main = "Utilities" if ind1990 >= 400 & ind1990 <= 472
replace sector_main = "Trade" if ind1990 >= 500 & ind1990 <= 691
replace sector_main = "Finance" if ind1990 >= 700 & ind1990 <= 721
replace sector_main = "Services" if ind1990 >= 731 & ind1990 <= 893
replace sector_main = "Agriculture" if ind1990 == 230
replace sector_main = "Government" if ind1990 >= 900 & ind1990 <= 931
replace sector_main = "Armed Force" if ind1990 >= 932 & ind1990 <= 960

//categorize occupation-level
gen occ_level =.
replace occ_level = 1 if occ1950 <= 300
replace occ_level = 0 if occ1950 > 300 & occ1950<=970
*--------------------------------------------------
//Market Level analysis
*--------------------------------------------------

estpost summarize earning [fw=wt], detail
esttab using "$output/summary_table.tex", replace label cells("count mean(fmt(1)) sd(fmt(1)) p25(fmt(1)) p50(fmt(1)) p75(fmt(1)) min(fmt(1)) max(fmt(1))") title("Summary Table for Entire Wage Data")

estpost tabstat earning [fw=wgt], listwise statistics(count mean sd min max)
esttab ., cells("count mean variance sd min max") noobs
esttab . using "/Users/koichionogi/Desktop/ClassMaterials/MACS/table7.tex", replace label title(Summary table of wage(earning)) cells("count mean variance sd min max") noobs

estpost summarize earning [fw=wt] if year == 2021, detail
esttab using "$output/summary_table.tex", replace label cells("count mean(fmt(1)) sd(fmt(1)) p25(fmt(1)) p50(fmt(1)) p75(fmt(1)) min(fmt(1)) max(fmt(1))") title("Summary Table for Wage Data in 2021")

estpost tab sector_main [fw=wt] if sector_main!="."
esttab using "$output/sum_ind_table.tex", replace label cells("b(fmt(2)) pct(fmt(2))")title("Summary Table for Occupation")

estpost tab occ_level [fw=wt]
esttab using "$output/sum_ind_table.tex", replace label cells("b(fmt(2)) pct(fmt(2))")title("Summary Table for Occupation")

collapse (count) pop = earning (mean) avg_earning=earning (median) med_earning=earning [fweight=wt], by(sector_main year)
drop if sector_main =="."

twoway (line avg_earning year if sector_main == "Agriculture") (line avg_earning year if sector_main == "Construction" ) (line avg_earning year if sector_main == "Finance") (line avg_earning year if sector_main == "Manufacturing" )(line avg_earning year if sector_main == "Mining" )(line avg_earning year if sector_main == "Services" )(line avg_earning year if sector_main == "Trade" )(line avg_earning year if sector_main == "Utilities" ), legend(order(1 "Agriculture" 2 "Construction" 3 "Finance" 4 "Manufacturing" 5 "Mining" 6 "Services" 7 "Trade" 8 "Utilities" )) graphregion(color(white)) bgcolor(white) ytitle("Average Earning") xtitle("Year") title("Average Earning by Industry")

egen tota = total(pop), by(year)
gen sh = pop/tota

twoway (line sh year if sector_main == "Agriculture") (line sh year if sector_main == "Construction" ) (line sh year if sector_main == "Finance") (line sh year if sector_main == "Manufacturing" )(line sh year if sector_main == "Mining")(line sh year if sector_main == "Services" )(line sh year if sector_main == "Trade" )(line sh year if sector_main == "Utilities" ), legend(order(1 "Agriculture" 2 "Construction" 3 "Finance" 4 "Manufacturing" 5 "Mining" 6 "Services" 7 "Trade" 8 "Utilities" )) graphregion(color(white)) bgcolor(white) ytitle("Share of Labor") xtitle("Year") title("Share of workers by Industry")

ineqdeco avg_earning, by(year)

use "$output/IPUS_cleaned.dta", clear

collapse (count) pop = earning (mean) avg_earning=earning (median) med_earning=earning [fweight=wt], by(occ_level year)

twoway (line avg_earning year if occ_level==0) (line avg_earning year if occ_level==1 ), legend(order(1 "Low-skill" 2 "High-skill")) graphregion(color(white)) bgcolor(white) ytitle("Average Earning") xtitle("Year") title("Average Earning by Occupation Type")
graph export "/Users/koichionogi/Dropbox/Concentration_wage inequality/Out/AverageEarning_occ.jpg", as(jpg) name("Graph") quality(90)

egen tota = total(pop), by(year)
gen sh = pop/tota
twoway (line sh year if occ_level==0) (line sh year if occ_level==1 ), legend(order(1 "Low-skill" 2 "High-skill")) graphregion(color(white)) bgcolor(white) ytitle("Share of Labor") xtitle("Year") title("Share of workers by Occupation Type")
graph export "/Users/koichionogi/Dropbox/Concentration_wage inequality/Out/Share_workers.jpg", as(jpg) name("Graph") quality(90)

ineqdeco avg_earning, by(year)

//run regression b/w wage gini and sales concentraion
use "/Users/koichionogi/Downloads/agg_concent_R1 (1).dta"
drop if year < 1931
twoway (line tsh_assets_ipol_0_1pct year) (line tsh_assets_ipol_1pct year) (line tsh_assets_ipol_10pct year) (line tsh_assets_ipol_50pct year), graphregion(color(white)) bgcolor(white) ytitle("Share in market assets") xtitle("Year") title("Historical Assets Share of Top Firms")

drop if year < 1959
twoway (line tsh_receipts_ipol_0_1pct year) (line tsh_receipts_ipol_1pct year) (line tsh_receipts_ipol_10pct year) (line tsh_receipts_ipol_50pct year), graphregion(color(white)) bgcolor(white) ytitle("Share in market sales") xtitle("Year") title("Historical Sales Share of Top Firms")

drop if year < 1962

use "data/agg_concent_R1 (2).dta", clear
drop if year <1962
//manually add gini numbers from X
ren var14 gini_wage
twoway (line gini_wage year)
drop if year <1968
//manually add gini numbers from XX
ren var15 gini_wage_ind
ren var16 gini_wage_occ
*--------------------------------------------------
//Industry Level
*--------------------------------------------------
drop if sector_main == "."
drop if sector_main == "Armed Force "
drop if sector_main == "Armed Force"
drop if sector_main == "Government"

egen subgroup = group(sector_main year)
ineqdeco earning [fw=wt], by(subgroup)



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

esttab using "$output/byInd_table_asset.tex", replace label title(Top 0.1% asset concentration and wage inequality by industry ) nonumbers mtitles("Aguriculture" "Mining" "Construction" "Manufacturing" "Utilities" "Trade" "Finance" "Services")
est clear

eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Agriculture"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Mining"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Construction"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Manufacturing"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Utilities"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Trade"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Finance"
eststo: quietly regress  gini tsh_receipts_ipol_0_1pct if sector_main == "Services"

esttab using "$output/byInd_table_sales.tex", replace label title(Top 0.1% sales concentration and wage inequality by industry ) nonumbers mtitles("Aguriculture" "Mining" "Construction" "Manufacturing" "Utilities" "Trade" "Finance" "Services")

est clear
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Agriculture"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Mining"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Construction"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Manufacturing"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Utilities"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Trade"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Finance"
eststo: quietly regress  gini tsh_receipts_ipol_1pct if sector_main == "Services"


esttab using "$output/byInd_table_sales2.tex", replace label title(Top 1% sales concentration and wage inequality by industry) nonumbers mtitles("Aguriculture" "Mining" "Construction" "Manufacturing" "Utilities" "Trade" "Finance" "Services")


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

*--------------------------------------------------
//Industry✖︎Occupation Level
*--------------------------------------------------
drop if sector_main == "."
drop if sector_main == "Armed Force "
drop if sector_main == "Armed Force"
drop if sector_main == "Government"

egen subgroup = group(sector_main occ_level year)
ineqdeco earning [fw=wt], by(subgroup)
eststo: quietly regress  gin_U tsh_receipts_ipol_0_1pct if sector_main == "Agriculture"
eststo: quietly regress  gin_H tsh_receipts_ipol_0_1pct if sector_main == "Agriculture"
eststo: quietly regress  gin_U tsh_receipts_ipol_0_1pct if sector_main == "Mining"
eststo: quietly regress  gin_H tsh_receipts_ipol_0_1pct if sector_main == "Mining"
eststo: quietly regress  gin_U tsh_receipts_ipol_0_1pct if sector_main == "Construction"
eststo: quietly regress  gin_H tsh_receipts_ipol_0_1pct if sector_main == "Construction"
eststo: quietly regress  gin_U tsh_receipts_ipol_0_1pct if sector_main == "Manufacturing"
eststo: quietly regress  gin_H tsh_receipts_ipol_0_1pct if sector_main == "Manufacturing"

esttab using "$output/byInd_Occ_table.tex", replace label title(Regression Result b/w Top Firms Sales and Gini Coefficients of Wage by industry and occupation-level) nonumbers mtitles("Agr L" "Agr H" "Min L" "Min H" "Con L" "Con H" "Man L" "Man H")

eststo: quietly regress  gin_U tsh_receipts_ipol_0_1pct if sector_main == "Utilities"
eststo: quietly regress  gin_H tsh_receipts_ipol_0_1pct if sector_main == "Utilities"
eststo: quietly regress  gin_U tsh_receipts_ipol_0_1pct if sector_main == "Trade"
eststo: quietly regress  gin_H tsh_receipts_ipol_0_1pct if sector_main == "Trade"
eststo: quietly regress  gin_U tsh_receipts_ipol_0_1pct if sector_main == "Finance"
eststo: quietly regress  gin_H tsh_receipts_ipol_0_1pct if sector_main == "Finance"
eststo: quietly regress  gin_U tsh_receipts_ipol_0_1pct if sector_main == "Services"
eststo: quietly regress  gin_H tsh_receipts_ipol_0_1pct if sector_main == "Services"

esttab using "$output/byInd_Occ_table2.tex", replace label title(Regression Result b/w Top Firms Sales and Gini Coefficients of Wage by industry and occupation-level) nonumbers mtitles( "Uti L" "Uti H" "Trd L" "Trd H" "Fin L" "Fin H" "Ser L" "Ser H")
