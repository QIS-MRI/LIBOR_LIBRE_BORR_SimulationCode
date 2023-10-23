# LIBOR_LIBRE_BORR_SimulationCode
Contains matlab code to numerically simulate LIBOR, LIBRE, and BORR RF pulses. Includes links to anonymized volunteer data from free-breathing 3D radial whole-heart MRI scans (DICOMS and RAW DATA).

Publication (Pre-print):

We would appreciate any feedback and welcome any inquiries!
********************
Code for numerical simulations of different off-resonant water excitation RF pulses
- Main_LIBOR_paper.m: Script to simulate the RF pulses and generate manuscript figures (including RF waveforms)
- Folder "dependencies" contains auxiliary *.m files 
***************
Data: https://zenodo.org/records/8338079
- Includes volunteer data (DICOM and Raw Data) for RF pulse calibration (n=3)
- Includes free-breathing 3D radial whole-heart volunteer data (DICOM and Raw Data) used for RF pulse comparison (n=5)
- Remark: Images were reconstructed at the scanner. Therefore  DICOMS were used for the analysis provided in the paper. Raw data is provided for the community to potentially test different image recontruction and motion compenation methods.
**************
Acknowledgement:
The framework of Brian Hargreaves was used as bases for the current simulations (http://mrsrl.stanford.edu/~brian/bloch/)
