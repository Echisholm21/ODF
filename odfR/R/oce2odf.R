


#'oce2odfHeader
#'
#'creates ODF standard header from metadata within an oce object to be copied and replicated in ODF files
#'object can subsequently be used in function `oce2odf`
#'
#'returns empty odf object with header metadata filled out
#'
#' @param obj oce object
#' @export
#'
#'
#' @examples
#' obj[['event_comments']]
#' obj[['description']]


oce2odfHeader <- function(obj){

  b <- gen_odfstruct()

  if (inherits(obj) == 'adp'){
    # for ( d in 1:length(obj[['distance']])){
    # b$ODF_HEADER$FILE_SPECIFICATION <- paste('MADCPS', '_', obj[['cruise_number']], '_', obj[['mooring_number']], '_', obj[['serial_number']] , '-', obj[['sensor_depth']] - obj[['distance']][[d]], '.ODF', sep = '')
    # }
    b$CRUISE_HEADER$COUNTRY_INSTITUTE_CODE <- obj[['country_code']]
    b$CRUISE_HEADER$CRUISE_NUMBER <- obj[['cruise_number']]
    b$CRUISE_HEADER$ORGANIZATION <- obj[['organization']]
    b$CRUISE_HEADER$CHIEF_SCIENTIST <- obj[['chief_scientist']]
    b$CRUISE_HEADER$START_DATE <- obj[['time_coverage_start']]
    b$CRUISE_HEADER$END_DATE <- obj[['time_coverage_end']]
    b$CRUISE_HEADER$PLATFORM <- obj[['platform']]
    b$CRUISE_HEADER$CRUISE_NAME <- obj[['cruise_name']]
    b$CRUISE_HEADER$CRUISE_DESCRIPTION <- obj[['cruise_description']]


    b$EVENT_HEADER$DATA_TYPE <- obj[['data_type']]
    b$EVENT_HEADER$EVENT_NUMBER <- obj[['mooring_number']]
    b$EVENT_HEADER$EVENT_QUALIFIER1 <- ''
    b$EVENT_HEADER$EVENT_QUALIFIER2 <- ''
    b$EVENT_HEADER$CREATION_DATE <- Sys.Date()
    b$EVENT_HEADER$ORIG_CREATION_DATE <- obj[['date_created']]
    b$EVENT_HEADER$START_DATE_TIME <- obj[['time_coverage_start']]
    b$EVENT_HEADER$END_DATE_TIME <- obj[['time_coverage_end']]
    b$EVENT_HEADER$INITIAL_LATITUDE <- obj[['latitude']]
    b$EVENT_HEADER$INITIAL_LONGITUDE <- obj[['longitude']]
    b$EVENT_HEADER$END_LATITUDE <- obj[['latitude']]
    b$EVENT_HEADER$END_LONGITUDE <- obj[['longitude']]
    b$EVENT_HEADER$MIN_DEPTH <- min(obj[['depth']])     #CAUTION THESE ARE ONLY PLACEHOLDERS, EACH FILE SHOULD HAVE
    b$EVENT_HEADER$MAX_DEPTH <- max(obj[['depth']])     #THESE VALUES REPLACED BY BIN DEPTH IN THE OCE2ODF FUNCTION
    b$EVENT_HEADER$SAMPLING_INTERVAL <- obj[['sampling_interval']]
    b$EVENT_HEADER$SOUNDING <- obj[['sounding']]
    b$EVENT_HEADER$DEPTH_OFF_BOTTOM  <- max(obj[['depth']]) - obj[['depthMean']]
    b$EVENT_HEADER$EVENT_COMMENTS <- obj[['event_comments']]


    b$INSTRUMENT_HEADER$INST_TYPE <- obj[['instrumentType']]
    b$INSTRUMENT_HEADER$MODEL <- obj[['model']]
    b$INSTRUMENT_HEADER$SERIAL_NUMBER <- obj[['serialNumber']]
    b$INSTRUMENT_HEADER$DESCRIPTION <- obj[['description']]

    return(b)



  }
}
#'
#'convert oce object to ODF
#'
#'Currently fully functioning for ADCP data
#'Accepts an oce class object (adp) and converts into a series of ODF files to
#'be exported
#'
#'Can also accept other moored instruments and convert from oce objects to odf
#' including mctd, mtr and mcm
#'

