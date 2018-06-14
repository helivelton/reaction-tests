#include <LiquidCrystal.h>
#include <SD.h>
#include <EEPROM.h>

boolean cartaoPresente = false;
LiquidCrystal lcd(5, 4, 3, 2, 1, 0);


int ID=0;
int acellCal = 0;
int anterior = 0;
int erro1=0;
int erro2=0;
int erro3=0;


int erros=0;   
int contagem=0;

float tempos[50];
float tempoReacao[50];


int pin;
long inicioTeste;
long fTeste;	
int tipo;
//int nivel = 0;

void zerarID()
{
  // write a 0 to all 512 bytes of the EEPROM
  for (int i = 0; i < 512; i++)
    EEPROM.write(i, 0);
    
  // turn the LED on when we're done
  lcd.clear();
  lcd.print("ID zerado");
  delay(2000);
}

void getID()
{
  int last = 0;
  int vlast = 0;
  
  if(EEPROM.read(0)==0)EEPROM.write(0,1);
  
  for (int i =0; i<500; i++){
    if(EEPROM.read(i)==0) last = i-1;
    ID += EEPROM.read(i);
    
  }
  
  if(EEPROM.read(last)==255) last +=1;
  vlast = EEPROM.read(last);
  
  EEPROM.write(last, vlast+1);
  


}






void config(int estado){
  const int ledCabeca = 0;
const int ledDireita = 1;
const int ledEsquerda = 2;
const int ledAbd = 3;

const int sensorCabeca = 6;
const int sensorDireita = 7;
const int sensorEsquerda = 8;
const int sensorAbd = 9;

  
  
digitalWrite(ledCabeca, estado);
digitalWrite(ledDireita, estado);
digitalWrite(ledEsquerda, estado);
digitalWrite(ledAbd, estado);

 
}


boolean acelerometro(){
  
const int xpin = A0;                  // Contantes dos
const int ypin = A1;                  // pinos em que
const int zpin = A2;                  // os eixos estao localizados

const int xpin2 = A3;                  // Contantes dos
const int ypin2 = A4;                  // pinos em que
const int zpin2 = A5;                  // os eixos estao localizados

int DX=0, DY=0, DZ=0;  // variaveis que armazenam a aceleraÃƒÆ’Ã‚Â§ao anterior de cada eixo
int DX2=0, DY2=0, DZ2=0;
  
  while(true){      //loop infinito
  
  int X=0,Y=0,Z=0; 
  int X2=0,Y2=0,Z2=0;
  
  int xx[9],yy[9],zz[9];  
  int xx2[9],yy2[9],zz2[9];

  for(int i=0; i<=9; i++){
    xx[i]=analogRead(xpin);
    yy[i]=analogRead(ypin);
    zz[i]=analogRead(zpin);

    xx2[i]=analogRead(xpin2);
    yy2[i]=analogRead(ypin2);
    zz2[i]=analogRead(zpin2);
  }
  
  for(int i=0; i<=9; i++){ //as leituras sao somadas em variaveis para cada eixo
    X = X + xx[i];
    Y = Y + yy[i];
    Z = Z + zz[i];

    X2 = X2 + xx2[i];
    Y2 = Y2 + yy2[i];
    Z2 = Z2 + zz2[i];
  }
  
  X = X/10; //entao feita a media das leituras
  Y = Y/10;
  Z = Z/10;

  X2 = X2/10;
  Y2 = Y2/10;
  Z2 = Z2/10;

 if( ((X-DX)<-acellCal) | ((Y-DY)<-acellCal) | ((Z-DZ)<-acellCal) | ((X2-DX2)<-acellCal) | ((Y2-DY2)<-acellCal) | ((Z2-DZ2)<-acellCal)){ //se houver um variacao significativa entre as leituras, houve um movimento
   
 return true; //entao a funcao de leitura e finalizada
 
 }
 
 DX=X; //armazenando as leituras anteriores
 DZ=Z;
 DY=Y;

 DX2=X2;
 DZ2=Z2;
 DY2=Y2;
  
  }
}

