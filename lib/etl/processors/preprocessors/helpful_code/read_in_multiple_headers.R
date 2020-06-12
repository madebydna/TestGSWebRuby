read_in_merged_header <- function(file, sheet=NULL, n_skip=0, n_rows, n_fill=NULL, na_val, name_clean=FALSE) {
 
  proper_headers <- find_column_headers(file=file, sheet=sheet, n_skip=n_skip, n_rows=n_rows, n_fill=n_fill, name_clean=name_clean) 


  #print(paste0('Proper headers are ',list(proper_headers )))
  
  #read in the file 
  
  #want to put in ability to read in with dif delims, csv etc
  
  #read in the actual data with no headers
  total_skip = n_skip + n_rows
  print(paste0('For actual data skipping ', total_skip))
  file_read_in <- read_xlsx(file, sheet=sheet, skip=total_skip, guess_max=100000, na=na_val, col_names=FALSE)
  
  #Specific sheet
  # if(!is.null(sheet)){
  # 
  #   #rows to skip
  #   if(!is.null(n_skip)){
  #     file_read_in <- read_xlsx(file, sheet=sheet, n_skip=n_skip, guess_max=100000, na=na_val, col_names=FALSE)
  #   }
  #   
  #   #sheet but no rows to skip
  #   else{
  #     file_read_in <- read_xlsx(file, sheet=sheet, guess_max=100000, na=na_val, col_names=FALSE)
  #   }
  # }
  # 
  # #no sheet
  # else{
  #   #still rows to skip
  #   if(!is.null(n_skip)){
  #     file_read_in <- read_xlsx(file, n_skip=n_skip, guess_max=100000, na=na_val, col_names=FALSE)
  #   }
  #   #no sheet no rows to skip
  #   else{
  #     file_read_in <- read_xlsx(file, guess_max=100000, na=na_val, col_names=FALSE)
  #   }
  # }

  
  names(file_read_in) = proper_headers
  
  #file_read_in_clean <- file_read_in %>% mutate(filename=str_remove(file, '/Volumes/Public/Data/Data_Operations/Data_Acquisition_Storage/DXT-.*/raw/'))
  
  file_read_in_clean <- file_read_in
  return(file_read_in_clean)
}

