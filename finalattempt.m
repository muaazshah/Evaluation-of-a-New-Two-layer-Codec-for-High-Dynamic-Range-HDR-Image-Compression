% Clear the command window, close all figures, and clear workspace variables
clc;
close all;
clear all;

% Read the HDR image from a file
hdrImage = hdrread('acoustical_shell_4k.hdr');
imshow(hdrImage);
title('HDR Image');

% Convert the HDR image to the YCbCr color space
YUV = rgb2ycbcr(hdrImage);

% Define parameters for non-linear quantization of Y channel
mu = 0.5;
F = @(x) sign(x) .* log(1 + mu * abs(x)) / log(1 + mu); % Non-linear mapping function
Finverse = @(y) sign(y) .* (1 + mu) .* abs(y).^(1 / mu - 1); % Inverse mapping function

% Apply non-linear quantization to the Y channel
Y = YUV(:, :, 1);
Y_quantized = F(Y);

% Display the quantized Y channel image
figure;
imshow(Y_quantized);
title('Quantized Y Channel');

% Perform linear quantization of Cb and Cr channels
Cb = YUV(:, :, 2);
Cr = YUV(:, :, 3);

% Define the number of levels for linear quantization
numLevels = 256;

% Linearly quantize the Cb and Cr channels
Cb_quantized = uint8((Cb + 1) / 2 * (numLevels - 1));
Cr_quantized = uint8((Cr + 1) / 2 * (numLevels - 1));

% Save the quantized Cb and Cr images as PNG files
imwrite(Cb_quantized, 'Cb_quantized.png');
imwrite(Cr_quantized, 'Cr_quantized.png');

% Display the quantized Cb and Cr channel images
figure;
subplot(1, 2, 1); imshow(Cb_quantized); title('Quantized Cb Channel');
subplot(1, 2, 2); imshow(Cr_quantized); title('Quantized Cr Channel');

% Calculate the residue Yr by subtracting quantized Y from the original Y
Yr = Y - Y_quantized;

% Linearly quantize the Yr channel
Yr_quantized = uint8((Yr + 1) / 2 * (numLevels - 1));
imwrite(Yr_quantized, 'Yr_quantized.png');

% Display the quantized Yr channel image
figure;
imshow(Yr_quantized);
title('Quantized Yr Channel');

% Restore the original HDR image (for visualization)
restoredY = Finverse(Y_quantized);
restoredImage = ycbcr2rgb(cat(3, restoredY, Cb, Cr));

% Display the restored HDR image and save it as a PNG file
figure;
imshow(restoredImage);
title('Restored HDR Image');
imwrite(restoredImage, 'restored_hdr_image.png');