void calibrarAcell(){
  delay(3000);
  
  while(true){
    lcd.clear();  
    
    while(digitalRead(6)==HIGH){
    lcd.setCursor(0,0);
    lcd.print("Insensibilidade:");
    lcd.setCursor(0,1);
    lcd.print(acellCal);
    
    if(digitalRead(7)==LOW){
      acellCal +=25;
      delay(1000);
    }
    
    if(digitalRead(8)==LOW){
      acellCal -=25;
      delay(1000);
    }
    
    
    }
    config(LOW);
    delay(2000);
    config(HIGH);
    acelerometro();
    config(LOW);
    delay(2000);
    
    config(HIGH);
    acelerometro();
    config(LOW);
    delay(2000);
    
    lcd.clear();
    lcd.print("Confirmar?");
    lcd.setCursor(0,1);
    lcd.print("1.Sim  2.Nao");
    
    while(digitalRead(7)==HIGH){
      if(digitalRead(6)==LOW)return;
    }
  }
  }


void botoesErro(int led){
  
  const int ledCabeca = 0;
const int ledDireita = 1;
const int ledEsquerda = 2;
const int ledAbd = 3;

const int sensorCabeca = 6;
const int sensorDireita = 7;
const int sensorEsquerda = 8;
const int sensorAbd = 9;

  
  switch(led){
    
      case 1:{
              pin = ledCabeca;
              erro1 = sensorDireita;
              erro2 = sensorEsquerda;
              erro3 = sensorAbd;
      
              }
        break;
      case 2:{
              pin = ledDireita;
              erro1 = sensorCabeca;
              erro2 = sensorEsquerda;
              erro3 = sensorAbd;
              }
        break;
      case 3:{
              pin = ledEsquerda;
              erro1 = sensorDireita;
              erro2 = sensorCabeca;
              erro3 = sensorAbd;
      
              }
        break;
      case 4:{
              pin = ledAbd;
              erro1 = sensorDireita;
              erro2 = sensorEsquerda;
              erro3 = sensorCabeca;
      
              }
      break;
    }
  
}




