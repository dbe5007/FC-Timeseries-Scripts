%% Automated Volume Map (VMP) Creation
%  Daniel Elbich
%  Penn State University
%  1/22/17
%
%
%  Requirements: BrainVoyager compatible GLM
%  This creates volume maps (VMPs) for reading into BrainVoyager. Create a subject and list of paths to the GLMs
%  you would like to create volume maps from. Code will not match subjects to paths so be sure both are in the
%  correct order. Values in the 'contrast' variable reflect placement and weighting of experimental condtions.
%  Update contrast as appropriate with given dataset.

% Timing Debug
%tic;

% Variables 'subjID' and 'glmpaths' must be created prior to code execution. Written to take cell input.

for a = 1:length(subjID)

% Read in GLM file
glm = xff(glmpaths{a,1});

% Set Contrast - Example weights 1st condition by 2, 2nd & 3rd conditions by -1, and ignores the 4th condition
contrast = glm.FFX_tMap([-2;-1;-1;0]);

% Map Name - Concatenates subject ID and contrast, but is not required
contrast.Map.Name = strcat(subjID{a,1},'CondtionA>CondtionB');

% Save VMP Files
if a == 1
    % Creates concatenated VMP for all subjects on 1st run of loop
    final_all = contrast;
    final_all.SaveAs(strcat('~/path/to/output/all.vmp'));
else
    % Open concatenated VMP for updating
    final_all=xff('~/path/to/output/subject_only.vmp');

    % Updates concatenated VMP to accomodate addition of new subject VMPs
    for aa=1:a
        final_all.Map(a).RunTimeVars=[];
    end

    %Iteratively saves all VMPs into one file
    final_all.Map(a) = contrast.Map;
    final_all.SaveAs(strcat('~/path/to/output/all.vmp'));
end

% Save subject VMP specifically
contrast.SaveAs(strcat('/path/to/vmps/',subjID{a,1},'_CondtionA.vmp'));

% Clean Up - contrast and GLM must be cleared on each iteration due to MATLAB memory limitations
contrast.ClearObject;
glm.ClearObject;

end

% Timing Debug
%toc;




