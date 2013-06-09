%% Signature extraction algorithm
function reconstructed_signature = signature_extraction(LLw_4, HHw_4, lengthOfWatermark)

% 2. Select all coefficient from LL4 and HH4 band
% reshape them to row vectors of size 1x256
LLw_4 = reshape(LLw_4, 1, length(LLw_4)^2);
HHw_4 = reshape(HHw_4, 1, length(HHw_4)^2);

% concatenate the above row vectors into a larger row vector of size 1x512
combined_LLw_4_and_HHw_4_coeff = [LLw_4 HHw_4];

% keep record of the index position of negatives to put back the sign in
% inverse process
negative_watermarked_idxs = combined_LLw_4_and_HHw_4_coeff(logical(combined_LLw_4_and_HHw_4_coeff)) < 0;

% keep only the positive integer parts
% combined_LLw_4_and_HHw_4_coeff_posint = round( abs( combined_LLw_4_and_HHw_4_coeff ) );

% separate the integer from the decimal fraction
combined_LLw_4_and_HHw_4_coeff_pos = abs(combined_LLw_4_and_HHw_4_coeff);
integer_part_of_watermarked_image = fix(combined_LLw_4_and_HHw_4_coeff_pos);
fraction_part_of_watermarked_image = abs(combined_LLw_4_and_HHw_4_coeff_pos - integer_part_of_watermarked_image);

% Clear workspace
clear('LLw_4', 'HHw_4', 'combined_LLw_4_and_HHw_4_coeff', ...
    'negative_watermarked_idxs', 'fraction_part_of_watermarked_image');

% Convert the integer part of selected coefficient into the binary code of L bits
binary_watermarked_coefficients = {};
for y = 1:length(combined_LLw_4_and_HHw_4_coeff_pos)
    % binary_watermarked_coefficients{y} = bitget( uint16( integer_part_of_watermarked_image(y) ), 16:-1:1 );
    binary_watermarked_coefficients{y} = decimalToBinaryVector(integer_part_of_watermarked_image(y), 16);
end

% Clear workspace
clear('combined_LLw_4_and_HHw_4_coeff_pos', 'integer_part_of_watermarked_image');

% 3. Extract the n-th (10-th) bit from the coefficient to extract the signature.
reconstructed_signature = zeros(1, lengthOfWatermark);
for u = 1:lengthOfWatermark
    for v = 1:16
        if (v == 10)
            reconstructed_signature(u) = binary_watermarked_coefficients{1, u}(v);
        end
    end
end

% Clear workspace
clear('binary_watermarked_coefficients');

end