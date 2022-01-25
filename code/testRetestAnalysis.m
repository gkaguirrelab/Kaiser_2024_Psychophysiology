%% testRetestAnalysis
% This script loads a blink data set into a MATLAB table variable. When
% run, it will aggregate data for a given subject and parameter(s), split
% by session. It will then produce a plot which describes the within session
% correlation for each session and will calculate the test retest reliability
% between sessions.
%%

% load file path
dataPath = fileparts(fileparts(mfilename('fullpath')));
spreadsheet ='1_2022.csv';

% choose subject and parameters
subList = {'15514'};
varNamesToPlot = {'latency','auc'};

xFit = linspace(log10(3),log10(70),50);
ylims = {[30 80],[0 5e4]};

figure();

% create MATLAB table variable
T = readtable(fullfile(dataPath,'data',spreadsheet));
allVarNames = T.Properties.VariableNames;

for ss = 1:length(subList)
    % TODO: find scans for desired subject and separate them into a table for
    % each of the two sessions
    
    % plot within session data and calculate R^2
    for tt = 1:length(sessionTables)
        for vv = 1:length(varNamesToPlot)
            ii = find(strcmp(varNamesToPlot{vv},allVarNames));

            y = T.(allVarNames{ii});
            goodPoints = ~isnan(y);
            x = log10(T.PSI);
            x = x(goodPoints);
            y = y(goodPoints);
            [x,idxX]=sort(x);
            y = y(idxX);

            subplot(length(varNamesToPlot),length(subList),ss+(vv-1)*length(subList));


            plot(x,y,'ob');
            [fitObj,G] = L3P(x,y);
            hold on
            plot(xFit,fitObj(xFit),'-r')
            xlim(log10([2 100]));
            rsquare = G.rsquare;
            if rsquare > 1 || rsquare < 0
                rsquare = nan;
            end
            title([varNamesToPlot{vv} ' - ' subList{ss} sprintf(' R^2=%2.2f',rsquare)])
            xlabel('puff pressure [log psi]')
            ylim(ylims{vv});
        end
    end
    
    % TODO: calculate and show between session correlation
end