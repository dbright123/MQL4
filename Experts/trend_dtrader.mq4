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
         market = (IsTesting()) ? Symbol() : markets[n++];
         tf = PERIOD_D1;
         //Print("1d check");
         //Starting with daily trade
         if(s_and_d(market,tf) == 0){
            tf = PERIOD_H1;
            //Print("30 min check");
            if(s_and_d(market,tf) == 0){
               if(ema_trend(market,tf) == 0){
                  //Order a Buy
                  market_order(market,OP_BUY);
               }
            }
         }
         else if(s_and_d(market,tf) == 1){
            tf = PERIOD_H1;
            //Print("30 min check");
            if(s_and_d(market,tf) == 1){
               if(ema_trend(market,tf) == 1){
                  //Order a Sell
                  market_order(market,OP_SELL);
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
   for(int z = 0; z < iBars(market,PERIOD_D1); z++){//Maxi bar check is a 1000
      if(iCustom(market,tf,"s_and_d",0,z) != 0){
         //Print("confirmed ",market," demand zone -->>", iCustom(market,tf,"s_and_d",0,z));
         //Print(z);
         return 0;
      }
      else if(iCustom(market,tf,"s_and_d",1,z) != 0){
         //Print("confirmed ",market," supply zone-->>", iCustom(market,tf,"s_and_d",1,z));
         //Print(z);
         return 1;
      }
      else if(iCustom(market,tf,"s_and_d",2,z) != 0){
         //Print("demand  ",market," zone fast -->>", iCustom(market,tf,"s_and_d",2,z));
         //Print(z);
         return 0;
      }
      else if(iCustom(market,tf,"s_and_d",3,z) != 0){
         //Print("supply  ",market," zone fast -->>", iCustom(market,tf,"s_and_d",3,z));
         //Print(z);
         return 1;
      }
   }
   return 2;
}

int ema_trend(string market, ENUM_TIMEFRAMES tf){
   double ema8 = iMA(market,tf,8,0,MODE_EMA,PRICE_CLOSE,0),
          ema12 = iMA(market,tf,12,0,MODE_EMA,PRICE_CLOSE,0),
          ema21 = iMA(market,tf,21,0,MODE_EMA,PRICE_CLOSE,0),
          ema55 = iMA(market,tf,55,0,MODE_EMA,PRICE_CLOSE,0),
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
   bool permit = True;
   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS)){
         if(OrderSymbol() == market){
            permit = False;
         }
      }
   }
   if(permit){
      double tp = 0,sl = 0;
      double atr = iATR(market,PERIOD_D1,14,0);
      double cp = iClose(market,PERIOD_D1,0);
      if(order == OP_BUY){
         sl = cp - atr;
         tp = (tp_calculator(market,order) != 0) ? tp_calculator(market,order) : cp + (atr * 2);
         
         int t = OrderSend(market,order,lot_size,cp,8,sl,tp,mdesc);
         if(t != -1){
            Alert(market," Ordered Successfully");
         }else Alert("Failed");
         
      }
      else if(order == OP_SELL){
         sl = cp + atr;
         tp =(tp_calculator(market,order) != 0) ? tp_calculator(market,order) : cp - (atr * 2);
         
         int t = OrderSend(market,order,lot_size,cp,8,sl,tp,mdesc);
         if(t != -1){
            Alert(market," Ordered Successfully");
         }else Alert("Failed");
      }
   }
   
   
}


void monitor(){
   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS)){
         if(OrderComment() == mdesc){
            double sl = 0;
            
            if(OrderType() == OP_BUY){
               /*
               if(s_and_d(market,PERIOD_D1) == 1){
                  //Emergency Close Market
                  if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),8,clrRed)){
                     Alert(OrderSymbol()," is really needed to be removed");
                  }else Print("Failed closing");
               }*/
               if(OrderProfit() > 80 * OrderLots()){
                  if(OrderOpenPrice() > OrderStopLoss()){
                     sl = OrderClosePrice() + OrderOpenPrice();
                     sl = sl/2;
                     if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0)){
                        Alert(OrderSymbol()," has been assigned a breakeven");
                     }else Print("Failed modifying");
                  }
                  
               }
            }
            else if(OrderType() == OP_SELL){
               /*
               if(s_and_d(market,PERIOD_D1) == 0){
                  //Emergency Close Market
                  if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),8,clrRed)){
                     Alert(OrderSymbol()," is really needed to be removed");
                  }else Print("Failed closing");
               }
               */
               if(OrderProfit() > 80 * OrderLots()){
                  if(OrderOpenPrice() < OrderStopLoss()){
                     sl = OrderClosePrice() + OrderOpenPrice();
                     sl = sl/2;
                     if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0)){
                        Alert(OrderSymbol()," has been assigned a breakeven");
                     }else Print("Failed modifying");
                  }
               }
            }
         }
      }
   }
}

double tp_calculator(string market, ENUM_ORDER_TYPE order){
   ENUM_TIMEFRAMES tf = PERIOD_D1;
   double cp = iClose(market,tf,0);
   if(order == OP_BUY){
      for(int i = 0; i < iBars(market,PERIOD_D1); i++){
         if(iCustom(market,tf,"s_and_d",1,i) != 0){
            if(iCustom(market,tf,"s_and_d",1,i) > cp){
               if(iClose(market,tf,i) > iOpen(market,tf,i)){
                  return iClose(market,tf,i);
               }
               else if(iClose(market,tf,i) < iOpen(market,tf,i)){
                  return iOpen(market,tf,i);
               }
            }
         }
         else if(iCustom(market,tf,"s_and_d",3,i) != 0){
            if(iCustom(market,tf,"s_and_d",3,i) > cp){
               if(iClose(market,tf,i) > iOpen(market,tf,i)){
                  return iClose(market,tf,i);
               }
               else if(iClose(market,tf,i) < iOpen(market,tf,i)){
                  return iOpen(market,tf,i);
               }
            }
         }
      }
   }
   else if(order == OP_SELL){
      for(int i = 0; i < iBars(market,PERIOD_D1); i++){
         if(iCustom(market,tf,"s_and_d",0,i) != 0){
            if(iCustom(market,tf,"s_and_d",0,i) < cp){
               if(iClose(market,tf,i) > iOpen(market,tf,i)){
                  return iOpen(market,tf,i);
               }
               else if(iClose(market,tf,i) < iOpen(market,tf,i)){
                  return iClose(market,tf,i);
               }
            }
         }
         else if(iCustom(market,tf,"s_and_d",2,i) != 0){
            if(iCustom(market,tf,"s_and_d",2,i) < cp){
               if(iClose(market,tf,i) > iOpen(market,tf,i)){
                  return iOpen(market,tf,i);
               }
               else if(iClose(market,tf,i) < iOpen(market,tf,i)){
                  return iClose(market,tf,i);
               }
            }
         }
      }
   }
   return 0;
}