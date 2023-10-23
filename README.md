# LIBOR_LIBRE_BORR_SimulationCode
Contains matlab code to numerically simulate LIBOR, LIBRE, and BORR RF pulses. 
Contains matlab code to read 3D radial phyllotaxis raw data from Siemens scanner, and compute k-space trajectory coordinates.
Includes links to anonymized volunteer data from free-breathing 3D radial whole-heart MRI scans (DICOMS and RAW DATA).

Publication (Pre-print):

We would appreciate any feedback and welcome any inquiries!
***************
Code for numerical simulations of different off-resonant water excitation RF pulses
- Main_LIBOR_paper.m: Script to simulate the RF pulses and generate manuscript figures (including RF waveforms)
- Folder "dependencies" contains auxiliary *.m files 
***************
Code for reading out raw data and ocmputing k-space trajectory:
- rawdata_load_read_compute_traj/main.m
- Folder "rawdata_load_read_compute_traj/dependencies" contains auxiliary *.m files 
***************
Data: https://zenodo.org/records/8338079
- Includes volunteer data (DICOM and Raw Data) for RF pulse calibration (n=3)
- Includes free-breathing 3D radial whole-heart volunteer data (DICOM and Raw Data) used for RF pulse comparison (n=5)
- Remark: Images were reconstructed at the scanner. Therefore  DICOMS were used for the analysis provided in the paper. Raw data is provided for the community to potentially test different image recontruction and motion compenation methods.
**************
Acknowledgement:
The framework of Brian Hargreaves was used as bases for the current simulations (http://mrsrl.stanford.edu/~brian/bloch/)
The 3D radial phyllotaxis trajectory was designed and implemented in matlab by Davide Piccini. Please cite https://onlinelibrary.wiley.com/doi/10.1002/mrm.22898 when using this trajectory.
