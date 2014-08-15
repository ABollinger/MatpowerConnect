function t_qps_matpower(quiet)
%T_QPS_MATPOWER  Tests of QPS_MATPOWER QP solvers.

%   MATPOWER
%   $Id: t_qps_matpower.m,v 1.6 2010/05/18 15:50:16 ray Exp $
%   by Ray Zimmerman, PSERC Cornell
%   Copyright (c) 2010 by Power System Engineering Research Center (PSERC)
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

if nargin < 1
    quiet = 0;
end

algs = [100 200 250 300 400];
names = {'BPMPD_MEX', 'MIPS', 'sc-MIPS', 'quadprog', 'ipopt'};
check = {'bpmpd', [], [], 'quadprog', 'ipopt'};

n = 35;
t_begin(n*length(algs), quiet);

opt.verbose = 0;
opt.mips_opt.comptol = 1e-8;

for k = 1:length(algs)
    if ~isempty(check{k}) && ~have_fcn(check{k})
        t_skip(n, sprintf('%s not installed', names{k}));
    else
        opt.alg = algs(k);
        if strcmp(names{k}, 'quadprog')
            opt.ot_opt = optimset('LargeScale', 'off');
        end
        
        t = sprintf('%s - 3-d LP : ', names{k});
        %% example from 'doc linprog'
        c = [-5; -4; -6];
        A = [1 -1  1;
             3  2  4;
             3  2  0];
        l = [];
        u = [20; 42; 30];
        xmin = [0; 0; 0];
        x0 = [];
        [x, f, s, out, lam] = qps_matpower([], c, A, l, u, xmin, [], [], opt);
        t_ok(s, [t 'success']);
        t_is(x, [0; 15; 3], 6, [t 'x']);
        t_is(f, -78, 6, [t 'f']);
        t_is(lam.mu_l, [0;0;0], 13, [t 'lam.mu_l']);
        t_is(lam.mu_u, [0;1.5;0.5], 9, [t 'lam.mu_u']);
        t_is(lam.lower, [1;0;0], 9, [t 'lam.lower']);
        t_is(lam.upper, zeros(size(x)), 13, [t 'lam.upper']);

        t = sprintf('%s - unconstrained 3-d quadratic : ', names{k});
        %% from http://www.akiti.ca/QuadProgEx0Constr.html
        H = [5 -2 -1; -2 4 3; -1 3 5];
        c = [2; -35; -47];
        x0 = [0; 0; 0];
        [x, f, s, out, lam] = qps_matpower(H, c, [], [], [], [], [], [], opt);
        t_ok(s, [t 'success']);
        t_is(x, [3; 5; 7], 8, [t 'x']);
        t_is(f, -249, 13, [t 'f']);
        t_ok(isempty(lam.mu_l), [t 'lam.mu_l']);
        t_ok(isempty(lam.mu_u), [t 'lam.mu_u']);
        t_is(lam.lower, zeros(size(x)), 13, [t 'lam.lower']);
        t_is(lam.upper, zeros(size(x)), 13, [t 'lam.upper']);
        
        t = sprintf('%s - constrained 2-d QP : ', names{k});
        %% example from 'doc quadprog'
        H = [   1   -1;
                -1  2   ];
        c = [-2; -6];
        A = [   1   1;
                -1  2;
                2   1   ];
        l = [];
        u = [2; 2; 3];
        xmin = [0; 0];
        x0 = [];
        [x, f, s, out, lam] = qps_matpower(H, c, A, l, u, xmin, [], x0, opt);
        t_ok(s, [t 'success']);
        t_is(x, [2; 4]/3, 7, [t 'x']);
        t_is(f, -74/9, 6, [t 'f']);
        t_is(lam.mu_l, [0;0;0], 13, [t 'lam.mu_l']);
        t_is(lam.mu_u, [28;4;0]/9, 7, [t 'lam.mu_u']);
        t_is(lam.lower, zeros(size(x)), 8, [t 'lam.lower']);
        t_is(lam.upper, zeros(size(x)), 13, [t 'lam.upper']);

        t = sprintf('%s - constrained 4-d QP : ', names{k});
        %% from http://www.uc.edu/sashtml/iml/chap8/sect12.htm
        H = [   1003.1  4.3     6.3     5.9;
                4.3     2.2     2.1     3.9;
                6.3     2.1     3.5     4.8;
                5.9     3.9     4.8     10  ];
        c = zeros(4,1);
        A = [   1       1       1       1;
                0.17    0.11    0.10    0.18    ];
        l = [1; 0.10];
        u = [1; Inf];
        xmin = zeros(4,1);
        x0 = [1; 0; 0; 1];
        [x, f, s, out, lam] = qps_matpower(H, c, A, l, u, xmin, [], x0, opt);
        t_ok(s, [t 'success']);
        t_is(x, [0; 2.8; 0.2; 0]/3, 5, [t 'x']);
        t_is(f, 3.29/3, 6, [t 'f']);
        t_is(lam.mu_l, [6.58;0]/3, 6, [t 'lam.mu_l']);
        t_is(lam.mu_u, [0;0], 13, [t 'lam.mu_u']);
        t_is(lam.lower, [2.24;0;0;1.7667], 4, [t 'lam.lower']);
        t_is(lam.upper, zeros(size(x)), 13, [t 'lam.upper']);

        t = sprintf('%s - (struct) constrained 4-d QP : ', names{k});
        p = struct('H', H, 'A', A, 'l', l, 'u', u, 'xmin', xmin, 'x0', x0, 'opt', opt);
        [x, f, s, out, lam] = qps_matpower(p);
        t_ok(s, [t 'success']);
        t_is(x, [0; 2.8; 0.2; 0]/3, 5, [t 'x']);
        t_is(f, 3.29/3, 6, [t 'f']);
        t_is(lam.mu_l, [6.58;0]/3, 6, [t 'lam.mu_l']);
        t_is(lam.mu_u, [0;0], 13, [t 'lam.mu_u']);
        t_is(lam.lower, [2.24;0;0;1.7667], 4, [t 'lam.lower']);
        t_is(lam.upper, zeros(size(x)), 13, [t 'lam.upper']);
    end
end

t_end;
