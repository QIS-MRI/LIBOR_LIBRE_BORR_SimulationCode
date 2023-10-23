%%%%%% Main script for reading out self-navigated whole-heart CMR raw data from Siemens PRISMA 3T MRI scanner
%%%%%% with 3D radial phyllotaxis trajectory computation
%%%%%% Provided alongside raw data from the study:
%%%%%% "Fat free noncontrast whole-heart CMR with fast and power-optimized off-resonant water excitation pulses" by Mackowiak et al. (2023)
%%%%%% 23.10.2023 - Adèle L.C. Mackowiak
%%%%%% contact: jbastiaansen.mri@gmail.com

%% Please cite the following work when using the data from the online repository https://zenodo.org/records/8338079
% "Fat free noncontrast whole-heart CMR with fast and power-optimized off-resonant water excitation pulses"
% A. Mackowiak et al., 2023
% link to publication [TBA]

%% Please cite the following work when using the 3D radial phyllotaxis trajectory 
% "Spiral phyllotaxis: the natural way to construct a 3D radial trajectory"
% D. Piccini et al., 2011 
% link to publication: https://doi.org/10.1002/mrm.22898 

%% Load and read raw data
basedir = '/OnlineRepository/';
VOL = '/HEART_V1/';
datapath = '/rawdata/meas_MID00318_FID128417_SN_LIBRE1100_f480_a16_T2pon_tra18x547.dat';

% Read raw data in format [Np x Nlines x 1 x 1 x Ncoil]
[twix_obj, rawData] = fReadSiemensRawData(fullfile(basedir, VOL,datapath));

%% Extract data parameters
param.Np     = double(twix_obj.image.NCol);                                         % Number of readout points per spoke
param.Nshot  = double(twix_obj.image.NSeg);                                         % Number of spirals acquired
param.Nseg   = double(twix_obj.image.NLin/param.Nshot);                             % Number of segments per spiral
param.Nlines = double(twix_obj.image.NLin);                                         % Number of acquired lines
param.Nx     = param.Np/2;                                                                                      
param.Ny     = param.Np/2;
param.Nz     = param.Np/2;

%% Compute trajectory coordinates
flagSelfNav     = true;
flagPlot        = true;
[kx, ky, kz]    = computePhyllotaxis(param.Np, param.Nseg, param.Nshot, flagSelfNav, flagPlot);
