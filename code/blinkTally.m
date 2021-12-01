dataPath = fileparts(fileparts(mfilename('fullpath')));

% load data files
subList = {'b96.csv','b97.csv', 'b99.csv', 'b100.csv'};

% setup plotting
varNamesToPlot = {'ipsi', 'contra'};
xFit = linspace(log10(3),log10(70),50);
ylims = {[0 35],[0 35]};
figure();

% loop through data
for ss = 1:length(subList)
    T = readtable(fullfile(dataPath,'data',subList{ss}));
    allVarNames = T.Properties.VariableNames;
    
    for vv = 1:length(varNamesToPlot)
        ii = find(strcmp(varNamesToPlot{vv},allVarNames));
        
        % throw out invalid blinks and sort PSI
        vY = T.(allVarNames{ii});
        goodPoints = ~isnan(vY);
        vX = log10(T.PSI);
        vX = vX(goodPoints);
        vY = vY(goodPoints);
        [vX,idxX]=sort(vX);
        
        % set up variables to tally
        x = [vX(1)];
        y = [1];
        count = 1;
        currPSI = vX(1);
        
        % tally blinks for each PSI
        for uu = 1:length(vX)
            
            if currPSI == vX(uu)
                count = count + 1;
            else
                x(end+1,:) = vX(uu);
                y(size(y),:) = count;
                count = 1;
                currPSI = vX(uu);
                y(end+1,:) = 1;
            end
            
            if count ~= 1
               y(size(y),:) = count; 
            end
        end
        
        % plot data
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