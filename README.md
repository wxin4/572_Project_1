# 572_Project_1

Matlab Version: R2019b Update 3 (9.7.0.1261785)

## How to run the code
1. Open Matlab with the above version. 

2. Put the DataFolder into the same directory of the .m file

3. Change the file_path name by the path of your own computer.

4. run the code by clicking on the "Run" button

5. If you want to take a deeper look at the figures, there are 3 figures shown after you run it.

6. The workspace contains all the variables in the code.

## Input Data
Five cell arrays:

a) The first cell array has tissue glucose levels every 5 mins for 2.5 hrs during a lunch meal
The data starts from 30 mins before meal intake an continues up to 2 hrs after the start of meal
consumption. There are several such time series for one subject.

b) The second cell array has time stamps of each time series in the first cell array.

c) The third cell array has insulin basal infusion input time series at different times during the 2.5
hr time interval.

d) The fourth cell array has time stamps for each basal or bolus insulin delivery time series.

e) The fifth cell array has insulin bolus infusion input time series at different times during the 2.5 hr
time interval

## Some facts about the data
Each cell array is an array of time series each of which can have varying lengths.

Each subject has multiple such time series but the total number of time series data for each subject may
vary.

You have data from 5 subjects.

The insulin input may not be every 5 mins hence the insulin time series length may vary significantly.

The time stamp which has the highest insulin delivery is the time at which the meal was logged.

## Requirements
a) Extract 4 different types of time series features from only the CGM data cell array and CGM
timestamp cell array.

b) For each time series explain why you chose such feature.

c) Show values of each of the features and argue that your intuition in step b is validated or
disproved?

d) Create a feature matrix where each row is a collection of features from each time series. SO if
there are 75 time series and your feature length after concatenation of the 4 types of featues is
17 then the feature matrix size will be 75 * 17.

e) Provide this feature matrix to PCA and derive the new feature matrix. Chose the top 5 features
and plot them for each time series.

f) For each feature in the top 5 argue why it is chosen as a top five feature in PCA?
