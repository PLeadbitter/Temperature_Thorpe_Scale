 % Script to calculate epsilon using a variety of methods
%% Clear up the workspace and load in data
clear  
close all

% add relevant paths for data, functions and toolboxes
addpath(genpath('C:\UEA\MatLab_Working_Folder\Toolboxes'));
addpath(genpath('C:\UEA\MatLab_Working_Folder\EURECA'));
 
load MSdata_Eur.mat; MSdata = MSdata_Eur; clear MSdata_Eur
load SG620_Hydro_data.mat; gridded_data = sg620_data; clear sg620_data

disp(sprintf('Data Loaded'));
%% Script Constants
% Constants
    prof_start = 1; prof_end = 258;
    prof_offset = 0; % profile offset for the MS_data
    g = gsw_grav(14,0); % acceleration du to gravity at 60 degrees north, sea surface
    eps_c = 0.64; % constant for the calculation of epsilon where epsilon = c * L_T^2 * N^3 
    fldnm = 'Eur'; % respective seabird data
    
%% Create 2 new N2 profiles for calculating N2 from 
% Create a single profile that has a single value of N2 in it for each
% profile
 n2 = 1e-5; % provide a generic N2 value that you want to the whole profile to be
 rho0 = 1026;
 
 for ii = prof_start:prof_end
     tic
     prof_num = ii + prof_offset; 
    % Create a unifrom N2 for 
        MSdata.n2_extra(ii).ave_1(1:length(MSdata.Binned(ii).ot_Z_1),1) = n2;
            idx = MSdata.Binned(ii).ot_no_1 ~= 0; 
            MSdata.n2_extra(ii).ave_1_whole(1:length(MSdata.Binned(ii).ot_no_1),1) = NaN;
            MSdata.n2_extra(ii).ave_1_whole(idx) = n2; clear idx
    
    % Create an N2 based of the seabird data for the FP07 1 data
        z = -gridded_data.depth;
        smo_rho = movmean(gridded_data.sigma0(:,ii),20,'omitnan'); %changed on 21/04/2021 to use a smooth density
        [n2_gsw,zz] =  bfrqsq(smo_rho,z,rho0);
        n2_gsw(n2_gsw < 0) = NaN; zz(isnan(n2_gsw)) = NaN;
        
    % Pre determine empty arrays for 'whole' data set
        MSdata.n2_extra(ii).Seabird_1_whole(1:length(MSdata.Binned(ii).ot_no_1),1) = NaN;
        
    for jj = 1:length(MSdata.Binned(ii).ot_Z_1)
        
        z1 = MSdata.Binned(ii).ot_Z_1(jj);
        [~,idx] = min(abs(zz + z1));
        MSdata.n2_extra(ii).Seabird_1(jj) = n2_gsw(idx); 
        
        idx_whole = (MSdata.Binned(ii).ot_r_no_1 == jj); 
        MSdata.n2_extra(ii).Seabird_1_whole(idx_whole) = n2_gsw(idx); 
        
        clear idx_whole idx smo_rho
        
    end
    
    t = toc; t = t/60;
    disp(sprintf('Calculted extra N2 values, profile %d of %d in %.1f minutes',prof_num,prof_end,t));
 end

%% Calculate TKE dissipation for each overturn

for ii = prof_start:prof_end
    tic 
    prof_num = ii + prof_offset;
       
    % Constants
    end_val = length(MSdata.Binned(ii).L_T_whole_1);
    
    % FP07 1
    L_T = MSdata.Binned(ii).L_T_1;
    ot_no = MSdata.Binned(ii).ot_r_no_1;
    n2a = MSdata.n2_extra(ii).ave_1;
    n2s = MSdata.n2_extra(ii).Seabird_1;
    
    [Eaw,Ea] = calc_eps(ot_no,L_T,n2a,eps_c,end_val);
    [Esw,Es] = calc_eps(ot_no,L_T,n2s,eps_c,end_val);
    
    MSdata.Outputs(ii).e_ave_whole_1 = Eaw;
    MSdata.Outputs(ii).e_ave_1 = Ea;
    MSdata.Outputs(ii).e_seabird_whole_1 = Esw;
    MSdata.Outputs(ii).e_seabird_1 = Es;
    clear Esw Es Eaw Ea L_T ot_no n2a n2s
    
    t = toc; t = t/60;
    disp(sprintf('Calculated TKE  from profile %d of %d in %.1f minutes',prof_num,prof_end,t));
end

%% Plot profiles Temperature, N2 and epsilon values
close all

%path = 'C:\UEA\MatLab_Working_Folder\RidgeMix\Processing\Images\D\test\Epsilon_test';
for ii = prof_start:prof_end
 
z = -MSdata.Binned(ii).Z;    
o = MSdata.Outputs(ii);
n = MSdata.Binned(ii);

f1 = figure('Position',[50,100,800,600],'Units','normalized');
ax1= axes('Position',[0.1 0.1 0.27 0.85]);
plot(n.L_T_whole_1,z,'.');
grid on
%axis ij
ylim([-2000 0])
ylabel('Depth [m]','FontSize',16)
xlabel('Thorpe Length [m]','FontSize',16)

ax2= axes('Position',[0.4 0.1 0.27 0.85]);
plot(o.N2_bulk_whole_1,z,'.',o.N2_mean_whole_1,z,'.');
%axis ij
grid on
yticklabels([]);
xlabel('Overturn N^2','FontSize',16)
legend('Bulk','Mean','Location','NorthWest')
ylim([-2000 0]); xlim([0 1e-4])

ax3= axes('Position',[0.7 0.1 0.27 0.85]);
h = plot(o.e_bulk_whole_1,z,'.',o.e_mean_whole_1,z,'.');
%axis ij
grid on
yticklabels([]);
xlabel('Overturn \epsilon','FontSize',16)
ylim([-2000 0]); xlim([1e-10 1e-5])
set(gca,'XScale','log')
set(f1,'Renderer','Painter')

fig = [path,filesep,'Profile_test',num2str(ii),'.png'];
saveas(f1,fig,'png')

end

%%
close all
tic
MSdata_Eur = MSdata;
save('C:\UEA\MatLab_Working_Folder\EURECA\Data','MSdata_Eur');
toc; 
disp(sprintf('Data Saved'));
