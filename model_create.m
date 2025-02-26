%% Create model here
clear, clc

load('data_sets/challenge_data/miR_validation.mat')

addpath nico_functions
addpath lotem_functions
addpath michal_functions

%  Pull Data  --- THIS DOES NOT HAVE TO BE TOUCHED

clear, clc 
challenge_path = 'data_sets/validation_data/';

load('data_sets/challenge_data/genes_validation.mat');
gene_validation = genes;


miRs_validation = load('data_sets/challenge_data/miR_validation.mat');
mirs_validation(1,:) = keys(miRs_validation.miRs);
mirs_validation(2,:) = values(miRs_validation.miRs);


save(strcat(challenge_path, 'gene_validation_use.mat'), 'gene_validation');
save(strcat(challenge_path, 'mirs_validation_use.mat'), 'mirs_validation');

%% Find the first instance of miRNA mRNA binding for each combination (Nico)
clear, clc

load('data_sets/validation_data/mirs_validation_use.mat')
load('data_sets/validation_data/gene_validation_use.mat')


run_initiation = input("Do you want to recalculate the miRNA-mRNA binding "  +  ...
"indices? This action will take approximatelly 2 minutes... \n([Y] = 1, [N] = 0):  ");

mirs_validation = mirs_validation(2, :);
fake_repress = ones(1, size(gene_validation, 1));


if run_initiation 
    fprintf("\nThis will take a minute...\n\n");
    temp = binding_indices_validation(mirs_validation, gene_validation, 'data_sets/validation_data/');

end
clearvars run_initiation

%% WIndows

clear, clc

load('data_sets/validation_data/true_indices.mat')
load('data_sets/validation_data/gene_validation_use.mat')

get_gene_windows(gene_validation,true_indices, 'validation_windows', 74, "validation");

%% Feature: Thermodynamics
path = 'data_sets/validation_data/';
path2 = 'data_sets/challenge_data/';

load(strcat(path, "reshaped_validation_windows.mat"))

calc_folding_e = input("\nWould you like to calculate folding " + ...
    "energies?\nThis will take a few minutes..\n [Y]:1, [N]:0\n>>");
if calc_folding_e == 1
    
    %tic
    dim = 0; % change this value depending of sequence region target
    folding_energies = find_folding_energies(windows_reshaped, "validation");
    %fold_energy_time = toc;  
end
clearvars calc_folding_e
 
%% Feature: Conservation

load(strcat(path, 'conservations.mat'));
load(strcat(path, 'whole_conservations.mat'));

conservation_ratios = cell(1, 3);
conservation_ratios{1, 1} = conservation{1, 1} ./ whole_conservations_reshaped{1, 1};
conservation_ratios{1, 2} = conservation{1, 2} ./ whole_conservations_reshaped{1, 2};
conservation_ratios{1, 3} = conservation{1, 3} ./ whole_conservations_reshaped{1, 3};

save(strcat(path, 'conservation_ratios.mat'), 'conservation_ratios');

%% Feature: Distance to terminus

load(strcat(path, 'reshaped_indices.mat'));
load(strcat(path, 'total_lengths.mat'));

[terminus_distance_one, terminus_distance_two] = distance_edge(reshaped_indices, lengths_reshaped, "training");

distance_ratio_one = cell(1, 3);
distance_ratio_two = cell(1, 3);
distance_ratio_three = cell(1, 3);

for i = 1:3
    distance_ratio_three{1, i} = reshaped_indices{1, i}./ lengths_reshaped{1, i};
    distance_ratio_one{1, i} = terminus_distance_one{1, i}./lengths_reshaped{1, i};
    distance_ratio_two{1, i} = terminus_distance_two{1, i}./lengths_reshaped{1, i};
end

clearvars i ans titles
save(strcat(path, 'terminus_distance_one.mat'), 'terminus_distance_one')
save(strcat(path, 'terminus_distance_two.mat'), 'terminus_distance_two')
save(strcat(path, 'distance_ratio_one.mat'), 'distance_ratio_one')
save(strcat(path, 'distance_ratio_two.mat'), 'distance_ratio_two')
save(strcat(path, 'distance_ratio_three.mat'), 'distance_ratio_three')

%% Feature: CAI 

load(strcat(path, 'reshaped_validation_windows.mat'));
load(strcat(path2, 'codon_CAI.mat'));
load(strcat(path, 'whole_sequence.mat'));

cai_reshaped = cell(1, 3);
cai_whole_reshaped = cell(1,3);