#'
#' @author E. Chisholm
#'Version 1.0
#'
#' @param obj oce object for data to be copied to odf
#' @param write whether or not to write out all the odf files produced, default
#'   is TRUE, if false please use binExport to select the bins for which you
#'   would like to produce ODFs
#' @param inst_code instrument code acronym for file name
#'
#'@details 
#' In order to function requires certain metadata items
#' * depthMean
#' * time_coverage_start
#' * time_coverage_end
#' * depthMin
#' * depthMax
#' * event_comments
#' * serialNumber
#' * mooring_number
#' * cruise_number
#' 
#' Examples of instrument codes: MADCPS (Moored ADCP), MCTD (moored CTD), MTR
#' (Moored temperature recorder), MCM (moored current meter)
#'
#'
#' @export



oce2odf <- function(obj, write = TRUE, inst_code =NULL){
  #identify type of oce object
  if (inherits(obj, what = 'adp') ){
    #file names
    names <- list()
    for( d in 1:length(obj[['distance']] )){
      #caUTION: oce uses snake case, ADCP process uses '_'
      names[[d]] <- paste('MADCPS', '_', obj[['cruise_number']], '_', obj[['mooring_number']], '_', obj[['serialNumber']] , '-',  round(obj[['distance']][[d]], digits = 0), '.ODF', sep = '')

    }
    #name variables to export to ODF
    params <- list('u', 'v', 'w', 'errv', 'pgd', 'agc')

    u <- obj[['v']][,,1]
    v <- obj[['v']][,,2]
    w <- obj[['v']][,,3]
    errv <- obj[['v']][,,4]
    pgd <- obj[['g', 'numeric']][,,4]
    agc <- apply(X = obj[['a', 'numeric']], MARGIN = 1:2, FUN = mean, na.rm = TRUE)
   #handle time separately
     sytm <- obj[['time']]

    #work on add_parameter to make easier
    #split each data variable into single depth time series

      #add each section of data as parameter in loop of odf files by depths

      #creates data array which matches dimensions of variables,
    b <- NULL
      for (d in 1: length(obj[['distance']])){
        b[[d]] <- gen_odfstruct()
        b[[d]]$DATA <- matrix(NA,  nrow = length(adp[['time']]),  ncol = length(params))
      }

     for (i in 1:length(params)){
        for( d in 1: length(obj[['distance']])){
            eval(parse(text = paste0("b[[d]]$DATA[,i] <- ", params[[i]], "[,d] ")))

          }
        }


    #handle time separately
    for (d in 1:length(obj[['distance']])){
      for(p in params)
      as.data.frame(b[[d]]$DATA)

      colnames(b[[d]]$DATA)<- list('EWCT_01', 'NSCT_01','VCSP_01', 'ERRV_01', 'PGDP_01', 'BEAM_01')
    }
    if (!is.null(obj[['time']])){
      SYTM_01 <- as.character(as.POSIXct(obj[['time']], origin = '1970-01-01 00:00:00'))
    for (d in 1:length(obj[['distance']])){
  b[[d]]$DATA <- cbind.data.frame(b[[d]]$DATA, SYTM_01)
    }
    }

    gf3 <- list()
    for( p in params){
      gf3[[p]] <- as.gf3(p)
    }
    for ( d in 1:length(obj[['distance']])){

      length(b[[d]]$PARAMETER_HEADER) <- length(b[[d]]$PARAMETER_HEADER) + length(params)
      for (i in 1:length(params)){
      b[[d]]$PARAMETER_HEADER[[i]] <- list(
        TYPE = 'SING',
        NAME = gf3[[params[[i]]]]$def,
        UNITS = gf3[[i]]$units,
        CODE = paste(gf3[[i]]$code , '01', sep = '_'),
        NULL_VALUE = '-1000000',
        PRINT_FIELD_WIDTH = as.character(gf3[[i]]$width),
        PRINT_DECIMAL_PLACES = as.character(gf3[[i]]$prec),
        ANGLE_OF_SECTION = '-1000000',
        MAGNETIC_VARIATION = '-1000000',
        DEPTH = round(obj[['depthMean']] - obj[['distance']][[d]], digits = 0),
        MINIMUM_VALUE = as.character(eval(parse(text = paste0("min(", params[[i]], ", na.rm = TRUE)")))),
        MAXIMUM_VALUE = as.character(eval(parse(text = paste0("max(", params[[i]], ", na.rm = TRUE)")))),
        NUMBER_VALID = as.character(eval(parse(text = paste0("length(na.omit(", params[[i]], "[,1]))")))),
        NUMBER_NULL = as.character(eval(parse(text = paste0("length(", params[[i]], "[,1]) - length(na.omit(" ,params[[i]], "[,1]))"))))
      )
      }
      if ( !is.null(obj[['time']])){
        s <- as.gf3('sytm')
      length(b[[d]]$PARAMETER_HEADER) <- length(b[[d]]$PARAMETER_HEADER) + 1
      i <- length(b[[d]]$PARAMETER_HEADER)
      b[[d]]$PARAMETER_HEADER[[i]] <- list(
        TYPE = 'SYTM',
        NAME = s$def,
        UNITS = s$units,
        CODE =  'SYTM_01',
        NULL_VALUE = '-99',
        PRINT_FIELD_WIDTH = s$width,
        PRINT_DECIMAL_PLACES = s$prec,
        ANGLE_OF_SECTION = '-99',
        MAGNETIC_VARIATION = '-99',
        DEPTH = '0',
        MINIMUM_VALUE = toupper(strftime(min(as.character(SYTM_01), na.rm = TRUE),format='%d-%b-%Y %T.00',tz="UTC")),
        MAXIMUM_VALUE = toupper(strftime(max(as.character(SYTM_01), na.rm = TRUE),format='%d-%b-%Y %T.00',tz="UTC")),
        NUMBER_VALID = length(na.omit(SYTM_01)),
        NUMBER_NULL = length(SYTM_01) - length(na.omit(SYTM_01))
      )
      }
    }



      #parameter header, polynomial cal header (optional), compass cal header
      #FIXME: adds to history header with each action like oce processing log

      #add header block to each odf file (standard, same for each file)

      for( d in 1:length(obj[['distance']])){

        #ODF HEADER
        b[[d]]$ODF_HEADER$FILE_SPECIFICATION <- paste('MADCPS', '_', obj[['cruise_number']], '_', obj[['mooring_number']], '_', obj[['serialNumber']] , '-', (round(obj[['depthMean']] - obj[['distance']][[d]], digits = 0)), sep = '')

        #CRUISE HEADER
        b[[d]]$CRUISE_HEADER$COUNTRY_INSTITUTE_CODE <- obj[['country_code']]
        b[[d]]$CRUISE_HEADER$CRUISE_NUMBER <- obj[['cruise_number']]
        b[[d]]$CRUISE_HEADER$ORGANIZATION <- obj[['organization']]
        b[[d]]$CRUISE_HEADER$CHIEF_SCIENTIST <- obj[['chief_scientist']]
        b[[d]]$CRUISE_HEADER$START_DATE <- toupper(strftime(obj[['time_coverage_start']],format='%d-%b-%Y %T.00',tz="UTC"))
        b[[d]]$CRUISE_HEADER$END_DATE <- toupper(strftime(obj[['time_coverage_end']],format='%d-%b-%Y %T.00',tz="UTC"))
        b[[d]]$CRUISE_HEADER$PLATFORM <- obj[['platform']]
        b[[d]]$CRUISE_HEADER$CRUISE_NAME <- obj[['cruise_name']]
        b[[d]]$CRUISE_HEADER$CRUISE_DESCRIPTION <- obj[['cruise_description']]


        b[[d]]$EVENT_HEADER$DATA_TYPE <- obj[['data_type']]
        b[[d]]$EVENT_HEADER$EVENT_NUMBER <- obj[['mooring_number']]
        b[[d]]$EVENT_HEADER$EVENT_QUALIFIER1 <- paste(obj[['serialNumber']],'-',round(obj[['depthMean']] - obj[['distance']][[d]], digits = 0) )
        b[[d]]$EVENT_HEADER$EVENT_QUALIFIER2 <- obj[['sampling_interval']]
        b[[d]]$EVENT_HEADER$CREATION_DATE <- Sys.Date()
        b[[d]]$EVENT_HEADER$ORIG_CREATION_DATE <- toupper(strftime(Sys.Date(),format='%d-%b-%Y %T.00',tz="UTC"))
        b[[d]]$EVENT_HEADER$START_DATE_TIME <- toupper(strftime(obj[['time_coverage_start']],format='%d-%b-%Y %T.00',tz="UTC"))
        b[[d]]$EVENT_HEADER$END_DATE_TIME <- toupper(strftime(obj[['time_coverage_end']],format='%d-%b-%Y %T.00',tz="UTC"))
        b[[d]]$EVENT_HEADER$INITIAL_LATITUDE <- obj[['latitude']]
        b[[d]]$EVENT_HEADER$INITIAL_LONGITUDE <- obj[['longitude']]
        b[[d]]$EVENT_HEADER$END_LATITUDE <- obj[['latitude']]
        b[[d]]$EVENT_HEADER$END_LONGITUDE <- obj[['longitude']]
        b[[d]]$EVENT_HEADER$MIN_DEPTH <- round(obj[['distance']][d] , digits = 0)
        b[[d]]$EVENT_HEADER$MAX_DEPTH <- round(obj[['distance']][d] , digits = 0)
        b[[d]]$EVENT_HEADER$SAMPLING_INTERVAL <- obj[['sampling_interval']]
        b[[d]]$EVENT_HEADER$SOUNDING <- obj[['sounding']]
        b[[d]]$EVENT_HEADER$DEPTH_OFF_BOTTOM  <- as.numeric(obj[['sounding']]) - obj[['distance']][d]
        b[[d]]$EVENT_HEADER$EVENT_COMMENTS <- paste(as.character(Sys.Date() , obj[['event_comments']]))

        # INSTRUMENT_HEADER

        b[[d]]$INSTRUMENT_HEADER$INST_TYPE <-'ADCP'
        b[[d]]$INSTRUMENT_HEADER$MODEL <- obj[['model']]
        b[[d]]$INSTRUMENT_HEADER$SERIAL_NUMBER <- obj[['serialNumber']]
        b[[d]]$INSTRUMENT_HEADER$DESCRIPTION <- obj[['description']]

        # RECORD_HEADER

        b[[d]]$RECORD_HEADER$NUM_CYCLE <- length(obj[['time']])
        b[[d]]$RECORD_HEADER$NUM_PARAM <- length(params) +1

      #delete null headers
  b[[d]]$POLYNOMIAL_CAL_HEADER <- NULL
  b[[d]]$COMPASS_CAL_HEADER <- NULL
  b[[d]]$RECORD_HEADER$NUM_CALIBRATION <- NULL
  b[[d]]$RECORD_HEADER$NUM_SWING <- NULL
      }


    save(b, file = paste0('MADCPS_', obj[['cruise_number']],'_',  obj[['mooring_number']], '_', obj[['sampling_interval']], '.Rd', sep = ''))


      #write odf sturctures to odf files
  #doesn't work --- line formatting issue, not skipping to new line
    if (write == TRUE){

    for(d in 1:length(obj[['distance']])){
    write_odf( b[[d]],   output_file =paste0(b[[d]]$ODF_HEADER$FILE_SPECIFICATION, '.ODF'))
      print(paste0("Bin", d,"of", length(obj[['distance']]),  "completed", sep = " "))
    }

    } else{
      return(b)

    }
  }


  if (!inherits(obj, what = 'adp') ){

    params <- names(obj@data)
    
    #remove time to handle separately
    
    t <- grep(params, pattern = "time")
    params <- params[-t]
    
    
    
    
    #creates data array which matches dimensions of variables,
    b <- NULL
    
    b <- gen_odfstruct()

    b$DATA <- matrix(NA,  nrow = length(obj[['time']]),  ncol = length(params))

    
    
    for (i in 1:length(params)){
      
      eval(parse(text = paste0("b$DATA[,i] <- obj@data$", params[[i]])))
      
      
    }
    
    
    #handle time separately
    
    
    b$DATA <- as.data.frame(b$DATA)
    
    gf3 <- list()
    for (i in 1:length(params)){
      gf3[[i]] <- as.gf3(params[[i]])
    }
    

    gfnames <- list()
    for (i in 1:length(params)){
      gfnames[[i]] <- gf3[[i]][['code']]
    }
   
    colnames(b$DATA)<- gfnames
    
    #timecheck
    
    if (!is.null(obj[['time']])){
      SYTM_01 <- as.character(as.POSIXct(obj@data[['time']], origin = '1970-01-01 00:00:00'))
      
        b$DATA <- cbind.data.frame(b$DATA, SYTM_01)
      
    
    }
    
    
    
    
    
     
      length(b$PARAMETER_HEADER) <- length(b$PARAMETER_HEADER) + length(params)
      for (i in 1:length(params)){
        b$PARAMETER_HEADER[[i]] <- list(
          TYPE = 'SING',
          NAME = gf3[[i]]$def,
          UNITS = gf3[[i]]$units,
          CODE = paste(gf3[[i]]$code , '01', sep = '_'),
          NULL_VALUE = '-1000000',
          PRINT_FIELD_WIDTH = as.character(gf3[[i]]$width),
          PRINT_DECIMAL_PLACES = as.character(gf3[[i]]$prec),
          ANGLE_OF_SECTION = '-1000000',
          MAGNETIC_VARIATION = '-1000000',
          DEPTH = round(obj[['depthMean']], digits = 0),
          MINIMUM_VALUE = as.character(eval(parse(text = paste0("min(obj@data[['", params[[i]], "']], na.rm = TRUE)")))),
          MAXIMUM_VALUE = as.character(eval(parse(text = paste0("max(obj@data[['", params[[i]], "']], na.rm = TRUE)")))),
          NUMBER_VALID = as.character(eval(parse(text = paste0("length(na.omit(obj@data[['", params[[i]], "']]))")))),
          NUMBER_NULL = as.character(eval(parse(text = paste0("length(obj@data[['", params[[i]], "']]) - length(na.omit(obj@data[['" ,params[[i]], "']]))"))))
        )
      }
      if ( !is.null(obj[['time']])){
        s <- as.gf3('sytm')
        length(b$PARAMETER_HEADER) <- length(b$PARAMETER_HEADER) + 1
        i <- length(b$PARAMETER_HEADER)
        b$PARAMETER_HEADER[[i]] <- list(
          TYPE = 'SYTM',
          NAME = s$def,
          UNITS = s$units,
          CODE =  'SYTM_01',
          NULL_VALUE = '-99',
          PRINT_FIELD_WIDTH = s$width,
          PRINT_DECIMAL_PLACES = s$prec,
          ANGLE_OF_SECTION = '-99',
          MAGNETIC_VARIATION = '-99',
          DEPTH = '0',
          MINIMUM_VALUE = toupper(strftime(min(as.character(SYTM_01), na.rm = TRUE),format='%d-%b-%Y %T.00',tz="UTC")),
          MAXIMUM_VALUE = toupper(strftime(max(as.character(SYTM_01), na.rm = TRUE),format='%d-%b-%Y %T.00',tz="UTC")),
          NUMBER_VALID = length(na.omit(SYTM_01)),
          NUMBER_NULL = length(SYTM_01) - length(na.omit(SYTM_01))
        )
      }
    
    
    
    
    #parameter header, polynomial cal header (optional), compass cal header
    #FIXME: adds to history header with each action like oce processing log
    
    if (is.null(inst_code)){
      warning("Please provide instrument code for file naming!")
    }
  
      #ODF HEADER
      b$ODF_HEADER$FILE_SPECIFICATION <- paste(inst_code, '_', obj[['cruise_number']], '_', obj[['mooring_number']], '_', obj[['serialNumber']] ,  sep = '')
      
      #CRUISE HEADER
      b$CRUISE_HEADER$COUNTRY_INSTITUTE_CODE <- obj[['country_code']]
      b$CRUISE_HEADER$CRUISE_NUMBER <- obj[['cruise_number']]
      b$CRUISE_HEADER$ORGANIZATION <- obj[['organization']]
      b$CRUISE_HEADER$CHIEF_SCIENTIST <- obj[['chief_scientist']]
      b$CRUISE_HEADER$START_DATE <- toupper(strftime(obj[['time_coverage_start']],format='%d-%b-%Y %T.00',tz="UTC"))
      b$CRUISE_HEADER$END_DATE <- toupper(strftime(obj[['time_coverage_end']],format='%d-%b-%Y %T.00',tz="UTC"))
      b$CRUISE_HEADER$PLATFORM <- obj[['platform']]
      b$CRUISE_HEADER$CRUISE_NAME <- obj[['cruise_name']]
      b$CRUISE_HEADER$CRUISE_DESCRIPTION <- obj[['cruise_description']]
      
      
      b$EVENT_HEADER$DATA_TYPE <- obj[['data_type']]
      b$EVENT_HEADER$EVENT_NUMBER <- obj[['mooring_number']]
      b$EVENT_HEADER$EVENT_QUALIFIER1 <- obj[['serialNumber']] 
      b$EVENT_HEADER$EVENT_QUALIFIER2 <- obj[['sampling_interval']]
      b$EVENT_HEADER$CREATION_DATE <- Sys.Date()
      b$EVENT_HEADER$ORIG_CREATION_DATE <- toupper(strftime(Sys.Date(),format='%d-%b-%Y %T.00',tz="UTC"))
      b$EVENT_HEADER$START_DATE_TIME <- toupper(strftime(obj[['time_coverage_start']],format='%d-%b-%Y %T.00',tz="UTC"))
      b$EVENT_HEADER$END_DATE_TIME <- toupper(strftime(obj[['time_coverage_end']],format='%d-%b-%Y %T.00',tz="UTC"))
      b$EVENT_HEADER$INITIAL_LATITUDE <- obj[['latitude']]
      b$EVENT_HEADER$INITIAL_LONGITUDE <- obj[['longitude']]
      b$EVENT_HEADER$END_LATITUDE <- obj[['latitude']]
      b$EVENT_HEADER$END_LONGITUDE <- obj[['longitude']]
      b$EVENT_HEADER$MIN_DEPTH <- obj[['depthMin']] 
      b$EVENT_HEADER$MAX_DEPTH <- obj[['depthMax']]
      b$EVENT_HEADER$SAMPLING_INTERVAL <- obj[['sampling_interval']]
      b$EVENT_HEADER$SOUNDING <- obj[['sounding']]
      b$EVENT_HEADER$DEPTH_OFF_BOTTOM  <- as.numeric(obj[['sounding']]) - obj[['depthMin']]
      b$EVENT_HEADER$EVENT_COMMENTS <- paste(as.character(Sys.Date() , obj[['event_comments']]))
      
      # INSTRUMENT_HEADER
      
      b$INSTRUMENT_HEADER$INST_TYPE <- inst_code
      b$INSTRUMENT_HEADER$MODEL <- obj[['model']]
      b$INSTRUMENT_HEADER$SERIAL_NUMBER <- obj[['serialNumber']]
      b$INSTRUMENT_HEADER$DESCRIPTION <- obj[['description']]
      
      # RECORD_HEADER
      
      b$RECORD_HEADER$NUM_CYCLE <- length(obj[['time']])
      b$RECORD_HEADER$NUM_PARAM <- length(params) +1
      
      #delete null headers
      b$POLYNOMIAL_CAL_HEADER <- NULL
      b$COMPASS_CAL_HEADER <- NULL
      b$RECORD_HEADER$NUM_CALIBRATION <- NULL
      b$RECORD_HEADER$NUM_SWING <- NULL
    
    
    
    save(b, file = paste0(inst_code, "_", obj[['cruise_number']],'_',  obj[['mooring_number']], '_', obj[['sampling_interval']], '.Rd', sep = ''))
    
    
    #write odf sturctures to odf files
    
    if (write == TRUE){
      
      
      write_odf( b,   output_file =paste0(b$ODF_HEADER$FILE_SPECIFICATION, '.ODF'))
      
      
    } else{
      return(b)
      
    }
  }
  
  
}




