clear all;

fontsize = 14;

% Load sample spectra
load('data_samples.mat');
data_spectrum = SPECTRA(:,1)/sum(SPECTRA(:,1));

% Create Parameter struct
global PARAM;

% Parameter limit file
par_limits;

% Set Parameter guess values
sim_params;

%
% Extremum Seeking
%

% Create the w values, w0 scales all of them
w0=4000;

w=zeros(1,17);

pr = primes(w0);
lpr = length(pr);

% The w(i) values are w(i) = sqrt(pi), where p1,...,p17 are the 17 primes less than w0. 
% This is a easy quick way to get pretty good "independence" between the
% varius frequencies.
for j2=1:17;
    w(17-(j2-1))=((w0^0.5)*pr(lpr-10*(j2-1)).^0.5);
end
    

% ES Time Step Size, choose dt small enough so that it takes 20 steps for
% the highest frequency cos(w(17)n dt) to complete one full oscillation
dt=(2*pi)/(20*w(17));


% Total Number of Extremum Seeking Steps
ESsteps=20;

% ES Time, a purely digital entity
EST = ESsteps*dt;

% alpha is, in a way, the size of the perturbation, maybe want different values
% for different parameters, depending how sensitive they are
scale = (High_limit-Low_limit);

alpha = scale/100;

% gain is the gain of each parameter's ES loop, maybe want different values
% for different parameters, depending how sensitive they are
gain = scale/100;



% Vector of 17 parameters that we will optimize

params=zeros(17,ESsteps);
cost=zeros(1,ESsteps);

    params(1,1) = PARAM.INIT.SIGZ0; % Bunch Length
    params(2,1) = PARAM.INIT.SIGD0; % Initial Energy Spread
    params(3,1) = PARAM.INIT.NPART; % Number of Particles
    params(4,1) = PARAM.INIT.ASYM;  % Initial Gaussian Asymmetry
    params(5,1) = PARAM.NRTL.AMPL;  % Amplitude of RF Compressor
    params(6,1) = PARAM.NRTL.PHAS;  % RF Compressor Phase
    params(7,1) = PARAM.NRTL.ELO;   % Low Energy Cutoff
    params(8,1) = PARAM.NRTL.EHI;   % High Energy Cutoff
    params(9,1) = decker;           % 2-10 Phase
    params(10,1) = ramp;            % Ramp Phase
    params(11,1) = PARAM.LI10.ELO;  % Low Energy Cutoff
    params(12,1) = PARAM.LI10.EHI;  % High Energy Cutoff
    params(13,1) = PARAM.LI20.ELO;  % Low Energy Cutoff
    params(14,1) = PARAM.LI20.EHI;  % High Energy Cutoff
    params(15,1) = PARAM.LI20.BETA; % Beta Function
    params(16,1) = PARAM.LI20.R16;  % Dispersion
    params(17,1) = PARAM.LI20.T166; % 2nd Order Dispersion

tic
for j=1:ESsteps-1;
    
    PARAM.LONE.PHAS = decker+ramp;  % Total Phase
    PARAM.LONE.GAIN = (PARAM.ENRG.E1 - PARAM.ENRG.E0)/cosd(PARAM.LONE.PHAS); % Energy gain

    
    % Run LiTrack
    OUT = LiTrackOpt('FACETpar');
    
    % Interpolate simulated spectrum
    sim_spectrum = interpSim(OUT,spectrum_axis);
    
    % Calculate residual
    residual = sum((sim_spectrum - data_spectrum).^2);
    
    % Set Cost as the value of the residual
    cost(j) = residual;
    
    for k = 1:17;
        params(k,j+1)=params(k,j)+dt*(cos(w(k)*j*dt+gain(k)*(cost(j))*(alpha(k)*w(k))^0.5));
        if params(k,j+1) < Low_limit(k);
            params(k,j+1) = Low_limit(k);
        else if params(k,j+1) > High_limit(k);
                params(k,j+1) = High_limit(k);
            end
        end
    end
    
    PARAM.INIT.SIGZ0 = params(1,j+1);       % Bunch Length
    PARAM.INIT.SIGD0 = params(2,j+1);       % Initial Energy Spread
    PARAM.INIT.NPART = params(3,j+1);       % Number of Particles
    PARAM.INIT.ASYM = params(4,j+1);        % Initial Gaussian Asymmetry
    PARAM.NRTL.AMPL = params(5,j+1);        % Amplitude of RF Compressor
    PARAM.NRTL.PHAS = params(6,j+1);        % RF Compressor Phase
    PARAM.NRTL.ELO = params(7,j+1);         % Low Energy Cutoff
    PARAM.NRTL.EHI = params(8,j+1);         % High Energy Cutoff
    decker = params(9,j+1);                 % 2-10 Phase
    ramp = params(10,j+1);                   % Ramp Phase
    PARAM.LI10.ELO = params(11,j+1);         % Low Energy Cutoff
    PARAM.LI10.EHI = params(12,j+1);         % High Energy Cutoff
    PARAM.LI20.ELO = params(13,j+1);         % Low Energy Cutoff
    PARAM.LI20.EHI = params(14,j+1);         % High Energy Cutoff
    PARAM.LI20.BETA = params(15,j+1);        % Beta Function
    PARAM.LI20.R16 = params(16,j+1);         % Dispersion
    PARAM.LI20.T166 = params(17,j+1);        % 2nd Order Dispersion
    
end
toc

% Plot Output
plot(spectrum_axis,data_spectrum,'g',spectrum_axis,sim_spectrum,'b');
legend('DATA','SIMULATION');
xlabel('X (mm)','fontsize',14);
text(-3.5,5e-3,['Residual = ' num2str(residual,'%0.2e')],'fontsize',14);