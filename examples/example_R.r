library(jsonlite)

df <- read.csv('C:\\path\\to\\test_result.csv')

#drop Qualtrics jibberish header rows
df <- df[3:nrow(df),]

example <- fromJSON(df[1,'task_tracker'])

on_task <- sum(example$log[which(example$log[,"duration_type"]=="on_task"),"duration"])
off_task <- sum(example$log[which(example$log[,"duration_type"]=="off_task"),"duration"])

on_task
off_task

new_df <- data.frame()
for (i in 1:nrow(df)){
  task_tracker <- fromJSON(df[1,'task_tracker'])
  log <- task_tracker$log
  on_task <- sum(log[which(log[,"duration_type"]=="on_task"),"duration"])
  off_task <- sum(log[which(log[,"duration_type"]=="off_task"),"duration"])
  
  new_df[i,] = list(df[i,"ResponseId"],on_task, off_task)
}
new_df
write.csv(new_df,"D:\\path\\to\\task_results_r.csv",quote=FALSE)
