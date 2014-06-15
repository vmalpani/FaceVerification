% LABELS is a vector of binary class labels.  Positive indicates the "positive" class, negative
% or zero indicates "negative."
% SCORES is a vector of scores, with larger values indicating greater likelihood of the positive
% class.  If the values
% To plot an ROC curve:
%   [tp, fp] = roc(labels, scores);
%   plot(fp, tp);
function [tp, fp, threshes, eer, eeThresh] = roc(labels, scores)

% Convert labels to strictly 1s (positive) and 0s (negative).
labels = (labels > 0);

% Sort from most likely to be postive to most likely to be negative.
[sscores, sscoreixes] = sort(scores, 'descend');
slabels = labels(sscoreixes);

% True positive and false positive rates at each threshold.
tp = cumsum(slabels) ./ sum(slabels);
fp = cumsum(~slabels) ./ sum(~slabels);

% Note that if we have multiple samples with the same score, we cannot really classify some of
% them as positive and others as negative.  So only the last (tp, fp) pair for each score should
% be included (based on the idea than anything with score greater than *or equal to* the
% threshold is classified positive).
oldscore = sscores(end);
isgood = true(size(sscores));
for ix = length(sscores)-1:-1:1
    if sscores(ix) == oldscore
        isgood(ix) = false;
    else
        oldscore = sscores(ix);
    end
end
goodpoints = find(isgood);
threshes = sscores(goodpoints);
tp = tp(goodpoints);
fp = fp(goodpoints);

% Equal error mean false_positive_rate = false_negative_rate.
% false_negative_rate = 1 - true_positive_rate, so we want to find where fp = 1 - tp, or
% where 1 - tp - fp = 0.  We may not be able to hit that exactly, but get as close as we can,
% taking the mean in the case of a tie.
d = 1 - tp - fp;
iee = find(abs(d) == min(abs(d)));
assert(length(iee) >= 1);
eeThresh = mean(threshes(iee));
eetp = sum((scores >= eeThresh) & labels) / sum(labels);
eefp = sum((scores >= eeThresh) & ~labels) / sum(~labels);
eer = mean([eetp 1-eefp]);

assert(tp(1) > 0 || fp(1) > 0);
if fp(1) ~= 0
    if size(tp, 1) > 1
        tp = [0; tp]; fp = [0; fp]; threshes = [inf; threshes];
    else
        tp = [0 tp]; fp = [0 fp]; threshes = [inf threshes];
    end
end
assert(tp(end) == 1 && fp(end) == 1);
