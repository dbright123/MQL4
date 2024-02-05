//+------------------------------------------------------------------+
//|                                                trend_dtrader.mq4 |
//|                                Dbright Software Development(DSD) |
//|                                       https://www.dbright.org/ea |
//+------------------------------------------------------------------+
#property copyright "Dbright Software Development(DSD)"
#property link      "https://www.dbright.org/ea"
#property version   "1.00"
#property strict
#property icon "bot.ico"
#property description "DBot FX is a powerful trading algorithm that uses a combination of technical indicators and market analysis to identify profitable trading opportunities. It is designed to be easy to use and can be used by traders of all experience levels."
extern string mdesc = "DBot FX"; //Market description

extern double lot_size = 0.01; // lot size
ENUM_TIMEFRAMES tf = PERIOD_D1;
string markets[] = {};
string market = "";
int n = 0;

double price = 0;
double tp = 0;
double sl = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int zigzag = {};
int s_and_d = {};
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   ArrayResize(markets,SymbolsTotal(False));
   n = 0;
   for(int i = 0; i < SymbolsTotal(False); i++){
      if(StringFind(SymbolName(i,False),"USD") != -1 && ((int)MarketInfo(SymbolName(i,False),MODE_DIGITS) == 5 || (int)MarketInfo(SymbolName(i,False),MODE_DIGITS) == 4)){
         markets[n] = SymbolName(i,False);
         Print(markets[n++]," --> ",(int)MarketInfo(SymbolName(i,False),MODE_DIGITS));
      }
   }
   ArrayResize(markets,n);
   Print(ArraySize(markets));
   n = 0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   //EventKillTimer();
   Alert(reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(IsExpertEnabled()){
      if(OrdersTotal() < 3){
         market = markets[n++];
         tf = PERIOD_D1;
         //Starting with daily trade
         if(s_and_d(market,tf) == 0){
            tf = PERIOD_M30;
            if(s_and_d(market,tf) == 0){
               if(ema_trend(market,tf) == 0){
                  tf = PERIOD_M5;
                  if(s_and_d(market,tf) == 0){
                     //Order a Buy
                     market_order(market,OP_BUY);
                  }
               }
            }
         }
         else if(s_and_d(market,tf) == 1){
            tf = PERIOD_M30;
            if(s_and_d(market,tf) == 1){
               if(ema_trend(market,tf) == 1){
                  tf = PERIOD_M5;
                  if(s_and_d(market,tf) == 1){
                     //Order a Sell
                     market_order(market,OP_SELL);
                  }
               }
            }
         }
         //demand is 0 and supply is 1
         if(n >= ArraySize(markets) - 1){
            n = 0;
         }
         monitor();
      }else{
         monitor();
      }
      
   }else{
      Alert("Please Enable Algo Trading on your metatrader before running the application");
      EventKillTimer();
      ExpertRemove();
   }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   if(!IsConnected()){
      Alert("Please check your internet connection");
   }
   if(!IsExpertEnabled()){
      Alert("Please enable Algo Trading");
   }
   Print(TimeHour(TimeGMT())," : ",TimeMinute(TimeGMT()));
  }
//+------------------------------------------------------------------+

int s_and_d(string market,ENUM_TIMEFRAMES tf){
   for(int z = 0; z < 1000; z++){//Maxi bar check is a 1000
      if(iCustom(market,tf,"s_and_d",0,z) != 0){
         Print("confirmed demand zone -->>", iCustom(market,tf,"s_and_d",0,z));
         Print(z);
         return 0;
      }
      else if(iCustom(market,tf,"s_and_d",1,z) != 0){
         Print("confirmed supply zone-->>", iCustom(market,tf,"s_and_d",1,z));
         Print(z);
         return 1;
      }
      else if(iCustom(market,tf,"s_and_d",2,z) != 0){
         Print("demand zone fast -->>", iCustom(market,tf,"s_and_d",2,z));
         Print(z);
         return 0;
      }
      else if(iCustom(market,tf,"s_and_d",3,z) != 0){
         Print("supply zone fast -->>", iCustom(market,tf,"s_and_d",3,z));
         Print(z);
         return 1;
      }
   }
   return 2;
}

int ema_trend(string market, ENUM_TIMEFRAMES tf){
   double ema8 = iMA(market,tf,8,0,MODE_EMA,PRICE_CLOSE,0),
          ema12 = iMA(market,tf,12,0,MODE_EMA,PRICE_CLOSE,0),
          ema21 = iMA(market,tf,21,0,MODE_EMA,PRICE_CLOSE,0),
          ema55 = iMA(market,tf,8,0,MODE_EMA,PRICE_CLOSE,0),
          cp = iClose(market,tf,0);
   
   if(cp > ema8 && ema8 > ema12){
      if(ema12 > ema21 && ema21 > ema55){
         return 0; 
      }
   }
   else if(cp < ema8 && ema8 < ema12){
      if(ema12 < ema21 && ema21 < ema55){
         return 1; 
      }
   }
   
   return 2;
}


void market_order(string market,ENUM_ORDER_TYPE order){
   if(order == OP_BUY){
   
   }
   else if(order == OP_SELL){
   
   }
   
}


void monitor(){
   for(int i = 0; i < OrdersTotal(); i++){
      
   }
}