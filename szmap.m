function [szsenmap, szfenmap] = szmap(varargin)
switch nargin
    case 4
        rawsenmap = varargin{1};
        rawfenmap = varargin{2};
        mask = varargin{3};
        scale = varargin{4};

end

for ss = 1:scale
    szsenmap{ss}=zeros(size(mask));
    szfenmap{ss}=zeros(size(mask));
end

%
for ss = 1:scale
    all_mean(ss) = mean(nonzeros(rawsenmap{ss}(:)));
    all_sd(ss) = std(nonzeros(rawsenmap{ss}(:)));
    szsen{ss}(:) = minus(nonzeros(rawsenmap{ss}),all_mean(ss))./all_sd(ss);
    szsenmap{ss}(mask) = szsen{ss};
end

clear all_mean all_sd

for ss = 1:scale
    all_mean(ss) = mean(nonzeros(rawfenmap{ss}(:)));
    all_sd(ss) = std(nonzeros(rawfenmap{ss}(:)));
    szfen{ss}(:) = minus(nonzeros(rawfenmap{ss}(:)),all_mean(ss))./all_sd(ss);
%     if length(nonzeros(rawfenmap{ss}(:))) ~= 66429
%         continue
    szfenmap{ss}(mask) = szfen{ss};
%     end
end
end