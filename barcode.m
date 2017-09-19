clc
clear all
a=imread('im5.jpg');
a=rgb2gray(a);
%b1=a(50,:,1);
 h=a(1250:end,500:end,1);
 b1=h(380,:);
b=b1>128;
k=1;
l=1;
for i=1:length(b)-1   
    if(b(i) == b(i+1))
        l=l+1;
    end
    if(b(i) ~= b(i+1))
        c(k)=l;
        d(k)=b(i);
        l=1;
        k=k+1;
    end
end
        