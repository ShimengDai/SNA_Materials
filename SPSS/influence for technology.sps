GET DATA
  /TYPE=TXT
  /FILE="C:\Users\kenfrank\Documents\MyFiles\COURSES\SEMINAR\SEMINAR\workshop 2012\talkt2.csv"
  /DELCASE=LINE
  /DELIMITERS=","
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  nominator F3.0
  nominee F3.0
  relate F1.0.
CACHE.
EXECUTE.
DATASET NAME w WINDOW=FRONT.

SORT CASES BY nominee(A).

DATASET DECLARE indeg.
SORT CASES BY nominee.
AGGREGATE
  /OUTFILE='indeg'
  /PRESORTED
  /BREAK=nominee
  /indeg=SUM(relate).


GET DATA
  /TYPE=TXT
  /FILE="C:\Users\kenfrank\Documents\MyFiles\COURSES\SEMINAR\SEMINAR\workshop 2012\indiv.csv"
  /DELCASE=LINE
  /DELIMITERS=","
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=3
  /IMPORTCASE=ALL
  /VARIABLES=
  gradelev A2
  Q37A1 F1.0
  Q37A2 F1.0
  Q37A3 F1.0
  Q37A4 F1.0
  Q37A5 F1.0
  Q39 F1.0
  Q401 F1.0
  Q402 F1.0
  Q403 F1.0
  Q404 F1.0
  Q405 F1.0
  Q406 F1.0
  Q41 F2.0
  Q42 F4.1
  Q43 F1.0
  Q48 F1.0
  Q38A1 F1.0
  Q38A2 F1.0
  Q38A3 F1.0
  Q38A4 F1.0
  Q38A5 F1.0
  Q38A6 F1.0
  Q38A7 F1.0
  Q38A8 F1.0
  Q38A9 F1.0
  Q38A10 F1.0
  Use1 F12.10
  Attitude1 F12.10
  Tvalue1 F12.10
  Svalue1 F12.10
  LearningTech1 F12.10
  Ease1 F12.10
  Hardware1 F4.2
  Software1 F12.10
  Use2 F12.10
  Tvalue2 F12.10
  Svalue2 F12.10
  LearningTech2 F12.10
  Ease2 F4.2
  Hardware2 F4.2
  Software2 F12.10
  View2 F12.10
  Help_Mean F12.10
  Help_Sum F12.10
  nominator F3.0
  cq43 A11
  grade F1.0
  i F2.0
  tg F1.0
  higrade F1.0
  nominee F3.0.
CACHE.
EXECUTE.
DATASET NAME yvar1 WINDOW=FRONT.
EXECUTE.

MATCH FILES /FILE * /DROP use2  Tvalue2 Svalue2 LearningTech2 Ease2 Hardware2 Software2 View2.
execute.
SORT CASES BY nominee(A).
EXECUTE.

DATA LIST / intid 1-10 nominee 11-20 cluster 21-30 simx 31-40 extra 41-50.
BEGIN DATA
       1.0       1.0       1.0       1.0       3.0
       2.0       2.0       1.0       1.0       3.0
       3.0       3.0       1.0       1.0       3.0
       4.0       4.0       2.0       1.0       3.0
       5.0       5.0       2.0       1.0       3.0
       6.0       6.0       2.0       1.0       3.0
END DATA.
DATASET NAME clusters WINDOW=FRONT.
SORT CASES BY nominee(A).
EXECUTE.


MATCH FILES /FILE=yvar1
  /FILE='indeg'
  /FILE=clusters
  /BY  nominee.
EXECUTE.

DATASET NAME yvar1x WINDOW=FRONT.


MATCH FILES /FILE=w
  /TABLE=yvar1x
  /BY  nominee.
EXECUTE.
RECODE indeg (MISSING=0).
EXECUTE.

COMPUTE exposure=relate * use1.
* comment *(indeg+1).
EXECUTE.

DATASET DECLARE influence1.
SORT CASES BY nominator.
AGGREGATE
  /OUTFILE=*
  /PRESORTED
  /BREAK=nominator
  /exposure_mean_1=MEAN(exposure)
  /outdeg=N.


COMPUTE nominee=nominator.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='yvar1x'
  /BY  nominee.
EXECUTE.
DATASET NAME totinfl WINDOW=FRONT.


GET DATA
  /TYPE=TXT
  /FILE="C:\Users\kenfrank\Documents\MyFiles\COURSES\SEMINAR\SEMINAR\workshop 2012\indiv.csv"
  /DELCASE=LINE
  /DELIMITERS=","
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=3
  /IMPORTCASE=ALL
  /VARIABLES=
  gradelev A2
  Q37A1 F1.0
  Q37A2 F1.0
  Q37A3 F1.0
  Q37A4 F1.0
  Q37A5 F1.0
  Q39 F1.0
  Q401 F1.0
  Q402 F1.0
  Q403 F1.0
  Q404 F1.0
  Q405 F1.0
  Q406 F1.0
  Q41 F2.0
  Q42 F4.1
  Q43 F1.0
  Q48 F1.0
  Q38A1 F1.0
  Q38A2 F1.0
  Q38A3 F1.0
  Q38A4 F1.0
  Q38A5 F1.0
  Q38A6 F1.0
  Q38A7 F1.0
  Q38A8 F1.0
  Q38A9 F1.0
  Q38A10 F1.0
  Use1 F12.10
  Attitude1 F12.10
  Tvalue1 F12.10
  Svalue1 F12.10
  LearningTech1 F12.10
  Ease1 F12.10
  Hardware1 F4.2
  Software1 F12.10
  Use2 F12.10
  Tvalue2 F12.10
  Svalue2 F12.10
  LearningTech2 F12.10
  Ease2 F4.2
  Hardware2 F4.2
  Software2 F12.10
  View2 F12.10
  Help_Mean F12.10
  Help_Sum F12.10
  nominator F3.0
  cq43 A11
  grade F1.0
  i F2.0
  tg F1.0
  higrade F1.0
  nominee F3.0.
CACHE.
EXECUTE.
DATASET NAME yvar2 WINDOW=FRONT.
EXECUTE.

MATCH FILES /FILE * /KEEP NOMINEE use2  Tvalue2 Svalue2 LearningTech2 Ease2 Hardware2 Software2 View2.
execute.
SORT CASES BY nominee(A).
EXECUTE.

MATCH FILES /FILE='totinfl'
  /TABLE='yvar2'
  /BY  nominee.
EXECUTE.
DATASET NAME ready WINDOW=FRONT.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT use2
  /METHOD=ENTER use1 exposure_mean_1
  /SAVE PRED RESID.


DATASET ACTIVATE ready.
UNIANOVA yvar2 BY cluster WITH yvar1 exposure_mean_1
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /CRITERIA=ALPHA(0.05)
  /DESIGN=yvar1 exposure_mean_1 cluster.
















