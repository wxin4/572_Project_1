% get the path of the csv files
file_path = "./DataFolder/";

% create a files array that holds the suffix of the file names, we will
% traverse each one of them.
files = {'1.csv', '2.csv', '3.csv', '4.csv', '5.csv'};

% loop through the files
for csv = files
    % Read files from CGMDateNumLunchPat 
    file = detectImportOptions(strcat(file_path, 'CGMDatenumLunchPat', csv));
    % time stamps are in reverse order so I flip the data around
    time_matrix = fliplr(readmatrix(strcat(file_path, 'CGMDatenumLunchPat', csv), file));
    
    % Read files from CGMSeriesLunchPat
    file = detectImportOptions(strcat(file_path, 'CGMSeriesLunchPat', csv));
    level_matrix = readmatrix(strcat(file_path, 'CGMSeriesLunchPat', csv) ,file);

    % First, eliminate NaN and no values 
    time_matrix(sum(isnan(time_matrix), 2) == 31, :) = [];
    level_matrix(sum(isnan(level_matrix), 2) == 31, :) = [];
    time_matrix = time_matrix.';
    level_matrix = level_matrix.';

    % Next, fill missing data and transpose back the two matrices
    % since it is the time series, we can use makima to calculate missing values
    time_matrix = fillmissing(time_matrix,'makima'); 
    level_matrix = fillmissing(level_matrix,'linear');
    time_matrix = transpose(time_matrix);
    level_matrix = transpose(level_matrix);

    % Traverse every csv files
    % create an empty array holding the feature values in one row, with
    % double type
    feature = double.empty();
    rowNum = size(level_matrix, 1);
    for index = 1:rowNum
        % Get every row from both matrices
        time_array = time_matrix(index, :);
        level_array = level_matrix(index, :);

        % Feature #1 - covariance of tissue glucose levels every 10 min
        c1 = std(level_array(:,1:2)) / mean(level_array(:,1:2));
        c2 = std(level_array(:,2:4)) / mean(level_array(:,2:4));
        c3 = std(level_array(:,4:6)) / mean(level_array(:,4:6));
        c4 = std(level_array(:,6:8)) / mean(level_array(:,6:8));
        c5 = std(level_array(:,8:10)) / mean(level_array(:,8:10));
        c6 = std(level_array(:,10:12)) / mean(level_array(:,10:12));
        c7 = std(level_array(:,12:14)) / mean(level_array(:,12:14));
        c8 = std(level_array(:,14:16)) / mean(level_array(:,14:16));
        c9 = std(level_array(:,16:18)) / mean(level_array(:,16:18));
        c10 = std(level_array(:,18:20)) / mean(level_array(:,18:20));
        c11 = std(level_array(:,20:22)) / mean(level_array(:,20:22));
        c12 = std(level_array(:,22:24)) / mean(level_array(:,22:24));
        c13 = std(level_array(:,24:26)) / mean(level_array(:,24:26));
        c14 = std(level_array(:,26:28)) / mean(level_array(:,26:28));
        c15 = std(level_array(:,28:31)) / mean(level_array(:,28:31));
        
        % make it a row by separating by commas so that the covariance
        % matrix will look like a row instead of a column
        covariance = [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15];

        % Feature #2 - get the polynomial coefficient of the tissue glucose
        % levels from the CGMSeriesLunchPat forms
        x = 1:size(level_array, 2);
        y = level_array;
        n = 5;
        [poly_coefficient, s] = polyfit(x,y,n); % normr?norm of the  residuals?????????????????????????????????
        z = polyval(poly_coefficient,x);

        % Feature #3 - calculate the difference of every time duration (10 min) of the
        % tissue glucose level
        time_dur = 3;
        var = 0;
        diff = zeros(length(level_array), 'double');
        
        % start from index number 2
        for idx = 2:length(level_array)
            % calculate each var that holds the difference between 10 min
            var = var + level_array(idx) - level_array(idx-1);
            
            % difference between 10 min
            if mod(idx, time_dur) == 0
                if idx == time_dur
                    diff = var;
                else
                    diff = horzcat(diff, var);
                end
                % reset the var
                var = 0;
            end
        end
        
        
        % Feature #4 - find the speed of tissue glucose level of each test
        % per person at every two timestamps
        speed_array = zeros(length(time_array), 'double')
        
        for i = 2:length(time_array)
            if i == 2
                speed_array = level_array(2) / 100000 / (time_array(2) - time_array(1)) % 100000 will be discussed in pdf
            else
                speed_array = horzcat(speed_array, level_array(i) / 100000 / (time_array(i) - time_array(i-1)))
            end
        end

        % b) Create the Feature Matrix
        % all four features extracted
        each_feature = horzcat(covariance, poly_coefficient, diff, speed_array);
        boolean = isempty(feature);
        
        % if there is no value, add the first row to the feature array
        if boolean == false
            feature = vertcat(feature, each_feature);
        else
            feature = each_feature;
        end 

    end

     
    % d) Create a feature matrix where each row is a collection of features from each time series.
    feature_matrix = normalize(feature, 'norm', 1);

    % e) Provide this feature matrix to PCA and derive the new feature matrix.
    % coeff - returns the principal component coefficients
    % principal component scores in score and the principal component variances in latent
    % each column of score corresponds to one principal component. The vector, latent, stores the variances of the four principal components.
    [coeff,score,latent] = pca(feature_matrix);
     
     
    % e) PCA & Best 5 features
    % Initialization
    % number of tests for each Subject
    num_of_tests = 1:rowNum;
     
    % The columns of X * coeff are orthogonal to each other.
    % Multiply the original data by the principal component vectors to get the projections of the original data on the
    % principal component vector space. This is also the output "score".
    dataInPrincipalComponentSpace = feature_matrix * coeff;
    corr_coef = corrcoef(dataInPrincipalComponentSpace);
     
    % get the plot figure name
    plot_name = string(strcat('Plotted Data From Subject ', csv));
     
    % plot the 5 figures from 5 Subjects
    figure('Name', plot_name, 'NumberTitle', 'off');
     
    % tile the 5 figures to 2 rows by 3 columns chart
    t = tiledlayout(2,3);

    % 1 - Visualize both the orthonormal principal component coefficients of all tests
    vbls_total = {};
    % Note that we can only plot the first 18 data because the last csv
    % file only contains 18 data.
    for i = 1:18
        vbls_total{end+1} = char(strcat('v_' + string(i)));
    end
    nexttile;
    biplot(coeff(1:18, 1:2), 'scores', score(1:18, 1:2), 'varlabels', vbls_total);
     
    % data representation in the space of the first three principal components shown in scatterplot 
    [coeff,score,latent,tsquared,explained] = pca(feature_matrix(:, 3:15));
    nexttile;
    
    % Note that if we run "explained", we can get the influence rate of all the rows of data
    % since the first 3 have a total of around 80% of the whole data, we
    % plot the first 3 dimensions of data of x-y-z coordinate with
    % surf(peaks)
    surf(peaks);
    axis tight;
    xlabel('1st_score')
    ylabel('2nd_score')
    zlabel('3rd_score')
    nexttile;

    % since the first 3 have a total of around 80% of the whole data, we
    % plot the first 3 dimensions of data of x-y-z coordinate with
    % scatter3
    scatter3(score(:,1),score(:,2),score(:,3))
    axis tight;
    xlabel('1st_score')
    ylabel('2nd_score')
    zlabel('3rd_score')
    nexttile;
     
    % plot the values of data in the PCA space
    plot(num_of_tests, dataInPrincipalComponentSpace);
    xlabel('tests')
    ylabel('pca space')
    nexttile;
     
    % finally, plot the timestamp and glucose level
    plot(time_array, level_array);
    xlabel('time stamp')
    ylabel('glucose level')
end