####ODF select bin export####


#' Select bin export
#'
#'Select particular ADCP bins to be exported to ODF files
#'
#'
#' @param obj an ODF structure object with multiple depth bins (produced from oce2odf)
#' @param bins the bin numbers you wish to export
#'
#'
#' @export
#'
#' @examples
#'
#' # oce2odf(adp, write = FALSE)
#' # bins <- list(12:34)
#' # binExport(obj = b, bins)
#'
binExport <- function(obj, bins){


  for(l in bins){
    write_odf( obj[[l]],   output_file =paste0(obj[[l]]$ODF_HEADER$FILE_SPECIFICATION))

  }
}


####add parameter####

#' Add parameter
#'
#' add a parameter to an existing ODF structure array (b)
#'reads in variable, add a parameter header, cal header and column to the data portion of the ODF
#'
#'parameter header has: type, name, units, code, null_value, print_field_width,
#'print_decimal_places, angle_of_Section magnetic_Variation, depth,
#'minimum_value, maximum_value, number_valid, number_null
#'
#'polynomial_cal_header has, parameter_name, calibration_date, application_date,
#'number_coefficients, coefficients
#'
#'
#'data columns should be added in order of parameter headers
#'
#' @param b odf structure
#' @param obj oce/ odf (?) object to  pull data and metadata from
#' @param VARNAME name of parameter (in object data is being pulled from)
#' @param cal TRUE/ FALSE whether or not to produce a polynomial cal header for same parameter code
#'
#'
#' @export
#'
#' @examples
#'
#'
#' b <- gen_odfstruct()
#' obj <- read.oce('MCTD****.ODF')
#'
#' b <- add_parameter(b, obj, VARNAME = 'salinity', cal = TRUE)
#'


