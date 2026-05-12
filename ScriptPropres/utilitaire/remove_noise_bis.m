function [S_clean, fc] = remove_noise_bis(S,freq,fe,applyWindow,debug)
    % REMOVE_NOISE_BIS  Alternative, non-destructive noise remover
    % Usage:
    %   S_clean = remove_noise_bis(S,freq,fe)
    %   [S_clean,fc] = remove_noise_bis(S,freq,fe,applyWindow,debug)
    %
    % Inputs:
    %   S - column signal
    %   freq - frequency vector associated with FFT (same length as S)
    %   fe - sampling frequency
    %   applyWindow (optional, default true) - apply Hann window before FFT
    %   debug (optional, default false) - plot spectrum for debugging
    %
    % Outputs:
    %   S_clean - lowpassed signal
    %   fc - detected central frequency used for the lowpass

    arguments
        S (:,1) double
        freq (1,:) double
        fe double
        applyWindow (1,1) logical = true
        debug (1,1) logical = false
    end

    % Defensive: ensure column vector
    S = S(:);

    % Remove DC offset (important when offset dominates spectrum)
    S = S - mean(S);

    % Optionally apply an analysis window to reduce leakage
    if applyWindow
        w = hann_maison(length(S));
        S_win = S .* w;
    else
        S_win = S;
    end

    % Compute centered spectrum
    S_fft = fftshift(fft(S_win));

    % Select only strictly positive frequency bins to avoid DC selection
    posIdx = find(freq > 0);
    if isempty(posIdx)
        warning('remove_noise_bis:NoPositiveFreq','No positive frequency bins found; using Nyquist as cutoff');
        fc = fe/2;
    else
        % find dominant amplitude in positive frequencies
        [~, relInd] = max(abs(S_fft(posIdx)));
        M_ind = posIdx(relInd);
        fc = freq(M_ind);
    end

    % Safety checks and fallback
    if ~(isnumeric(fc) && isfinite(fc) && fc > 0)
        fc = max(1, fe/1000); % fallback small positive freq
        warning('remove_noise_bis:InvalidFC','Computed fc invalid, fallback to %g Hz', fc);
    end

    % Debug plot if requested
    if debug
        figure;
        plot(freq, abs(S_fft));
        xlabel('Frequency (Hz)'); ylabel('|FFT|');
        title(sprintf('Spectrum (detected fc = %.3g Hz)', fc));
        xlim([0, min(fe/2, fc*4)]);
    end

    % Apply lowpass filter around detected fc
    cutoff = fc * 1.9;
    cutoff = min(cutoff, fe/2 - eps);
    %S_clean = lowpass(S, cutoff, fe);
    S_clean = lowpass_maison(S, cutoff, fe);

end
