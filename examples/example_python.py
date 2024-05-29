import json
import csv
import os

# Load in results file
test_file = os.path.normpath("C:/path/to/test_result.csv")
with open(test_file, 'r') as f:
    reader = csv.DictReader(f)
    data = []
    for row in reader:
        data.append(row)

# Remove first 2 rows of Qualtrics jibberish
data = data[2:]

example = json.loads(data[0]['task_tracker'])

#Example Check Point totals
b1_off = sum([item['duration'] for item in example['check_points']['B1Q1'] if item['duration_type']=='off_task'])
b1_on = sum([item['duration'] for item in example['check_points']['B1Q1'] if item['duration_type']=='on_task'])


#Example CSV generation

task_results=[]
for d in data:
    task_tracker = json.loads(d['task_tracker'])
    log = task_tracker['log'][1:]
    total_off = round(sum([item['duration'] for item in log if item['duration_type']=='off_task']),2)
    total_on = round(sum([item['duration'] for item in log if item['duration_type']=='on_task']),2)
    
    row={'id':d['ResponseId'],
        'on_task':total_on,
        'off_task':total_off}

    task_results.append(row)


save_file = os.path.normpath("C:/path/to/task_results_python.csv")
with open(save_file, 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=list(task_results[0].keys()))
    writer.writeheader()
    for row in task_results:
        writer.writerow(row)