cap program drop cquadextr
*program drop cquadextr
program cquadextr, rclass

	syntax varlist [if] [in]
	
	// Make sure the user is having rcall installed and running
	// =========================================================================
	rcall_check
	
	// Syntax processing
	// =========================================================================
	tokenize `varlist'
    local first `1'
    macro shift
    local rest `*'
    local rest : subinstr local rest " " "+", all	
	
	marksample touse
	preserve
	quietly keep if `touse'
	quietly keep `varlist' 
	
	// Run R function
	// =========================================================================
	rcall vanilla: 										///
	library(cquad);                                     ///
	///attach(read.csv("`RData'")); 					/// load temporary data
	A = as.matrix(st.data());  						/// load temporary data
	out = cquad_ext(A[,1],A[,ncol(A)],A[,-c(1,ncol(A))],Ttol=5);      ///
	coefficients = as.matrix(out\$coefficients); summary(out); 	/// return coef
	vcov = as.matrix(out\$vcov);			 	/// return variance-covariance matrix
	He = as.matrix(out\$J);			 				/// return Hessian of the lk function
	ser = as.matrix(out\$se);			 				/// return standard errors
	serr = as.matrix(out\$ser);					 /// return robust s.e.
        rm(out);
        rm(names);               /// erase stored results
	rm(A); 
	
	// restore the data
	restore
	
	// Return scalars and matrices to Stata. The magin happens here
	// =========================================================================
	return add
end
