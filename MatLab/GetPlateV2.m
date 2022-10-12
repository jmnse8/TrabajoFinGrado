clear all; close all;

[aa bb]=uigetfile({'*.*','All files'});

J=imread([bb aa]);
I = imrotate(J,-90,'bilinear');
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
        
        figure;
        imshow(Ir);
        impixelinfo;
        %[label, Error]  = classify(netTransfer,Ir);
        % Almacenar los errores
        %Errors(i,:)= Error;
        
        %MaxValor = max(Error);
        %if strcmp(char(label),'Plataforma2') && (MaxValor > 0.6)
        %   PlataformasCandidatas(i) = MaxValor;
        %end
    end
end
