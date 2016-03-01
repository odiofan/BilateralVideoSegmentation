% slice bilateral data from the bilateral grid
function sliced = slice2(labels,bilateralData,gridSize)

[nPoints,nDims] = size(bilateralData);
[nVertices,nClasses] = size(labels);

% get ceil/floor for n-linear interpolation
floors = floor(bilateralData);
ceils = ceil(bilateralData);
remainders = bilateralData - floors;


sliced = zeros(nPoints,nClasses);

for i=1:2^nDims
    % use the binary representation as floor (0) and ceil (1)
    bin = dec2bin(i-1,nDims);
    
    weights = ones(nPoints,1);
    % multiply weights for each dimension
    for j=1:nDims
        if bin(j)=='0' % floor
            weights = weights .* (1-remainders(:,j));
            if j==1
                indices = floors(:,j);
            else
                indices = indices + prod(gridSize(1:j-1)).*(floors(:,j)-1);
            end
            
        else % ceil
            weights = weights .* remainders(:,j);
            if j==1
                indices = ceils(:,j);
            else
                indices = indices + prod(gridSize(1:j-1)).*(ceils(:,j)-1);
            end
            
        end
    end
    
    sliced = sliced + labels(indices) .* weights;
end
