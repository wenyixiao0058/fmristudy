function [senmap, fenmap] = multiscale_entropy4fmri(varargin)
switch nargin

    case 7
        data = varargin{1};
        mask = varargin{2};
        scale = varargin{3};
        m = varargin{4};
        r = varargin{5};
        n = varargin{6};
        tau = varargin{7};

    otherwise
        "Error: incorrect number of inputs!"
end

% size of mask
senmap=cell(1,scale);
fenmap=cell(1,scale);
for ss = 1:scale
    senmap{ss}=zeros(size(mask));
    fenmap{ss}=zeros(size(mask));
end

for ii = 1:size(data,1)
    MFE(ii,:)=MSE_mu(data(ii,:),m,r,tau,scale);
    MSE(ii,:)=MFE_mu(data(ii,:),m,r,n,tau,scale);
end


for ss = 1:scale
    senmap{ss}(mask) = MSE(:,ss);
    fenmap{ss}(mask) = MFE(:,ss);
end

