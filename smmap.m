function [smsenmap, smfenmap] = smmap(varargin)
switch nargin
    case 4
        rawsenmap = varargin{1};
        rawfenmap = varargin{2};
        mask = varargin{3};
        scale = varargin{4};

end

for ss = 1:scale
    smsenmap{ss}=zeros(size(mask));
    smfenmap{ss}=zeros(size(mask));
end

% 
for ss = 1:scale
all_mean(ss) = mean(nonzeros(rawsenmap{ss}(:)));
smsen{ss}(:) = nonzeros(rawsenmap{ss}(:))./all_mean(ss);
smsenmap{ss}(mask) = smsen{ss};
end

clear all_mean 

for ss = 1:scale
all_mean(ss) = mean(nonzeros(rawfenmap{ss}(:)));
smfen{ss}(:) = nonzeros(rawfenmap{ss}(:))./all_mean(ss);
smfenmap{ss}(mask) = smfen{ss};
end