set more off 
clear
cd "C:\Users\garrisal\Documents\MIST\Networks\Network Data\STATA Influence"

* text files of the data-saved in stata
infile nominator nominee relate using "C:\Users\garrisal\Documents\MIST\Networks\Network Data\STATA Influence\w.txt"

save w, replace
clear

infile nominee yvar1 using "C:\Users\garrisal\Documents\MIST\Networks\Network Data\STATA Influence\yvar1.txt"
gen nominator=nominee
save yvar1, replace
clear

infile nominee yvar2 using "C:\Users\garrisal\Documents\MIST\Networks\Network Data\STATA Influence\yvar2.txt"
gen nominator=nominee
save yvar2, replace

clear

use w
drop if nominator==nominee
gen pair=10000*nominator+nominee
*this is done to make a single ID number for each pair,  so the pair (1,2) has ID 100002

duplicates report pair
duplicates list pair
duplicates drop pair, force
*collapse (first) nominator nominee relate, by(pair)

save w, replace

*collapse (sum)relate, by nomineee

bysort nominee: egen indegree=sum(relate)

merge m:1 nominee using yvar1
drop if _merge==2  /*get rid of the people who aren't part of ties but in yvar file*/
* potentially impute for people who we don't have a yvar1
/* replace yvar1== group average perhaps
make a flag variable for people who are imputed */
*drop if _merge==1  /*we have people who */
drop _merge

*create a new variable that is exposure
gen exposure=relate*yvar1
gen exposure_plus=exposure*(indegree+1)

collapse (mean) exposure exposure_plus (sum) relate, by(nominator)
*collapse (sum) exposure exposure_plus (sum) relate, by(nominator)
*collapse (max) exposure exposure_plus (sum) relate, by(nominator)
rename exposure exposure_mean
rename exposure_plus exp_plus_mean

* after your means command, someone doesn't have any "resources"
* if you are using means, then you want to include a school mean in the model
merge 1:m nominator using yvar1
tab _merge

drop _merge


*rename _merge yvar1_merge

merge 1:m nominator using yvar2
* create a dummy variable to account for people with ties but no exposure
gen exp_miss=0
replace exp_miss=1 if exposure_mean==. & relate!=0 & relate!=.



* create a dummy variable for people with no ties
gen no_ties=0
replace no_ties=1 if relate==.
replace relate=0 if no_ties==1


replace exposure_mean=0 if exp_miss==1 | no_ties==1
replace exp_plus_mean=0 if exp_miss==1 | no_ties==1


rename _merge yvar2_merge
* look for interactions between yvar1 and exposure_mean
* maybe we want to include the relate variable 
reg yvar2 yvar1 exposure_mean exp_miss no_ties
*no_ties is a dummy variable that flags those actors who do not make any nominations
*exp_miss is a dummy variable that flags those actors who make nominations, but there is missing data on the actors they nominate
