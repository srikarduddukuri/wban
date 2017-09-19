clc
clear all
iptsetpref('ImshowAxesVisible','on')
%I = zeros(100,100);
%I(25:75, 25:75) = 1;
a=imread('im5.jpg');
a=rgb2gray(a);
%b1=a(50,:,1);
 h=a(1400:1800,600:1100,1);
 b1=h>128;
 I=b1;
 I=imrotate(I,30);

theta = 0:180;
[R,xp] = radon(I,theta);
imshow(R,[],'Xdata',theta,'Ydata',xp,...
            'InitialMagnification','fit')
xlabel('\theta (degrees)')
ylabel('x''')
colormap(hot), colorbar
iptsetpref('ImshowAxesVisible','off')