Sequences_ORF = windows_reshaped{1,2};
Sequence_ORF_whole = whole_reshaped{1, 2};
cai_reshaped{1,2} = CAI_generator(Sequences_ORF,codon_CAI);
cai_whole_reshaped{1, 2} = CAI_generator(Sequence_ORF_whole, codon_CAI);
cai_ratio{1, 2} = cai_reshaped{1, 2}./cai_whole_reshaped{1, 2};

Sequences_UTR5 = windows_reshaped{1,1};
Sequence_UTR5_whole = whole_reshaped{1, 1};
cai_reshaped{1, 1} = CAI_generator(Sequences_UTR5,codon_CAI);
cai_whole_reshaped{1, 1} = CAI_generator(Sequence_UTR5_whole, codon_CAI);
cai_ratio{1, 1} = cai_reshaped{1, 1}./cai_whole_reshaped{1, 1};

Sequences_UTR3 = windows_reshaped{1,3};
Sequence_UTR3_whole = whole_reshaped{1, 3};
cai_reshaped{1, 3} = CAI_generator(Sequences_UTR3,codon_CAI);
cai_whole_reshaped{1, 3} = CAI_generator(Sequence_UTR3_whole, codon_CAI);
cai_ratio{1, 3} = cai_reshaped{1, 3}./cai_whole_reshaped{1, 3};

clearvars ans CAI_ORF CAI_UTR3 CAI_UTR5 Sequences_ORF Sequences_UTR3 Sequences_UTR5 titles windows_reshaped i codon_CAI 
save(strcat(path, 'cai_reshaped.mat'), 'cai_reshaped')
save(strcat(path, 'cai_whole_reshaped.mat'), 'cai_whole_reshaped')
save(strcat(path, 'cai_ratio.mat'), 'cai_ratio')

%% Feature: tAI 


load(strcat(path, 'reshaped_validation_windows.mat'));
load(strcat(path2, 'codon_tAI.mat'));
load(strcat(path, 'whole_sequence.mat'));

tai_reshaped = cell(1, 3);
tai_whole_reshaped = cell(1,3);

Sequences_ORF = windows_reshaped{1,2};
Sequence_ORF_whole = whole_reshaped{1, 2};
tai_reshaped{1,2} = CAI_generator(Sequences_ORF,codon_tAI);
tai_whole_reshaped{1, 2} = CAI_generator(Sequence_ORF_whole, codon_tAI);
tai_ratio{1, 2} = tai_reshaped{1, 2}./tai_whole_reshaped{1, 2};

Sequences_UTR5 = windows_reshaped{1,1};
Sequence_UTR5_whole = whole_reshaped{1, 1};
tai_reshaped{1, 1} = CAI_generator(Sequences_UTR5,codon_tAI);
tai_whole_reshaped{1, 1} = CAI_generator(Sequence_UTR5_whole, codon_tAI);
tai_ratio{1, 1} = tai_reshaped{1, 1}./tai_whole_reshaped{1, 1};

Sequences_UTR3 = windows_reshaped{1,3};
Sequence_UTR3_whole = whole_reshaped{1, 3};
tai_reshaped{1, 3} = CAI_generator(Sequences_UTR3,codon_tAI);
tai_whole_reshaped{1, 3} = CAI_generator(Sequence_UTR3_whole, codon_tAI);
tai_ratio{1, 3} = tai_reshaped{1, 3}./tai_whole_reshaped{1, 3};



clearvars ans tAI_ORF tAI_UTR3 tAI_UTR5 Sequences_ORF Sequences_UTR3 Sequences_UTR5 titles windows_reshaped i codon_tAI 
save(strcat(path, 'tai_reshaped.mat'), 'tai_reshaped');
save(strcat(path, 'tai_whole_reshaped.mat'), 'tai_whole_reshaped');
save(strcat(path, 'tai_ratio.mat'), 'tai_ratio');

%% GC content (Michal)

load(strcat(path, 'reshaped_validation_windows.mat'));
load(strcat(path, 'whole_sequence.mat'));


gc_reshaped = cell(1, 3);
gc_whole_reshaped = cell(1, 3);
gc_ratio = cell(1, 3);

%reshaped_nt_windows.mat is windows_reshaped
Sequences_ORF = windows_reshaped{1,2};
gc_reshaped{1, 2} = GC_content_generator(Sequences_ORF);
gc_whole_reshaped{1, 2} = GC_content_generator(whole_reshaped{1,2});
gc_ratio{1, 2} = gc_reshaped{1, 2} ./ gc_whole_reshaped{1, 2};

Sequences_UTR5 = windows_reshaped{1,1};
gc_reshaped{1, 1} = GC_content_generator(Sequences_UTR5);
gc_whole_reshaped{1, 1} = GC_content_generator(whole_reshaped{1,1});
gc_ratio{1, 1} = gc_reshaped{1, 1} ./ gc_whole_reshaped{1, 1};

