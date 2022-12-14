
#testing if x is a wholenumber
#'
#'@export

is.wholenumber <- function (x, tol = .Machine$double.eps^0.5)
  abs(x - round(x)) < tol

#based on Rfast implementation
#'
#'@export

fast_lm <- function(x,y)
{
  be <- solve(crossprod(x),crossprod(x,y))
  resid <-  y - x %*% be
  out <- list(be = be,
              residuals = resid)
  return(out)
}


#Circular permutation on vector
# Code adapted from https://mzuer.github.io
#'
#'@export

shifter <- function(x, n = 1) {
  # if (n == 0) x else c(tail(x, -n), head(x, n))
  if (n == 0) x else c(tail(x, n), head(x, -n))
}

#shifter(c(1:10), n=-1)
# [1]  1  2  3  4  5  6  7  8  9 10
#shifter(c(1:10), n=1)
# [1] 10  1  2  3  4  5  6  7  8  9
#shifter(c(1:10), n=2)
# [1]  9 10  1  2  3  4  5  6  7  8


#'@export

'%!in%' <- function(x,y)!('%in%'(x,y))



#Product bewteen a NxJ matrix and a JxKxP tensor
#returns a JxKxP tensor in which slice along dim 3 is the matrix product of the slice
#and the matrix
#'@export

'%x%' <- function(mat, tens)
{
 out <-   abind(
                lapply( 1:dim(tens)[3],
                        function(xi) mat%*% tens[,,xi]
                       ),
                        along =3
                )
 return(out)

}


#Product bewteen a  J vector and a JxKxP tensor
#returns a 1xKxP tensor in which slice along dim 3 is the  product between  matrix product of the slice
#and the vector

#'@export

'%vxtens%' <- function(vec, tens)
{
    out <-   abind(
                  lapply( 1:dim(tens)[3],
                          function(xi) vec%*% tens[,,xi]
                        ),
                  along =3
                   )

  return( out)
}



#'@title
#'@export

fast_lm <- function(x,y)
{
  be <- solve(crossprod(x),crossprod(x,y))
  resid <-  y - x %*% be
  out <- list(be = be,
              residuals = resid)
  return(out)
}



#' @title transform 3d array into a matrix
#'
#' @description transform 3d array into a matrix where the number of column is equal to the length of the third dimension, code inspired from a comment of  Sven Hohenstein on stack overflow
#'
#' @param array  a 3 way tensor
#' @return a matrix
#'@export

cbind_3Darray <- function(array)
{
  #transform 3d array into a list of matrix then  concatenate each matrix finally bind them


  if(length(dim( array))==3){
    mat <- do.call(cbind, lapply ( lapply(seq(dim(array)[3]), function(x)array[ , , x]),c))
  }else{
    if(length(dim(array))==2){
      mat <- array
    }else{
      stop("Provided array is not a matrix or a 3 way tensor")
    }
  }

  return(mat)
}




#' @Title Check mark type for multfsusie
#' @param Y list of matrices
#' @param min_levres corresponds to the minimum amount of column for a trait to be considered as "functional"
#' @details return of vector indicating what kind of matrices are stored in the different component of Y. USeful for multfSuSiE
is.functional <- function(Y, min_levres =4, data.format="ind_mark"){
  if( data.format=="ind_mark"){
    tt <- unlist((lapply(lapply(Y,dim) ,`[[`, 2)))
    tt2 <- ifelse( tt < 2^min_levres, "univariate", "functional")
    ncond <- sum( ifelse( tt < 2^min_levres, tt, 1))

    out <- list( mark_type = tt2,
                 dim_mark  =  tt,
                 ncond = ncond)
  }
  if(data.format=="list_df"){
    tt2      <- c()
    dim_mark <- c()
    if( !is.null(Y$Y_f)){
      tt2 <- c(tt2,rep( 'functional', length(Y$Y_f)))
      dim_mark <- c(dim_mark, do.call( c,
                                  lapply( 1:length(Y$Y_f),
                                          function(k)
                                            ncol(Y$Y_f[[k]]))
                                  )
                    )
    }
    if( !is.null(Y$Y_u)){
      tt2 <- c(tt2, "univariate")
      dim_mark <- c(dim_mark, ncol(Y$Y_u))
    }
    ncond <- sum( ifelse( dim_mark < 2^min_levres, tt, 1))
    out <- list( mark_type = tt2,
                 dim_mark  =  dim_mark,
                 ncond = ncond)
  }


  attr(out, "class") <- 'multfsusie_data_type'
  return( out)

}

multi_array_colScale <- function(Y, scale=FALSE){

  if( !is.null(Y$Y_u))
  {
    Y$Y_u <- susiF.alpha:::colScale   (Y$Y_u,scale=FALSE)
  }
  if(!is.null(Y$Y_f)){
    Y$Y_f <- lapply( 1:length(Y$Y_f), function(k)  susiF.alpha:::colScale(Y$Y_f[[k]],scale=FALSE) )
  }

 return( Y)
}

