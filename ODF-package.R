#' Ocean Data Format (ODF)

#' Copyright (C) 2006-2014 DFO, Bedford Institute of Oceanography, Canada.
#' You may distribute under the terms of either the GNU General Public
#' License or the Apache v2 License, as specified in the README file.

#' Description:
#'   Package intended to read, write and work with files in the Ocean Data Format (ODF)
#' 
#' @details
#' ODSToolbox Version: 2.0
#'
#' Last Updated: June 17, 2014.
#'
#' Source:
#'   Ocean Data and Information Services,
#'   Bedford Institute of Oceanography, DFO, Canada.
#'   DataServicesDonnees@@dfo-mpo.gc.ca
#'
#' Notes:
#'   This program was totally re-designed and re-written for
#'   ODSToolbox Version 2.0. It is not based on Version 1.0.
#'   In addition the package, classes, methods and functions,
#'   originally written for Matlab were, re-written again to 
#'   be used in R.
#'
#'   While this new version of read_odf corrects many errors in
#'   Version 1.0, and includes some new functionalities such as
#'   checking if all mandatory header blocks and all mandatory
#'   fields are presented in the input ODF file etc., it is possible
#'   that this program may have some conflicts with other tools in
#'   ODSToolbox, please email yongcun.hu@@dfo-mpo.gc.ca if the
#'   user find any problems.
#'
#' See also \code{\link{read_odf}}, \code{\link{write_odf}}.
#'
#' @docType package
#' @author Yongcun Hu, Patrick Upson
#' @name ODF
#'
NULL