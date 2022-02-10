%% testRetestAnalysis
% This script loads a blink data set into a MATLAB table variable. When
% run, it will aggregate data for a given subject and parameter(s), split
% by session. It will then produce a plot which describes the within session
% correlation for each session and will calculate the test retest reliability
% between sessions.
%%

% load file path
dataPath = fileparts(fileparts(mfilename('fullpath')));
spreadsheet ='UPenn Ipsi Summary_25ms_02062022.csv';

% choose subject and parameters
% run subjects 149590, 14589, and 14588 only for highest 3 PSI levels
subList = {15512, 15507, 15506, 15505, 14596, 14595, 14594, 14593, 14592, 14591, ...
    14590, 14589, 14588};
% };
varNamesToPlot = {'latencyI', 'aucI'};
highestOnly = 'TRUE';
% highestOnly = 'FALSE';

xFit = linspace(log10(3),log10(70),50);
% ylims = {[30 80]};

% create MATLAB table variable
T = readtable(fullfile(dataPath,'data',spreadsheet));
allVarNames = T.Properties.VariableNames;

for vv = 1:length(varNamesToPlot)
    
    figure();
    plotNum = 0;
    pX = [];
    pY = [];
    oX = [];
    oY = [];
    
    for ss = 1:length(subList)

        % find scans for desired subject
        scans = T(ismember(T.subjectID,subList{ss}),:);
        scans = scans(ismember(scans.valid,'TRUE'),:);

        % separate scans into a table for each of the sessions
        dates = unique(scans.scanDate);
        if highestOnly
           A = scans(ismember(scans.intendedPSI, 15),:);
           B = scans(ismember(scans.intendedPSI, 30),:);
           C = scans(ismember(scans.intendedPSI, 60),:);
           scans = vertcat(A, B, C);
        end
        sessOne = scans(ismember(scans.scanDate,dates(1,1)),:);
        sessTwo = scans(ismember(scans.scanDate,dates(2,1)),:);
        ii = find(strcmp(varNamesToPlot{vv},allVarNames));

        % session one data
        plotNum = plotNum + 1;
        y = sessOne.(allVarNames{ii});
        goodPoints = ~isnan(y);
        x = log10(sessOne.PSI);
        x = x(goodPoints);
        y = y(goodPoints);
        [x,idxX]=sort(x);
        y = y(idxX);
        weights = sessOne.numIpsi;
        mSize = weights*20;

        % make plot
        subplot(2,length(subList),plotNum);
        scatter(x,y,mSize);
        fitObj = fitlm(x,y,'RobustOpts', 'on', 'Weight', weights);
        hold on
        plot(x,fitObj.Fitted,'-r');
        xlim(log10([2 100]));
        pX(end+1) = fitObj.Coefficients.Estimate(2);
        oX(end+1) = fitObj.Coefficients.Estimate(1);
        rsquare = fitObj.Rsquared.Ordinary;
        if rsquare > 1 || rsquare < 0
            rsquare = nan;
        end
        title(['Subject ' num2str(subList{ss})], 'FontSize', 14)
        if plotNum ~= 1
            yticklabels("");
            xticklabels("");
            xticks([]);
            yticks([]);
        else
            ylabel(['Session one ' varNamesToPlot{vv}], 'FontSize', 14)
            xlabel('puff pressure [log psi]', 'FontSize', 14)
        end
        % ylim(ylims{vv});

        % session two data
        y = sessTwo.(allVarNames{ii});
        goodPoints = ~isnan(y);
        x = log10(sessTwo.PSI);
        x = x(goodPoints);
        y = y(goodPoints);
        [x,idxX]=sort(x);
        y = y(idxX);
        weights = sessTwo.numIpsi;
        mSize = weights*20;

        % make plot
        subplot(2,length(subList),plotNum + length(subList));
        scatter(x,y,mSize);
        fitObj = fitlm(x,y,'RobustOpts', 'on', 'Weight', weights);
        hold on
        plot(x,fitObj.Fitted,'-r')
        xlim(log10([2 100]));
        pY(end+1) = fitObj.Coefficients.Estimate(2);
        oY(end+1) = fitObj.Coefficients.Estimate(1);
        rsquare = fitObj.Rsquared.Ordinary;
        if rsquare > 1 || rsquare < 0
            rsquare = nan;
        end
        if plotNum == 1
            ylabel(['Session two ' varNamesToPlot{vv}], 'FontSize', 14)
        end
        yticklabels("");
        xticklabels("");
        xticks([]);
        yticks([]);
        % ylim(ylims{vv});
    end
    
    % plot parameter test retest values across subjects
    figure();
    pl = subplot(1,1,1);
    plot(pX,pY,'ob');
    fitObj = fitlm(pX,pY,'RobustOpts', 'on');
    hold on
    plot(pX,fitObj.Fitted,'-r')
    rsquare = fitObj.Rsquared.Ordinary;
    if rsquare > 1 || rsquare < 0
        rsquare = nan;
    end
    title([varNamesToPlot{vv} ' slope by session - ' sprintf(' R^2=%2.2f',rsquare)], 'FontSize', 14)
    xlabel(['Slope'], 'FontSize', 14)
    ylabel(['Slope'], 'FontSize', 14)
    ylim(xlim);
    axis(pl, 'square');
    
%     % plot offset test retest values across subjects
%     subplot(1,2,2);
%     plot(oX,oY,'ob');
%     fitObj = fitlm(oX,oY,'RobustOpts', 'on');
%     hold on
%     plot(oX,fitObj.Fitted,'-r')
%     rsquare = fitObj.Rsquared.Ordinary;
%     if rsquare > 1 || rsquare < 0
%         rsquare = nan;
%     end
%     title([varNamesToPlot{vv} ' offset - ' sprintf(' R^2=%2.2f',rsquare)])
%     xlabel([varNamesToPlot{vv} ' offset session 1'])
%     ylabel([varNamesToPlot{vv} ' offset session 2'])
    
end