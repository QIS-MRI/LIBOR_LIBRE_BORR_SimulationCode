% Bloch Equation Simulation. 
% Based on framework provided by Brian Hargreaves
% Jessica Bastiaansen
% -----------------------------------------
function [sig, totalrf]=GRE_Bloch_Simulation(RFCHOICE, RFNUMBER, REPETITIONS, TR_ms, TISSUE_FREQ, angles, tau_ms, f_rf, PHASECHOICE_deg, T1_ms, T2_ms, ISPLOT)

% RFCHOICE      - Choice of RF pulse - 1=LIBRE pulse; 2=BORR; 3=Flexible phase pulse [0-360]; 
% RFNUMBER      - Choice of amount of subpulses - 1=Single Pulse; 2=Two pulses;
% TISSUE_FREQ   - Array of tissue frequencies to simulate
% angles         - RF excitation angles in [degrees]
% tau_ms        - [duration of a single pulse in ms, pulse spacing in ms]
% f_rf          - Frequency offset of the RF pulse(s)
% PHASECHOICE_deg - Phase difference between end 1st and start 2nd pulse
% REPETITIONS   - TOTAL RF excitations
% TR_ms         - [TR_ms,  SIEMENS_TR-REPETITIONS*TR_ms]; Simply added dead time before new segment starts
% Examples:
% LIBRE pulse can be simulated with  RFCHOICE=1 RFNUMBER=2 
% BORR  pulse can be simulated with  RFCHOICE=2 RFNUMBER=2
% A pulse like LIBRE or BORR with flexible phase RFCHOICE=3 RFNUMBER=2
% Single pulse (SP) can be simulated with  RFCHOICE=1/2/3 RFNUMBER=1

sig=[]; sig_TE=[]; sig_TR=[];  Mz=[];   
gammabar = 42.57e6;     % in [Hz/T]
gamma = gammabar*2*pi;  % in [rad/s*T]
tau = tau_ms(1)*1e-3;   % in [s]
B1= angles./(RFNUMBER*tau*360*gammabar); % Takes into account the total RF power, either for single pulse or two pulse case
t = 0:.01*1e-3:tau;     % in s. % DONT CHANGE IT WILL AFFECT THE GRID OF THE FATSAT PULSE
dT = t(2)-t(1);         % in s.
b1 = ones(size(t))*B1;
TR=TR_ms(1)*1e-3; 
TE=TR*0.5;
t_to_TE=0:dT:(TE-RFNUMBER*tau);
t_TE_to_TR=0:dT:(TR-TE);
t_added_after_segment=0:dT:(TR_ms(2)*1e-3);

% Define shape (first) RF (sub) pulse
rfmod = exp(1i*(2*pi*f_rf*t)); 
rf_init = (gamma*b1)*dT; % Rotation in radians. (2*pi*gammabar*B1*t)
rf=rf_init.*rfmod;    

% Define phase offset second subpulse (if applicable)
if (RFCHOICE==1)
    desired_phase_offset = -2*pi*f_rf*tau; % LIBRE pulse
elseif (RFCHOICE==2)
    desired_phase_offset = pi; % Ye et all pulse
elseif (RFCHOICE==3)
    desired_phase_offset = PHASECHOICE_deg/180*pi; % Flexible
end
 
phase_offset_endpulse = angle(rf(end));  % The phase at the end of the first pulse is angle(rf(end))
phase_offset=phase_offset_endpulse+desired_phase_offset ;

% Define shape second subpulse
if RFNUMBER>1
    rfmod2 = exp(1i*(2*pi*f_rf*t+phase_offset ));
    rf2=rf_init.*rfmod2;
else
    rf2=[];
end
totalrf=[rf,0,rf2]; % zero added for visualization of the gap between subpulses

freq = TISSUE_FREQ;	% Hz. 
sig = 0*freq;		% Allocate space.
sig_TE = 0*freq;
sig_TR = 0*freq;

