%% slopeTestRetest
% 
%       Scan PSI index (out of 26 scans, discarding scan 1):
%          3.5 PSI: [3 8 13 24 25]
%          7.5 PSI: [9 11 12 20 22]
%          15 PSI: [4 7 16 17 21]
%          30 PSI: [2 10 15 18 26]
%          60 PSI: [5 6 14 19 23]
%
%% set up parameters

% load file path
dataPath = fileparts(fileparts(mfilename('fullpath')));
spreadsheet ='Upenn_Ipsilateral Afiles_clean_full.csv';

% choose subject and parameters
subList = {15512, 15507, 15506, 15505, 14596, 14595, 14594, 14593, 14592, 14591, ...
    14590, 14589, 14588, 14587, 14586};
varNamesToPlot = {'auc', 'latency', 'timeUnder20', 'openTime', 'initialVelocity', ...
     'closeTime', 'maxClosingVelocity', 'maxOpeningVelocity', 'blinkRate'};

% create MATLAB table variable
T = readtable(fullfile(dataPath,'data',spreadsheet));
allVarNames = T.Properties.VariableNames;

results = NaN(9,4);

%% get slopes for each session
for vv = 1:length(varNamesToPlot)
    
    subjectMeans = [];
    sessOneSlopes = [];
    sessTwoSlopes = [];
    
    for ss = 1:length(subList)
        
        psi = [30 3.75 15 60 60 15 3.75 7.5 30 7.5 7.5 3.75 60 30 15 15 30 60 7.5 15 7.5 60 3.75 3.75 30];
        ii = find(strcmp(varNamesToPlot{vv},allVarNames));

        % find scans for desired subject
        scans = T(ismember(T.subjectID,subList{ss}),:);
        scans = scans(ismember(scans.valid,'TRUE'),:);
        dates = unique(scans.scanDate);
        sessOne = scans(ismember(scans.scanDate,dates(1,1)),:);
        sessTwo = scans(ismember(scans.scanDate,dates(2,1)),:);

        % calculate residuals as a function of trial number session 1
        acqMeans = NaN(1,25);
        for zz = 1:25
            temp = sessOne(ismember(sessOne.scanNumber, zz+1),:);
            if ~isempty(temp) 
               acqMeans(zz) = mean(temp.(varNamesToPlot{vv}), 'omitnan');
            end
        end

        fitObj = fitlm(log10(psi),acqMeans,'RobustOpts', 'on');
        modelY = fitObj.Fitted;
        
        resByTrial = NaN(25, 8);
        resMeansByTrial = NaN(1,8);
        for zz = 1:8
            temp = sessOne(ismember(sessOne.stimIndex, zz),:);
            if ~isempty(temp)
                for yy = 1:25
                    tt = temp(ismember(temp.scanNumber, yy+1),:);
                    if isempty(tt)
                        residual = NaN;
                    elseif length(tt.(varNamesToPlot{vv})) == 1
                        residual = tt.(varNamesToPlot{vv})(1) - modelY(yy);
                    else
                        res1 = tt.(varNamesToPlot{vv})(1) - modelY(yy);
                        res2 = tt.(varNamesToPlot{vv})(1) - modelY(yy);
                        residual = mean([res1 res2]);
                    end
                    resByTrial(yy,zz) = residual;
                end
            end
            resMeansByTrial(1,zz) = mean(resByTrial(:,zz), 'omitnan');
        end
        
        % get session one slope
        fitObj = fitlm((1:8),resMeansByTrial,'RobustOpts', 'on');
        sessOneSlope = fitObj.Coefficients.Estimate(2);
        sessOneSlopes(end+1) = sessOneSlope;
        
        % calculate residuals as a function of trial number session 2
        acqMeans = NaN(1,25);
        for zz = 1:25
            temp = sessTwo(ismember(sessTwo.scanNumber, zz+1),:);
            if ~isempty(temp) 
               acqMeans(zz) = mean(temp.(varNamesToPlot{vv}), 'omitnan');
            end
        end

        fitObj = fitlm(log10(psi),acqMeans,'RobustOpts', 'on');
        modelY = fitObj.Fitted;
        
        resByTrial = NaN(25, 8);
        resMeansByTrial = NaN(1,8);
        for zz = 1:8
            temp = sessTwo(ismember(sessTwo.stimIndex, zz),:);
            if ~isempty(temp)
                for yy = 1:25
                    tt = temp(ismember(temp.scanNumber, yy+1),:);
                    if isempty(tt)
                        residual = NaN;
                    elseif length(tt.(varNamesToPlot{vv})) == 1
                        residual = tt.(varNamesToPlot{vv})(1) - modelY(yy);
                    else
                        res1 = tt.(varNamesToPlot{vv})(1) - modelY(yy);
                        res2 = tt.(varNamesToPlot{vv})(1) - modelY(yy);
                        residual = mean([res1 res2]);
                    end
                    resByTrial(yy,zz) = residual;
                end
            end
            resMeansByTrial(1,zz) = mean(resByTrial(:,zz), 'omitnan');
        end
        
        % get session two slope
        fitObj = fitlm((1:8),resMeansByTrial,'RobustOpts', 'on');
        sessTwoSlope = fitObj.Coefficients.Estimate(2);
        sessTwoSlopes(end+1) = sessTwoSlope;
        
        % get mean slope across sessions
        meanSlope = mean([sessOneSlope sessTwoSlope]);
        subjectMeans(end+1) = meanSlope;

    end
    
    [h,p,ci,stats] = ttest(subjectMeans);
    co = corrcoef(sessOneSlopes,sessTwoSlopes)
    meanSlope = mean(subjectMeans);
    results(vv,1) = co(1,2);
    results(vv,2) = meanSlope;
    results(vv,3) = stats.tstat;
    results(vv,4) = p;
    
end