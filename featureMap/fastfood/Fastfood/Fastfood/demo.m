% Demo for Fastfood kernel expansions [Le et al. 2013]
%
% Ji Zhao@CMU
% 12/19/2013
% zhaoji84@gmail.com
% This file is part of the FastMMD [Zhao & Meng 2015] code.
%
% Reference:
% [1] Q.V. Le, T. Sarlos, A.J. Smola. Fastfood - Approximating Kernel Expansions in Loglinear Time. ICML, 2013.
% [2] Ji Zhao, Deyu Meng. FastMMD: Ensemble of Circular Discrepancy for Efficient Two-Sample Test. Neural Computation, 2015.

%%
clear;
%% parameter for Fastfood
d = 100; % dimension of input pattern
n = d*20; % basis number used for approximation
sgm = 10; % bandwidth for Gaussian kernel

%% generate two sets of patterns
X1 = randn(d, 4000);
X2 = randn(d, 4000);

%% exact calculation of Gaussian kernel

tic
K_exact = zeros(size(X1,2), size(X2,2));
for i = 1:size(X1,2)
    for j = 1:size(X2,2)
        K_exact(i,j) = exp( -norm(X1(:,i)-X2(:,j),2)^2/(2*sgm^2) );
    end
end
time_exact = toc

%% Fastfood approximation of Gaussian kernel
try
    % test whether we can use Spiral package
    fwht_spiral([1; 1]);
    use_spiral = 1;
catch
    display('Cannot perform Walsh-Hadamard transform using Spiral WHT package.');
    display('Use Matlab function fwht instead, which is slow for large-scale data.')
    use_spiral = 0;
end

tic
para = FastfoodPara(n, d);
PHI1 = FastfoodForKernel(X1, para, sgm, use_spiral);
PHI2 = FastfoodForKernel(X2, para, sgm, use_spiral);
K_appro = PHI1'*PHI2;
time_fastfood = toc

norm(K_exact )
norm(K_appro)
norm(K_exact - K_appro)

%%
% K_exact
% K_appro