void testeA(int numSensores){
  
const int ledCabeca = 0;
const int ledDireita = 1;
const int ledEsquerda = 2;
const int ledAbd = 3;

const int sensorCabeca = 6;
const int sensorDireita = 7;
const int sensorEsquerda = 8;
const int sensorAbd = 9;

    
    arquivoS("ID do teste ; ");
    arquivoI(ID);
    arquivoSln(";");
    arquivoS("Tipo de teste ; ");
    arquivoIln(tipo);
    arquivoSln(" ");
    arquivoSln("ID;TR;TM;TResp;VM;");
  
	//funÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o do teste tipo 1
  inicioTeste = millis();
  fTeste = inicioTeste + 10000;
 
 
 
   while(millis()<=fTeste){ // enquanto o tempo atual nÃƒÆ’Ã‚Â£o for igual ao tempo de fim do teste.

   
   int led = random(1, (numSensores +1));
   
   
   switch(led){
    
      case 1: pin = ledCabeca;
        break;
      case 2: pin = ledDireita;
        break;
      case 3: pin = ledEsquerda;
        break;
      case 4: pin = ledAbd;
      break;
    }
  
  

   botoesErro(led);
  
  
    
   if(anterior != led){ // quando o mesmo led da leitura anterior ÃƒÆ’Ã‚Â© selecionado, o processo de leitura nÃƒÆ’Ã‚Â£o ÃƒÆ’Ã‚Â© executado 
       
        
        config(LOW);
	digitalWrite(pin, HIGH);//acendendo led

	float tempoi=millis( ); //armazendo momento em que o led acendeu

	int sensor = pin + 6;  //selecionando sensor equivalente ao led
        //Serial.println("acelerometro");
        acelerometro(); //chamada da funÃƒÆ’Ã‚Â§ao acelerometro

        tempoReacao[contagem]=((millis())-tempoi) / 1000;
        
        boolean tempoNaoAcabou = true;
        boolean noPush = true;
        boolean acertou = false;
        
	while(noPush & tempoNaoAcabou){
	digitalWrite(pin, HIGH);
        
        digitalWrite(sensor,HIGH);
        digitalWrite(erro1,HIGH);
        digitalWrite(erro2,HIGH);
        digitalWrite(erro3,HIGH);
        
        if(digitalRead(sensor)==LOW){
		noPush=false;
                acertou=true;
                
	   }
        if(millis()>fTeste)tempoNaoAcabou=false;
          
        
          if((digitalRead(erro1)==LOW)){
            erros++;
            noPush=false;
                  
           }
    
          if((digitalRead(erro2)==LOW)){
            erros++;
            noPush=false;
            
           }
    
          if((digitalRead(erro3)==LOW)){
            erros++;
            noPush=false;
            
         }
          
    
  }
 

  digitalWrite(pin, LOW);
  
  if (acertou){
  float tempor =((millis()-tempoi) / 1000);
  tempos[contagem] = tempor;
  
    arquivoI(contagem+1); arquivoS(";");  
    arquivoD(tempoReacao[contagem]); arquivoS(";");
    arquivoD(tempos[contagem]-tempoReacao[contagem]); arquivoS(";");
    arquivoDln(tempos[contagem]);
    
  contagem++; //incremento de variÃƒÆ’Ã‚Â¡vel de contagem de golpes
  
    }
    delay(300);
    
    
   }
    anterior = led;

  
  
}
}
void lcdFimTeste(){  //funÃƒÆ’Ã‚Â§ao executada no fim do teste que mostra os resultados na LCD


  float menor = tempos[0];
  float menorR = tempoReacao[0];
  float menorMov = (tempos[0]-tempoReacao[0]);
    
  float maior = tempos[0];
  float maiorR = tempoReacao[0];
  float maiorMov = (tempos[0]-tempoReacao[0]);
  
  float media;
  float mediaR;
  float mediaMov;
  
  float soma = 0;
  float somaR = 0;
  float somaMov = 0;

  for(int i=0; i<=contagem-1; i++){            //for criado para percorrer o verto que armazenou os tempos, com o objetivo de calcular o tempo menor, o maior e a soma de todos
    
    
    
    float tempoMov = (tempos[i] - tempoReacao[i]);
    
    if (tempos[i]<menor) menor = tempos[i];
    if (tempoReacao[i]<menorR) menorR = tempoReacao[i];
    if (tempoMov<menorMov) menorMov = tempoMov;
    
    if (tempos[i]>maior) maior = tempos[i];
    if (tempoReacao[i]>maiorR) maiorR = tempoReacao[i];
    if (tempoMov>maiorMov) maiorMov = tempoMov;
    
    
    soma += tempos[i];
    somaR += tempoReacao[i];
    somaMov += tempoMov;
    
  }
  
  
  media = (float)soma/(float)contagem; //calculando a media, dividindo a soma dos tempos pelo numero de acertos
  mediaR = (float)somaR/(float)contagem; //calculando a media, dividindo a soma dos tempos pelo numero de acertos
  mediaMov = (float)somaMov/(float)contagem; //calculando a media, dividindo a soma dos tempos pelo numero de acertos
  
  
  for(int i=0; i<=2;i++){ //enquanto o botao ligar nao for acionado, seram repetidos os seguintes procedimentos
  
  lcd.clear();                 //limpando tela LCD
  lcd.print("TR.min ");         //Escrevendo na tela (tempo minimo)
  lcd.print(menorR);            //as seguintes Strings 
  lcd.print(" seg");           // e variaveis
  
 
  lcd.setCursor(0,1);        //colocando o cursor da tela LCD na segunda linha
  lcd.print("TR.max ");       //Escrevendo na tela (tempo maximo)
  lcd.print(maiorR);          //as seguintes Strings 
  lcd.print(" seg");         // e variaveis
  
  /*
  Serial.print("T.max ");
  Serial.print(maior);
  Serial.println(" seg");
  */
  delay(4000);              //pausa de 4 segundos (tempo em que as imformaÃƒÆ’Ã‚Â§oes ficaram na tela

  
  lcd.clear();              //limpando novamente a tela para mostrar as imformacoes seguintes
  lcd.print("TR.med ");      //Escrevendo na tela (tempo medio)
  lcd.print(mediaR);
  lcd.print(" seg");
  
  
  delay(4000);
  
  
  
  lcd.clear();                 //limpando tela LCD
  lcd.print("TM.min ");         //Escrevendo na tela (tempo minimo)
  lcd.print(menorMov);            //as seguintes Strings 
  lcd.print(" seg");           // e variaveis
  
 
  lcd.setCursor(0,1);        //colocando o cursor da tela LCD na segunda linha
  lcd.print("TM.max ");       //Escrevendo na tela (tempo maximo)
  lcd.print(maiorMov);          //as seguintes Strings 
  lcd.print(" seg");         // e variaveis
  
  /*
  Serial.print("T.max ");
  Serial.print(maior);
  Serial.println(" seg");
  */
  delay(4000);              //pausa de 4 segundos (tempo em que as imformaÃƒÆ’Ã‚Â§oes ficaram na tela

  
  lcd.clear();              //limpando novamente a tela para mostrar as imformacoes seguintes
  lcd.print("TM.med ");      //Escrevendo na tela (tempo medio)
  lcd.print(mediaMov);
  lcd.print(" seg");

  delay(4000);
  
  
  
  lcd.clear();                 //limpando tela LCD
  lcd.print("TResp.min ");         //Escrevendo na tela (tempo minimo)
  lcd.print(menor);            //as seguintes Strings 
  lcd.print(" seg");           // e variaveis
  
 
  lcd.setCursor(0,1);        //colocando o cursor da tela LCD na segunda linha
  lcd.print("TResp.max ");       //Escrevendo na tela (tempo maximo)
  lcd.print(maior);          //as seguintes Strings 
  lcd.print(" seg");         // e variaveis
  
  /*
  Serial.print("T.max ");
  Serial.print(maior);
  Serial.println(" seg");
  */
  delay(4000);              //pausa de 4 segundos (tempo em que as imformaÃƒÆ’Ã‚Â§oes ficaram na tela

  
  lcd.clear();              //limpando novamente a tela para mostrar as imformacoes seguintes
  lcd.print("TResp.med ");      //Escrevendo na tela (tempo medio)
  lcd.print(media);
  lcd.print(" seg");
  
  
  /*
  Serial.print("T.med ");
  Serial.print(media);
  Serial.println(" seg");
  */
  delay(4000);
  lcd.clear();    
  lcd.print("N.acerto ");  //Escrevendo na tela(numero de acertos)
  lcd.print(contagem);  
  
  /*
  Serial.print("N.acerto ");
  Serial.println(contagem);
  */
  
  
  lcd.setCursor(0,1);
  lcd.print("N.erros ");  //escrevendo na tela (numero de erros)
  lcd.print(erros);
  
  /*
  Serial.print("N.erros ");
  Serial.println(erros);
  */
  delay(4000);
}
  
}

