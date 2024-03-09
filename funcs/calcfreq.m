function freq = calcfreq(sig)
%CALCFREQ Given a signal find the largest frequencies aside from the mean
%spike, if it exists.  We might also like to find the second largest
%frequency as well
    output = sig;
    Fs = 160;               % Sampling frequency                    
    T = 1/Fs;             % Sampling period       
    L = length(output);  % Length of signal
    t = (0:L-1)*T;        % Time vector
    
    % figure
    % hold on
    % plot(t,output)
    % 
    % title("Original Data")
    % xlabel("t (seconds)")
    % ylabel("X(t)")
    Y1 = fft(output);
    
    % figure
    % plot(Fs/L*(0:L-1),abs(Y1),"LineWidth",3)
    % title("Complex Magnitude of fft Spectrum")
    % xlabel("f (Hz)")
    % ylabel("|fft(X)|")
    
    P21 = abs(Y1/L);
    P11 = P21(1:(L-1)/2+1);
    P11(2:end-1) = 2*P11(2:end-1);

    % figure
    f = Fs/L*(0:(L/2));
    % plot(f,P11,"k","LineWidth",2); 
    % xlabel("f (Hz)")
    % ylabel("|P1(f)|")
    
    [B,I] = maxk(P11,10);
    % if I(1) = 1; then go with the next peak...that is the dominant frequency
    % if we use that index to index f
    if I(1) < 3
        freq(1) = f(I(2));
        freq(2) = f(I(3));
    else
        freq(1) = f(I(1));
        if I(2) < 3
            freq(2) = f(I(3));
        else
            freq(2) = f(I(2));
        end
    end

end

