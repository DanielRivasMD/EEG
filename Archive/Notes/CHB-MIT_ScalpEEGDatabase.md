
## [CHB-MIT Scalp EEG Database](https://physionet.org/content/chbmit/1.0.0/)

Published: June 9, 2010. Version: 1.0.0

### Abstract

This database, collected at the Children’s Hospital Boston, consists of EEG recordings from pediatric subjects with intractable seizures. Subjects were monitored for up to several days following withdrawal of anti-seizure medication in order to characterize their seizures and assess their candidacy for surgical intervention.

### Data Description

Recordings, grouped into 23 cases, were collected from 22 subjects (5 males, ages 3–22; and 17 females, ages 1.5–19). (Case chb21 was obtained 1.5 years after case chb01, from the same female subject.) The file SUBJECT-INFO contains the gender and age of each subject. (Case chb24 was added to this collection in December 2010, and is not currently included in SUBJECT-INFO.)

Each case (chb01, chb02, etc.) contains between 9 and 42 continuous .edf files from a single subject. Hardware limitations resulted in gaps between consecutively-numbered .edf files, during which the signals were not recorded; in most cases, the gaps are 10 seconds or less, but occasionally there are much longer gaps. In order to protect the privacy of the subjects, all protected health information (PHI) in the original .edf files has been replaced with surrogate information in the files provided here. Dates in the original .edf files have been replaced by surrogate dates, but the time relationships between the individual files belonging to each case have been preserved. In most cases, the .edf files contain exactly one hour of digitized EEG signals, although those belonging to case chb10 are two hours long, and those belonging to cases chb04, chb06, chb07, chb09, and chb23 are four hours long; occasionally, files in which seizures are recorded are shorter.

All signals were sampled at 256 samples per second with 16-bit resolution. Most files contain 23 EEG signals (24 or 26 in a few cases). The International 10-20 system of EEG electrode positions and nomenclature was used for these recordings. In a few records, other signals are also recorded, such as an ECG signal in the last 36 files belonging to case chb04 and a vagal nerve stimulus (VNS) signal in the last 18 files belonging to case chb09. In some cases, up to 5 “dummy” signals (named "-") were interspersed among the EEG signals to obtain an easy-to-read display format; these dummy signals can be ignored.

The file RECORDS contains a list of all 664 .edf files included in this collection, and the file RECORDS-WITH-SEIZURES lists the 129 of those files that contain one or more seizures. In all, these records include 198 seizures (182 in the original set of 23 cases); the beginning ([) and end (]) of each seizure is annotated in the .seizure annotation files that accompany each of the files listed in RECORDS-WITH-SEIZURES. In addition, the files named chbnn-summary.txt contain information about the montage used for each recording, and the elapsed time in seconds from the beginning of each .edf file to the beginning and end of each seizure contained in it.

### Relevant Publications

In addition to the thesis cited at the top of this page, these publications describe a patient-specific seizure onset detection algorithm, and the first of them describes its evaluation using this database:

Ali Shoeb, John Guttag. Application of Machine Learning to Epileptic Seizure Onset Detection. 27th International Conference on Machine Learning (ICML), June 21-24, 2010, Haifa, Israel.

Ali Shoeb, Herman Edwards, Jack Connolly, Blaise Bourgeois, S. Ted Treves, John Guttag. Patient-Specific Seizure Onset Detection. Epilepsy and Behavior. August 2004, 5(4): 483-498. [doi:10.1016/j.yebeh.2004.05.005]

### Acknowledgments

A team of investigators from Children’s Hospital Boston (CHB) and the Massachusetts Institute of Technology (MIT) created and contributed this database to PhysioNet. The clinical investigators from CHB include Jack Connolly, REEGT; Herman Edwards, REEGT; Blaise Bourgeois, MD; and S. Ted Treves, MD. The investigators from MIT include Ali Shoeb, PhD and Professor John Guttag.
