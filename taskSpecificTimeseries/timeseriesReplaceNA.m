%% Fix Timeseries Values
%  Daniel Elbich
%  Penn State University
%  1/22/18
%
%
%  Coding all values equaling zero with NA. New values will
%  be ignored by GIMME program when modeling networks.

for a=1:length(names)

    % Read in CSV files
    m=csvread(names{a,1});
    
    for p=1:length(m)

        % Checks every cell in all timeseries and replaces 0 with 'NA'
        for q=1:size(m,2)
            if m(p,q)==0
                n{p,q}='NA';
            else
                n{p,q}=m(p,q);
            end
        end

        % Clear loop counter
        clear q;

    end

    % Saves timeseries to new CSV file
    cell2csv([names{a,1}(1:end-4) '_NA.csv'],n)
    
    clear m n p;
    
end

% Cleanup
clear a;
