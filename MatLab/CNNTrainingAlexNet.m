clear all; close all;

imds = imageDatastore('AlexNet', 'IncludeSubfolders', true, 'LabelSource','foldernames');

[imdsTrain,imdsValidation] = splitEachLabel(imds,0.9,'randomized');

numTrainImages = numel(imdsTrain.Labels);
idx = randperm(numTrainImages,64);
figure
for i = 1:64
    subplot(8,8,i)
    I = readimage(imdsTrain,idx(i));
    imshow(I)
end

% load netlayer y visualizar
net = alexnet;
layers = net.Layers;
lgraph = layerGraph(layers);
analyzeNetwork(lgraph);

inputSize = net.Layers(1).InputSize;

%% Seguimos las instrucciones teniendo en cuenta lo descrito en la siguiente dirección:
% https://es.mathworks.com/help/nnet/ref/alexnet.html#bvnzu37

% Replace Final Layers
% The last three layers of the pretrained network net are configured for 1000 classes. These three layers must be fine-tuned for the new classification problem. Extract all layers, except the last three, from the pretrained network.

layersTransfer = net.Layers(1:end-3);

%Transfer the layers to the new classification task by replacing the last three layers with a fully connected layer, a softmax layer, and a classification output layer. Specify the options of the new fully connected layer according to the new data. Set the fully connected layer to have the same size as the number of classes in the new data. To learn faster in the new layers than in the transferred layers, increase the WeightLearnRateFactor and BiasLearnRateFactor values of the fully connected layer.
numClasses = numel(categories(imdsTrain.Labels));

%numClasses = 6; %Número de clases almacenadas en nuestra base de datos 
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

%% Train Network
%The network requires input images of size 227-by-227-by-3, but the images in the image datastores have different sizes. Use an augmented image datastore to automatically resize the training images. Specify additional augmentation operations to perform on the training images: randomly flip the training images along the vertical axis, and randomly translate them up to 30 pixels horizontally and vertically. Data augmentation helps prevent the network from overfitting and memorizing the exact details of the training images.

pixelRange = [-30 30];
scaleRange = [0.9 1.1];
imageAugmenter = imageDataAugmenter('RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange, ...
    'RandXScale',scaleRange, ...
    'RandYScale',scaleRange);

augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter);

augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

numaugsValidationImages = augimdsValidation.NumObservations;
idx = randperm(numaugsValidationImages,16);

figure
for i = 1:16
    subplot(4,4,i)
    I = imread(augimdsValidation.Files{idx(i),1});
    imshow(I)
end

options = trainingOptions('sgdm', ...
    'MiniBatchSize',10, ...
    'MaxEpochs',4, ...
    'InitialLearnRate',1e-4, ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',3, ...
    'ValidationPatience',Inf, ...
    'Verbose',false, ...
    'Plots','training-progress');

%Train the network that consists of the transferred and new layers. By default, trainNetwork uses a GPU if one is available (requires Parallel Computing Toolbox™ and a CUDA® enabled GPU with compute capability 3.0 or higher). Otherwise, it uses a CPU. You can also specify the execution environment by using the 'ExecutionEnvironment' name-value pair argument of trainingOptions.
netTransfer = trainNetwork(augimdsTrain,layers,options);

save netTransferPlataformaAlexNet netTransfer

%% Validación del proceso de entrenamiento

[YValidationPred,probs] = classify(netTransfer,imdsValidation);
validationAccuracy = mean(YValidationPred == imdsValidation.Labels);
validationError = mean(YValidationPred ~= imdsValidation.Labels);

YTrainPred = classify(netTransfer,imdsTrain);
trainError = mean(YTrainPred ~= imdsTrain.Labels);
disp("Error Entrenamiento: " + trainError*100 + "%")
disp("Error Validacion: " + validationError*100 + "%")

%% Plot the confusion matrix. Display the precision and recall for each class by using column and row summaries. Sort the classes of the confusion matrix. The largest confusion is between unknown words and commands, up and off, down and no, and go and no.
figure('Units','normalized','Position',[0.2 0.2 0.5 0.5]);
cm = confusionchart(YValidationPred,imdsValidation.Labels, ...
    'ColumnSummary','column-normalized', ...
    'RowSummary','row-normalized');
cm.Title = 'Matriz Confusion Validacion AlexNet';

%% Resultados de clasificación con imágenes de validación
idx = randperm(numel(imdsValidation.Files),8);
figure
for i = 1:8
    subplot(4,2,i)
    I = readimage(imdsValidation,idx(i));
    imshow(I)
    label = YValidationPred(idx(i));
    title(string(label) + ", " + num2str(100*max(probs(idx(i),:)),3) + "%");
end

%% Visualización de los pesos

% Get the network weights for the second convolutional layer
w1 = netTransfer.Layers(2).Weights;

% Scale and resize the weights for visualization
w1 = mat2gray(w1);
w1 = imresize(w1,5);

% Display a montage of network weights. There are 96 individual sets of
% weights in the first layer.
figure
montage(w1)
title('First convolutional layer weights')