function [particleArrayTimes, timeElasped, plottingStruct] = advectMapping(outputMatFolder,saveBaseName,muValue,particlesPerDimension,firstVortexLocation,options)
%> Code Description:
%     Advects a group of particles forward in time via the mapping method
%     described in Aref, Hassan. "Stirring by chaotic advection."
%     Journal of Fluid Mechanics 1984.
%
%> Inputs:
%     outputMatFolder:           Folder where the resulting particle array and
%                                plotting struct will be stored
%     saveBaseName:              Name of .mat file for the storage of particle
%                                array and plotting struct
%
%     muValue:                   Mu value, essentially a measure of how fast the
%                                stirrers switch on/off (lower -> more often)
%
%     particlesPerDimension:     Particles per dimension of the particle
%                                array that will be advected (default: 100 -> 
%                                10000 particles total)
%
%     firstVortexLocation:       Location of first vortex that will be
%                                on as a complex number, x: real, y: imag
%                                (keep radius < 1)
%
%     options:                   Plotting and frame options as struct,
%                                .maxTime -> end time of simulation (default 12),
%                                .frameRate -> how often record position 
%                                   (default -> 60 per sec),
%                                .particleArrayXLims & .particleArrayYLims for
%                                   bounds of initial particle array (defaults 
%                                   based on Aref's original plots)
%
%> Outputs:
%     particleArrayTimes:        Particle array for each time,
%                                flattened to 1 dim for particle locations,
%                                2nd dim is time
%
%     timeElapsed:               Time it took to run
%
%     plottingStruct:            Records relevant info to be passing to
%                                associated plotting functions
%
%> Harrison Ross Hibbett (harrison_hibbett@alumni.brown.edu) 2025
    arguments
        outputMatFolder string
        saveBaseName string
        muValue double
        particlesPerDimension double = 100
        firstVortexLocation double = 0.5+0i
        options.maxTime double = 12
        options.frameRate double = 60
        options.particleArrayXLims double = [-0.1279, 0.1279]
        options.particleArrayYLims double = [0, 0.1279*2]
    end




% Create Output Folder (if needed)
if ~exist(outputMatFolder, 'dir')
   mkdir(outputMatFolder)
end

saveBaseName = char(saveBaseName);
if length(saveBaseName) <= 3 || saveBaseName(end-3:end) ~= ".mat"
    saveBaseName = saveBaseName + ".mat";
end
saveLoc = fullfile(outputMatFolder,saveBaseName);

tic

%% Problem Parameters
a_val = 1;  % Radius of boundary-- default => 1
b_val = firstVortexLocation;   % Position of first vortex (complex) -- default => 0.5
c_cent = 0;   % Center of Circle -- default => 0

vort_1_pos = b_val;  
vort_2_pos = -1*vort_1_pos;
inv_vort_1_pos = c_cent + (a_val^2/(abs(vort_1_pos-c_cent))^2)*(vort_1_pos-c_cent);
inv_vort_2_pos = c_cent + (a_val^2/(abs(vort_2_pos-c_cent))^2)*(vort_2_pos-c_cent);

beta_val = b_val/a_val;
Gamma_val = 2*pi;

mu_val = muValue;
T_val = mu_val*2*pi / Gamma_val;

%% define video parameters
fps = options.frameRate;
time_end = options.maxTime;

total_frames = (fps*time_end) + 1;
frame_times = linspace(0,time_end,total_frames);

%% Set up Array of particles
ppd = particlesPerDimension;

xLims = options.particleArrayXLims; yLims = options.particleArrayYLims;
marker_array = createFlowMarkers(xLims,yLims,ppd);
marker_array_1d = marker_array(:);
marker_array_size = length(marker_array_1d);
marker_time_array = zeros(marker_array_size,total_frames);
marker_time_array(:,1) = marker_array_1d;

%% Find the times of stirrer swap and which stirrer is on and a given time
num_swaps = time_end*2*(1/T_val);
stirrer_swaps_times = (0:num_swaps+2)*0.5*T_val;
right_stirrer_on = zeros(size(stirrer_swaps_times));
right_stirrer_on(1:2:length(right_stirrer_on)) = 1;

%% Stirrer Calc
swap_times_cell = cell([1,total_frames-1]);
swap_times_count = zeros([1,total_frames-1]);
for time = 1:total_frames-1
    t_0 = frame_times(time);
    t_1 = frame_times(time+1);
    % Find if stirrer's swap ON/OFF within timeframe
    swaps_within_timeframe = 0;
    swaps_timeframe = [t_0];
    % Find which stirrer is ON at t_0
    swaps_rel = stirrer_swaps_times - t_0;
    swaps_rel(swaps_rel<=0) = nan;
    [~,Index] = min(swaps_rel);
    first_stirrer_pos = right_stirrer_on(Index-1);
    for j = 1:length(stirrer_swaps_times)
        if stirrer_swaps_times(j) < t_1 && stirrer_swaps_times(j) > t_0
            swaps_within_timeframe = swaps_within_timeframe + 1;
            swaps_timeframe = [swaps_timeframe, stirrer_swaps_times(j)];
        end
    end
    swaps_timeframe = [swaps_timeframe, t_1];
    swap_times_cell{time} = swaps_timeframe;
    swap_times_count(time) = swaps_within_timeframe;
end


%% Advect Particles Frames

for time = 1:total_frames-1

    swaps_timeframe = swap_times_cell{time};
    swaps_within_timeframe = swap_times_count(time);

    t_0 = frame_times(time);
    % Find which stirrer is ON at t_0
    swaps_rel = stirrer_swaps_times - t_0;
    swaps_rel(swaps_rel<=0) = nan;
    [~,Index] = min(swaps_rel);
    first_stirrer_pos = right_stirrer_on(Index-1);

    
    % for all particles
    for particle_i = 1:length(marker_array_1d)
        % particle_pos = pos_record(time);
        particle_pos = marker_time_array(particle_i,time);

        stirrer_position = first_stirrer_pos;
        % stirrer_position = 0;
        for i = 1:(1+swaps_within_timeframe)

            t_start = swaps_timeframe(i);
            % Find circle track parameters, lambda, rho, zeta_0
            zeta_0 = particle_pos;
            delta_t = swaps_timeframe(i+1) - t_start;

            if stirrer_position
                vort_pos = vort_1_pos;
                inv_pos = inv_vort_1_pos;
            else
                vort_pos = vort_2_pos;
                inv_pos = inv_vort_2_pos;
            end
        
            particle_pos_next = calcNextPos(vort_pos,inv_pos,delta_t/(2*pi)^2,zeta_0,stirrer_position,a_val,Gamma_val);

            if stirrer_position == 0
                stirrer_position = 1;
            else
                stirrer_position = 0;
            end
        end
        % pos_record(time+1) = particle_pos;
        marker_time_array(particle_i,time+1) = particle_pos_next;
    end

    statusBar(100*(time/(total_frames-1)));
end

particleArrayTimes = marker_time_array;
fprintf('\n');  %  new line

% Create plottingStruct
plottingStruct.vortexLocations = [vort_1_pos, vort_2_pos];
plottingStruct.muValue = muValue;
plottingStruct.maxTime = options.maxTime;
plottingStruct.frameRate = options.frameRate;

% Save particle array as .mat
saveDispString = sprintf("Saving array and plottingStruct to '%s'...", saveLoc);
disp(saveDispString)
save(saveLoc,"particleArrayTimes","plottingStruct");

timeElasped = toc;



%% Internal Functions

function marker_array = createFlowMarkers(xLims, yLims, pointsPerAxis)
    x_array_part= repmat(linspace(xLims(1),xLims(2),pointsPerAxis),pointsPerAxis,1);
    y_array_part= repmat(linspace(-yLims(1)*1i,-yLims(2)*1i,pointsPerAxis)',1,pointsPerAxis);

    marker_array = x_array_part+y_array_part;
end


function [path_center, path_radius] = calcStreamlineCircle(vort_pos,inv_pos,particle_pos)
    % path_center = (vort_pos*norm(inv_pos) - inv_pos*norm(vort_pos))/((norm(inv_pos) - norm(vort_pos)));
    lambda = abs((particle_pos-vort_pos)/(particle_pos-inv_pos));
    path_center = (vort_pos-(lambda^2*inv_pos))/(1-lambda^2);
    % path_radius = abs(particle_pos - path_center);
    path_radius = (lambda * abs(vort_pos - inv_pos))/abs(1-lambda^2);
end

function nextPosition = calcNextPos(vort_pos,inv_pos,t_step,zeta_0,stirrer_right,a_val,Gamma_val)

    lambda =  abs((zeta_0-vort_pos)/(zeta_0-(a_val^2/vort_pos)));

    [center, rho] = calcStreamlineCircle(vort_pos, inv_pos, zeta_0);

    if stirrer_right
        theta_0 = real(log((zeta_0-center)/rho)*-1*1i);
        A_theta_0 = theta_0 - ((2*lambda)/(1+lambda^2))*sin(theta_0);
        T_lambda = (rho^2/Gamma_val)*((1+lambda^2)/(1-lambda^2));
        t = t_step;
        RHS = A_theta_0 + (2*pi*t)/T_lambda;
        theta_t = inverse_A_theta(RHS,lambda,30000);
    else
        theta_0 = -real(log((zeta_0-center)/rho)*-1*1i);
        theta_0 = mod(pi - theta_0,2*pi);
        A_theta_0 = theta_0 - ((2*lambda)/(1+lambda^2))*sin(theta_0);
        T_lambda = (rho^2/Gamma_val)*((1+lambda^2)/(1-lambda^2));
        t = t_step;
        RHS = A_theta_0 + (2*pi*t)/T_lambda;
        theta_t = -1*inverse_A_theta(RHS,lambda,30000);
        theta_t = mod(pi - theta_t,2*pi);
    end
    nextPosition = center + rho*exp(1i*theta_t);
end

function theta = inverse_A_theta(RHS,lambda,n_s)
    k = lambda;

    % n_s = 30000;
    x_s = linspace(0,2*pi,n_s);
    % x_s = linspace(0,2*pi,n_s);
    
    y_s = x_s - ((2*k)/(1+k^2)).*sin(x_s);
    % plot(x_s,y_s)
    RHS = mod(RHS,2*pi);

    found = interp1(y_s,x_s, RHS);
    
    theta = found;
end

function statusBar(percent)
    persistent lastStr  % store last message

    percent = max(0, min(100, percent));

    % Length of the bar
    barWidth = 50;

    % Number of "#" symbols to show
    numHashes = round((percent/100) * barWidth);
    numSpaces = barWidth - numHashes;

    % Bar Message
    barStr = ['[', repmat('#',1,numHashes), repmat('. ',1,numSpaces), ']'];
    msg = sprintf('%s %3d%%', barStr, round(percent));

    if strcmp(lastStr, msg)

    else
        % Erase last message if it exists
        if ~isempty(lastStr)
            fprintf(repmat('\b',1,length(lastStr)));
        end
    
        % Print
        fprintf('%s', msg);
    
    % Store for next call
        lastStr = msg;
    
        % Reset at 100% so next call starts clean
        if percent >= 100
            lastStr = [];
            fprintf('\n');  % Start new line
        end
    end
end

end