% Bloch simulations. Based on framework developed by Brian Hargreaves
% Bastiaansen, Mackowiak
% RF pulse simulations for LIBRE, LIBOR, BORR pulses

clear all, close all
TISSUE_FREQ = [-800:10:800]; %Range of off-resonance, here -800Hz to 800Hz in steps of 10Hz
xticklabels = [min(TISSUE_FREQ)/1000:0.2:max(TISSUE_FREQ)/1000];
water_index=find(TISSUE_FREQ == 0);
TR_ms=5; fat_rf=-440; 
T1_ms=2000; 
T2_ms=50; 
tau_ms=0.5; WFdephasingWE11=1.1;
f_rf=1560/2; %1-90-1 version divided by 2

% ************* Figure 1 *************
% RF responses of a single 10 deg excitation as function of off-resonance and phase offset of the second subpulse
phase= [0: 5: 360]; flip_angle=10; repetitions=1;
for i=1:length(phase) 
    RFResponseLIBOR(i,:)= GRE_Bloch_Simulation(3, 2, repetitions, [TR_ms 0],  TISSUE_FREQ, flip_angle, [tau_ms 0], f_rf, phase(i), T1_ms, T2_ms, 0);
    % RFResponseWE90 simulates a WE 1-90-1 pulse
    % RFResponseWE90(i,:) = GRE_Bloch_Simulation(3, 2, repetitions, [TR_ms 0],  TISSUE_FREQ, flip_angle, [0.3 (WFdephasingWE11/2)-0.3], 0, phase(i), T1_ms, T2_ms, 0);       
