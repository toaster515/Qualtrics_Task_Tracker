library(jsonlite)

df <- read.csv('C:\\path\\to\\test_result.csv')

#drop Qualtrics jibberish header rows
df <- df[3:nrow(df),]

example <- fromJSON(df[1,'task_tracker'])

on_task <- sum(example$log[which(example$log[,"duration_type"]=="on_task"),"duration"])
off_task <- sum(example$log[which(example$log[,"duration_type"]=="off_task"),"duration"])

print(on_task)
print(off_task)

check_points <- example[['check_points']]

keys <-unlist(names(check_points))
for (k in keys){
  check_point_on <- sum(check_points[[k]][which(check_points[[k]][,"duration_type"]=="on_task"),"duration"])
  check_point_off <- sum(check_points[[k]][which(check_points[[k]][,"duration_type"]=="off_task"),"duration"])
  print(paste(k, check_point_on, check_point_off, sep=" "))
}

new_df <- data.frame()
for (i in 1:nrow(df)){
  task_tracker <- fromJSON(df[1,'task_tracker'])
  
  #Total On and Off task
  log <- task_tracker$log
  on_task <- sum(log[which(log[,"duration_type"]=="on_task"),"duration"])
  off_task <- sum(log[which(log[,"duration_type"]=="off_task"),"duration"])
  new_df[i,] = list(df[i,"ResponseId"],on_task, off_task)
  
  #On and Off task for each check point
  check_points <- task_tracker[['check_points']]
  keys <- unlist(names(check_points))
  for (k in keys){
    new_df[i,paste0(k,"_on_task")] <- sum(check_points[[k]][which(check_points[[k]][,"duration_type"]=="on_task"),"duration"])
    new_df[i,paste0(k,"_off_task")] <- sum(check_points[[k]][which(check_points[[k]][,"duration_type"]=="off_task"),"duration"])
  }
}
new_df
write.csv(new_df,"D:\\path\\to\\task_results_r.csv",quote=FALSE)
