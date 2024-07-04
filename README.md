****************************************************************
*Project: Teacher's Bias in Assessments
*Code: Replication of data cleaning and preparation and analyses
*Authors: Carlos J. Gil-Hernández, Irene Pañeda-Fernández, 
          Leire Salazar, and Jonatan Castaño-Muñoz
*Last Update: 04/07/2024
*Software: STATA/MP 17
****************************************************************

* Here you can find the replication dofile in STATA format in the "code" folder and the raw and working datasets (including the codebook)
  of the teacher's bias in assessment experiment in the "data" folder:

 1. "/replication files/code/datacleaning.do" contains all the data cleaning and preparation procedures from the raw anonymized Qualtrics data 
     where we applied the survey experiment (see "data" folder .dta or .csv files named "raw_dataset_anonymized") to set a 
     working dataset ready to be analyzed.

 2. The folder "/replication files/data" contains the data files named "raw_dataset_anonymized" and "cleandataset" in .dta (data/STATA) or .csv (data/CSV) 
    format on the raw and working data, respectively, to replicate the findings of the teacher's bias in assessments project or 
    run your own analyses. If you do not have access to STATA software, you can check the variables labels 
    of the "cleandataset" in the "data/codebook_cleandataset" Excel file.

    Data Citation: 
        Gil-Hernández, Carlos J., Leire Salazar, Jonatan Castaño Muñoz, and Irene Pañeda-Fernandez. 2023. 
        “Teacher’s Bias Dataset: A Factorial Survey Experiment.” European Commission, Joint Research Centre (JRC) 
        [Dataset] PID: http://data.europa.eu/89h/f14f5209-f032-4218-a89a-4643143809af

 4. "datanalysis.do" reproduces all the tables and figures presented in the article and online appendix (if you want to 
     reproduce the analyses from the pre-test pilot data, please get in contact with the corresponding author) using the data file named "cleandataset"
     in the "data" folder (in .dta or .csv format). The output from "datanalysis.do" will be printed in the "/replication files/output" subfolders
     for tables (main or appendix) or figures (main or appendix).
