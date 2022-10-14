clear all; close all;

%definición de parámetros para las ventanas modales de diálogo
options.Resize='on';
options.WindowStyle='modal';
options.Interpreter='tex';

Modelo = 'Alex';
prompt = {'Alex/Google'};
dlg_title = '¿nuevos datos?';
num_lines = 1;
def = {'Alex'};
answer = inputdlg(prompt,dlg_title,num_lines,def,options);
tipoRed = answer{1};
load netTransferPlataformaAlexNet;
% Dimensión requerida por la red
sz = netTransfer.Layers(1).InputSize;

[aa bb]=uigetfile({'*.*','All files'});

I=imread([bb aa]);
I = imrotate(I,-90,'bilinear');
[M,N,c] = size(I);

HSV = rgb2hsv(I);
G = HSV(:,:,3);

level = graythresh(G);
negra = imbinarize(G,level);

se = strel('disk',8);
Binaria2 = imopen(negra,se);
Binaria3 = imclose(Binaria2,se);
Binaria4 = bwmorph(Binaria3,'clean');
%figure; imshow(negra);
%figure; imshow(Binaria2);
%figure; imshow(Binaria3);
%figure; imshow(Binaria4);

[Etiquetas,NumRegiones] = bwlabel(Binaria4);

disp(NumRegiones);%V1 => 17147 || V2 => 198

PropRegiones = regionprops(Etiquetas,'all');

TamArea = 7000;
RegionesSeleccionadas = zeros(1,NumRegiones);
for i=1:1:NumRegiones
  if PropRegiones(i).Area > TamArea
      RegionesSeleccionadas(i) = 1;
  end
end

PlataformasCandidatas = zeros(1,NumRegiones);
Errors = zeros(NumRegiones,9);
for i=1:1:NumRegiones
    if RegionesSeleccionadas(i) == 1
        Rectangulo = round(PropRegiones(i).BoundingBox);
        %Coordenadas de la región y control de desbordamiento de la imagen:
        %(X,Y) de la esquina superior izquierda
        XSupIzda = Rectangulo(1);
        if XSupIzda <=0; XSupIzda = 1; end
        YSupIzda = Rectangulo(2);
        if YSupIzda <=0; YSupIzda = 1; end
        
        ancho =  Rectangulo(3); alto = Rectangulo(4); % ancho y alto del rectángulo
    
        XSupDcha =  round(XSupIzda + ancho);
        if XSupDcha > N; XSupDcha = N; end
        YSupDcha =  YSupIzda; 
     
        XInfIzda =  XSupIzda;
        YInfIzda =  round(YSupIzda + alto);
        if YInfIzda > M; YInfIzda = M; end

        XInfDcha =  XSupDcha; 
        YInfDcha =  YInfIzda;
    
        Recorte = I(YSupIzda:1:YInfIzda,XSupIzda:1:XSupDcha,:);     
        
        % Seleccionamos sólo las regiones que tienen etiqueta la
        % plataforma2 y además la probabilidad de clasificación sea
        % superior a 0.5 para garantizar que tenga un valor suficiente
        Ir = imresize(Recorte, [227 227]);
        
        %figure;
        %imshow(Ir);
        %impixelinfo;
        [label, Error]  = classify(netTransfer,Ir);
        %Almacenar los errores
        %Errors(i,:)= Error;
        
        MaxValor = max(Error);
        if strcmp(char(label),'Matricula') && (MaxValor > 0.6)
           PlataformasCandidatas(i) = MaxValor;
        end
    end
end


% De todas las plataformas identificadas elegimos la que haya obtenido el
% mayor valor en la clasificación, que se identifica con el parámetro col
MaxP = max(PlataformasCandidatas);
[row,col,v] = find(PlataformasCandidatas == MaxP);

%% Dibujo de la plataforma sobre la imagen original
Rectangulo = round(PropRegiones(col).BoundingBox);
%Coordenadas de la región y control de desbordamiento de la imagen:
%(X,Y) de la esquina superior izquierda
XSupIzda = Rectangulo(1);
if XSupIzda <=0; XSupIzda = 1; end
YSupIzda = Rectangulo(2);
if YSupIzda <=0; YSupIzda = 1; end
        
ancho =  Rectangulo(3); alto = Rectangulo(4); % ancho y alto del rectángulo
    
XSupDcha =  round(XSupIzda + ancho);
if XSupDcha > N; XSupDcha = N; end
YSupDcha =  YSupIzda;

XInfIzda =  XSupIzda;
YInfIzda =  round(YSupIzda + alto);
if YInfIzda > M; YInfIzda = M; end

XInfDcha =  XSupDcha; 
YInfDcha =  YInfIzda;



%OCR de matlab

IMat = I(YSupIzda:1:YInfIzda,XSupIzda:1:XSupDcha,:);
%imwrite(IMat,"D:\GitHub\TrabajoFinGrado\MatLab\matricula.jpg");
HSV = rgb2hsv(IMat);
G2 = HSV(:,:,3);

level2 = graythresh(G2);
negra2 = imbinarize(G2,level2);
figure;imshow(negra2);
bbox = detectTextCRAFT(negra2,CharacterThreshold=0.55);
results = ocr(negra2,bbox, 'CharacterSet','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ','TextLayout','Block');
disp([results.Text]);

%{
% Sort the character confidences.
[sortedConf, sortedIndex] = sort(results.CharacterConfidences, 'descend');

% Keep indices associated with non-NaN confidences values.
indexesNaNsRemoved = sortedIndex( ~isnan(sortedConf) );

% Get the top seven indexes.
topTenIndexes = indexesNaNsRemoved(1:7);

%}

%------------

color = 'red'; texto = ['Matrícula: ',results.Text];
figure; imshow(I); impixelinfo; title('Identificación matricula'); hold on; 
text(XSupDcha+100,YSupDcha,texto,'Color','y','FontSize',10,'FontWeight','bold')
line([XSupIzda,XSupDcha],[YSupIzda,YSupDcha],'LineWidth',2,'Color',color)
line([XSupIzda,XInfIzda],[YSupIzda,YInfIzda],'LineWidth',2,'Color',color)
line([XSupDcha,XInfDcha],[YSupDcha,YInfDcha],'LineWidth',2,'Color',color)
line([XInfIzda,XInfDcha],[YInfIzda,YInfDcha],'LineWidth',2,'Color',color)
hold off