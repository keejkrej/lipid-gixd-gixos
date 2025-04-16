function [DS_RRF, DS_term,  RRF_term] = calc_CWM_DS_RRF_integ(beta_space, qxy0, energy, alpha, Rqxy_HWHM, DSqxy_HWHM, DSbeta_HWHM, tension, temp, amin)
% calculation of the ratio between diffuse scattering and R/RF by double integration over beta and phi
% diffuse scattering at fixed tth (phi) alone vertical direction. Mind that they correspond to different qxy
% input requires rebinned data in beta in equal step size
% beta_space: [deg] tt (vertical)
% qxy0: [A^-1] qxy at beta = 0deg
% energy, alpha, sdd, footprint: energy [keV], incident angle [deg], sample-detector distance [mm], footprint length [mm]
% qxy_HWHM: [A^-1] HWHM of the qxy resolution for specular reflection, can be obtained from width of the specular signal
% DSqxy_HWHM: [A^-1] HWHM of the qxy resolution for diffuse scattering
% gamma: [N/m] surface tension
% temp: [K] temperature
% amin: minimal wavelength cutoff of the surface CW

% basic
Qmax = pi/amin;
kb = 1.381E-23; % Boltzmann constant, J/K
wavelength = 12.4/energy;
wave_number = 2*pi / wavelength;
qz_space = (sind(alpha)+sind(beta_space)) * wave_number;

% openning in phi [deg]
phi = 2*asind(qxy0/(2*wave_number)); % offspecular angle [deg]
phi_HWHM = rad2deg(DSqxy_HWHM*wavelength/2/pi); % % HWHM of phi resolution, [deg]
phi_upper = phi + phi_HWHM;
phi_lower = phi - phi_HWHM;

% openning in beta [deg]
% beta_FW = mean(beta_space(2:end) - beta_space(1:end-1));
beta_upper = beta_space + DSbeta_HWHM;
beta_lower = beta_space - DSbeta_HWHM;

% tension term
kbT_gamma = kb*temp/tension*10^20; % kbT/gamma, prefactor
eta = kbT_gamma/2/pi*qz_space.^2;
RRF_term = (Rqxy_HWHM/Qmax).^eta;

% DS via integral
DS_term = ones(length(beta_space),1);
for idx = 1:length(beta_space)
    fun = @(tt,tth) CWM_integral_delta_beta_delta_phi(tt, tth, kbT_gamma, wave_number, alpha, Qmax);
    DS_term(idx,1) = integral2(fun, beta_lower(idx), beta_upper(idx), phi_lower, phi_upper);
end
DS_RRF = DS_term ./ RRF_term;

close(findobj('name','GIXOS factor'));
fig=figure('name','GIXOS factor');
plot(qz_space, DS_RRF/DS_RRF(1),'-','LineWidth', 1.5,'DisplayName',strcat('Q_x_y_,_0=',num2str(qxy0),char(197),'^-^1'));
hold off;
ylabel('DS/(R/R_F)','FontSize',12);
xlabel(['Q_z [' char(197) '^-^1]'],'FontSize',12);
ax=gca;
ax.FontSize = 12;
ax.LineWidth = 1;
ax.TickDir = 'out';
legend('location','NorthWest','box','off');
%ylim([0 400]);
xlim([0 1.2]);
grid on;

end

