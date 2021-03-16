
### Project EEG ideas

1. General approach:
	- **Background**: there is a variety of studies combining EEG and AI that are succesful, however sample sizes are most often limited [REFERENCES]
	- **Goal**: generic EEG [interpretation | prediction]? AI tool
	- **Methodology**: large sample of most abundant EEG in a variety of diseases
	- **Impact**: general use for the medical community, not only neurologists



2. Specific approach:
	- **Background**: EEG is an essential in the diagnosis and follow up of some diseases, e.g. epilepsy
	- **Goal**: disease specific EEG [interpretation | prediction]? AI tool
	- **Methodology**: small sample defined by specific inclusion and exclusion criteria
	- **Impact**: restricted to a specific condition
	- **Examples**:
		- Classification of epilepsy types?
		- Diagnosis of epileptic epidose during post-ictal period?

TUH
real-time computer assisted monitoring of electroencephalograms can improve the quality and efficiency of a physician's diagnostic capabilities.
the ability to rapidly detect and interpret seizures and other brain abnormalities in critical care settings can improve patient outcomes.
automatic detection would reduce moribility and mortality without increasing the costs of care.
due to manpower and cost constrains hospitals lack 24 / 7 neurologist coverage.
MindReader offers the potential to revolutionize healthcare in critical care settings by allowing clinicians to identify clinical changes rapidly and treat patients more safely and effectively.

modules:
  - signal preprocessor
  - feature extractor
  - event decoder
  - postprocessor
  - visualizer


EEG is vulnerable to interference -> characteristics & sampling method
model is simple in implementation with low computational complexity
present results in real time
