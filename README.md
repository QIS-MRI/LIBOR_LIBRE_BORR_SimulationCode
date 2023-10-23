# LIBOR_LIBRE_BORR_SimulationCode
Contains matlab code to numerically simulate LIBOR, LIBRE, and BORR RF pulses. Includes links to anonymized volunteer data from free-breathing 3D radial whole-heart MRI scans (DICOMS and RAW DATA).

Publication (Pre-print):

********************
Code for numerical simulations of different off-resonant water excitation RF pulses
- Main_LIBOR_paper.m: Script to simulate the RF pulses and generate manuscript figures (including RF waveforms)
- All other *.m files are auxiliary functions
***************
Data: https://zenodo.org/records/8338079
- Includes volunteer data (DICOM and Raw Data) for RF pulse calibration (n=3)
- Includes free-breathing 3D radial whole-heart volunteer data (DICOM and Raw Data) used for RF pulse comparison (n=5)
- Remark: Images were reconstructed at the scanner. Therefore  DICOMS were used for the analysis provided in the paper. 
**************
Acknowledgement:
The framework of Brian Hargreaves was used as bases for the current simulations (http://mrsrl.stanford.edu/~brian/bloch/)
