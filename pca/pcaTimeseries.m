%% PCA Analysis for Timeseries Data Reduction
%  Daniel Elbich
%  5/8/15

% This program conducts PCA analysis on time series data extracted from
% Brain Voyager. This program reads in data tables exported from Brain
% Voyager with p & t values for all voxels. The program subsequently reads
% in the individual time series data from a region of varying size and
% length. Using these, The program begins to search for vectors that are
% both below the specific significance value and having a positive t value,
% indicating a positive relationship. Once these values are found, the
% program searches for duplicate vectors (i.e. the exact same timeseries in
%a different region) as this will bias the transformation. The program then
% submits these values to a PCA analysis via funciton call, returning the
% first principal component and the explained variance. These values are
% relocated into output variables for final export to csv files for further
% analysis and record keeping.

%Debug
%pval = .01;
%load('demo_variables.mat');

signif = questdlg('Select series using p value?','Series Selection','Yes','No','Cancel','Cancel');

switch signif
    case 'Yes'
        prompt = {'Enter desired p value:'};
        dlg_title = 'Signficance Level';
        num_lines = 1;
        def = {'.01'};
        pval = inputdlg(prompt,dlg_title,num_lines,def);
        pval=str2double(pval);
    case 'No'
        pval = 't';
    case 'Cancel'
        break;
end


for a=1:length(subjID)
    
    for z=1:length(regions)
        %Read in text files containing all individual voxel timeseries
        
        %Locate subject specific regions & peak data
        
        for p=1:length(filenamests)
            k=strfind(filenamests{p,1}, subjID{a,1}(end-3:end));
            j=regexpi(filenamests{p,1}, regions{z,1});
            l=strfind(filenamespeak{p,1}, subjID{a,1}(end-3:end));
            m=regexpi(filenamespeak{p,1}, regions{z,1});
            
            if sum(j+k+l+m)~=0 %(k~=[] && j~=[] && l~=[] && m~=[])
                break;
            end
        end
        
        % Reads in raw individual voxel timeseries
        fileID = fopen(filenamests{p,1});
        data_ts = textscan(fileID,'%s','Delimiter','\t');
        vars = strread(data_ts{1,1}{1,1},'%s');%%
        
        for b=2:length(data_ts{1,1})
            vars = strread(data_ts{1,1}{b,1},'%s');
            series((b-1),:) = transpose(vars(1:end));
        end
        
        series=str2double(series(:,2:end));
        
        % Reads in region significance information
        fid=fopen(filenamespeak{p,1});
        data_peak = textscan(fid,'%s','Delimiter','\n');
        tempcsv = cell(size(data_peak{1,1},1),5);
        
        
        for b=1:length(data_peak{1,1})
            limbo=strsplit(data_peak{1,1}{b,1});
            for c=1:length(limbo)
                tempcsv{b,c}=limbo{1,c};
            end
            clear limbo;
        end
        
        e=1;
        f=2;
        
        % Locates correct placement to find number of voxels
        while strcmpi(tempcsv{e,1},'NrOfVoxels:') == 0
            e=e+1;
        end
        
        while isempty(tempcsv{e,f}) == 1
            f=f+1;
        end
        
        begin=1+(length(tempcsv)-str2double(tempcsv{e,f}));
        tempval=str2double(tempcsv(begin:end,:));
        
        c=1;
        
        % Locates voxel coordinates with positive t value and at pre-defined
        % significance level.
        if isnumeric(pval) == 1
            for b=1:length(tempval)
                if tempval(b,5)<=pval && tempval(b,4) > 0
                    posval(c,1:size(tempval,2))=tempval(b,1:end);
                    c=c+1;
                end
            end
        else
            for b=1:length(tempval)
                if tempval(b,4) > 0
                    posval(c,1:size(tempval,2))=tempval(b,1:end);
                    c=c+1;
                end
            end
        end
        
        % Uses significant voxel coordinates to select signficant timeseries
        for b=1:size(posval,1)
            for c=1:size(series,2)
                if isequal(posval(b,1:3),series(1:3,c)')
                    pca_data(:,b)=series(4:end,c);
                end
            end
        end
        
        % Clear repeating timeseries (repeats occur proportionally to
        % functional:structual voxel size)
        
        for b=1:size(pca_data,2)
            for c=(b+1):size(pca_data,2)
                if c==size(pca_data,2)
                    break;
                end
                if isequal(pca_data(:,b),pca_data(:,c))==1
                    pca_data(:,c)=0;
                    %c=c-1;
                end
            end
            
            if b==size(pca_data,2)
                break;
            end
        end
        
        c=1;
        
        for b=1:size(pca_data,2)
            
            if mean(pca_data(:,b)) ~= 0
                clean_pca(:,c)=pca_data(:,b);
                c=c+1;
            end
            
        end
                
        %Calls PCA function
        [timeapprox, EXPLAINED]=pcaCalc(clean_pca);
        
        % Passes approximated timeseries for region to concatenation
        % variable for later output
        tempoutput(:,z)=timeapprox;
        
        % Output file with expained variances for all regions for all
        % components
        tempexplainedvar(:,z)=EXPLAINED;
        
        % Clears all temporary variables to prevent data carryover
        clear data_ts series data_peak tempcsv tempval posval pca_data clean_pca timeapprox;
        
    end
    
    % Conversion to cell for export & addition of region headers
    tempoutput=num2cell(tempoutput);
    tempexplainedvar=num2cell(tempexplainedvar);
    tempexplainedvar=insertrows(tempexplainedvar,regions',0);
    
    % Exports all series for subject to a csv file.
    cell2csv([subjID{a,1} '.csv'],tempoutput);
    cell2csv([subjID{a,1} '_ExplainedVariance.csv'],tempexplainedvar);
    
    clear tempoutput tempexplainedvar;

end
