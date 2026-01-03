%% Advect Particle Arrays and store result

storagePath = pwd;

trialNames = ["0_1", "0_35", "0_5", "1", "2", "3"];
muValuesLoop = [0.1, 0.35, 0.5, 1, 2, 3]; 

for i = 1:length(muValuesLoop)
    outputMatFolder = fullfile(storagePath,"particle_arrays");
    [particleArrayTimes, timeElasped, plottingStruct] = advectMapping(outputMatFolder,trialNames(i),muValuesLoop(i));
end

%% Make Img Frames of the trials

for i = 1:length(muValuesLoop)
    imgFolderPath = fullfile(storagePath,trialNames(i));
    matData = fullfile(storagePath,"particle_arrays",trialNames(i) + ".mat");
    load(matData)  % Will load variables "particleArrayTimes", "plottingStruct" into workspace
    makeAllFrames(particleArrayTimes,imgFolderPath,plottingStruct);
end

