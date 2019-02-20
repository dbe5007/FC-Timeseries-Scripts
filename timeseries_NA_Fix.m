for a=1:length(names)
    
    m=csvread(names{a,1});
    
    for p=1:length(m)
        
        for q=1:size(m,2)
            if m(p,q)==0
                n{p,q}='NA';
            else
                n{p,q}=m(p,q);
            end
            
        end
    end
    
    cell2csv([names{a,1}(1:end-4) '_NA.csv'],n)
    
    clear m n p;
    
end


clear a q;