function [totuptake, conserve, leach] = SIMfunc(system, precip, apptime1, mass)
%% Load Root Data
load("L.mat")
load("str.mat")
load("mapage.mat")
load("maprad.mat")
load("mapsurf.mat")
load("mapvol.mat")
load("devfact.mat")
load("totalrootvol")
load("mgaccumdemand")
load("massndemand.mat")
%% Farmer Decisions and Precipitation
% answer yes/no with 1/0
before = apptime1(1);
apptime= apptime1(2) ; %days before or after
application = mass; %mg/cm^2
P = precip;
%% System Setup
KS = system.KS;
WP = system.WP ;
FC = system.FC;
SAT = system.SAT;
TT = system.TT;
N = system.N;
a = system.A;
M = system.M;
SWly1 = system.SWly1;
%% SET UP NO3
n = 100;
r1 = 19;
r2 = 19;
if before == 1
    timelength = 120+apptime;
    NitLay(1,1) = application;
    NitLay(2:n,1) = ones(1,n-1)*0; %mass of N in layer
    NitMob = zeros(n,r1,r2,timelength,24); %mass of mobile N in layer
    nitratel(:,:,:,1,:) = (repmat(NitLay(:,1), 1, r1, r2,24));
    nitratel(:,:,:,1,:) = nitratel(:,:,:,1,:);
elseif before == 0
    timelength = 120;
    NitLay(2:n,1) = ones(1,n-1)*0; %mass of N in layer
    NitMob = zeros(n,r1,r2,timelength,24); %mass of mobile N in layer
    nitratel(:,:,:,1,:) = (repmat(NitLay(:,1), 1, r1, r2,24));
    nitratel(:,:,:,1,:) = nitratel(:,:,:,1,:);
end

SWlyex = zeros(n,r1, r2,timelength);

