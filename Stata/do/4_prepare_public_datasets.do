clear all

global repo_dir "/home/m.olckers/U/lis-tax-transfer-U"

cd $repo_dir/Stata/output

use "LIS Reducing Inequality Country.dta", clear

* Generate variables

gen tax_kakwani = tax_conc_inc3 - inc3_gini
gen transfer_kakwani = transfer_conc_inc2 - inc2_gini

gen hhaa_tax_kakwani = hhaa_tax_conc_inc3 - hhaa_inc3_gini
gen hhaa_transfer_kakwani = hhaa_transfer_conc_inc2 - hhaa_inc2_gini

* Drop net datasets and other datasets with problems

drop if inc2_gini==.
global net_datasets "at00 be00 gr00 hu05 hu07 hu09 hu12 hu99 ie00 it00 lu00 mx00 mx02 mx04 mx08 mx10 mx12 mx98 si10"
foreach ccyy in $net_datasets {
drop if countryyear=="`ccyy'"
}
drop if ccode=="kr"|countryyear=="jp08" |country=="Poland"|country=="Switzerland"

* Create an indicator for the most recent year
gen most_recent_year=.

bys ccode: egen ymax=max(year)
replace ymax=0 if ymax>year
replace ymax=1 if ymax==year

replace most_recent_year=0
replace most_recent_year=1 if ymax==1
replace most_recent_year=0 if countryyear=="ie10"
replace most_recent_year=1 if countryyear=="ie07"

* Drop certain variables

drop *_SSE*

drop ccode
drop inc4_min_inc4

drop ymax

* Label variables

label variable countryyear "Dataset identifier"
label variable country "Country"
label variable year "Year"

label variable inc1_gini "Primary Income"
label variable inc2_gini "Market Income"
label variable inc3_gini "Gross Income"
label variable inc4_gini "Disposable Income"
label var dhi_gini "Disposable household income (from the LIS variable dhi)"

label variable hhaa_inc1_gini "Primary Income"
label variable hhaa_inc2_gini "Market Income"
label variable hhaa_inc3_gini "Gross Income"
label variable hhaa_inc4_gini "Disposable Income"
label var hhaa_dhi_gini "Disposable household income (from the LIS variable dhi)"

label variable transfer_conc_inc1 "Transfer Concentration Coeffiicient (Primary Income)"
label variable transfer_conc_inc2 "Transfer Concentration Coeffiicient (Market Income)"
label variable transfer_conc_inc3 "Transfer Concentration Coeffiicient (Gross Income)"
label variable transfer_conc_inc4 "Transfer Concentration Coeffiicient (Disposable Income)"

label variable hhaa_transfer_conc_inc1 "Transfer Concentration Coeffiicient (Primary Income)"
label variable hhaa_transfer_conc_inc2 "Transfer Concentration Coeffiicient (Market Income)"
label variable hhaa_transfer_conc_inc3 "Transfer Concentration Coeffiicient (Gross Income)"
label variable hhaa_transfer_conc_inc4 "Transfer Concentration Coeffiicient (Disposable Income)"

label variable tax_conc_inc1 "Tax Concentration Coefficient (Primary Income)"
label variable tax_conc_inc2 "Tax Concentration Coefficient (Market Income)"
label variable tax_conc_inc3 "Tax Concentration Coefficient (Gross Income)"
label variable tax_conc_inc4 "Tax Concentration Coefficient (Disposable Income)"

label variable hhaa_tax_conc_inc1 "Tax Concentration Coefficient (Primary Income)"
label variable hhaa_tax_conc_inc2 "Tax Concentration Coefficient (Market Income)"
label variable hhaa_tax_conc_inc3 "Tax Concentration Coefficient (Gross Income)"
label variable hhaa_tax_conc_inc4 "Tax Concentration Coefficient (Disposable Income)"


label var inc1_mean "Primary Income"
label var inc2_mean "Market income"
label var inc3_mean "Gross Income"
label var inc4_mean "Disposable Income"
label var dhi_mean "Disposable household income (from the LIS variable dhi)"

label var hhaa_inc1_mean "Primary Income"
label var hhaa_inc2_mean "Market income"
label var hhaa_inc3_mean "Gross Income"
label var hhaa_inc4_mean "Disposable Income"
label var hhaa_dhi_mean "Disposable household income (from the LIS variable dhi)"

