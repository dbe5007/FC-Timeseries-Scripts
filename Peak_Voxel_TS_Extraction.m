%% Automated Import Voxel Peaks and Extract Timeseries
%  Daniel Elbich
%  Lab of Developmental Neuroscience
%  12/25/15
%
%
%  This process uses output from the automated voxel selection (for more
%  paste "help Peak_Voxel_Automation" into MATLAB console. The required 
%  excel sheet is output from the aformentioned program and used for
%  importing the placement corrected peaks. New peaks are used to create
%  new (final) VOI files and timeseries data is extracted using these.
%  There are multiple (optional) checks for organizing and outputing files
%  for connectivity and condition specific analyses.
%
%  All files must be pre-generated and loaded into the program. This
%  automates peak selection and negative peak correction. Maunal correction
%  for VOI placement and overlap is still required.
%
%  NOTE: This method requires high resolution (HiRes) VMPs created by
%  BrainVoyager. Results using any other map cannot be guarenteed
%  accurate. See forum hyperlink or script author for futher information.
%
%  http://www.brainvoyager.com/ubb/Forum3/HTML/000404.html
%
%  Requires NeuroElf Toolbox (formerly BVQXtools) - http://neuroelf.net/


%% Loading in BV files

% Load in Excel File
[PeakFileName,PeakFilePath] = uigetfile('*.xls','Select Excel File');
[~,Sheets]=xlsfinfo(strcat(PeakFilePath,PeakFileName));

%Load in VTC List
options.Interpreter = 'tex';
options.Default = 'Already Loaded';
qstring = 'Load in VTC List?';
choicevtc = questdlg(qstring,'VTC List',...
    'MAT File','Excel File','Already Loaded',options);

switch choicevtc
    case 'MAT File'
        vtcpath=uigetfile('*.mat','Select MAT File');
    case 'Excel File'
        [VTCName,VTCPath]=uigetfile('*.xlsx','Select Excel File');
        [~,~,vtcpath]=xlsread(strcat(VTCPath,VTCName));
    case 'Already Loaded'
        
end

% File format check
options.Interpreter = 'tex';
options.Default = 'No';
choice = questdlg({'First Coordinates: \n',[],vtcpath{1,1},vtcpath{2,1},[],'Format Correct?'}, ...
    'VTC List Check', ...
    'Yes','No','Cancel');

% Handle response
switch choice
    case 'Yes'
    case 'No'
        break;
    case 'Cancel'
        break;
end

% Organize Timeseries Check
options.Interpreter = 'tex';
options.Default = 'No';
qstring = 'Do you want to create files for connectivity analysis?';
choiceorg = questdlg(qstring,'Connectivity Analyses?',...
    'Yes','No',options);

switch choiceorg
    case 'Yes'
        % Condition Specific Analysis
        options.Interpreter = 'tex';
        options.Default = 'No';
        qstring = 'Do you want to do Condition Analysis';
        choicecondition = questdlg(qstring,'Condition',...
            'Yes','No',options);
        
        switch choicecondition
            case 'Yes'
                condition = 1;
                pwd;
                mkdir(ans,'out/Condition');
                txtsavepath = strcat(ans,'/out/Condition');
            case 'No'
                condition = 0;
        end
        
        % Remove Regions
        options.Interpreter = 'tex';
        options.Default = 'No';
        qstring = 'Do you want to remove any regions from the exported timeseries?';
        choiceremove = questdlg(qstring,'Remove ROi',...
            'Yes','No',options);
        
        switch choiceremove
            case 'Yes'
                remove_roi = 1;
                break_l=false;
                count=1;
                while break_l==false;
                    check = inputdlg('Enter region number to be removed (i.e. column). Leave blank for no region.');
                    if isequal(check{1,1},'') == 0
                        node_del(1,count) = str2double(check);
                        count=count+1;
                    else
                        break_l=true;
                    end
                end
                
                node_del=sort(node_del,'descend');
                
            case 'No'
                remove_roi = 0;
        end
    case 'No'
        condition = 0;
end

clear choice choiceremove options qstring;

% Timing Debug
%tic;

%% Main Code

% Subject Interation

for z=2:length(Sheets)
    
    %[~,~,RAW]=xlsread(PeakFileName,Sheets{1,z});
    [~,~,RAW]=xlsread([PeakFilePath,PeakFileName],Sheets{1,z});
    
    index=1;
    
    while strcmpi(RAW{index,1},'Placement Fix Below')==0
        index=index+1;
    end
    
    % Debug Code
    %index=0;
    %ctab=RAW(index+2:index+9,2:6);
    %ctab=RAW(index+2:index+14,2:6);
    ctab=RAW(index+2:end,2:6);
    
    if z==2
        
        %roilist=RAW(2:(index-6),1)';
        roilist=RAW(2:(index-3),1)';
        
        %Delete Nodes from Lists
        for gone=1:length(node_del)
            %ctab(node_del(gone),:)=[];
            roilist(node_del(gone))=[];
        end
        
    end
    

    
    %ctab=RAW(index+2:index+13,2:6);
    ctab=cell2mat(ctab);
    
    %Create & Save Spherical ROIs
    voi = xff('new:voi');
    
    %Iterate over coordinates in table
    for cc = 1:size(ctab, 1)
        
        %Add coordinate
        voi.AddSphericalVOI(ctab(cc,1:3),6);
        
        %Add Name to VOI
        voi.VOI(cc).Name=strcat(Sheets{1,z},'_',RAW{index+1+cc,1},'_6mm_Sphere.voi');
        
    end
    
    %Update VOI Information
    voi.FileVersion=4;
    
    savename=strcat(Sheets{1,z},'_6mm_Spheres_Corrected_Final.voi');
    
    %Save Sphere VOI
    %voi.SaveAs('temp.voi');
    voi.SaveAs(savename);
    
    %Debug
    %[VTCName,VTCPath] = uigetfile('*.vtc','Select Volume Map (VTC)');
    %vtc = xff(strcat(VTCPath,VTCName));
    
     if strcmpi('ES_9148',Sheets{1,z})==1
         pause;
     end
    
    %Pull timeseries for each region and each voxel
    vtc=xff(vtcpath{z-1,1});
    %[voitc,voitc_all] = vtc.VOITimeCourse(voi);
    [voitc, ~, ~, voitc_all] = vtc.VOITimeCourse(voi);
    
    %Remove regions from final timeseries
    if remove_roi==1
        b=0;
        for aa = 1:length(node_del)
            if aa==1
                voitc(:,node_del(1,aa)) = [];
                voitc_all{1,node_del(1,aa)} = [];
                voitc_all = voitc_all(~cellfun('isempty',voitc_all));
            else
                voitc(:,(node_del(1,aa)-b)) = [];
                voitc_all{1,(node_del(1,aa)-b)} = [];
                voitc_all = voitc_all(~cellfun('isempty',voitc_all));
            end
            b=1;
        end
    end
    
    
    
    %Get Variance data from ROIs
    for variance=1:length(voitc_all)
        
        var_final(:,variance)=std(voitc_all{1,variance},0,2);
        
    end
    
    %Save Timeseries
    voitc=num2cell(voitc);
    cell2csv([Sheets{1,z} '.csv'],voitc);   %Outputs values to csv for each participant
    
    %Save Variance Sheet
    var_final=num2cell(var_final);
    cell2csv([Sheets{1,z} '_Variance.csv'],var_final);   %Outputs values to csv for each participant
    
    if condition == 1
        
        voitc=cell2mat(voitc);
        
        %Mean Deviate Time Series
        sizet = size(voitc);
        
        for a = 1:sizet(1,2)
            
            avg = mean(voitc(:,a));
            
            for b = 1:sizet(1,1)
                
                voitc(b,a) = voitc(b,a) - avg;
                
            end
            
        end
        
        for zz = 1:length(roilist)
            
            %roilist{1,zz}=strrep(roilist{1,zz},'"','');
            
            temptxt = {txtsavepath '/' Sheets{1,z} '_' roilist{1,zz} '.1D'};
            ftxtname = {Sheets{1,z} '_' roilist{1,zz} '.txt'};
            
            txtfile = strcat(temptxt{1,:});
            ftxtname = strcat(ftxtname{1,:});
            
            newfileID = fopen(txtfile,'w');
            
            %for rows = 1:serieslength
            %for rows = 1:(length(data{1,1})-1)
            for rows=1:length(voitc)
                fprintf(newfileID,'%f\n',voitc(rows,zz));
            end
            
            fclose(newfileID);
            
        end
        
    end
    
    clear var_final voitc voitc_all;
    
end


%toc;

