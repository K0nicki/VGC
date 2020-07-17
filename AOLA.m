function y = AOLA(varargin)
% Implementacja algorytmu AOLA ( Adaptive Overlap and Add algorithm). 
% Algorytm ma na celu zwiększenie czasu trwania sygnału bez wpływu na jego częstotliwość
% Założenia: Jeżeli jest pobudzenie dźwięczne to przedłuż dźwięk, w
% przeciwnym wypadku powiel ostatnie 40 próbek
%
% @param1    Buffor sygnału przetwarzanego
% @param2    Flaga, jeżeli reverse tzn, że sygnał będzie skracany

    if  (length(nargin) == 1) & (varargin{2} ~= 'reverse')
        x = varargin{1};
        r = xcorr(x); r = r(floor(length(r)/2) : end);

        offset = 20;                                % Offset w celu ominięcia stałej
        rMax = max(r(offset : end));                % Znalezienie najwyższego piku zaraz po stałej
        iMax = find(r == rMax);                     % Pobranie indeksu maximum (kandydat na pobudzenie dźwięczne)

        if ( rMax >0.35*r(1) ) T = iMax;            % Pobudzenie dźwięczne
        else T = 40;                                % Pobudzenie szumowe
        end

        y = [x x(T : end)];
        
    elseif varargin{2} == 'reverse'
        x = varargin{1};
        r = xcorr(x); r = r(floor(length(r)/2) : end);

        offset = 20;                                % Offset w celu ominięcia stałej
        rMax = max(r(offset : end));                % Znalezienie najwyższego piku zaraz po stałej
        iMax = find(r == rMax);                     % Pobranie indeksu maximum (kandydat na pobudzenie dźwięczne)

        if ( rMax >0.35*r(1) ) T = iMax;            % Pobudzenie dźwięczne
        else T = 40;                                % Pobudzenie szumowe
        end

        y = x(1 : end - T);
    end
end