% run.m - Interactive script to input rider data, calculate XC geometry, and plot

% =========================================================================
% Step 1: Interactively get Rider Anthropometric Data (using input function)
% =========================================================================
fprintf('--- Please enter your measurement data (Unit: mm) ---\n');

% Get Height
while true
    rider_height_mm = input('Enter your Height (mm): ');
    if isnumeric(rider_height_mm) && rider_height_mm > 1000 && rider_height_mm < 2500
        break;
    else
        fprintf('Invalid input. Please enter a reasonable value (1000mm-2500mm).\n');
    end
end

% Get Wingspan
while true
    rider_wingspan_mm = input('Enter your Wingspan (mm): ');
    if isnumeric(rider_wingspan_mm) && rider_wingspan_mm > 1000 && rider_wingspan_mm < 2500
        break;
    else
        fprintf('Invalid input. Please enter a reasonable value (1000mm-2500mm).\n');
    end
end

% Get Inseam (Leg Length)
while true
    rider_inseam_mm = input('Enter your Inseam / Crotch Height (mm): ');
    % Inseam should be less than height
    if isnumeric(rider_inseam_mm) && rider_inseam_mm > 400 && rider_inseam_mm < rider_height_mm
        break;
    else
        fprintf('Invalid input. Please enter a reasonable value (must be less than Height).\n');
    end
end

% Get Shoulder Width
while true
    rider_shoulder_mm = input('Enter your Shoulder Width (mm): ');
    if isnumeric(rider_shoulder_mm) && rider_shoulder_mm > 300 && rider_shoulder_mm < 600
        break;
    else
        fprintf('Invalid input. Please enter a reasonable value (300mm-600mm).\n');
    end
end

% =========================================================================
% Step 2: Call the XC Geometry Calculation Function
% =========================================================================
% Ensure calculate_xc_geo.m is in the MATLAB search path.
geo = calculate_xc_geo(rider_height_mm, rider_wingspan_mm, rider_inseam_mm, rider_shoulder_mm);

% Print calculated results for verification
fprintf('\n--- XC Geometry Calculation Results ---\n');
fprintf('  Inputs: H %.0f, W %.0f, I %.0f, S %.0f mm\n', rider_height_mm, rider_wingspan_mm, rider_inseam_mm, rider_shoulder_mm);
fprintf('  Calculated Reach: %.1f mm\n', geo.Reach);
fprintf('  Calculated Stack: %.1f mm\n', geo.Stack);
fprintf('  Calculated Seat Tube Len: %.1f mm\n', geo.seat_tube_len);
fprintf('  Head Angle: %.1f deg\n', geo.head_angle_deg);
fprintf('-----------------------------------------\n');

% =========================================================================
% Step 3: Call mtb_fit_and_plot (Directly plots the calculated geo structure)
% =========================================================================
opts = struct('title',sprintf('XC Geometry H%.0f/W%.0f/I%.0f', rider_height_mm, rider_wingspan_mm, rider_inseam_mm),...
              'annot_dx',240,'annot_anchor','front_axle');
out = mtb_fit_and_plot(geo, opts);