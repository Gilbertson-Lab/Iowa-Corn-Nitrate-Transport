load uniqmu %unique codes for Iowa soil map units
load 2020precip %file containing hourly precipitation from 2020
load SDATA %file containing soil data from Iowa
load farm %file containing fertilizer amount and application timing
%%
systemdepth = 100;
mass = farm(1,1);
timing = farm(2,:);
for i = 1 %iterate through Iowa Soil Map Units
    muind = uniqmu(i);
    name = ['MU',num2str(muind)];
    conames = fieldnames(SDATA.(name));
    conames(length(conames)) = [];
    tic
    for j = 1 %iterate through components of Iowa Soil Map Units
        name2 = char(conames(j));
        depth1 = table2array(SDATA.(name).(name2)(1,10));
        if depth1 >= systemdepth
            sand = table2array(SDATA.(name).(name2)(1,34));
            silt = table2array(SDATA.(name).(name2)(1,52));
            clay = table2array(SDATA.(name).(name2)(1,61));
            OM = table2array(SDATA.(name).(name2)(1,67));
            KS = table2array(SDATA.(name).(name2)(1,83));
            FC = table2array(SDATA.(name).(name2)(1,92));
            WP = table2array(SDATA.(name).(name2)(1,95));
            SAT = table2array(SDATA.(name).(name2)(1,98));
            numhor = 1;
            data = [sand silt clay OM KS FC WP SAT depth1];
            nancheck = (isnan(data));
            if any(nancheck == 1)
                continue
            end
        else
            sand1 = table2array(SDATA.(name).(name2)(1,34));
            silt1 = table2array(SDATA.(name).(name2)(1,52));
            clay1 = table2array(SDATA.(name).(name2)(1,61));
            OM1 = table2array(SDATA.(name).(name2)(1,67));
            KS1 = table2array(SDATA.(name).(name2)(1,83));
            FC1 = table2array(SDATA.(name).(name2)(1,92));
            WP1 = table2array(SDATA.(name).(name2)(1,95));
            SAT1 = table2array(SDATA.(name).(name2)(1,98));
            depth2 = table2array(SDATA.(name).(name2)(2,10));
            if depth2 >= systemdepth
                sand2 = table2array(SDATA.(name).(name2)(2,34));
                silt2 = table2array(SDATA.(name).(name2)(2,52));
                clay2 = table2array(SDATA.(name).(name2)(2,61));
                OM2 = table2array(SDATA.(name).(name2)(2,67));
                KS2 = table2array(SDATA.(name).(name2)(2,83));
                FC2 = table2array(SDATA.(name).(name2)(2,92));
                WP2 = table2array(SDATA.(name).(name2)(2,95));
                SAT2 = table2array(SDATA.(name).(name2)(2,98));
                numhor = 2;
                data = [sand1 silt1 clay1 OM1 KS1 FC1 WP1 SAT1 depth1;...
                    sand2 silt2 clay2 OM2 KS2 FC2 WP2 SAT2 depth2];
                nancheck = sum(isnan(data));
                if any(nancheck == 1)
                    indnan = find(nancheck == 1);
                    for nan = 1:length(indnan)
                        data(2, indnan(nan)) = data(1, indnan(nan));
                    end
                end
            else
                sand2 = table2array(SDATA.(name).(name2)(2,34));
                silt2 = table2array(SDATA.(name).(name2)(2,52));
                clay2 = table2array(SDATA.(name).(name2)(2,61));
                OM2 = table2array(SDATA.(name).(name2)(2,67));
                KS2 = table2array(SDATA.(name).(name2)(2,83));
                FC2 = table2array(SDATA.(name).(name2)(2,92));
                WP2 = table2array(SDATA.(name).(name2)(2,95));
                SAT2 = table2array(SDATA.(name).(name2)(2,98));
                depth3 = table2array(SDATA.(name).(name2)(3,10));
                if depth3 >= systemdepth
                    sand3 = table2array(SDATA.(name).(name2)(3,34));
                    silt3 = table2array(SDATA.(name).(name2)(3,52));
                    clay3 = table2array(SDATA.(name).(name2)(3,61));
                    OM3 = table2array(SDATA.(name).(name2)(3,67));
                    KS3 = table2array(SDATA.(name).(name2)(3,83));
                    FC3 = table2array(SDATA.(name).(name2)(3,92));
                    WP3 = table2array(SDATA.(name).(name2)(3,95));
                    SAT3 = table2array(SDATA.(name).(name2)(3,98));
                    numhor = 3;
                    data = [sand1 silt1 clay1 OM1 KS1 FC1 WP1 SAT1 depth1;...
                    sand2 silt2 clay2 OM2 KS2 FC2 WP2 SAT2 depth2;...
                    sand3 silt3 clay3 OM3 KS3 FC3 WP3 SAT3 depth3];
                    nancheck = isnan(data);
                    for nan1 = 1:9
                        for nan2 = 1:3
                            if nancheck(nan2, nan1) == 1
                                data(nan2, nan1) = data(nan2-1, nan1);
                            end
                        end
                    end
                else
                    sand3 = table2array(SDATA.(name).(name2)(3,34));
                    silt3 = table2array(SDATA.(name).(name2)(3,52));
                    clay3 = table2array(SDATA.(name).(name2)(3,61));
                    OM3 = table2array(SDATA.(name).(name2)(3,67));
                    KS3 = table2array(SDATA.(name).(name2)(3,83));
                    FC3 = table2array(SDATA.(name).(name2)(3,92));
                    WP3 = table2array(SDATA.(name).(name2)(3,95));
                    SAT3 = table2array(SDATA.(name).(name2)(3,98));
                    sand4 = table2array(SDATA.(name).(name2)(4,34));
                    silt4 = table2array(SDATA.(name).(name2)(4,52));
                    clay4 = table2array(SDATA.(name).(name2)(4,61));
                    OM4 = table2array(SDATA.(name).(name2)(4,67));
                    KS4 = table2array(SDATA.(name).(name2)(4,83));
                    FC4 = table2array(SDATA.(name).(name2)(4,92));
                    WP4 = table2array(SDATA.(name).(name2)(4,95));
                    SAT4 = table2array(SDATA.(name).(name2)(4,98));
                    numhor = 4;
                    depth4 = table2array(SDATA.(name).(name2)(4,10));
                    data = [sand1 silt1 clay1 OM1 KS1 FC1 WP1 SAT1 depth1;...
                    sand2 silt2 clay2 OM2 KS2 FC2 WP2 SAT2 depth2;...
                    sand3 silt3 clay3 OM3 KS3 FC3 WP3 SAT3 depth3;
                    sand4 silt4 clay4 OM4 KS4 FC4 WP4 SAT4 depth4];
                    nancheck = isnan(data);
                    for nan1 = 1:9
                        for nan2 = 1:4
                            if nancheck(nan2, nan1) == 1
                                data(nan2, nan1) = data(nan2-1, nan1);
                            end
                        end
                    end
                    if any(isnan(data))
                        pause
                    end
                end
            end
        end
        location = SDATA.(name).stations;
        system = syssetup(data);
        for P = 1
            totmass = mass.*19.*19;
            pname = ['station',num2str(location(P))];
            precip = precipdata(:,location(P));
            [totuptake, conserve, leach] = SIMfunc(system, precip, timing, mass);
            DATA.(name).(name2).(pname)(:,1) = [totuptake, conserve, leach];
            DATA.(name).(name2).(pname)(:,2) = [totuptake, conserve, leach]./totmass;
        end
        clearvars -except DATA SDATA precipdata uniqmu j i conames name muind timing mass systemdepth
        toc
    end
end
filename = 'results.mat';
save(filename, 'DATA');
            