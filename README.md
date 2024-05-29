## About

This project demonstrates how to integrate custom JavaScript with Qualtrics to monitor user activity and track task engagement. The script detects whether a participant has left or entered the browser window and records these events in real-time. All captured data is stored within a JSON object and saved as an embedded variable within the Qualtrics platform.

## Key Features

- **Browser Activity Tracking**: Monitors if a participant navigates away from or returns to the survey window.
- **Real-time Data Recording**: Logs entry and exit events as they occur.
- **JSON Data Storage**: Collects and structures data in a JSON format for easy analysis.
- **Qualtrics Integration**: Utilizes embedded variables to store the JSON object directly within Qualtrics.

## How It Works

- **JavaScript Integration**: The custom JavaScript code is added to the Qualtrics survey.
- **Event Listeners**: The script sets up event listeners to detect when the survey window is active or inactive.
- **Data Logging**: Each event (entry/exit) is logged with a timestamp and other metadata information in a JSON object.
- **Embedding Data**: The JSON object is saved in a convenient single embedded variable within Qualtrics which can then be used for further analysis.

This project serves as a practical way for enhancing survey data collection by tracking participant engagement and providing additional insights into survey-taking behavior.

---
## Implementation

In Qualtrics
- Navigate to the Look and feel section of your Qualtrics project
- Under General, copy and paste the `header.html` file contents into the code section of the header.

![[screenshot_1.png]]

- Ensure there is an Embedded Data variable named `task_tracker` like the image below:
![[screenshot_2.png]]

And that's it! Everything will be stored as a string JSON variable within this singular variable to make things convenient.

**Optionally**, you can also include checkpoints by adding a `check_point` Embedded Data variable, which will add separate updates to a `check_points` array stored within the `task_tracker` object.
![[screenshot_3.png]]

The checkpoints will be stored as keys, each containing their own array of tracking. Updates will be added continuously to whatever the active value within the `check_point` variable is. You can set the checkpoint via the Survey flow editor like the above image, or within a specific block by adjusting the Javascript like so:

![[screenshot_4.png]]

---
### Functionality, Use and Interpretation

The JSON is stored as a string for each submission to the survey. So in order to use it for analysis, you just need to parse the JSON using a scripting language such as Python or R. 

For instance, in **Python**, this would be as simple as:

```
import json
import csv
import os

results_file = os.path.normpath("your/path/results.csv")
with open(results_file, 'r') as f:
    reader = csv.DictReader(f)
    data = []
    for row in reader:
        data.append(row)
        
# Remove first 2 rows of Qualtrics jibberish
data = data[2:]

# Load first submission's task_tracker data
example = json.loads(data[0]['task_tracker'])
```

The keys within this example, which will be in every participant's task_tracker are:
```
print(list(example.keys()))

#OUTPUT
['start_time',
 'offTask_check',
 'onTask_check',
 'check_points',
 'page_check',
 'log']
```

Or the same thing in **R**:
```
library(jsonlite)

df <- read.csv('D:\\Julia\\Qualtrics_TaskTracking\\test_result.csv')

#drop Qualtrics jibberish header rows
df <- df[3:nrow(df),]

example <- fromJSON(df[1,'task_tracker'])
```

The JSON itself has some variables that are only needed in order for the tracking to work correctly, such as `offTask_check, onTask_check, and page_check`, but it also includes the overall `start_time` that is used to calculate the durations. 

The main logging data is stored in the `log` key of the object, and if you are using checkpoints, they are added as an array inside the `check_points` key. Although the timestamps are present in every event, there are also other keys to make doing the time analysis more convenient. 

Each event gets placed in the `task_tracker`'s `log` with a label as follows:
- `start`
	- The very first event when the form loads
	- Only has the `time_check`
- `enter`
	- Browser window is activated
- `exit`
	- Browser window has been left
- `next_page`
	- Participant has successfully moved to the next page
	- This will record an "on_task"
- `validation_error`
	- In the event there is a validation error when the participant tries to go to the next page

so here is an example of the first 3 items in this example:
```
print(example['log'][:3])

#OUPUT
[{'event': 'start', 'time_check': 1716996284016},
 {'event': 'exit',
  'time_check': 1716996287629,
  'last_check': 1716996284016,
  'duration': 3.613,
  'duration_type': 'on_task',
  'page': 1},
 {'event': 'enter',
  'time_check': 1716996289296,
  'last_check': 1716996287629,
  'duration': 1.667,
  'duration_type': 'off_task',
  'page': 1}]
```

You can see that the start is recorded, and each event get's a label, as well as the time stamp for when it occurred, the last time check, and the duration and duration type of the recorded event. This means that when the `event` is "exit", it is recording how long they were on task before exiting the browser window with the `duration` key. This is indicated for convenience by the `duration_type`, which can be used to sum the total on and off task events easily.

Continuing the example, here is the total durations in **Python**:
```
#Sum all the durations, ignoring the first 'start' entry, if the duration_type is on or off
total_on = sum([item['duration'] for item in example['log'][1:] if item['duration_type']=='on_task'])
total_off = sum([item['duration'] for item in example['log'][1:] if item['duration_type']=='off_task'])

# total_off = 27.603
# total_on = 85.542
```

And again in **R**:
```
on_task <- sum(example$log[which(example$log[,"duration_type"]=="on_task"),"duration"])
off_task <- sum(example$log[which(example$log[,"duration_type"]=="off_task"),"duration"])

# off_task = 27.603
# on_task = 85.542
```

Or if you only want to know this for a specific checkpoint:
```
print(example['check_points']['B1Q1'])

#OUTPUT
[{'event': 'exit',
  'time_check': 1716996287629,
  'last_check': 1716996284016,
  'duration': 3.613,
  'duration_type': 'on_task',
  'page': 1},
 {'event': 'enter',
  'time_check': 1716996289296,
  'last_check': 1716996287629,
  'duration': 1.667,
  'duration_type': 'off_task',
  'page': 1},
 {'event': 'exit',
  'time_check': 1716996296993,
  'last_check': 1716996289296,
  'duration': 7.697,
  'duration_type': 'on_task',
  'page': 1},
 {'event': 'enter',
  'time_check': 1716996304170,
  'last_check': 1716996296993,
  'duration': 7.177,
  'duration_type': 'off_task',
  'page': 1},
 {'event': 'next_page',
  'time_check': 1716996307807,
  'last_check': 1716996296993,
  'duration': 10.814,
  'duration_type': 'on_task',
  'page': 1}]
```

You could find the off_task total for Block 1 by using the B1Q1 checkpoint:
```
b1_off = sum([item['duration'] for item in example['check_points']['B1Q1'] if item['duration_type']=='off_task'])

#OUTPUT
8.844
```

This example code is provided in the example folder