end
Figure_LIBOR(abs(RFResponseLIBOR'), [], max(max(abs([RFResponseLIBOR]))), TISSUE_FREQ, phase, 30, ['RF Response LIBOR'  ])
ylabel('Phase offset 2nd pulse (degrees)'); xlabel('Off resonance (kHz)'); 
% Figure_LIBOR(abs(RFResponseWE90'), [], max(max(abs([RFResponseWE90]))), TISSUE_FREQ, phase, 30, ['RF Response WE 1-90-1'  ])
% ylabel('Phase offset 2nd pulse (degrees)'); xlabel('Off resonance (kHz)'); 

% Extra figure - Line plots of the Mxy as function of off-resonance after a single excitation 
% For simplicity the TR is identical for all four cases
repetitions=1;
figure('color', [1 1 1]); 
data_LIBOR=abs(GRE_Bloch_Simulation(3, 2, repetitions, [TR_ms 0],  TISSUE_FREQ, 13.5, [tau_ms 0], f_rf, -45, T1_ms, T2_ms, 0));
plot(TISSUE_FREQ, data_LIBOR, 'g', 'Linewidth', 1.0); hold on
data_LIBRE=abs(GRE_Bloch_Simulation(1, 2, repetitions, [TR_ms 0],  TISSUE_FREQ, 26, [tau_ms 0], 1560, 0, T1_ms, T2_ms, 0  ));       
plot(TISSUE_FREQ, data_LIBRE, 'k', 'Linewidth', 1.0); hold on;
data_BORR=abs(GRE_Bloch_Simulation(3, 2, repetitions, [TR_ms 0],  TISSUE_FREQ, 40, [tau_ms 0], 1560, 180, T1_ms, T2_ms, 0 ));       
plot(TISSUE_FREQ, data_BORR, 'r', 'Linewidth', 1.0); hold on;
data_WE90=abs(GRE_Bloch_Simulation(3, 2, repetitions, [TR_ms 0],  TISSUE_FREQ, 10, [0.3 (WFdephasingWE11/2)-0.3], 0, 90, T1_ms, T2_ms, 0));       
plot(TISSUE_FREQ, data_WE90, 'b', 'Linewidth', 1.0); hold on;
legend('LIBOR', 'LIBRE', 'BORR', 'WE 1-90-1');
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels, 'TickDir', 'out','FontSize',16);
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels, 'TickDir', 'out','FontSize',16);
ylabel('Mxy (a.u)'); xlabel('Off resonance (kHz)'); 

% ************* Figure 2A **************
% RF waveforms required for equal water excitation (0Hz)
% Retrieve RF profiles, phases and magnitude 
[~, totalrfLIBOR]    =GRE_Bloch_Simulation(3, 2, repetitions, [TR_ms 0], [0],13.5, [tau_ms 0], f_rf, -45, T1_ms, T2_ms, 0);
[~, totalrfLIBRE]    =GRE_Bloch_Simulation(1, 2, repetitions, [TR_ms 0], [0], 26,  [tau_ms 0], 1560,   0, T1_ms, T2_ms, 0);       
[~, totalrfBORR]     =GRE_Bloch_Simulation(3, 2, repetitions, [TR_ms 0], [0], 40,  [tau_ms 0], 1560, 180, T1_ms, T2_ms, 0);       
[~, totalrfLIBRE2200]=GRE_Bloch_Simulation(1, 2, repetitions, [TR_ms 0], [0],13.5, [1.1 0],     500,   0, T1_ms, T2_ms, 0); 

figure('color', [1 1 1]);
dT=0.00001; %in [s]
gamma_times_dT= 42.57*1000000*2*pi()*dT; %To convert B1 magnitude into [T] 
datasets = { 'totalrfLIBOR', 'totalrfLIBRE', 'totalrfBORR', 'totalrfLIBRE2200'};
RFindex = {'LIBOR (1.0ms)', 'LIBRE (1.0ms)', 'BORR (1.0ms)', 'LIBRE (2.2ms)'};
clear xticklabels;
ymin = 0; ymax = 3; %in microTesla
for i = 1:length(datasets)
    subplot(2, 2, i);
    yyaxis right;
    plot(1:length(eval(datasets{i})), angle(eval(datasets{i})), [ '-'], 'Linewidth', 1.0);
    hold on;
    yyaxis left;
    plot(1:length(eval(datasets{i})), abs(eval(datasets{i}))/(gamma_times_dT/1e6), [ '-'], 'Linewidth', 1.0);%factor 1e6 to convert to microtesla
    hold on;
    ylim([ymin ymax]);
    custom_xticklabels=[0:0.2:length(eval(datasets{i}))/100];
    xticks(1:20:length(eval(datasets{i}))); % Set the x-ticks at these positions
    xticklabels(custom_xticklabels); % Apply the custom labels
    title([ RFindex{i}]);
    yyaxis right;
    ylabel('B1 phase (rad)');
    yyaxis left;
    ylabel('B1 amplitude (uT)');
    xlabel('Time (ms)');
end

% ************* Figure 2B *************
% Mxy response of 500 excitations as function of excitation angle
% Timeconsuming simulation
angle= [2: 1: 26];
repetitions=500; %change to 500
if length(angle)>1
    for i=1:length(angle) 
        LIBORph40(i,:)=GRE_Bloch_Simulation(3, 2, repetitions, [TR_ms 0],  TISSUE_FREQ, angle(i), [tau_ms 0], 1560/2, -40, T1_ms, T2_ms, 0);
        LIBRE500(i,:)= GRE_Bloch_Simulation(1, 2, repetitions, [TR_ms 0],  TISSUE_FREQ, angle(i), [tau_ms 0], 1560, 0, T1_ms, T2_ms, 0);
        BORR500(i,:)=  GRE_Bloch_Simulation(3, 2, repetitions, [TR_ms 0],  TISSUE_FREQ, angle(i), [tau_ms 0], 1560, 180, T1_ms, T2_ms, 0);
        LIBRE1100(i,:)=GRE_Bloch_Simulation(1, 2, repetitions, [TR_ms 0],  TISSUE_FREQ, angle(i), [1.1 0], 500, 0, T1_ms, T2_ms, 0);       
    end
end
Figure_LIBOR(abs(LIBORph40'), [], max(max(abs([LIBORph40]))), TISSUE_FREQ, angle, 2, ['GRE LIBOR ph40 frf 1560/2'  ])
ylabel('RF excitation angle (deg)'); xlabel('Off resonance (kHz)'); 
Figure_LIBOR(abs(LIBRE500'), [], max(max(abs([LIBRE500]))), TISSUE_FREQ, angle, 2, ['GRE LIBRE500'  ])
ylabel('RF excitation angle (deg)'); xlabel('Off resonance (kHz)'); 
Figure_LIBOR(abs(BORR500'), [], max(max(abs([BORR500]))), TISSUE_FREQ, angle, 2, ['GRE BORR500'  ])
ylabel('RF excitation angle (deg)'); xlabel('Off resonance (kHz)'); 
Figure_LIBOR(abs(LIBRE1100'), [], max(max(abs([LIBRE1100]))), TISSUE_FREQ, angle, 2, ['GRE LIBRE1100'  ])
ylabel('RF excitation angle (deg)'); xlabel('Off resonance (kHz)'); 




