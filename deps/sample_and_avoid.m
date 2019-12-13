function point = sample_and_avoid(S, pts_to_avoid, sigma_sample, sigma_global)
% point = SAMPLE_AND_AVOID(S, pts_to_avoid, sigma_sample, sigma_global)
%
%   This takes the size of an ND array and returns a point that is unlikely
%   to be near a set of points to avoid (M x N). Points are avoided if they
%   are roughly sigma (1 x N) away from the list of provided points.

if length(sigma_sample) < length(S)
    
    sigma_sample(end+1:length(S)) = sigma_sample(end);
    
end
    
if length(sigma_global) < length(S)
    
    sigma_global(end+1:length(S)) = sigma_global(end);
    
end

N = length(S);

XN = cell(1,N);
mask = ones(S);

for j=1:N
    gv{j} = 1:size(mask,j);
end

[XN{:}] = ndgrid(gv{:});

if nargin > 3
    ctr = 0.5 + S/2;
    mask = mask.*exp(-((XN{j} - ctr(j)).^2/ ...
                          (2*sigma_global(j)^2)));
end


for i = 1:size(pts_to_avoid, 1)
    
    pt = pts_to_avoid(i, :);
    
    point_mask = ones(S);
    for j=1:N
        point_mask = point_mask.*exp(-((XN{j} - pt(j)).^2/ ...
                          (2*sigma_sample(j)^2)));
    end
    
    mask = mask .* (1-point_mask);
    
end

accepted = false;
while ~accepted
    
    for i = 1:N
        point{i} = randi(S(i));
    end
    
    p_thresh = mask(point{:});
    
    if rand() < p_thresh
        accepted = true;
    end
    
end