Sequences_UTR3 = windows_reshaped{1,3};
gc_reshaped{1, 3} = GC_content_generator(Sequences_UTR3);
gc_whole_reshaped{1, 3} = GC_content_generator(whole_reshaped{1,3});
gc_ratio{1, 3} = gc_reshaped{1, 3} ./ gc_whole_reshaped{1, 3};

clearvars ans CAI_ORF CAI_UTR3 CAI_UTR5 Sequences_ORF Sequences_UTR3 Sequences_UTR5 titles windows_reshaped i codon_CAI 
save(strcat(path, 'gc_reshaped.mat'), 'gc_reshaped')
save(strcat(path, 'gc_whole_reshaped.mat'), 'gc_whole_reshaped')
save(strcat(path, 'gc_ratio.mat'), 'gc_ratio')

%% RUN

clear, clc


% CAI Scores
load('data_sets/validation_data/cai_reshaped.mat')
load('data_sets/validation_data/cai_whole_reshaped.mat')
load('data_sets/validation_data/cai_ratio.mat')

% GC content
load('data_sets/validation_data/gc_reshaped.mat')
load('data_sets/validation_data/gc_whole_reshaped.mat')
load('data_sets/validation_data/gc_ratio.mat')

% Terminus distances
load('data_sets/validation_data/terminus_distance_one.mat')
load('data_sets/validation_data/terminus_distance_two.mat')
load('data_sets/validation_data/distance_ratio_one.mat')
load('data_sets/validation_data/distance_ratio_two.mat')
load('data_sets/validation_data/distance_ratio_three.mat')
load('data_sets/validation_data/total_lengths.mat')
load('data_sets/validation_data/reshaped_indices.mat')

% Energies
load('data_sets/validation_data/folding_energies.mat')

%   tAI
load('data_sets/validation_data/tai_reshaped.mat')
load('data_sets/validation_data/tai_whole_reshaped.mat')
load('data_sets/validation_data/tai_ratio.mat')

% Conservation
load('data_sets/validation_data/conservations.mat')
load('data_sets/validation_data/conservation_ratios.mat')
load('data_sets/validation_data/whole_conservations.mat')

%%  MODEL VALIDATION ORF

for i = 2
   
load('regression_models/orf_model.mat')
X =     [cai_reshaped{i}', cai_whole_reshaped{i}', cai_ratio{i}', ...
    conservation{i}', whole_conservations_reshaped{i}', conservation_ratios{i}', ...
    gc_reshaped{i}', gc_whole_reshaped{i}', gc_ratio{i}', ...
    reshaped_indices{i}', terminus_distance_one{i}', terminus_distance_two{i}',...
    distance_ratio_one{i}', distance_ratio_two{i}', distance_ratio_three{i}', ...
    folding_energies{i}', ...
    tai_reshaped{i}', tai_whole_reshaped{i}', tai_ratio{i}'];
    
    % IF LASSO
%     coef = orf_model.coef;
%     coef0 = orf_model.coef0;
%     lasso_y_pred = coef' * X' + coef0; 
    % IF STEPWISE
    validation_orf = predict(orf_model, X); 
    
end

load('data_sets/validation_data/reconstruct_index_two.mat')
pred_orf = reconstruct_data(validation_orf, reconstruct_index_two);
save('validation_predictions/pred_orf.mat', 'pred_orf');

%% MODEL VALIDATION ORF


load('regression_models/utr3_model.mat')
i = 3;

X =     [cai_reshaped{i}', cai_whole_reshaped{i}', cai_ratio{i}', ...
    conservation{i}', whole_conservations_reshaped{i}', conservation_ratios{i}', ...
    gc_reshaped{i}', gc_whole_reshaped{i}', gc_ratio{i}', ...
    reshaped_indices{i}', terminus_distance_one{i}', terminus_distance_two{i}',...
    distance_ratio_one{i}', distance_ratio_two{i}', distance_ratio_three{i}', ...
    folding_energies{i}', ...
    tai_reshaped{i}', tai_whole_reshaped{i}', tai_ratio{i}'];

% 
% coef = lasso_model{i}.coef;
% coef0 = lasso_model{i}.coef0;
% lasso_y_pred{i} = coef' * X' + coef0; 

validation_utr3 = predict(utr3_model, X); 


load('data_sets/validation_data/reconstruct_index_three.mat')
pred_utr3 = reconstruct_data(validation_utr3, reconstruct_index_three);
save('validation_predictions/pred_utr3.mat', 'pred_utr3');
