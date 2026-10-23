function [azimuth, elevation] = Sun_Position(year, month, day, hour, minute, second, latitude, longitude, timezone)
%#codegen

% Day of year
daysBefore = [0 31 59 90 120 151 181 212 243 273 304 334];

N = daysBefore(month) + day;

% Leap year correction
if mod(year,4) == 0 && (mod(year,100) ~= 0 || mod(year,400) == 0)
    if month > 2
        N = N + 1;
    end
end

% Decimal time
decimalHour = hour + minute/60 + second/3600;

% Fractional year
gamma = 2*pi/365 * (N - 1 + (decimalHour - 12)/24);

% Equation of Time (minutes)
EoT = 229.18 * ( ...
    0.000075 ...
    + 0.001868*cos(gamma) ...
    - 0.032077*sin(gamma) ...
    - 0.014615*cos(2*gamma) ...
    - 0.040849*sin(2*gamma));

% Solar declination (radians)
declination = ...
    0.006918 ...
    - 0.399912*cos(gamma) ...
    + 0.070257*sin(gamma) ...
    - 0.006758*cos(2*gamma) ...
    + 0.000907*sin(2*gamma) ...
    - 0.002697*cos(3*gamma) ...
    + 0.001480*sin(3*gamma);

% Solar time
timeCorrection = EoT + 4*(longitude - 15*timezone);

solarTime = decimalHour + timeCorrection/60;

% Hour angle
hourAngle = 15*(solarTime - 12);

% Convert to radians
latRad = latitude*pi/180;
haRad = hourAngle*pi/180;

% Solar elevation
sinElevation = sin(latRad)*sin(declination) + ...
    cos(latRad)*cos(declination)*cos(haRad);

elevation = asin(sinElevation)*180/pi;

% Solar azimuth
azimuth = atan2( ...
    sin(haRad), ...
    cos(haRad)*sin(latRad) - tan(declination)*cos(latRad));

azimuth = azimuth*180/pi;

% Convert to 0–360 degree convention
azimuth = mod(azimuth + 180, 360);

end