add_parameter <- function(b, data, VARNAME, cal = FALSE){

  gf3 <- as.gf3(VARNAME)


  length(b$PARAMETER_HEADER) <- length(b$PARAMETER_HEADER) +1

  params <- list()
  for (i in length(b$PARAMETR_HEADER)){
    params[[i]] <- b$PARAMETER_HEADER$CODE
  }
  if (gf3 %in% params){
    gf3$code <- paste(gf3$code, '02', sep = '_')
  } else{
    gf3$code <- paste(gf3$code, '01', sep = '_')
  }

  i <- length(b$PARAMETER_HEADER)
  b$PARAMETER_HEADER[[i]] <-
    list(
      TYPE = 'SING',
      NAME = VARNAME,
      UNITS = gf3$units,
      CODE = gf3$code ,
      NULL_VALUE = '-99',
      PRINT_FIELD_WDITH = gf3$width,
      PRINT_DECIMAL_PLACES = gf3$prec,
      ANGLE_OF_SECTION = '',
      MAGNETIC_VARIATION = '',
      DEPTH = '',
      MINIMUM_VALUE = min(data, na.rm = TRUE),
      MAXIMUM_VALUE = max(data, na.rm = TRUE),
      NUMBER_VALID = '',
      NUMBER_NULL = ''
    )




  if (cal == TRUE){
    length(b$POLYNOMIAL_CAL_HEADER) <- length(b$POLYNOMIAL_CAL_HEADER) +1
    i <- length(b$POLYNOMIAL_CAL_HEADER)

    b$POLYNOMIAL_CAL_HEADER[[i]] <-
      list(
        PARAMETER_NAME = VARNAME,
        CALIBRATION_DATE = '',
        APPLICATION_DATE = '',
        NUMBER_COEFFICIENTS = '',
        COEFFICIENTS = ''
      )

  }


  if (is.null(dim(b$DATA))){
    b$DATA <- matrix(dim = dim(data))
    b$DATA <-  as.matrix(data)
  } else {
    b$DATA <- cbind(b$DATA, data)
  }
  i <- length(b$DATA[1,])

  colnames(b$DATA[[i]]) <- gf3$code

  b$DATA <- as.data.frame(b$DATA)

  return(b)
}


