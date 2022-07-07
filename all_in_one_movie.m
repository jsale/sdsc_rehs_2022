%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ffffffff
% Create and save an image sequence and movie
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working director
workingDir = '/Users/tyleralex/Documents/MATLAB/Week 2 - June 27-July 1';

% Load data and channel layout
ch_layout = csvread('neuromag306mag_channel_layout.csv');
sleep_state = xlsread("hypnogramdata.xlsx");
% Initialize variables
band_array = ["low_delta","delta","theta","alpha","beta","gamma","unfiltered"];
band_title_array = ["Low Delta","Delta","Theta","Alpha","Beta","Gamma","Unfiltered"];
subject = "subj2";
channel = "m1";
subject_title = "Subject 2";
channel_title = "M1";   
increment = 10;
full_length = 15444;

% Loop through frequency bands in band_array
for band_inc = 1:1
    imageDir = sprintf('%s/video/%s/images/', workingDir, band_array(band_inc));
     imageNames = dir(fullfile(imageDir,'*.jpg'));
     imageNames = {imageNames.name}';
 
     for j = 1:length(imageNames)
        delete(fullfile(imageDir,imageNames{j}));
     end
     imageDir = sprintf('%s/video/%s/temp/', workingDir, band_array(band_inc));
     imageNames = dir(fullfile(imageDir,'*.jpg'));
     imageNames = {imageNames.name}';
 
     for j = 1:length(imageNames)
        delete(fullfile(imageDir,imageNames{j}));
    end
    band = band_array(band_inc);
    band_title = band_title_array(band_inc);
    if band_inc == 7
        input_data = sprintf('%s/subj-2-data/M1_movmean.mat', workingDir);
    else
        for bund=1:6
            input_data = sprintf('%s/subj-2-data/M1_%s_movmean.mat', workingDir, band_array(bund));
            load(input_data);
        end
    end
    load(input_data);

    x = ch_layout(:,2);
    y = ch_layout(:,3);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create Image Sequence
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %zval = 1;
    %variable in charge of position of progress bar
    barpos = 87.5;

      %swapped the elements of padsize
    for zval=1:increment:full_length
        for cur_band=1:6
            %loop through all band data to add all images
            band = band_array(cur_band);
    band_title = band_title_array(cur_band);
        if cur_band == 1
            Period = m1_low_delta_movmean.trial{1, 1}(:,zval);
        elseif cur_band == 2
            Period = m1_delta_movmean.trial{1, 1}(:,zval);
        elseif cur_band == 3
            Period = m1_theta_movmean.trial{1, 1}(:,zval);
        elseif cur_band == 4
            Period = m1_alpha_movmean.trial{1, 1}(:,zval);
        elseif cur_band == 5
            Period = m1_beta_movmean.trial{1, 1}(:,zval);
        elseif cur_band == 6
            Period = m1_gamma_movmean.trial{1, 1}(:,zval);
        elseif cur_band == 7
            Period = m1_movmean.trial{1, 1}(:,zval);
        end
           
        Period(30) = (Period(19) + Period(29) + Period(34) + Period(35))/4;
        Period(81) = (Period(80) + Period(82) + Period(89))/3;
        Period(92) = (Period(91) + Period(93) + Period(102))/3;

        [xq,yq] = meshgrid(-100:5:100, -100:5:100);
        vq = griddata(x,y,Period,xq,yq,'cubic');

        m = mesh(xq,yq,vq);
        m.FaceColor = 'interp';
        m.EdgeColor = 'none';
        axis equal;
        %axis square;
        colormap jet;
        az = 0;
        el = 90;
        view(az, el);
        colorbar;
        lighting gouraud
        
% Uncomment the code below to set the colorbar axis limits
        
        if cur_band == 7
            caxis([0.5e-11 2.5e-11]);
        elseif cur_band == 1
            caxis([0.1e-11 2.0e-11]);
        else
            caxis([0.1e-11 5.0e-12]);
        end

% Uncomment lines below to set plot parameters

%         colorbar('Position', [0.85 0.2 0.05 0.4], 'Label', 'Power')
%         c = colorbar;
%         c.Label.String = 'Power (V^2/Hz)';
%         c.Position = [0.82 0.22 0.05 0.4];
% 
%         xlabel('Scalp Location', "FontName", "ArialBold", "FontWeight", "bold", "FontSize", 14)
%         ax.XTick = [1 5.5 10];
%         ax.XTickLabel = {'Left','Midline','Right'};
%         ylabel("Scalp Location", "FontName", "ArialBold", "FontWeight", "bold", "FontSize", 14)
%         ax.YTick = [1 10];
%         ax.YTickLabel = {'Frontal','Occipital'};
%         zlabel("Time (seconds)", "FontName", "ArialBold", "FontWeight", "bold", "FontSize", 14)
        title_str = sprintf('%s %s %s', subject_title, channel_title, band_title);
        title({title_str;'   '}, "FontName", "ArialBold", "FontWeight", "bold", "FontSize", 16)
%         str1 = {'L-R'};
%         text(3,yval,14800,str1, "FontName", "ArialBold", "FontWeight", "bold", "FontSize", 14)
%         str2 = {'R-L'};
%         text(7,yval,14800,str2, "FontName", "ArialBold", "FontWeight", "bold", "FontSize", 14)

        % Save image
            outfile = sprintf('%s/video/%s/temp/%s_%s_%s_movmean_z%d.jpg', workingDir, band, subject, channel, band, zval+10000);
        %saves the grid to temporary file 
         saveas(gcf, outfile);
        end
        for bandz=1:6
              band = band_array(bandz);
    band_title = band_title_array(bandz);
            outfile = sprintf('%s/video/%s/temp/%s_%s_%s_movmean_z%d.jpg', workingDir, band, subject, channel, band, zval+10000);

            cur_img = imread(outfile);

            %resizes image to fit wanted size
            cur_img = imresize(cur_img,[875 1167]);
            subplot(3,3,bandz);
            imshow(cur_img);
        end
        %initialize and pad hypnogram sides
        hypno = imread("subj2_hypnogram.png");
        %padded_hyp = padarray(hypno,[0 floor((size(cur_img,2)-839)/2)],255);
        
        subplot(3,3,[7,9]);
        imshow(hypno);
      
        %combine two images
        file = sprintf('%s/video/%s/images/%s_%s_%s_movmean_z%d.jpg', workingDir, band, subject, channel, band, zval+10000);
        %prod = cat(1,cur_img,padded_hyp);
        

        %imshow(prod);
        %hold on;

        %add the progress bar
        rectangle('Position', [barpos 50 5 183] , 'FaceColor', '#CE7639','EdgeColor','#CE7639');
        barpos = barpos + (increment/15444) * (880.5-87.5);
        
        %save file
        %pause(5);
        saveas(gcf, file);
        clf();
    end
    %imshow("data/)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create Movie
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    videoDir = sprintf('%s/video/%s/', workingDir, band);
    imageDir = sprintf('%s/video/%s/images/', workingDir, band);
    imageNames = dir(fullfile(imageDir,'*.jpg'));
    imageNames = {imageNames.name}';
    video_file = sprintf('%s_%s_%s_yes_axis_limits_x%d.mp4', subject, channel, band, increment);
    outputVideo = VideoWriter(fullfile(videoDir,video_file), 'MPEG-4');
    open(outputVideo)

    for j = 1:length(imageNames)
       img = imread(fullfile(imageDir,imageNames{j}));
       writeVideo(outputVideo,img)
    end

    close(outputVideo)
end