%WATER UPTAKE
Kx =  0.0432/24; % cm^3/hour from Javaux 2008
Kr = 1.728E-4/24; %per hour from Javaux 2008
prw = 10197.2; %cm
SWly = SWly1;
Wperc = zeros(n, r1, r2, timelength,24);
uptake = zeros(n, r1, r2, timelength,24);
S = zeros(n, r1, r2, timelength,24);
agefact = zeros(n, r1, r2, timelength);
wuptake = zeros(n, r1, r2, timelength,24);
h = zeros(n, r1, r2, timelength,24);
psw = zeros(n, r1, r2, timelength,24);
mapsurf(:,:,:,:) = zeros(n,r1,r2,timelength);
%% SIMULATION
for t = 2:timelength
    if before == 1 && t < apptime
        devfact(t) = 0;
        mapsurf(:,:,:,t) = zeros(n,r1,r2);
        maprad(:,:,:,t) = zeros(n,r1,r2);
        mapvol(:,:,:,t) = zeros(n,r1,r2);
        mapage(:,:,:,t) = zeros(n,r1,r2);
    elseif before == 1 && t>apptime 
        mapsurf(:,:,:,t) = mapsurf00(:,:,:,t-apptime);
        maprad(:,:,:,t) = maprad00(:,:,:,t-apptime);
        mapvol(:,:,:,t) = mapvol00(:,:,:,t-apptime);
        mapage(:,:,:,t) = mapage00(:,:,:,t-apptime);
    elseif before == 0
        mapsurf(:,:,:,t) = mapsurf00(:,:,:,t);
        maprad(:,:,:,t) = maprad00(:,:,:,t);
        mapvol(:,:,:,t) = mapvol00(:,:,:,t);
        mapage(:,:,:,t) = mapage00(:,:,:,t);
    end
    simtime = t;
    for hour = 1:24
        totalhour = (t-1)*24 + hour;
        if before == 1
            totalhour = totalhour + (28 - apptime)*24;
        end
        if before == 1 && t > apptime 
            dayuptake(t) = sum(uptake(:,:,:,t,:),'all');
            alluptake = sum(dayuptake(:),'all');
            Cint = alluptake/(totalrootvol(t-apptime));
            Cgoal = (massdemand(t-apptime))/(totalrootvol(t-apptime));
        elseif before == 0
            dayuptake(t) = sum(uptake(:,:,:,t,:),'all');
            alluptake = sum(dayuptake(:),'all');
            Cint = alluptake/(totalrootvol(t));
            Cgoal = (massdemand(t))/(totalrootvol(t));
        elseif before == 1 && t < apptime 
            Cint = 0;
            Cgoal = 0;
        end
        for x = 1:n
            for y = 1:r1
                for z = 1:r2
                    if x == 1
                        if hour == 1
                            SWly(1,y,z,t,hour) = P(totalhour)  - Wperc(1,y,z,t-1,24) + SWly(1,y,z,t-1,24)-wuptake(1,y,z,t-1,24);
                            if SWly(x,y,z,t,hour) <= WP(1,y,z)
                                SWly(x,y,z,t,hour) = WP(1,y,z);
                            end
                            if SWly(1,y,z,t,hour) <= FC(1,y,z)
                                SWlyex(1,y,z,t,hour) = 0;
                            else
                                SWlyex(1,y,z,t,hour) = SWly(1,y,z,t,hour) - FC(1,y,z);
                                if SWlyex(1,y,z,t,hour) > SAT(1,y,z) - FC(1,y,z)
                                    SWlyex(1,y,z,t,hour) = SAT(1,y,z) - FC(1,y,z);
                                end
                            end
                            Wperc(1,y,z,t,hour) =  SWlyex(1,y,z,t,hour)*(1-exp(-1/TT(1,y,z)));
                        else
                            SWly(1,y,z,t,hour) =  P(totalhour) - Wperc(1,y,z,t,hour-1) + SWly(1,y,z,t,hour-1) - wuptake(1,y,z,t,hour-1);
                            if SWly(1,y,z,t,hour) <= WP(1,y,z)
                                SWly(1,y,z,t,hour) = WP(1,y,z);
                            end
                            if SWly(1,y,z,t,hour) <= FC(1,y,z)
                                SWlyex(1,y,z,t,hour) = 0;
                            else
                                SWlyex(1,y,z,t,hour) = SWly(1,y,z,t,hour) - FC(1,y,z);
                                if SWlyex(1,y,z,t,hour) > SAT(1,y,z) - FC(1,y,z)
                                    SWlyex(1,y,z,t,hour) = SAT(1,y,z) - FC(1,y,z);
                                end
                            end
                            Wperc(1,y,z,t,hour) =  SWlyex(1,y,z,t,hour)*(1-exp(-1/TT(1,y,z)));
                        end
                    elseif x > 1
                        if hour == 1
                            SWly(x,y,z,t,hour) = Wperc(x-1,y,z,t-1,24) - Wperc(x,y,z,t-1,24) + SWly(x,y,z,t-1,24) - wuptake(x,y,z,t-1, 24);
                            if SWly(x,y,z,t,hour) <= WP(x,y,z)
                                SWly(x,y,z,t,hour) = WP(x,y,z);
                            end
                            if SWly(x,y,z,t,hour)>SAT(x,y,z)
                                SWly(x,y,z,t,hour) = SAT(x,y,z);
                            end
                            if SWly(x,y,z,t,hour) <= FC(x,y,z)
                                SWlyex(x,y,z,t,hour) = 0;
                            else
                                SWlyex(x,y,z,t,hour) = SWly(x,y,z,t,hour) - FC(x,y,z);
                            end
                            Wperc(x,y,z,t,hour) =  SWlyex(x,y,z,t,hour)*(1-exp(-1/TT(x,y,z)));
                        else
                            SWly(x,y,z,t,hour) = Wperc(x-1,y,z,t,hour-1) - Wperc(x,y,z,t,hour-1) + SWly(x,y,z,t,hour-1) - wuptake(x,y,z,t, hour -1);
                            if SWly(x,y,z,t,hour) <= WP(x,y,z)
                                SWly(x,y,z,t,hour) = WP(x,y,z);
                            end
                            if SWly(x,y,z,t,hour)>SAT(x,y,z)
                                SWly(x,y,z,t,hour) = SAT(x,y,z);
                            end
                            if SWly(x,y,z,t,hour) <= FC(x,y,z)
                                SWlyex(x,y,z,t,hour) = 0;
                            else
                                SWlyex(x,y,z,t,hour) = SWly(x,y,z,t,hour) - FC(x,y,z);
                            end
                            Wperc(x,y,z,t,hour) =  SWlyex(x,y,z,t,hour)*(1-exp(-1/TT(x,y,z)));
                        end
                    end
                    S(x,y,z,t,hour) = (SWly(x,y,z,t,hour) - WP(x,y,z))/(SAT(x,y,z) - WP(x,y,z));
                    if S(x,y,z,t,hour) < 0
                        S(x,y,z,t,hour) = 0;
                    elseif S(x,y,z,t,hour) > 1
                        S(x,y,z,t,hour) = 1;
                    end
                    h(x,y,z,t,hour) = ((((S(x,y,z,t,hour)).^(-1/M(x,y,z))-1).^(1/N(x,y,z)))/a(x,y,z)); %ml/d^2*cm
                    psw(x,y,z,t,hour) = h(x,y,z,t,hour);
                    if mapsurf(x,y,z,t) ~= 0
                        wuptake(x,y,z,t,hour) = -Kr*(psw(x,y,z,t,hour)-prw)*(mapsurf(x,y,z,t));
                        if wuptake(x,y,z,t,hour) < 0
                            wuptake(x,y,z,t,hour) = 0;
                        elseif wuptake(x,y,z,t,hour) >= SWly(x,y,z,t,hour)
                            wuptake(x,y,z,t,hour) = SWly(x,y,z,t,hour) - WP(x,y,z);
                        end
                    else
                        A(x,y,z,t,hour) = 0;
                        wuptake(x,y,z,t,hour) = 0;
                    end
                    % SWAT NITRATE
                    if x == 1
                        if hour == 1
                            if before == 0 && t == apptime
                                NitMob(1,y,z,t,hour) = nitratel(1,y,z,t-1,24)*(1-exp((-Wperc(1,y,z,t,hour))/(SAT(1,y,z))));
                                nitratel(1,y,z,t,hour) = nitratel(1,y,z,t-1,24) - NitMob(1,y,z,t,hour) + application;
                                if isnan(nitratel(1,y,z,t,hour)) 
                                    disp("stop")
                                    pause
                                end
                            else
                                NitMob(1,y,z,t,hour) = nitratel(1,y,z,t-1,24)*(1-exp((-Wperc(1,y,z,t,hour))/(SAT(1,y,z))));
                                nitratel(1,y,z,t,hour) = nitratel(1,y,z,t-1,24) - NitMob(1,y,z,t,hour);
                                if isnan(nitratel(1,y,z,t,hour))
                                    disp("stop")
                                    pause
                                end
                            end
                        else
                            NitMob(1,y,z,t,hour) = nitratel(1,y,z,t,hour-1)*(1-exp((-Wperc(1,y,z,t,hour))/(SAT(1,y,z))));
                            nitratel(1,y,z,t,hour) = nitratel(1,y,z,t,hour-1) - NitMob(1,y,z,t,hour);
                            if isnan(nitratel(1,y,z,t,hour))
                                disp("stop")
                                pause
                            end
                        end
                    elseif x > 1
                        if hour == 1
                            NitMob(x,y,z,t,hour) = nitratel(x,y,z,t-1,24)*(1-exp((-Wperc(x,y,z,t,hour))/(SAT(x,y,z))));
                            nitratel(x,y,z,t,hour) = nitratel(x,y,z,t-1,24) - NitMob(x,y,z,t,hour) + NitMob(x-1,y,z,t,hour);
                            if isnan(nitratel(x,y,z,t-1,24))
                                disp("stop")
                                pause
                            end
                        else
                            NitMob(x,y,z,t,hour) = nitratel(x,y,z,t,hour-1)*(1-exp((-Wperc(x,y,z,t,hour))/(SAT(x,y,z))));
                            nitratel(x,y,z,t,hour) = nitratel(x,y,z,t,hour-1) - NitMob(x,y,z,t,hour) + NitMob(x-1,y,z,t,hour);
                            if isnan(nitratel(x,y,z,t,hour))
                                disp("stop")
                                pause
                            end
                        end
                    end
                    if before == 1 && t<apptime
                        uptake(x,y,z,t,hour) = 0;
                    elseif before == 0 || before == 1 && t>apptime
                        if mapsurf(x,y,z,t) == 0
                            uptake(x,y,z,t,hour) = 0;
                        elseif nitratel(x,y,z,t,hour) <= 0
                            uptake(x,y,z,t, hour) = 0;
                            nitratel(x,y,z,t,hour) = 0;
                        elseif mapsurf(x,y,z,t) ~= 0 && nitratel(x,y,z,t,hour)>0
                            age = mapage(x,y,z,t);
                            agefact(x,y,z,t) = 1-((t - age)/120);
                            Imax = (35.81 * 86400 * 10^-12 * 62.05*1000); % mg/cm^2*h
                            Km = 17.25*0.001*62.05*10^-6 * 1000 ; %mg/cm^3
                            C = nitratel(x,y,z,t,hour); %mg/cm^3
                            if isnan(C)
                                disp("stop")
                                pause
                            end
                            if Cgoal > Cint && before == 0
                                uptake(x,y,z,t,hour) = agefact(x,y,z,t).*devfact(t).*((mapsurf(x,y,z,t))*(Imax * (C)*(Cgoal-Cint))./(Km + (C)));
                            elseif Cgoal > Cint && before == 1
                                uptake(x,y,z,t,hour) = agefact(x,y,z,t-apptime).*devfact(t-apptime).*((mapsurf(x,y,z,t))*(Imax * (C)*(Cgoal-Cint))./(Km + (C)));
                            elseif Cgoal < Cint
                                uptake(x,y,z,t,hour) = 0;
                                %mg/cm^2*d
                            end
                        end
                        if nitratel(x,y,z,t,hour) <= uptake(x,y,z,t,hour)
                            uptake(x,y,z,t,hour) = nitratel(x,y,z,t,hour);
                            nitratel(x,y,z,t,hour) = 0;
                        end
                        if uptake(x,y,z,t,hour) < 0
                            uptake(x,y,z,t,hour) = 0;
                        end
                    end
                end
            end
        end
        nitratel(:,:,:,t,hour) = nitratel(:,:,:,t,hour) - uptake(:,:,:,t,hour);
    end  
end

totuptake = sum(uptake, 'all');
conserve = sum(nitratel(:,:,:,timelength,24),'all');
leach = (mass*r1*r2) - totuptake - conserve;