####as GF3####
#' Translate to GF3 codes
#'
#' @param VARNAME the common name for known variables or the GF3 param code if known
#'
#' @return list with GF3 code, def, width, prec and units
#' @export
#'
#'
as.gf3 <- function(VARNAME){

  load("R/gf3defs.RData")


  if (!( VARNAME %in% gf3defs$CODE)){

    if (VARNAME == 'u'){
      codevar <- 'EWCT'
    }
    if (VARNAME == 'v'){
      codevar <- 'NSCT'
    }
    if (VARNAME == 'w'){
      codevar <- 'VCSP'
    }
    if (VARNAME == 'errv'){
      codevar <- 'ERRV'
    }
    if (VARNAME == 'pgd'){
      codevar <- 'PGDP'
    }
    if (VARNAME == 'agc'){
      codevar <- 'BEAM'
    }
    if (VARNAME == 'sytm'){
      codevar <- 'SYTM'
    }
    if (VARNAME == 'salinity'){
      codevar <- 'PSAL'
    }
    if (VARNAME == 'temperature'){
      codevar <- 'TEMP'
    }
    if (VARNAME == 'sigmaTheta'){
      codevar <- 'SIGP'
    }
    if (VARNAME == 'theta'){
      codevar <- 'POTM'
    }
    if (VARNAME == 'density'){
      codevar <- 'DENS'
    }
    if (VARNAME == 'oxygen'){
      codevar <- 'DOXY'
    }
    if (VARNAME == 'oxygenVoltage'){
      codevar <- 'OXYV'
    }
    if (VARNAME == 'pressure'){
      codevar <- 'PRES'
    }
    if (VARNAME == 'scan'){
      codevar <- 'CNTR'
    }
    if (VARNAME == 'depth'){
      codevar <- 'DEPH'
    }
    if (VARNAME == 'flag'){
      codevar <- 'FFFF'
    }
    if (VARNAME == 'conductivity'){
      codevar <- 'CNDC'
    }
  }
  if (VARNAME %in% gf3defs$GF3_CODE){
    codevar <- VARNAME
  }
  if (is.null(codevar)){
    warning(paste("Could not find variable code for", VARNAME))
    stop()
  }

  #add more oce to gf3 code translations
  #eg for ctd, cm, tr, etc
  loc <- gf3defs$GF3_CODE == codevar
  VARNAME <- list(
    code = gf3defs$GF3_CODE[loc],
    def = gf3defs$GF3_DEFINITION[loc],
    units = gf3defs$UNITS[loc],
    width = gf3defs$WIDTH[loc],
    prec = gf3defs$PRECISION[loc]
  )
  return(VARNAME)
}





