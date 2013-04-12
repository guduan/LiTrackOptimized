par_name = {'Initial bunch length';
            'Initial energy spread';
            'Initial number of particles';
            'Initial asymmetry';
            'NRTL Compressor Amplitude';
            'NRTL Compressor Phase';
            'NRTL R56';
            'NRTL T566';
            '2-10 Phase';
            '11-20 Phase';
            'Ramp Phase';
            'S20 Beta';
            'YAG Dispersion';
            'YAG 2nd Order Dispersion'};

% Lower limit on params    
Low_limit = [6e-3;
             7e-4;
             1.6e10;
             -0.4;
             0.033;
             88;
             0.58;
             0.8;
             -30;
             -10;
             -10;
             4;
             100;
             -1000;];
         
% Higher limit on params                 
High_limit= [10e-3;
             10e-4;
             2.4e10;
             0.05;
             0.046;
             92;
             0.63;
             1.2;
             -10;
             +10;
             +10;
             6.0;
             130;
             1000;];
         
Cent=(High_limit+Low_limit)/2;
Diff=High_limit-Low_limit;

nPar = 14;

if length(par_name) ~= nPar
    error('Update number of parameters');
end