label var transfer_mean "Social transfers"
label var tax_mean "Taxes and social security contributions"
label var allpension_mean "Public and private pensions"
label var pubpension_mean "Public pensions"
label var pripension_mean "Private pensions"

label var hhaa_transfer_mean "Social transfers"
label var hhaa_tax_mean "Taxes and social security contributions"
label var hhaa_allpension_mean "Public and private pensions"
label var hhaa_pubpension_mean "Public pensions"
label var hhaa_pripension_mean "Private pensions"

label var inc1_conc_inc1 "Primary Income Concentration Coefficient (Primary Income)"
label var inc1_conc_inc2 "Primary Income Concentration Coefficient (Market Income)"
label var inc1_conc_inc3 "Primary Income Concentration Coefficient (Gross Income)"
label var inc1_conc_inc4 "Primary Income Concentration Coefficient (Disposable Income)"
label var inc2_conc_inc1 "Market Income Concentration Coefficient (Primary Income)"
label var inc2_conc_inc2 "Market Income Concentration Coefficient (Market Income)"
label var inc2_conc_inc3 "Market Income Concentration Coefficient (Gross Income)"
label var inc2_conc_inc4 "Market Income Concentration Coefficient (Disposable Income)"
label var inc3_conc_inc1 "Gross Income Concentration Coefficient (Primary Income)"
label var inc3_conc_inc2 "Gross Income Concentration Coefficient (Market Income)"
label var inc3_conc_inc3 "Gross Income Concentration Coefficient (Gross Income)"
label var inc3_conc_inc4 "Gross Income Concentration Coefficient (Disposable Income)"
label var inc4_conc_inc1 "Disposable Income Concentration Coefficient (Primary Income)"
label var inc4_conc_inc2 "Disposable Income Concentration Coefficient (Market Income)"
label var inc4_conc_inc3 "Disposable Income Concentration Coefficient (Gross Income)"
label var inc4_conc_inc4 "Disposable Income Concentration Coefficient (Disposable Income)"

label var allpension_conc_inc1 "Pension Concentation Coefficient (Primary Income)"
label var allpension_conc_inc2 "Pension Concentation Coefficient (Market Income)"
label var allpension_conc_inc3 "Pension Concentation Coefficient (Gross Income)"
label var allpension_conc_inc4 "Pension Concentation Coefficient (Disposable Income)"
label var pubpension_conc_inc1 "Public Pension Concentation Coefficient (Primary Income)"
label var pubpension_conc_inc2 "Public Pension Concentation Coefficient (Market Income)"
label var pubpension_conc_inc3 "Public Pension Concentation Coefficient (Gross Income)"
label var pubpension_conc_inc4 "Public Pension Concentation Coefficient (Disposable Income)"
label var pripension_conc_inc1 "Private Pension Concentation Coefficient (Primary Income)"
label var pripension_conc_inc2 "Private Pension Concentation Coefficient (Market Income)"
label var pripension_conc_inc3 "Private Pension Concentation Coefficient (Gross Income)"
label var pripension_conc_inc4 "Private Pension Concentation Coefficient (Disposable Income)"

label variable hxits_mean "Employee Social Security Contributions (LIS and Imputations)"
label variable hsscee_mean "Employee Social Security Contributions (Imputed)"
label variable hsscer_mean "Employer Social Security Contributions (Imputed)"
label variable hssc_mean "Social Security Contributions (Imputed)"

label variable hxits_conc_inc3 "Social Security Contributions"
label variable hsscee_conc_inc3 "Employee Social Security Contributions"
label variable hsscee_conc_inc3 "Employee Social Security Contributions (Imputed)"
label variable hsscer_conc_inc3 "Employer Social Security Contributions (Imputed)"
label variable hssc_conc_inc3 "Social Security Contributions (Imputed)"

label variable tax_kakwani "Kakwani index of tax progressivity"
label variable transfer_kakwani "Kakwani index of transfer targeting"

label variable hhaa_tax_kakwani "Kakwani index of tax progressivity"
label variable hhaa_transfer_kakwani "Kakwani index of transfer targeting"

label variable most_recent_year "Indicator for the most recent year for each country"

* Save data

save "$repo_dir/docs/public_data/DoTT.dta" , replace
export delimited using "$repo_dir/docs/public_data/DoTT.csv", replace