% -------- START SIMULATION -------------
rot_counter=0;
for f=1:length(freq) % Loop over frequency range
    rot_counter=0;
    M = [0;0;1];    
   [A,B] = freeprecess(dT*1000,T1_ms,T2_ms,freq(f));
        for i_reps=1:REPETITIONS
            rot_counter=0;                
            M = [0; 0; M(3)]; % Gradient spoiling (GRE) -> Set Mx and My to zero after each RF.            
                for k = 1:length(rf)-1
                    M = A*M+B;   % Propagate to next pulse.
                    M = throt(abs(rf(k)),atan2(imag(rf(k)),real(rf(k)) )) * M;	% RF Rotation.                 
                    rot_counter=rot_counter+1;
                    k=k+1;
                end;            
           
                % Optional - Add an amount of dead time between two subpulses pulses
            t_LIBRE_BORR_LIBOR_ipd=0:dT:(tau_ms(2)*1e-3);
            if RFCHOICE<4 % For WE there is only a phase evolution between two RF pulses
                for k31=1:length(t_LIBRE_BORR_LIBOR_ipd)-1
                    M=A*M+B;
                    rot_counter=rot_counter+1;
                    k31=k31+1;
                end
            end            

            if RFNUMBER==2
                for k2 = 1:length(rf2)-1      % Second RF pulse                
                    M = A*M+B;				% Propagate to next pulse.
                    M = throt(abs(rf2(k2)), atan2(imag(rf2(k2)), real(rf2(k2)))) * M;	% RF Rotation.
                    rot_counter=rot_counter+1;
                    k2=k2+1;
                end;  
            end
              
            % subtract phase of last RF pulse from the signal
            % for correct RF spoiling - This will rotate the transmit and
            % receive fields by the same amount
            LastRFPhase=atan2(imag(rf(1)),real(rf(1)));
            % test RF spoiling - subtract last RF phase LastRFPhase
            % or PHASECHOICE_deg/180*pi *i_reps
            % M_RFspoiled=( M(1)+1i*M(2) )*exp(-1i*LastRFPhase);
            % M = [real(M_RFspoiled); imag(M_RFspoiled); M(3)];           
            
            % Original
            sig(f) = M(1)+1i*M(2); % Signal right after the end of the RF pulse  
            % TEST RF SPOILING
            sig(f) = (M(1)+1i*M(2) ) * exp(-1i*LastRFPhase) ; 
                       
            if freq(f)==0
                SS_sig(i_reps)=M(1)+1i*M(2);
                % TEST RF SPOILING
                SS_sig(i_reps) = ( M(1)+1i*M(2) ) * exp(-1i*LastRFPhase) ;                 
            end

            % -------  End RF pulse part, start precession
                for k4=1:length(t_to_TE)-1
                    M=A*M+B;
                    rot_counter=rot_counter+1;
                    k4=k4+1;
                end
            sig_TE(f)=M(1)+i*M(2); % Signal at TE
            % TEST RF SPOILING
            sig_TE(f) = ( M(1)+1i*M(2) ) * exp(-1i*LastRFPhase) ;             
            
            if freq(f)==0
                SS_sig_TE(i_reps)=M(1)+1i*M(2);
            end
            SS_sig_TE_all(f,i_reps)=M(1)+1i*M(2);

                for k5=1:length(t_TE_to_TR)-1
                    M=A*M+B;
                    rot_counter=rot_counter+1;
                    k5=k5+1;
                end 

            sig_TR(f)=M(1)+i*M(2); % Signal at end TR
            % TEST RF SPOILING
            sig_TR(f) = ( M(1)+1i*M(2) ) * exp(-1i*LastRFPhase) ;                        
            Mz(f)= M(3);
                       
            if freq(f)==0
                SS_sig_TR(i_reps)=M(1)+1i*M(2);
            end
            SS_sig_TR_all(f,i_reps)=M(1)+1i*M(2);

           i_reps=i_reps+1; % is this necessary? 
        end
       
        % t_added_after_segment
        for k6=1:length(t_added_after_segment)-1
            M=A*M+B;
            k6=k6+1;
        end         
end;
rot_counter;

if (ISPLOT==1)
    figure
    subplot(2,1,1);
    plot(freq,abs(sig)); hold on
    plot(freq,abs(sig_TE)); hold on
    plot(freq,abs(sig_TR));
    ylabel('Signal (fraction of M_0)');
    xlabel('Tissue Frequency (Hz)');
    title(['Signal Amplitude, '  num2str(RFNUMBER) ' pulses, ' num2str(f_rf) 'Hz, ' num2str(tau*1000) 'ms, angle=' num2str(angles) ', TR=' num2str(TR_ms(1)) 'ms, T1=' num2str(T1_ms) 'ms, T2=' num2str(T2_ms) 'ms, Nex=' num2str(REPETITIONS)], 'FontSize', 8);
    ylim([0 1]);
    legend('End RF', 'TE (half TR)', 'TR');
    grid on;
    subplot(2,1,2);
    plot(freq,atan2(imag(sig),real(sig)));
    hold on
    plot(freq,atan2(imag(sig_TE),real(sig_TE)));
    hold on
    plot(freq,atan2(imag(sig_TR),real(sig_TR)));
    ylabel('Phase (rad)'); 
    xlabel('Frequency (Hz)');
    title('Signal Phase');
    legend('End RF', 'TE (half TR)', 'TR');
    grid on;
end 

if (ISPLOT==1)
    figure
    subplot(2,1,1);
    plot([1:REPETITIONS],abs(SS_sig));
    hold on
    plot([1:REPETITIONS],abs(SS_sig_TE));
    hold on
    plot([1:REPETITIONS],abs(SS_sig_TR));
    ylabel('Signal (fraction of M_0)');
    xlabel('Repetitions');
    title(['Signal Amplitude,  '  num2str(RFNUMBER) ' pulses, ' num2str(f_rf) 'Hz, ' num2str(tau*1000) 'ms, angles=' num2str(angles) ', TR=' num2str(TR_ms(1)) 'ms, T1=' num2str(T1_ms) 'ms, T2=' num2str(T2_ms) 'ms, Nex=' num2str(REPETITIONS)], 'FontSize', 8);
    ylim([0 1]);
    legend('End RF', 'TE (half TR)', 'TR', 'Fat End RF');
    grid on;
    subplot(2,1,2);
    plot([1:REPETITIONS],atan2(imag(SS_sig),real(SS_sig)));
    hold on
    plot([1:REPETITIONS],atan2(imag(SS_sig_TE),real(SS_sig_TE)));
    hold on
    plot([1:REPETITIONS],atan2(imag(SS_sig_TR),real(SS_sig_TR)));
    ylabel('Phase (rad)'); 
    xlabel('Repetitions');
    title('Signal Phase');
    legend('End RF', 'TE (half TR)', 'TR');
    grid on;
end 

rot_counter=0;
i_reps=0;
