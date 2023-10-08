clc;
close all;
clear all;

% Read the HDR image
hdrImage = hdrread('acoustical_shell_4k.hdr');
imshow(hdrImage);
title('HDR Image');



% Convert HDR to YCbCr color space
YUV = rgb2ycbcr(hdrImage);

% Parameters for non-linear quantization of Y
mu = 0.5;
F = @(x) sign(x) .* log(1 + mu * abs(x)) / log(1 + mu);
Finverse = @(y) sign(y) .* (1 + mu) .* abs(y).^(1 / mu - 1);

% Non-linear quantization of Y channel
Y = YUV(:, :, 1);
Y_quantized = F(Y);

% Display the quantized Y image
figure;
imshow(Y_quantized);
title('Quantized Y');

% Linear quantization of Cb and Cr channels
Cb = YUV(:, :, 2);
Cr = YUV(:, :, 3);

% Define the number of levels for linear quantization
numLevels = 256;

% Linear quantization of Cb and Cr channels
Cb_quantized = uint8((Cb + 1) / 2 * (numLevels - 1));
Cr_quantized = uint8((Cr + 1) / 2 * (numLevels - 1));

% Save quantized Cb and Cr images as PNG
imwrite(Cb_quantized, 'Cb_quantized.png');
imwrite(Cr_quantized, 'Cr_quantized.png');

% Display the quantized Cb and Cr images
figure;
subplot(1, 2, 1); imshow(Cb_quantized); title('Quantized Cb');
subplot(1, 2, 2); imshow(Cr_quantized); title('Quantized Cr');

% Calculate Yr residue
Yr = Y - Y_quantized;

% Linear quantization of Yr
Yr_quantized = uint8((Yr + 1) / 2 * (numLevels - 1));
imwrite(Yr_quantized, 'Yr_quantized.png');
% Display the quantized Yr image
figure;
imshow(Yr_quantized);
title('Quantized Yr');

% Restore the original HDR image (for visualization)
restoredY = Finverse(Y_quantized);
restoredImage = ycbcr2rgb(cat(3, restoredY, Cb, Cr));
figure;
imshow(restoredImage);
title('Restored HDR Image');
imwrite(restoredImage, 'restored_hdr_image.png');