void escolheTeste(){ //funÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o para escolher o tipo de teste

	int teste = 5;
        boolean escolheu = false;
        
  //Serial.println("Selecione o teste");
  
  while(!escolheu){
    
    
    
    
    delay(45);
    
    if(teste==6)teste=5;
    
    lcd.clear();
    lcd.print("Selecione o teste:");
    lcd.setCursor(0,1);
    lcd.print(teste);
    
    if(digitalRead(7)==LOW){
      teste+=1;
      delay(1000);
    }
    
    if(digitalRead(6)==LOW) escolheu = true;
    
  }
    
	lcd.clear();
        lcd.print("teste "); lcd.print(teste);
        delay(2000);
        config(LOW); //Apagando todos os leds
	
        config(HIGH); //Acendendo todos od leds
        delay(500);
        config(LOW);
        delay(500);
        config(HIGH);
        delay(500);
        config(LOW);
        

        int intervalo = random(2,7);
        
        delay(intervalo*1000);



        tipo = teste;
	//Serial.println("entrateste");

	switch(teste){
	
	
        case 5: testeA(4);
	break;
	
	
	}

}

void menu(){ //funÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o para escolher o tipo de teste

	int opc = 1;
        boolean escolheu = false;
        
  //Serial.println("Selecione o teste");
  
  while(!escolheu){
    
    
    
    
    delay(45);
    
    if(opc==5)opc=1;
    
    lcd.clear();
    lcd.print("Opcao:");
    lcd.setCursor(0,1);
    
    switch(opc){
      case 1:lcd.print("Teste");
      break;
      case 2:lcd.print("Zerar ID");
      break;
      case 3:lcd.print("Calibrar acel.");
      break;
    }
      
    if(digitalRead(6)==LOW) escolheu = true;  
      
    if(digitalRead(7)==LOW){
      opc+=1;
      delay(1000);
    }
    
    
    
  }
    
	

        

        switch(opc){
	
	case 1: {
                 lcd.clear();
                 lcd.print("...");
                 delay(2000); 
                 escolheTeste();
                 }
	break;
	case 2: {
                lcd.clear();
                lcd.print("...");
                delay(2000);
                zerarID();
                menu();
                }
	break;
	case 3: {
                lcd.clear();
                lcd.print("...");
                delay(2000);
                calibrarAcell();
                menu();
                }
	break;  
	
	}

}

