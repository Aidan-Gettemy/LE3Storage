design = zeros(1,18);
for k = 1:1000
    st(k) = wblrnd(.1,1.5);
    for j = 1:3
        if j == 1
            design(k,1) = st(k);
            for i = 2:6
                f = next_seg(design(k,(j-1)*6+i-1));
                if f>1
                    f =1;
                end
                design(k,(j-1)*6+i) = f;
            end
        else
            for i = 1:6
                c = randn(1)*.125*(i/6)+design(k,i);
                if c<0;c=0.00;end
                if c>1;c=1;end
                design(k,(j-1)*6+i) = c;
            end
        end

        
    end
end
for i = 1:40
    figure
    bar(1:6,design(i,1:6),"yellow")
    hold on
    bar(7:12,design(i,7:12),"magenta")
    bar(13:18,design(i,13:18),"red")
end
figure
histogram(st,linspace(0,1,100))
% *******        *******        *******        *******        *******      
function y = next_seg(y)
    r_n = rand(1);
    a = 6^(1/6);
    b = (1/6)^(1/6);
    if r_n < .5
        y = y*a;
    elseif r_n < .75
        y = y*2*a;
    elseif r_n < .875
        y = y*3*a;
    else
        y = y*b;
    end
end