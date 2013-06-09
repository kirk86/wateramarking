%% Watermark Embedding algorithm
function [watermarked_image, signature] = watermark_embedding(cover_image, watermark_logo, key, print_figures)

% 1. Apply Haar wavelet and decompose cover image into four sub-bands:
% LL, HL, LH, and HH
[LL, HL, LH, HH] = dwt2(cover_image, 'haar');

% 2. Using Haar wavelet, further decompose LL band to the 4th level.
% [LL_1, HL_1, LH_1, HH_1] = dwt2(LL, 'haar');    % 1st step DWT
% [LL_2, HL_2, LH_2, HH_2] = dwt2(LL_1, 'haar');  % 2nd step DWT
% [LL_3, HL_3, LH_3, HH_3] = dwt2(LL_2, 'haar');  % 3rd step DWT
% [LL_4, HL_4, LH_4, HH_4] = dwt2(LL_3, 'haar');  % 4rth step DWT

if (print_figures == true)
    % Images coding.
    cod_cA1 = wcodemat(LL);
    cod_cH1 = wcodemat(HL);
    cod_cV1 = wcodemat(LH);
    cod_cD1 = wcodemat(HH);
    dec2d = [cod_cA1, cod_cH1; cod_cV1, cod_cD1];
    
    % Plot one step decomposition
    figure;
    image(dec2d);
    title('One step DWT decomposition');
    
    clear('dec2d', 'cod_cA1', 'cod_cH1', 'cod_cV1', 'cod_cD1');
end

% 3. Apply SVD to HH (high frequency) band
[Uh Sh Vh] = svd(HH, 'econ');

% 4. Watermark logo W is decomposed using SVD
[Uw Sw Vw] = svd(watermark_logo, 'econ');

% 5. Replace singular values of the HH (high frequency) band with the
% singular values of the watermark
Sh_diag = diag(Sh);
Sw_diag = diag(Sw);
% for ii = 1:size(Sw, 1)
%     Sh_diag(ii) = Sw_diag(ii);
% end
if (length(watermark_logo) >= 256)
    Sh_diag(1:length(Sh), :) = Sw_diag(1:length(Sh), :);
elseif(length(watermark_logo) < 256)
    Sh_diag(1:length(watermark_logo), :) = Sw_diag(1:length(watermark_logo), :);
end
Sh(logical(eye(size(Sh)))) = Sh_diag;

%----- Signature generation algorithm
% 6. Generate signature
signature = signature_generation(Uw, Vw, key);

%---- Signature embedding algorithm
% 7. Embedd signature to cover image
% LL_inv = signature_embedding(LL_4, HH_4, signature);
LL_inv = signature_embedding(LL, signature, print_figures);

% 8. Apply SVD to obtain the modified HH band wich now holds the SV's of
% watermark logo
HH_modified = Uh * Sh * Vh';

% 9. Apply inverse DWT with modified LL(LL_inv) & HH(HH_modified) band to
% obtain the watermarked image
% Here the HH band should be the one modified with SV's
watermarked_image = idwt2(LL_inv, HL, LH, HH_modified, 'haar');

if (print_figures == true)
    figure;
    subplot(2, 2, 1);
    imshow(cover_image, []);
    title('Cover image');
    subplot(2, 2, 2);
    imshow(watermarked_image, []);
    title('Watermarked image signed with secret key');
    subplot(2, 2, 3);
    imshow(watermark_logo, []);
    title('Watermark logo');
end

clear('LL', 'HL', 'LH', 'HH',...
    'LL_1', 'HL_1', 'LH_1', 'HH_1', ...
    'LL_2', 'HL_2', 'LH_2', 'HH_2',...
    'LL_3', 'HL_3', 'LH_3', 'HH_3',...
    'LL_4', 'HL_4', 'LH_4', 'HH_4');

clear('Uh', 'Sh', 'Vh', 'Uw', 'Sw', 'Vw', 'Sh_diag', 'Sw_diag');

end