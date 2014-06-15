function [ featureSubset ] = subsetSelection( full_features, poi_idx )
%{ 
    Author : Vaibhav Malpani 
    Uni: vom2102
    Course: Biometrics CS6737
    Homework 5 - Face Verification using SIFT features in SVM classifier
    
    Given the full feature set, choose desriptors corresponding to the 
    points in poi_idx
%}
    featureSubset = zeros(size(full_features,1),(size(poi_idx,2)*128)+1);
    featureSubset(:,1) = full_features(:,1);
    for i = 1 : size(poi_idx,2)
        idx = poi_idx(i);
        featureSubset(:,128*(i-1)+2:128*(i)+1) = full_features(:,128*(idx-1)+2:128*(idx)+1);
    end
end

