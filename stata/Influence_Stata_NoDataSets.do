clear
set more off

*Moves network data from a matrix to a dataset
matrix w = (2,1,1\ 1,2,1\ 3,2,1\ 1,3,1\ 2,3,1\ 6,3,1\ 3,4,1\ 5,4,1\ 6,4,1\ 4,5,1\ 3,6,1\ 4,6,1)
matrix colnames w = nominator nominee relate
svmat double w, names(col)

*Generates the indegree variable
bysort nominee: egen indegree = sum(relate)

*yvar1 data
matrix y1 = (1,2.4\ 2,2.6\ 3,1.1\ 4,-.50\ 5,-3.0\ 6,-1.0)
matrix colnames y1 = nominee yvar1

gen yvar1_nominee = .
gen yvar1 = .

local rows_y1 = rowsof(y1)
*Merge the yvar1 data from the matrix with the network data
forvalues  a = 1/`rows_y1' {
	replace yvar1_nominee = y1[`a',2] if y1[`a',1] == nominee
	replace yvar1 = y1[`a',2] if y1[`a',1] == nominator
}

*Generates the exposure variables
gen exposure = relate * yvar1_nominee
gen exposure_plus = exposure * (indegree + 1)

*Generates mean exposure variable
bysort nominator: egen exp_mean = mean(exposure)
*bysort nominator: egen exp_plus_mean = mean(exposure_plus)

*bysort nominator: egen exp_sum = sum(exposure)
*bysort nominator: egen exp_plus_sum = sum(exposure_plus)

*yvar2 data
matrix y2 = (1,2\ 2,2\ 3,1\ 4,-.5\ 5,-2\ 6,-.5)
matrix colnames y2 = nominator yvar2

gen yvar2 = .

local rows_y2 = rowsof(y2)
*Merge yvar2 data from the matrix with the network data
forvalues  a = 1/`rows_y2' {
	replace yvar2 = y2[`a',2] if y2[`a',1] == nominator
}

*Drop some unnecessary variables and any duplicates
drop nominee relate indegree yvar1_nominee exposure exposure_plus
duplicates drop

*Regression
reg yvar2 yvar1 exp_mean, beta
