* Encoding: UTF-8.
/* reading in network data. relate indicates the w or network data.
DATA LIST /nominator 1-3 nominee 5-7 w 9-11.
BEGIN DATA
2.0 1.0 1.0
1.0 2.0 1.0
3.0 2.0 1.0
1.0 3.0 1.0
2.0 3.0 1.0
6.0 3.0 1.0
3.0 4.0 1.0
5.0 4.0 1.0
6.0 4.0 1.0
4.0 5.0 1.0
3.0 6.0 1.0
4.0 6.0 1.0
END DATA.
DATASET NAME network WINDOW=FRONT.

SORT CASES BY nominee(A).

/* making in-degree -- number of times nominated.
DATASET DECLARE indeg.
SORT CASES BY nominee.
AGGREGATE
  /OUTFILE='indeg'
  /PRESORTED
  /BREAK=nominee
  /indeg=SUM(w).

/* reading in yvar1 the measure of the outcome but at time 1.
DATA LIST / nominee 1-3 yvar1 5-8.
BEGIN DATA
1.0 2.4
2.0 2.6
3.0 1.1
4.0 -0.5
5.0 -3.0
6.0 -1.0
END DATA.
DATASET NAME yvar1 WINDOW=FRONT.
SORT CASES BY nominee(A).
EXECUTE.

/* reading in cluster assignments as from KliqueFinder output  -- optional.
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

/* combining all individual level data.

MATCH FILES /FILE=yvar1
  /FILE='indeg'
  /FILE=clusters
  /BY  nominee.
EXECUTE.

DATASET NAME yvar1x WINDOW=FRONT.

/* matching network data with individual level.

MATCH FILES /FILE=network
  /TABLE=yvar1x
  /BY  nominee.
EXECUTE.
RECODE indeg (MISSING=0).
EXECUTE.
/* calculating exposure term.
COMPUTE exposure=w * yvar1.
* comment *(indeg+1).
EXECUTE.
DATASET NAME exposure WINDOW=FRONT.

DATASET DECLARE influence1.
/* aggregating exposure for a given person.
SORT CASES BY nominator.
AGGREGATE
  /OUTFILE=*
  /PRESORTED
  /BREAK=nominator
  /exposure_mean_1=MEAN(exposure)
  /outdeg=N.

/* sum or mean?.

COMPUTE nominee=nominator.
EXECUTE.
/* matching exposure term back on original data.
MATCH FILES /FILE=*
  /TABLE='yvar1x'
  /BY  nominee.
EXECUTE.
DATASET NAME totinfl WINDOW=FRONT.

/* read in yvar2 -- outcome at time 2.
DATA LIST / nominator 1-3 yvar2 5-8.
BEGIN DATA
1.0 2.0
2.0 2.0
3.0 1.0
4.0 -0.5
5.0 -2.0
6.0 -0.5
END DATA.
DATASET NAME yvar2 WINDOW=FRONT.
COMPUTE nominee=nominator.
SORT CASES BY nominee(A).

/* mathcing yvar2 with other individual data.
MATCH FILES /FILE='totinfl'
  /TABLE='yvar2'
  /BY  nominee.
EXECUTE.
DATASET NAME ready WINDOW=FRONT.

/* running regression, with or without interept?.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT yvar2
  /METHOD=ENTER yvar1 exposure_mean_1
  /SAVE PRED RESID.

/* running general linear model with cluster membership.
DATASET ACTIVATE ready.
UNIANOVA yvar2 BY cluster WITH yvar1 exposure_mean_1
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /CRITERIA=ALPHA(0.05)
  /DESIGN=yvar1 exposure_mean_1 cluster.






