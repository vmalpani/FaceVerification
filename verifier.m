function [test,train] = verifier(pairs_path, data_path, out_path)
% %{
% Author : Vaibhav Malpani 
% Uni: vom2102
% Course: Biometrics CS6737
% Homework 5 - Face Verification using SIFT features in SVM classifier
% 
% This is the main function which calls all other functions to generate
% features, normalize them and train the SVM classifier to generate a model 
% used to classify the test data. Finally, a ROC curve is generated and 
% ouput is printed to the desired file.
% %}
folds = read_lfw_folds(pairs_path);
train = [];
test = [];

% Building 1st fold -> test and rest -> train
% Saving it to disk to perform further analysis
for i = 1 : size(folds,2)
    fprintf('\nIn Fold: %d\n', i)
    if i == 1
        test = [test ; folds2split(folds(1,i), data_path)];
    else
        train = [train ; folds2split(folds(1,i), data_path)];
    end
end

fprintf('Saving features to disk...\n')
save('test.mat', 'test');
save('train.mat', 'train');

fprintf('Loading Features\n')
te = load ('test.mat');
tr = load ('train.mat');

% Feature Selection
train_set = tr.train(:,:);
test_set = te.test(:,:);
full_set = double([test_set;train_set]);

% Selecting face points to generate optimal feature subset
fprintf('POI Selected\n')
feature_idx = [1,3,4,6,7,9,10,12,13,16,17,20, 21,22,23, 27,29]

featureSubset = subsetSelection(full_set, feature_idx);

fprintf('Normalizing Features\n')
for i = 2 : size(featureSubset,2)
    featureSubset(:,i) = (featureSubset(:,i) - mean(featureSubset(:,i)))./(std(featureSubset(:,i)) + eps);
end

decision_val = [];
output_labels = [];
all_test_labels = featureSubset(:,1);
all_accuracy = zeros(1,10);
% Iteratively cross-validating each fold
for j = 1:10
    trainArray = zeros(size(train_set,1),size(featureSubset,2));
    testArray = zeros(size(test_set,1),size(featureSubset,2));
    fprintf('\nFold %d\n', j)
    for i = 1 : 10
        if i == j
            testArray(:,:) = featureSubset((600*(i-1))+1:600*(i),:);
        elseif i > j
            trainArray((600*(i-2))+1:600*(i-1),:) = featureSubset((600*(i-1))+1:600*(i),:);
        else
            trainArray((600*(i-1))+1:600*(i),:) = featureSubset((600*(i-1))+1:600*(i),:);
        end
    end
    train_features = trainArray(:,2:end);
    train_labels = trainArray(:,1);

    test_features = testArray(:,2:end);
    test_labels = testArray(:,1);

    % change cost of misclassification
    % e = The default parameter (-e 0.001) sets this value. 
    % The smaller the value is, the more accurate will the trained model be, 
    % but the more iterations will be taken.
    % c = cost
    % g = gamma
    fprintf('Training SVM...\n')
    model = svmtrain(train_labels, train_features);

    fprintf('Classifying the test data...\n')
    [predict_label, accuracy, prob_estimates] = svmpredict(test_labels, test_features, model);
    
    decision_val = [decision_val; prob_estimates];
    output_labels = [output_labels; predict_label];
    fprintf('Accuracy: %f\n', accuracy(1))
    all_accuracy(j) = accuracy(1);
end
fprintf('All Folds Accuracies: %f %f %f %f %f %f %f %f %f %f\n', all_accuracy(:));
fprintf('Mean Accuracy: %f\n', mean(all_accuracy));
fprintf('Std. Deviation: %f\n', std(all_accuracy));

count = 0;
fid1 = fopen(pairs_path, 'rt');
fid2 = fopen(out_path, 'wt');
fprintf('Writing Output. Pls check "pairs_out.txt"\n')
while feof(fid1) == 0
    count = count + 1;
    if count == 1
        tline = fgetl(fid1);
        nline = [tline, '\n'];
        fprintf(fid2, nline);
    else
        tline = fgetl(fid1);
        nline = [num2str(decision_val(count-1)), '\t', tline, '\n'];
        fprintf(fid2, nline);
    end
end
fclose(fid1);
fclose(fid2);

fprintf('Generating ROC...\n')
[tp, fp] = roc(all_test_labels, decision_val);
plot(fp, tp);
legend('SIFT & SVM');
xlabel('False Positive Rate(FPR)','FontSize',16);
ylabel('True Positive Rate(FPR)','FontSize',16);
title('ROC Curve','FontSize',16);
end