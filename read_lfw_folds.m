% Reads a file in the format of LFW's pairs.txt, and returns a struct array describing the
% folds, with one entry per fold.  Each entry has two members, 'labels' which is a column vector
% of labels (1 for same, -1 for different), and 'pairs', which is a two-column cell array with
% the image paths in each pair.
function folds = read_lfw_folds(pairspath)

% clear all;
% pairspath = 'pairs.txt';

fin = fopen(pairspath);
nums = textscan(fin, '%d %d', 1, 'collectoutput', true);
nfolds = nums{1}(1);
nperfold = nums{1}(2);

folds = struct('labels', {}, 'pairs', {});
for ifold = 1:nfolds
    pairs = cell(nperfold*2, 2);
    d = textscan(fin, '%s %d %d', nperfold, 'collectoutput', true);
    for iperfold = 1:nperfold
        sub = d{1}{iperfold};
        n1 = d{2}(iperfold, 1);
        n2 = d{2}(iperfold, 2);
        pairs(iperfold, :) = { ...
            sprintf('%s/%s_%04d.jpg', sub, sub, n1), ...
            sprintf('%s/%s_%04d.jpg', sub, sub, n2)};
    end
    d = textscan(fin, '%s %d %s %d', nperfold, 'collectoutput', true);
    for iperfold = 1:nperfold
        sub1 = d{1}{iperfold};
        n1 = d{2}(iperfold);
        sub2 = d{3}{iperfold};
        n2 = d{4}(iperfold);
        pairs(nperfold+iperfold, :) = { ...
            sprintf('%s/%s_%04d.jpg', sub1, sub1, n1), ...
            sprintf('%s/%s_%04d.jpg', sub2, sub2, n2)};
    end
    folds(ifold) = struct('labels', {[ones(nperfold, 1); -ones(nperfold, 1)]}, ...
                          'pairs', {pairs});
end
while 1
    s = fgetl(fin);
    if s == -1, break; end;
    assert(length(s) == 0);
end
fclose(fin);
