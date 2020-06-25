find_column_headers <- function(file, sheet=NULL, n_skip=0, n_rows, n_fill=NULL, name_clean=FALSE) {

  
  #read in all headers
  headers <- read_xlsx(file, sheet=sheet, skip=n_skip, n_max=n_rows, col_names=FALSE)

  
  #fill headers as specified by n_fill, default NULL
  if(!is.null(n_fill)) {
    
    headers_filled <- tibble()
    
    for(i in 1:n_fill){
      fill <- as_tibble(zoo::na.locf(c(headers[i,]), na.rm=FALSE))
      
      
      headers_filled <- bind_rows(headers_filled, fill)

    }
    
    #bind back filled rows with rows that didnt need to be filled
    headers_filled_tibble <- bind_rows(headers_filled, headers[-c(1:n_fill),])
  
  }
  
  #no filling necessary
  else {
    headers_filled_tibble <- as_tibble(headers)
  }
  
  #join together tibble rows (separate headers) with _
  joined_headers <- headers_filled_tibble[1,]
  for(i in 1:(n_rows-1)){
    
    joined_headers <- paste0(joined_headers, '_', headers_filled_tibble[i+1,])
    
  }
  
  
  if(any(str_detect(joined_headers, 'NA'))) {
    headers_cleaned <- joined_headers %>% str_remove('_NA') %>% 
      str_remove('NA_')
  
  }
  else{
    headers_cleaned <- joined_headers
  }
  
  #clean names if requested, using janitor make_clean_names
  if(name_clean==TRUE){
    headers_cleaned <- janitor::make_clean_names(headers_cleaned)
  }
  else{}
  
  return(headers_cleaned)
}

