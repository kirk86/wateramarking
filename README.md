Robust and Secure Watermarking using SVD & DWT
============================================

This a secure and robust watermarking scheme based on singular values replacement and DWT transformation. 

The technique is described in the following paper: http://www.ias.ac.in/sadhana/Pdf2012Aug/425.pdf

What it does and how to use it:
==================================

## Part A:

If you just want to hide a logo "let's say a watermark message (a.k.a image)" inside another image then simply open "dwt_svd.m" go to line 41: and change the "gaussian_plot = true" to "gaussian_plot = false".

On line 42: change "print_figures = false" to "print_figures = true".

Finally execute the dwt_svd.m from matlab command window and watch the figures.


## Part B:

Now if you want to :

    1. embed a watermeark message into some images

    2. attack those watermarked images to see the strength of watermarking scheme

    3. plot gaussians and roc curves

Then don't make the changes I mentioned in **Part A**.

Execute (when I say execute I mean run the commands from matlab command window) "dwt_svd.m" to apply the watermark to the image you want, then execute "attacks.m" and enter in **"single quotes"** the name of the attack you want to apply to the watermarked images (e.g. 'mean' or 'median' or 'noise' or 'rotation' or 'shear' or 'crop').

Then a popup window will ask you to indicate the watermark message you used in the embeding step when you initially applied the watermark to the cover image when you executed the "dwt_svd.m" file.

After the code stops executing you should have images with numeric names from [1-1000] in the following directories:

* attacked: => in this directory will be stored the watermarked images after the attack has been applied to them

* logos: => here you'll have the corresponding watermark logos extracted from the attacked images

* watermarked_images: => here you'll have the images with the watermark applied to them

