%% Signature generation algorithm for authenticating matrices U and V
function signature = signature_generation(U, V, key)

% Proposed algorithm
% 1. Sum the column of orthogonal matrices and create 1-D array
Usum = sum(U);
Vsum = sum(V);

% 2. Based on the threshold, map the array values into corresponding binary digits
Usum_threshold = median(Usum);  % threshold based on median value of each Uw & Vw matrix
Vsum_threshold = median(Vsum);

% transform Usum martix to binary using above threshold
Usum(find(Usum > Usum_threshold)) = 1;
Usum(find(Usum < Usum_threshold)) = 0;

% transform Vsum martix to binary using above threshold
Vsum(find(Vsum > Vsum_threshold)) = 1;
Vsum(find(Vsum < Vsum_threshold)) = 0;

clear('Usum_threshold', 'Vsum_threshold');

% XOR the 2 matrices to obtain 1-D array of dimension 1x512
UV_XOR = bitxor(uint8(Usum), uint8(Vsum));

% 3. Generate a PSRNG sequence using the key of dim. 1x512 and XOR it with
%    the UV_XOR 1-D array above
rand('seed', key);
% produce binary sequence to perform XOR with UVsum
binary_seq = randi([0 1], 1, length(UV_XOR));
signature = double( bitxor(uint8(UV_XOR), uint8(binary_seq)) ); % signature length=512

clear('Usum', 'Vsum', 'UV_XOR', 'binary_seq');
end