imds = imageDatastore('AlexNet',...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');

idx = size(imds.Files,1);

for i=1:1:idx
  D = cell2mat(imds.Files(i));
  Img = imread(D);
  
  I = imresize(Img, [224 224]);
  
  [a,b] = find(D =='\');

  S1 = D(1:b(4));
  S2 = 'GoogleNet';
  S3 = D(b(5):b(6)-1);
  S4 = D(b(6):size(D,2));
  fichero = [S1,S2,S3,S4];
  imwrite(I,fichero);
end