%% Automated Peak Voxel Selection & VOI Creation
%  Daniel Elbich
%  Lab of Developmental Neuroscience
%  12/22/15
%
%  This process selects peak activation from BrainVoyager volume maps
%  (VMP) using a volume of interest (VOI) file. VMP and VOI files must be
%  premade and loaded into the program. This autmates peak selection and
%  negative peak correction. Maunal correction for palcement and overlap is
%  still required.
%
%  NOTE: This method requires high resolution (HiRes) VMPs created by
%  BrainVoyager. Results using any other map cannot be guarenteed
%  accurate. See forum hyperlink or script author for futher information.
%
%  Requires NeuroElf Toolbox (formerly BVQXtools) - http://neuroelf.net/
%
%  Uses xlwrite toolbox to for output - https://www.mathworks.com/matlabcentral/fileexchange/38591-xlwrite--generate-xls-x--files-without-excel-on-mac-linux-win
%
%  http://www.brainvoyager.com/ubb/Forum3/HTML/000404.html


%% Loading in BV files

% Load VMP
[VMPName,VMPPath] = uigetfile('*.vmp','Select Volume Map (VMP)');
vmp = xff(strcat(VMPPath,VMPName));

% Load VOI
[VOIName,VOIPath] = uigetfile('*.voi','Select Volume of Interest (VOI)');
voi = xff(strcat(VOIPath,VOIName));

% Timing Debug
tic;

% Create Vector of Region Names from VOI file
for zz=1:length(voi.VOI)
    
    %k = strfind(voi.VOI(zz).Name,'_');
    region_list{zz,1}=voi.VOI(zz).Name;
    %region_list{zz,1}=region_list{zz,1}((k(end)+1):end);
        
end

clear k zz;

mkdir('statoutput');

%% Main Code

% Subject Interation

