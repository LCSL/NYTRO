#include <math.h>
#include "mex.h"
#include "spiral_wht.h"
#include "parallel.h"

/* 
Walsh-Hadamard transform using Spiral WHT package
Ji Zhao@CMU
01/25/2014

example:
>> A =rand(4096, 1000);
tic; fwht(A, 4096, 'hadamard')*4096; toc
tic; fwht_spiral(A, 12); toc
Elapsed time is 5.340516 seconds.
Elapsed time is 0.061315 seconds.
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	/* Macros for the ouput and input arguments */
	#define B_OUT plhs[0]
	#define A_IN  prhs[0]
	/* #define D_IN  prhs[1] */
	double *B, *A, d, *x, tmp;
	int M, N, m, n;
    bool flag = false;
    Wht *Wht_tree;
    
	if(nrhs < 1 || nrhs > 1)
		mexErrMsgTxt("Wrong number of input arguments.");
	else if(nlhs > 1)
		mexErrMsgTxt("Too many output arguments.");    
    
	M = mxGetM(A_IN); /* Get rows of A */
	N = mxGetN(A_IN); /* Get columns of A */
    if (M==1 && N==1)
        mexErrMsgTxt("Input argument must be a matrix.");
    else if(M==1 && N>1)
    {
        tmp = M;
        M = N;
        N = tmp;
        flag = true;
    }
 	/*if(nrhs == 1)
		d = 2.0;
	else
		d = mxGetScalar(D_IN); */
    d = floor(log(M)/log(2));
    if(M-pow(2, d)!=0)
        mexErrMsgTxt("Input argument must be a matrix with dimesnion 2^n.");

    Wht_tree = wht_get_tree(d); /* 2^d */
    if (Wht_tree == NULL)
        mexErrMsgTxt("Could not find tree of size 2^2 in wht_trees file,\nDid you do \"make install\"?\n");

    x = mxMalloc(sizeof(Wht)*M);
	A = mxGetPr(A_IN); /* Get the pointer to the data of A */
    if(!flag)
        B_OUT = mxCreateDoubleMatrix(M, N, mxREAL); /* Create the output matrix */
    else
        B_OUT = mxCreateDoubleMatrix(N, M, mxREAL);
	B = mxGetPr(B_OUT); /* Get the pointer to the data of B */
	for(n = 0; n < N; n++) /* Compute a matrix with Walsh-Hadamard transform */
	{
        for(m = 0; m < M; m++) x[m] = A[m + M*n];
        wht_apply(Wht_tree, 1, x);
		for(m = 0; m < M; m++) B[m + M*n] = x[m];
	}
    wht_delete(Wht_tree);
	return;
}