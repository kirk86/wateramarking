%%  DWT - SVD Watermarking
function [psnr_values, psnr2dB_values] = dwt_svd()
% clear workspace
clear all;
close all;
clc;

%change directory
folder_name = uigetdir(pwd, 'Select Directory Where the .m Files Reside');
if ( folder_name ~= 0 )
    if ( strcmp(pwd, folder_name) == 0 )
        cd(folder_name);
    end
else
    return;
end

% read cover image & watermark logo
[cover_fname, cover_pthname] = ...
    uigetfile('*.jpg; *.png; *.tif; *.bmp', 'Select the Cover Image');
if (cover_fname ~= 0)
    cover_image = strcat(cover_pthname, cover_fname);
    cover_image = double( rgb2gray( imread( cover_image ) ) );
    cover_image = imresize(cover_image, [512 512], 'bilinear');
else
    return;
end

[watermark_fname, watermark_pthname] = ...
    uigetfile('*.jpg; *.png; *.tif; *.bmp', 'Select the Watermark Logo');
if (watermark_fname ~= 0)
    watermark_logo = strcat(watermark_pthname, watermark_fname);
    watermark_logo = double( im2bw( rgb2gray( imread( watermark_logo ) ) ) );
    watermark_logo = imresize(watermark_logo, [512 512], 'bilinear');
else
    return;
end

% Set constant variables
numOfKeys = 20;
gaussian_plot = true;
print_figures = false;

if (gaussian_plot == false)
    secret_key = 3; % random secret key
    
    watermarked_image = watermark_embedding(cover_image, watermark_logo, ...
        secret_key, print_figures);
    
    watermark_extraction(watermarked_image, watermark_logo, secret_key, ...
        print_figures, true);
    
else
    % Set function parameters to not print any plots and not to do any
    % signature authentication
    %     print_figures = false;
    
    % Pre-allocate matrices
    psnr_values = zeros(1, numOfKeys);
    psnr2dB_values = zeros(1, numOfKeys);
    
    decoded_correct = zeros(1, numOfKeys);
    decoded_wrong = zeros(1, numOfKeys);
    
    %     [m, n] = size(watermark_logo);
    %     correctWatermarkDiff = zeros(1, m*n);
    wrongWatermarkDiff = zeros(1, length(watermark_logo));
    
    for key = 1:numOfKeys
        % Embedding with the right key
        [watermarked_image, original_signature] = ...
            watermark_embedding(cover_image, watermark_logo, key, print_figures);
        
        watermarked_images_dir = strcat(pwd, '\watermarked_images\', num2str(key), '.png');
        imwrite(uint8(watermarked_image), watermarked_images_dir, 'png');
        
        % Transform the original watermrak (i.e. the original signature) to
        % the interval [-1, 1]
        original_signature(find(original_signature == 0)) = -1;
        
        % Measure the degree of distortion of the original and the watermarked
        % image using PSNR (dB)
        psnr_values(key) = psnr(cover_image, watermarked_image);
        psnr2dB_values(key) = pow2db(psnr_values(key));
        
        % Detection with the right key, message_correct is actually the
        % watermark_logo because in essence that's what I'm hidding in the
        % cover image. Whereas the watermark_correct is actually the signature
        % which helps in the detection of false acceptance and false
        % rejection
        [~, ~, recon_sig_corr, LL4, HH4] = ...
            watermark_extraction(watermarked_image, watermark_logo, key, ...
            print_figures, true);
        
        % transform the watermark_correct(i.e. the reconstructed_signature)
        % and the watermark_wrong(i.e. the wrong reconstructed signature)
        % to the interval [-1, 1]
        recon_sig_corr(find(recon_sig_corr == 0)) = -1;
        
        LL4 = LL4(:)';
        HH4 = HH4(:)';
        LL4 = LL4 - mean(LL4);
        HH4 = HH4 - mean(HH4);
        comb_HH4_LL4 = [LL4 HH4];
%         decoded_correct(key) = (abs(comb_HH4_LL4) * recon_sig_corr')/512^2;
%         decoded_correct(key) = sum(comb_HH4_LL4 .* recon_sig_corr)/512^2;
        
        % Detection with the wrong key
        [~, watermark_wrong, recon_sig_wrng, LL4wr, HH4wr] = ...
            watermark_extraction(watermarked_image, watermark_logo, key+11, ...
            print_figures, false);
        
        watermark_wrong(find(watermark_wrong == 0)) = -1;
        
        LL4wr = LL4wr(:)';
        HH4wr = HH4wr(:)';
        LL4wr = LL4wr - mean(LL4wr);
        HH4wr = HH4wr - mean(HH4wr);
        combwr_HH4_LL4 = [LL4wr HH4wr];
%         decoded_wrong(key) = (abs(combwr_HH4_LL4) * watermark_wrong')/512^2;
%         decoded_wrong(key) = sum(watermark_wrong .* original_signature)/512;
        
        % Keep track of the correlation between the watermark_correct and
        % the watermark_wrong
        correlation_correct  = corrcoef(comb_HH4_LL4, recon_sig_corr);
        decoded_correct(key) = correlation_correct(2, 1);
        correlation_wrong = corrcoef(combwr_HH4_LL4, watermark_wrong);
        decoded_wrong(key) = correlation_wrong(2, 1);
        
        % Calculate the difference between the correct extracted watermarks and
        % the original watermark and the wrong extracted watermarks and the orignal
        %         correctKeyWatermarkDiff(key, :) = watermark_wrong - original_signature;
        wrongWatermarkDiff(key, :) = watermark_wrong - original_signature;
        
        clear('watermark_correct', 'comb_HH4_LL4', 'watermark_wrong', ...
            'combwr_HH4_LL4', 'original_signature', ...
            'LL4', 'HH4', 'LL4wr', 'HH4wr');
        
        % Clear workspace
        clear('watermark_logo_row', 'watermark_logo_extracted_correct', ...
            'watermark_logo_extracted_wrong', 'watermarked_image', ...
            'watermark_correct', 'watermark_wrong', 'message_correct', ...
            'message_wrong', 'watermarked_image');
        
    end
    
    meanOfDecodCorr = mean(decoded_correct);
    stdOfDecodCorr = std(decoded_correct);
    meanOfDecodWrng = mean(decoded_wrong);
    stdOfDecodWrng = std(decoded_wrong);
    
    gaussians(meanOfDecodCorr, stdOfDecodCorr, meanOfDecodWrng, stdOfDecodWrng);
    [Pfa, Pfr] = PfaPfr(meanOfDecodCorr, stdOfDecodCorr, meanOfDecodWrng, stdOfDecodWrng, numOfKeys);
    
    % Measure bit error rate, and plot against threshold T of pfa,
    % where T = pfa/pfr. Or equivalently plot BER & E versus pfa
    BER = BitErrorRate(wrongWatermarkDiff);
    
end

end