clearvars; close all;

%% Voice Gender Conversion
% Celem niniejszego skryptu jest jak najwierniejsza konwersja damskiego głosu na meski i vice versa bez strat na naturalności. 

[x, fs] = audioread("mowa_1.wav");
%soundsc(female,fs);

[m,n] = size(x);

% Zamienienie orientacji wertykalnej na horyzontalną
if (m > n) 
    x = x'; 
end

% Tworzenie wektora czasu
T = length(x)/fs;      
t = 0: 1/fs : T - 1/fs;     

% Plot
figure;
subplot(311);
plot(t, x, 'b');
title("Sygnał wejsciowy"); grid;

subplot(312);
plot(t, x, 'b');
title("Zoom - głoska dźwięczna"); grid;
xlim([3.3411 3.3796]); ylim([-0.65 0.65]);


subplot(313);
plot(t, x, 'b');
title("Zoom - głoska bezdźwięczna"); grid;
xlim([1.0411 1.0796]); ylim([-0.65 0.65]);
%}

% Preemfaza sygnału. Równomierne skupienie mocy sygnalu w zależności od
% częstotliwości
%x = filter([1 -0.9735], 1, x);        

out = [];                                                       % Pusty buffor na zmieniony sygnał wejściowy
predict = 10;                                                   % Liczba współczynników filtra LPC. Wystarcza tylko 5 (dodatkowe 5 to sprzężenia, aby uniknąć liczb zespolonych)
step = 180;                                                     % Długość bloku próbek
windowSize = 240;                                               % Długość stosowanego okna, większy niż ilość poróbek
frames = floor((length(x) - windowSize) / step + 1);            % Liczba operacji analizy i syntezy do wykonania
ratioFormant = 1/0.87;                                          % Stosunek próbki wejściowej do wyjściowej w al. AOLA - przedłużenie sygnału


for i = 1 : frames
    
    % Pobranie kolejnej partii próbek
    n = 1 + (i - 1) * step : windowSize + (i - 1) * step;
    bx = x(n);
    
    % Okienkowanie sygnału
    bx = bx.*(hamming(windowSize)');
    
    %% Analiza: wyznaczanie parametrów sygnału
    
    % Usunięcie wartości średniej                                                                           
    bx = bx - mean(bx);
    
    
    %   IMPLEMENTACJA ALGORYTMU AOLA
    
    refBuff = bx;                                   % buffor referencyjny, stan początkowy
    ratio = 1;
    
    figure(1);
    subplot(211);
    plot(bx);
    xlabel("Buffor przed AOLA");
    
    while ratio < ratioFormant
        % Zastosowanie właściwości autokorelacji w celu znalezienia kolejnych
        % harmonicznych. Wykorzystanie właściwości, że pobudzenie dźwięczne
        % pojawia się w określonych okresie charakterystycznym dla danego głosu
        r = xcorr(bx); r = r( floor(length(r) / 2) : end);

        % Szukanie głoski dźwięcznej                                                                           
        offset = 20;                                % Offset w celu ominięcia stałej
        rMax = max(r(offset : end));                % Znalezienie najwyższego piku zaraz po stałej
        iMax = find(r == rMax);                     % Pobranie indeksu maximum (kandydat na pobudzenie dźwięczne)

        sufix = bx(end - iMax : end);               % Obliczenie sufixu
        bx = [bx sufix];                            % Przedłużenie sygnału
        ratio = length(bx)/length(refBuff);
    end
    subplot(212);
    plot(bx);
    xlabel("Buffor po AOLA");
    pause; clf(1);
end

disp("end");
% Deemfaza sygnału - odwrócenie wejściowego filtra preemfazy
%out = filter(1, [1 -0.9735], out);

%out = out / max(out);                           % Normowanie 






























    