void arquivoS(String texto){
while (true){
  File arquivo = SD.open("testes.csv", FILE_WRITE);
    
  if(arquivo){
  arquivo.print(texto);
  arquivo.close(); 
  return;
  } 
  }
}

void arquivoSln(String texto){
while (true){
  File arquivo = SD.open("testes.csv", FILE_WRITE);
    
  if(arquivo){
  arquivo.println(texto);
  arquivo.close(); 
  return;
  } 
  }
}

void arquivoD(double texto){
while (true){
  File arquivo = SD.open("testes.csv", FILE_WRITE);
    
  if(arquivo){
  arquivo.print(texto);
  arquivo.close(); 
  return;
  } 
  }
}

void arquivoDln(double texto){
while (true){
  File arquivo = SD.open("testes.csv", FILE_WRITE);
    
  if(arquivo){
  arquivo.println(texto);
  arquivo.close(); 
  return;
  } 
  }
}

void arquivoI(int texto){
while (true){
  File arquivo = SD.open("testes.csv", FILE_WRITE);
    
  if(arquivo){
  arquivo.print(texto);
  arquivo.close(); 
  return;
  } 
  }
}

void arquivoIln(int texto){
while (true){
  File arquivo = SD.open("testes.csv", FILE_WRITE);
    
  if(arquivo){
  arquivo.println(texto);
  arquivo.close(); 
  return;
  } 
  }
}


