% This file is part of the HörTech Open Master Hearing Aid (openMHA)
% Copyright © 2024 Hörzentrum Oldenburg gGmbH
%
% openMHA is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as published by
% the Free Software Foundation, version 3 of the License.
%
% openMHA is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License, version 3 for more details.
%
% You should have received a copy of the GNU Affero General Public License,
% version 3 along with openMHA.  If not, see <http://www.gnu.org/licenses/>.


% Script for computing filter coefficients defining the extent of residual 
% acoustic hearing (CIS strategy), plotting the results, and displaying 
% them on the screen in a format that is compatible with the Linux shell 
% scripts and Windows batch files included in this openMHA example

clear;
close all;
clc;

if isunix
    addpath(genpath('/usr/lib/openmha/mfiles'));
elseif ispc
    addpath(genpath('C:/Program Files/openMHA/mfiles'));
end

if isoctave
    pkg load signal;
end

% -------------------------------------------------------------------------

fc = 359;       % cutoff frequency / Hz (lowest CI auralization frequency)
srate = 48000;  % sampling rate / Hz
n = 3;          % filter order
precision = 6;  % precision (significant digits)

% Compute the coefficients for a Butterworth lowpass filter:
Wn = fc/(srate/2);
[b, a] = butter(n, Wn, 'low');

% Reduce numeric precision to guarantee conformity with C++ single-
% precision floating-point format ("float", or "mha_real_t" in openMHA):
b = eval(mat2str(b, 6));
a = eval(mat2str(a, 6));

% Plot the frequency response of the filter:
figure(1);
freqz(b, a, srate/2, srate);
subplot(2, 1, 1);
xticks(0:2000:srate/2);
xticklabels((0:2000:srate/2)/1000);
xlabel('Frequency / kHz');
ylim([-40 0]);
hold on;
plot([fc fc], ylim, 'r--');
fontSize = get(gca, 'FontSize');
text(fc, 0, '{\it f}_c', 'Color', 'r', 'FontSize', fontSize, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
hold off;
ylabel('Magnitude / dB');
title({'Residual Acoustic Hearing Filter (CIS)', ''});
subplot(2, 1, 2);
hold on;
plot([fc fc], ylim, 'r--');
yl = ylim;
text(fc, yl(2), '{\it f}_c', 'Color', 'r', 'FontSize', fontSize, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
hold off;
xticks(0:2000:srate/2);
xticklabels((0:2000:srate/2)/1000);
xlabel('Frequency / kHz');
ylabel('Phase / degrees');

% Plot the pole-zero plot of the filter:
figure(2);
zplane(b, a);
gridColor = get(gca, 'GridColor');
h = findobj(gca, 'LineStyle', ':');
set(h, 'Color', gridColor, 'LineStyle', '-');
grid on;
axis square;
ylim(xlim);
xlabel('Real Part');
ylabel('Imaginary Part');
title({'Residual Acoustic Hearing Filter (CIS)', ''});

% Verify that the filter is stable:
if ~isstable(b, a)
    error('The filter is unstable. Consider changing the filter order and/or cutoff frequency.');
end

% Display the results:
expression = '(?<=e[+-])0';
sB = strtrim(sprintf('%g ', b));
sB = regexprep(sB, expression, '');
sA = strtrim(sprintf('%g ', a));
sA = regexprep(sA, expression, '');
fprintf('Residual acoustic hearing filter for CIS (Linux):\n\n');
fprintf(['export ACOUSTIC_IIRFILTER_B="[' sB ']"\n']);
fprintf(['export ACOUSTIC_IIRFILTER_A="[' sA ']"\n\n\n']);
fprintf('\nResidual acoustic hearing filter for CIS (Windows):\n\n');
fprintf(['set ACOUSTIC_IIRFILTER_B=[' sB ']\n']);
fprintf(['set ACOUSTIC_IIRFILTER_A=[' sA ']\n\n']);

figure(1);