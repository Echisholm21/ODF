% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ODFtoolbox.R, R/read_odf.R
\name{extract_val}
\alias{extract_val}
\alias{extract_val}
\title{extract_val}
\usage{
extract_val(line)

extract_val(line)
}
\arguments{
\item{line}{The line to be split up at an '=' symbol. The left side of the
symbol becomes the key, the right side becomes the value}

\item{line}{The line to be split up at an '=' symbol. The left side of the
symbol becomes the key, the right side becomes the value}
}
\description{
Description:
	Used to split a line into a key and value pair. Leading and trailing spaces
are removed and 00000D+00 strings are replaced with 00000E+00 strings.

Description:
	Used to split a line into a key and value pair. Leading and trailing spaces
are removed and 00000D+00 strings are replaced with 00000E+00 strings.
}
