This is an implementation of the Fastfood kernel expansions [1]. This code is part of our FastMMD paper[2]. Please cite [2] if you use this code.

We provide two verisons of Walsh-Hadamard transform in Fastfood. One is the Matlab built-in function fwht, the other is based on Spiral WHT package [3]. Spiral version is much more efficient than Matlab version for large-scale data. If you want to enable Spiral version, please download the package and compile file fwht_spiral.c.

This code was written by Ji Zhao. If you want to give some feedback, please contact him by email zhaoji84@gmail.com.

Reference:
[1] Q. Le, T. Sarlos, and A. Smola. Fastfood - Approximating Kernel Expansions in Loglinear Time. ICML, 2013.
[2] Ji Zhao, Deyu Meng. FastMMD: Ensemble of Circular Discrepancy for Efficient Two-Sample Test. Neural Computation, 2015. 
[3] Spiral WHT Package. http://www.spiral.net/software/wht.html


