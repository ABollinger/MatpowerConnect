function compare_case(mpc1, mpc2)
%COMPARE_CASE  Compares the bus, gen, branch matrices of 2 MATPOWER cases.
%   COMPARE_CASE(MPC1, MPC2)
%   Compares the bus, branch and gen matrices of two MATPOWER cases and
%   prints a summary of the differences. For each column of the matrix it
%   prints the maximum of any non-zero differences.

%   MATPOWER
%   $Id: compare_case.m,v 1.8 2010/04/26 19:45:25 ray Exp $
%   by Ray Zimmerman, PSERC Cornell
%   Copyright (c) 1996-2010 by Power System Engineering Research Center (PSERC)
%
%   This file is part of MATPOWER.
%   See http://www.pserc.cornell.edu/matpower/ for more info.
%
%   MATPOWER is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published
%   by the Free Software Foundation, either version 3 of the License,
%   or (at your option) any later version.
%
%   MATPOWER is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with MATPOWER. If not, see <http://www.gnu.org/licenses/>.
%
%   Additional permission under GNU GPL version 3 section 7
%
%   If you modify MATPOWER, or any covered work, to interface with
%   other modules (such as MATLAB code and MEX-files) available in a
%   MATLAB(R) or comparable environment containing parts covered
%   under other licensing terms, the licensors of MATPOWER grant
%   you additional permission to convey the resulting work.

%% define named indices into bus, gen, branch matrices
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

%% read data & convert to internal bus numbering
[baseMVA1, bus1, gen1, branch1] = loadcase(mpc1);
[baseMVA2, bus2, gen2, branch2] = loadcase(mpc2);

%% set sizes
solvedPF = 0;
solvedOPF = 0;
Nb = VMIN;
Ng = APF;
Nl = ANGMAX;

%% check for PF results
if size(branch1, 2) >= QT && size(branch2, 2) >= QT
    solvedPF = 1;
    Nl = QT;
    %% check for OPF results
    if size(branch1, 2) >= MU_ST && size(branch2, 2) >= MU_ST
        solvedOPF = 1;
        Nb = MU_VMIN;
        Ng = MU_QMIN;
        Nl = MU_ST;
    end
end

%% set up index name matrices
    buscols = char( 'BUS_I', ...
                    'BUS_TYPE', ...
                    'PD', ...
                    'QD', ...
                    'GS', ...
                    'BS', ...
                    'BUS_AREA', ...
                    'VM', ...
                    'VA', ...
                    'BASE_KV', ...
                    'ZONE', ...
                    'VMAX', ...
                    'VMIN'  );
    gencols = char( 'GEN_BUS', ...
                    'PG', ...
                    'QG', ...
                    'QMAX', ...
                    'QMIN', ...
                    'VG', ...
                    'MBASE', ...
                    'GEN_STATUS', ...
                    'PMAX', ...
                    'PMIN', ...
                    'PC1', ...
                    'PC2', ...
                    'QC1MIN', ...
                    'QC1MAX', ...
                    'QC2MIN', ...
                    'QC2MAX', ...
                    'RAMP_AGC', ...
                    'RAMP_10', ...
                    'RAMP_30', ...
                    'RAMP_Q', ...
                    'APF'   );
    brcols = char(  'F_BUS', ...
                    'T_BUS', ...
                    'BR_R', ...
                    'BR_X', ...
                    'BR_B', ...
                    'RATE_A', ...
                    'RATE_B', ...
                    'RATE_C', ...
                    'TAP', ...
                    'SHIFT', ...
                    'BR_STATUS' );
if solvedPF
    brcols = char(  brcols, ...
                    'PF', ...
                    'QF', ...
                    'PT', ...
                    'QT'    );
    if solvedOPF
        buscols = char( buscols, ...
                        'LAM_P', ...
                        'LAM_Q', ...
                        'MU_VMAX', ...
                        'MU_VMIN'   );
        gencols = char( gencols, ...
                        'MU_PMAX', ...
                        'MU_PMIN', ...
                        'MU_QMAX', ...
                        'MU_QMIN'   );
        brcols = char(  brcols, ...
                        'MU_SF', ...
                        'MU_ST' );
    end
end

%% print results
fprintf('----------------  --------------  --------------  --------------  -----\n');
fprintf(' matrix / col         case 1          case 2        difference     row \n');
fprintf('----------------  --------------  --------------  --------------  -----\n');

%% bus comparison
[temp, i] = max(abs(bus1(:, 1:Nb) - bus2(:, 1:Nb)));
[v, gmax] = max(temp);
i = i(gmax);
fprintf('bus');
nodiff = ' : no differences found';
for j = 1:size(buscols, 1)
    [v, i] = max(abs(bus1(:, j) - bus2(:, j)));
    if v
        nodiff = '';
        if j == gmax, s = ' *'; else s = ''; end
        fprintf('\n  %-12s%16g%16g%16g%7d%s', buscols(j, :), bus1(i, j), bus2(i, j), v, i, s );
    end
end
fprintf('%s\n', nodiff);

%% gen comparison
[temp, i] = max(abs(gen1(:, 1:Ng) - gen2(:, 1:Ng)));
[v, gmax] = max(temp);
i = i(gmax);
fprintf('\ngen');
nodiff = ' : no differences found';
for j = 1:size(gencols, 1)
    [v, i] = max(abs(gen1(:, j) - gen2(:, j)));
    if v
        nodiff = '';
        if j == gmax, s = ' *'; else s = ''; end
        fprintf('\n  %-12s%16g%16g%16g%7d%s', gencols(j, :), gen1(i, j), gen2(i, j), v, i, s );
    end
end
fprintf('%s\n', nodiff);

%% branch comparison
[temp, i] = max(abs(branch1(:, 1:Nl) - branch2(:, 1:Nl)));
[v, gmax] = max(temp);
i = i(gmax);
fprintf('\nbranch');
nodiff = ' : no differences found';
for j = 1:size(brcols, 1)
    [v, i] = max(abs(branch1(:, j) - branch2(:, j)));
    if v
        nodiff = '';
        if j == gmax, s = ' *'; else s = ''; end
        fprintf('\n  %-12s%16g%16g%16g%7d%s', brcols(j, :), branch1(i, j), branch2(i, j), v, i, s );
    end
end
fprintf('%s\n', nodiff);
