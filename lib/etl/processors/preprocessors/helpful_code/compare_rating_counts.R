#find rating counts, need to know date ratings were run and server
library(RMySQL)
library(RMariaDB)

compare_rating_counts <- function(state, rating_type, date, server, test_only=FALSE, growth=TRUE){

  
  #be able to run for multiple ratings at a time
  
  if(length(rating_type)>1){
    for(i in rating_type){
      compare_rating_counts(state, i, date, server)
    }
  }

  
  #pull in ratings from db
  pull_ratings <- function(state, d_type_id, server){
    if(server=='qa'){
      con <- dbConnect(MySQL(),
                       user = 'developer',
                       password = 'devsare2cool',
                       host = paste0(server, '-warehouse.greatschools.org'),
                       dbname = 'omni')
    }
    
    else{
      con <- dbConnect(MySQL(),
                       user = 'developer',
                       password = 'devsare2cool',
                       host = paste0(server, '-gsdata.greatschools.org'),
                       dbname = 'omni') 
    }

    ratings_omni <- dbGetQuery(con, paste0("select * from data_sets as d
                             left join ratings as r
                             on r.data_set_id=d.id
                             left join breakdowns as b
                             on b.id=r.breakdown_id
                             where d.id=(SELECT max(id) FROM data_sets where state='", state, "' and data_type_id in (", d_type_id, "));"))
    # Disconnect from the database
    dbDisconnect(con)
    return(ratings_omni)
  }
  
  if(rating_type=='test'){
    ratings_db <- pull_ratings(state, 155, server)
  }
  
  if(rating_type=='college_readiness'){
    ratings_db <- pull_ratings(state, 156, server)
  }
  
  else if (rating_type=='equity'){
    ratings_db_158 <- pull_ratings(state, 158, server)
    ratings_db_185 <- pull_ratings(state, 185, server)
    ratings_db <- dplyr::bind_rows(ratings_db_158, ratings_db_185)
  }
  
  else if (rating_type=='growth'){
    ratings_db <- pull_ratings(state, 157, server)
  }
  
  else if (rating_type=='growth_proxy'){
    ratings_db <- pull_ratings(state, 159, server)
  }
  
  # else if (rating_type=='summary'){
  #     dtype_list <- c(160, 176, 177, 178, 179, 180, 181, 182, 186)
  #     ratings_db <- data.frame()
  #     for (i in dtype_list){
  #       ratings_db <- dplyr::bind_rows(ratings_db, pull_ratings(state, i, server))
  #     }
  # }
  
  else if (rating_type=='summary'){
    if(growth==TRUE){
      dtype_list <- c(160, 176, 177, 178, 179, 181, 182, 186)
      ratings_db <- data.frame()
      for (i in dtype_list){
        ratings_db <- dplyr::bind_rows(ratings_db, pull_ratings(state, i, server))
      }
    }
    
    if(test_only==TRUE){
      dtype_list <- c(176)
      ratings_db <- data.frame()
      for (i in dtype_list){
        ratings_db <- dplyr::bind_rows(ratings_db, pull_ratings(state, i, server))
      }
    }
    
    else{
      dtype_list <- c(160, 176, 177, 179, 180, 181, 182, 186)
      ratings_db <- data.frame()
      for (i in dtype_list){
        ratings_db <- dplyr::bind_rows(ratings_db, pull_ratings(state, i, server))
      }
    }
  }
  
  #pull in rating file
  read_rating_file <- function(state, rating_type){
    path <- '/Volumes/Public/Data/Data_Operations/Loading/rating_tool_output/rating_files/'
    file_path <- paste0(path, state, '_', rating_type, '_', date, '_rating.csv')
    rating_file <- read_delim(file_path, delim=',', guess_max=100000)
    return(rating_file)
  }
  rating_file <- read_rating_file(state, rating_type) %>% filter(!is.na(rating))
  
  if(test_only==TRUE){
    rating_file <- rating_file %>% filter(data_type_id==155)
  }
  

  if(nrow(rating_file)==nrow(ratings_db)){
    print(paste0('counts line up for ', rating_type, ' in ', state))
  }
  else{
    print(paste0('Counts dont line up! Rating file:', nrow(rating_file), ' DB:', nrow(ratings_db)))
  }


}
