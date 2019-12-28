function [conservation] = conservation(seq,bs_indices)

load('genes_training.mat');
cons = genes_training.conservation;
L = length(bs_indices);
avg = 0;
conservation = [];

for j=1:1:L
    a = bs_indices(j); %1st binding site index
    for i=0:1:6
        avg = avg + seq.conservation(i+a); %???? ????? ??????? ?? ????? 
    end
    conservation = [conservation, avg/7];
    avg = 0;
end

conservation = conservation;
end