for z=1:length(vmp.Map)
    
    % Creating temporary VOI file
    %voi_temp=voi;
    
    % For Multiple VOIs - Temporary Fix
    
    % Load VOI
    %[VOIName,VOIPath] = uigetfile('*.voi','Select Volume of Interest (VOI)');
    %voi = xff([VOIPath{1,1} filesep VOIName{z,1}]);
    
    % Single VOI - WM FIX
    voi = xff([VOIPath VOIName]);
    
    % Create Vector of Region Names from VOI file
    for zz=1:length(voi.VOI)
        
        %k = strfind(voi.VOI(zz).Name,'_');
        region_list{zz,1}=voi.VOI(zz).Name;
        %region_list{zz,1}=region_list{zz,1}((k(end)+1):end);
        
    end
    
    clear k zz;

    % Get Subject ID
    k = strfind(vmp.Map(z).Name,'_');
    subjID=vmp.Map(z).Name;
    subjID=subjID(1:(k(2)-1));
    
    % Negative Region Counter
    neg_count=0;
    
    % Get voxel details for each region
    for zz=1:length(region_list)
        
        % Set temporary VOI file to region iterated by loop
        %voi_temp.VOI=voi.VOI(zz);
        voi.VOI=voi.VOI(zz);
        
        % Pull voxel details from VMP using region
        %void=voi_temp.Details(vmp, z);
        void=voi.Details(vmp, z);
        
        % Move voxel data to temp file
        tempvoxelstats=void.VoxelData;
        
        % Coordinate System Check - ONLY DONE ONCE!!!
        if z==1 && zz==1
            
            % DIALOG BOX
            choice = questdlg({'First Coordinates: \n',[],num2str(tempvoxelstats(1,1:3)),[],'Convert to TAL?'}, ...
                'Coordinate System Check', ...
                'Yes','No','Cancel');
            
            % Handle response
            switch choice
                case 'Yes'
                    convert=1;
                case 'No'
                    convert=0;
                case 'Cancel'
                    break;
            end
            
        end
        
        % Convert BV System Coordinates to TAL System
        if convert==1
            
            TAL_X = 128 - tempvoxelstats(:,1);
            TAL_Y = 128 - tempvoxelstats(:,2);
            TAL_Z = 128 - tempvoxelstats(:,3);
            
            tempvoxdata=[TAL_X,TAL_Y,TAL_Z];
            
            clear TAL_X TAL_Y TAL_Z;
            
        else
            
            tempvoxdata=[tempvoxelstats(:,2), tempvoxelstats(:,3), tempvoxelstats(:,1)];
            
        end
        
        % Add t and p value data
        tempvoxdata(:,4)=tempvoxelstats(:,5);
        tempvoxdata(:,5)=tempvoxelstats(:,6);
        
        % Find peak activation
        [M,I]=max(tempvoxdata(:,4));
        
        % Store peak for sphere creation
        ctab(zz,1:5)=tempvoxdata(I,1:5);
        
        % NEGATIVE/0 t Value Flag
        if M<=0
            neg_count=neg_count+1;
            neg_val(neg_count)=zz;
        end
        
        % Write output
        dlmwrite(['statoutput/',subjID,'_',region_list{zz,1},'.txt'],tempvoxdata);
        
        
        % Reload VOI
        %voi = xff(strcat(VOIPath,VOIName));
        %voi = xff([VOIPath{1,1} filesep VOIName{z,1}]);
        
        % Single VOI - WM FIX
        voi = xff([VOIPath VOIName]);
        
        % Reload VMP??
        %vmp = xff(strcat(VMPPath,VMPName));
        
        clear tempvoxdata tempvoxelstats;
        
    end
    
    
    % Create & Save Spherical ROIs
    sphere_voi = xff('new:voi');
    
    % Make Spheres
    for cc = 1:size(ctab, 1)
        
        % Add coordinate
        %sphere_voi.AddSphericalVOI(ctab(cc, 1:3), 6);
        sphere_voi.AddSphericalVOI(ctab(cc, 1:3), 3);
        
        % Add Name to VOi
        %sphere_voi.VOI(cc).Name=strcat(subjID,'_',region_list{cc,1},'_6mm_Sphere.voi');
        sphere_voi.VOI(cc).Name=strcat(subjID,'_',region_list{cc,1},'_3mm_Sphere.voi');
        
    end
    
    % Update VOI Information
    sphere_voi.FileVersion=4;
    %savename=strcat(subjID,'_6mm_Spheres.voi');
    savename=strcat(subjID,'_3mm_Spheres.voi');
    
    % Save Sphere VOI
    sphere_voi.SaveAs(savename);
    
    % Create Summary File
    if z==1;
        basic_summary={'Subject ID','Negative/0 Peaks'};
        xlwrite('Peak_Summary.xls',basic_summary,'Summary','A1');
        startRange=strcat('A',num2str(z+1));
    else
        startRange=strcat('A',num2str(z+1));
    end
    
    % Include Non-Positive/Problem Peak Information
    if neg_count>0
        for q=1:length(neg_count)
            bad_regions(q,1)=region_list(neg_val(q));
        end
        
        bad_regions = strjoin(bad_regions,', ');
        subj_sum={subjID,bad_regions};
        
    else
        subj_sum={subjID,'All Positive'};
    end
    
    xlwrite('Peak_Summary.xls',subj_sum,'Summary',startRange);
    
    % Write Individual Subject Sheet
    startRange={'A1','A2'};
    %title=strjoin({'Regions','X','Y','Z','t value','p value'},', ');
    xlwrite('Peak_Summary.xls',{'Regions','X','Y','Z','t value','p value'},subjID,startRange{1});
    xlwrite('Peak_Summary.xls',[region_list,num2cell(ctab)],subjID,startRange{2});
    
    xlwrite('Peak_Summary.xls',{'Placement Fix Below'},subjID,'A16');
    xlwrite('Peak_Summary.xls',{'Regions','X','Y','Z','t value','p value'},subjID,'A17');
    xlwrite('Peak_Summary.xls',region_list,subjID,'A18');
    
    clear neg_count neg_val sphere_voi bad_regions subj_sum ctab startRange; %voi_temp
    
end

% Timing Debug
%toc;

    
