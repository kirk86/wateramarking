%% Watermark extraction algorithm
function [watermark_logo_extracted, generated_signature, reconstructed_signature, LLw_4, HHw_4] = watermark_extraction(watermarked_image, watermark_logo, key, print_figures, signature_authentication)

% 1. Using Haar wavelet, decompose the noisy watermarked image into four
% sub-bands: LL, HL, LH, and HH
[LLw HLw LHw HHw] = dwt2(watermarked_image, 'haar');

% 2. Further decompose LL band to the 4th level.
[LLw_1, HLw_1, LHw_1, HHw_1] = dwt2(LLw, 'haar');    % 1st step DWT
[LLw_2, HLw_2, LHw_2, HHw_2] = dwt2(LLw_1, 'haar');  % 2nd step DWT
[LLw_3, HLw_3, LHw_3, HHw_3] = dwt2(LLw_2, 'haar');  % 3rd step DWT
[LLw_4, HLw_4, LHw_4, HHw_4] = dwt2(LLw_3, 'haar');  % 4rth step DWT

% Clear workspace
clear('LLw_1', 'LLw_2', 'LLw_3', ...
    'HLw_1', 'HLw_2', 'HLw_3', 'HLw_4', ...
    'LHw_1', 'LHw_2', 'LHw_3', 'LHw_4', ...
    'HHw_1', 'HHw_2', 'HHw_3', ...
    'LLw', 'HLw', 'LHw');

% 3. Apply SVD to watermark logo
[Uw_x Sw_x Vw_x] = svd(watermark_logo, 'econ');

% 4. Generate signature using Uw & Vw matrices
generated_signature = signature_generation(Uw_x, Vw_x, key);

% 5. Extract signature from LLw_4 & HHw_4 bands using all of the 512
% coefficients
reconstructed_signature = signature_extraction(LLw_4, HHw_4, length(watermark_logo));

if (signature_authentication == true)
    
    % 6. Compare the 2 signatures
    if ( reconstructed_signature == generated_signature | corr2(reconstructed_signature, generated_signature) > 0.7 )
        % proceed to watermark extraction if authentication is successful
%         helpdlg('Authentication was successful!');
        
        % 8. Apply SVD to HH band
        [Ucw Scw Vcw] = svd(HHw, 'econ');
        
        % 9. Extract the singular values from HH band
        HH_singularValues = zeros(length(watermark_logo));
        Shh_diag = diag(HH_singularValues);
        Scw_diag = diag(Scw);
        %for jj = 1:size(Sw_x, 1)
        %    Shh_diag(jj) = Scw_diag(jj);
        %end
        if (length(watermark_logo) >= 256)
            Shh_diag(1:length(Scw), :) = Scw_diag;
        elseif (length(watermark_logo) < 256)
            Shh_diag(1:length(watermark_logo), :) = Scw_diag(1:length(watermark_logo), :);
        end
        HH_singularValues(logical(eye(size(HH_singularValues)))) = Shh_diag;
        
        % 10. Construct the watermark using singular values and orthogonal matrices
        % Uw and Vw obtained using SVD of original watermark
        watermark_logo_extracted = Uw_x * HH_singularValues * Vw_x';
        
        % Clear workspace
        clear( 'Uw_x', 'Sw_x', 'Vw_x', ...
            'Ucw', ',Scw', 'Vcw', 'HH_singularValues', 'Shh_diag', ...
            'Scw_diag');
        
        if (print_figures == true)
            figure;
            imshow(watermark_logo_extracted, []);
            title('Extracted watermark');
        end
        
        % This constitutes a blind decoding as watermark extraction process does
        % not require original cover image for extracting the watermark at the receiver
    else
        errordlg('Authetication Failure. The signatures do not match. No watermark extracted!');
        watermark_logo_extracted = zeros(length(watermark_logo), length(watermark_logo));
        return;
    end
else
    % Proceed directly to watermark extraction based on random selected
    % values from HH band using the key as an indicator
    %     rand('seed', key);
    % produce random sequence to choose HH values
    %     index = randi([1 256], 1, length(watermark_logo));
    
    % 8. Apply SVD to HH band
    [Ucw Scw Vcw] = svd(HHw, 'econ');
    
    % 9. Extract the singular values from HH band
    HH_singularValues = zeros(length(watermark_logo));
    Shh_diag = diag(HH_singularValues);
    Scw_diag = diag(Scw);
    % Choose random values from Scw base on key index
    %     Scw_random_diag = Scw(index);
    
    %for jj = 1:size(Sw_x, 1)
    % Shh_diag(jj) = Scw_diag(jj);
    %   Shh_diag(jj) = Scw_random_diag(jj);
    %end
    %     Shh_diag = Scw_random_diag;
    if (length(watermark_logo) >= 256)
        Shh_diag(1:length(Scw), 1) = Scw_diag;
    elseif (length(watermark_logo) < 256)
        Shh_diag(1:length(watermark_logo), :) = Scw_diag(1:length(watermark_logo), :);
    end
    HH_singularValues(logical(eye(size(HH_singularValues)))) = Shh_diag;
    
    % Clear workspace
    clear('Ucw', 'Scw', 'Vcw', 'Shh_diag', 'Scw_diag', 'Scw_random_diag');
    
    % 10. Construct the watermark using singular values and orthogonal matrices
    % Uw and Vw obtained using SVD of original watermark
    watermark_logo_extracted = Uw_x * HH_singularValues * Vw_x';
    
    % Clear workspace
    clear('HH_singularValues');
    
    if (print_figures == true)
        figure;
        imshow(watermark_logo_extracted, []);
        title('Extracted watermark');
    end
    
end

end