void arquivoSD(){
  float menor = tempos[0];
  float menorR = tempoReacao[0];
  float menorMov = (tempos[0]-tempoReacao[0]);
    
  float maior = tempos[0];
  float maiorR = tempoReacao[0];
  float maiorMov = (tempos[0]-tempoReacao[0]);
  
  float media;
  float mediaR;
  float mediaMov;
  
  float soma = 0;
  float somaR = 0;
  float somaMov = 0;

  for(int i=0; i<=contagem-1; i++){            //for criado para percorrer o verto que armazenou os tempos, com o objetivo de calcular o tempo menor, o maior e a soma de todos
    
    
    
    float tempoMov = (tempos[i] - tempoReacao[i]);
    
    if (tempos[i]<menor) menor = tempos[i];
    if (tempoReacao[i]<menorR) menorR = tempoReacao[i];
    if (tempoMov<menorMov) menorMov = tempoMov;
        
    if (tempos[i]>maior) maior = tempos[i];
    if (tempoReacao[i]>maiorR) maiorR = tempoReacao[i];
    if (tempoMov>maiorMov) maiorMov = tempoMov;
    
    
    soma += tempos[i];
    somaR += tempoReacao[i];
    somaMov += tempoMov;
    
  }
  
  
  media = (float)soma/(float)contagem; //calculando a media, dividindo a soma dos tempos pelo numero de acertos
  mediaR = (float)somaR/(float)contagem; //calculando a media, dividindo a soma dos tempos pelo numero de acertos
  mediaMov = (float)somaMov/(float)contagem; //calculando a media, dividindo a soma dos tempos pelo numero de acertos
    
        arquivoSln(";"); 
        
	arquivoS("Min ; ");
        arquivoD(menorR);
        arquivoS(";");
	arquivoD(menorMov);
        arquivoS(";");
	arquivoD(menor);
        arquivoSln(";");
	
        arquivoS("Max ; ");
        arquivoD(maiorR);
        arquivoS(";");
	arquivoD(maiorMov);
        arquivoS(";");
	arquivoD(maior);
        arquivoSln(";");
        
        arquivoS("Med ; ");
        arquivoD(mediaR);
        arquivoS(";");
	arquivoD(mediaMov);
        arquivoS(";");
	arquivoD(media);
        arquivoSln(";");
        
        arquivoS("Qtde ERROS;");arquivoIln(erros);
        arquivoS("Qtde Acertos;");arquivoIln(contagem);
	arquivoSln(" ");
        arquivoSln(" ");
}



void setup(){
    pinMode(0, OUTPUT); //led CabeÃƒÆ’Ã‚Â§a
    pinMode(1, OUTPUT); //led Peito Direito
    pinMode(2, OUTPUT); //led Peito Esquerdo
    pinMode(3, OUTPUT); //led Abdomen
    
    pinMode(6, INPUT);  //sensorCabeÃƒÆ’Ã‚Â§a
    pinMode(7, INPUT);  //sensor Peito Direito
    pinMode(8, INPUT);  //sensor Peito Esquerdo
    pinMode(9, INPUT);  //sensor Abdomen
    
    digitalWrite(6, HIGH);  //define o estado inicial HIGH para os pinos dos sensores e botÃƒÆ’Ã‚Âµes. Quando os sensores sÃƒÆ’Ã‚Â£o acionados, o digital read retorna LOW
    digitalWrite(7, HIGH);
    digitalWrite(8, HIGH);
    digitalWrite(9, HIGH);
    	
    pinMode(10,OUTPUT); //Pino CS do SD deve ser definido como OUTPUT
	
    randomSeed(analogRead(A0));

    lcd.begin(16,2);

		
    
    
	
  //testeSD
  if (!SD.begin(10)) {
    lcd.clear();
    lcd.print("cartao ausente");
    delay(2000);
    return;

  }
  cartaoPresente = true;
  lcd.clear();
  lcd.print("cartao");
  lcd.setCursor(0,1);
  lcd.print("inicializado");
  delay(2000);
  cartaoPresente = true;
}

void loop(){
   
   getID();
   menu();
   delay(2000);
   lcd.clear();
   lcd.print("gravando");
   
   
   arquivoSD();
   
   lcd.clear();
   lcd.print("gravado");
   
   
     delay(3000);
   while(true){
     lcdFimTeste();       
   }

}




