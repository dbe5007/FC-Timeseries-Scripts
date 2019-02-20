cond={'faces','objects'};

for z=1:length(filenames)
    
    ts=csvread(filenames{z,1});
    
    for x=1:length(cond)
        
        for y=1:size(ts,2)
            
            ts_new(:,y)=ts(:,y).*conditions.(cond{1,x});
            
        end
        
        ts_new=num2cell(ts_new);
        
        cell2csv([filenames{z,1}(1:end-4) '_' cond{1,x} '.csv'],ts_new);
        
        clear ts_new;
        
    end
    
end
        