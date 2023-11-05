//+------------------------------------------------------------------+
//|                                                      Dbot_FX.mq4 |
//|                                Dbright Software Development(DSD) |
//|                                       https://www.dbright.org/ea |
//+------------------------------------------------------------------+
#property copyright "Dbright Software Development(DSD)"
#property link      "https://www.dbright.org/ea"
#property version   "4.15"
#property strict
#property icon "bot.ico"
#property description "DBot FX is a powerful trading algorithm that uses a combination of technical indicators and market analysis to identify profitable trading opportunities. It is designed to be easy to use and can be used by traders of all experience levels."


extern string mdesc = "DBot FX"; //Market description

extern double lot_size = 0.01; // lot size

string markets[] = {"EURUSD","GBPUSD"};
string market = "";
int n = 0;


double price = 0;
double tp = 0;
double sl = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(30);
   Alert("Dbot FX started");
   Alert("for more information, please visit www.dbright.org/ea");
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   Alert("Dbot FX ended ",reason);
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      if(n < ArraySize(markets)){// General logic for the programming of the system
         analyseTrade();
      }
      marketExit();
      //Comment("Working ",GetTickCount());
  }

void analyseTrade(){
     market = markets[n];
     if(IsTesting()) market = Symbol();
     Print("checking ",market," ",n);
     n++;
     if(orderConfirm(market)){
        //loading the program

        lot_size = (lot_size > 0.01) ? lot_size : 0.01;
        price = 0;
        tp = 0;
         if(Strategy(market)== 1 && trendConfirm(market) == 1){
            Print("Getting ready to buy ",market);
            price = MarketInfo(market,MODE_ASK);
            tp = tp_calculator(market,1);
            if(MathAbs(tp - price) <= 0.001){
               tp = 0;
            }
            sl = sl_calculator(market,1);
            if(MathAbs(sl - price) <= 0.0005){
               sl = 0;
            }
            if(tp != 0 && sl != 0) OrderSend(market,OP_BUY,lot_size,price,3,sl,tp,mdesc);

         }else if(Strategy(market) == 2 && trendConfirm(market) == 2){
            Print("Getting ready to sell ",market);
            price = MarketInfo(market,MODE_BID);
            tp = tp_calculator(market,2);
            if(MathAbs(tp - price) <= 0.001){
               tp = 0;
            }
            sl = sl_calculator(market,2);
            if(MathAbs(sl - price) <= 0.0005){
               sl = 0;
            }
            if(tp != 0 && sl != 0) OrderSend(market,OP_SELL,lot_size,price,3,sl,tp,mdesc);

         }
     }
     
     if(n == ArraySize(markets)) n = 0;
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   if(!IsConnected()){
      Alert("No Internet Connection");
   }
   if(!IsExpertEnabled()){
      Alert("Please Enable Expert Advisor");
   }
   
   
   
  }
//+------------------------------------------------------------------+

bool orderConfirm(string market){
   bool permit = true;
   if(permit){
      for(int i = 0; i < OrdersTotal(); i++){
         if(OrderSelect(i, SELECT_BY_POS)){
            if(market == OrderSymbol() && OrderComment() == mdesc){
               permit = false;
               break;
            }
         }
      }
   
   }
   
   return permit;
}

double tp_calculator(string market, int order_type){
   if(order_type == 1){
      for(int i = 0; i < iBars(market,PERIOD_H1); i++){
         if(iFractals(market,PERIOD_H1,MODE_UPPER,i) != 0 && iCustom(market,PERIOD_H1,"ZigZag",12,5,3,0,i) != 0){
            if((float)iFractals(market,PERIOD_H1,MODE_UPPER,i) == (float)iCustom(market,PERIOD_H1,"ZigZag",12,5,3,0,i)){
               if(iCustom(market,PERIOD_H1,"ZigZag",12,5,3,0,i) > iClose(market,PERIOD_H1,0)){
                  if(iClose(market,PERIOD_H1,i) > iOpen(market,PERIOD_H1,i)){
                     return iClose(market,PERIOD_H1,i);
                  }
                  else if(iClose(market,PERIOD_H1,i) < iOpen(market,PERIOD_H1,i)){
                     return iOpen(market,PERIOD_H1,i);
                  }
                  
               }
            }
         
         }
      }
   }
   else if(order_type == 2){
      for(int i = 0; i < iBars(market,PERIOD_H1); i++){
         if(iFractals(market,PERIOD_H1,MODE_LOWER,i) != 0 && iCustom(market,PERIOD_H1,"ZigZag",12,5,3,0,i) != 0){
            if((float)iFractals(market,PERIOD_H1,MODE_LOWER,i) == (float)iCustom(market,PERIOD_H1,"ZigZag",12,5,3,0,i)){
               if(iCustom(market,PERIOD_H1,"ZigZag",12,5,3,0,i) < iClose(market,PERIOD_H1,0)){
                  if(iClose(market,PERIOD_H1,i) > iOpen(market,PERIOD_H1,i)){
                     return iOpen(market,PERIOD_H1,i);
                  }
                  else if(iClose(market,PERIOD_H1,i) < iOpen(market,PERIOD_H1,i)){
                     return iClose(market,PERIOD_H1,i);
                  }
               }
            }
         }
      }
   }
   return 0;

}

double sl_calculator(string market, int order_type){
   if(order_type == 2){
      for(int i = 0; i < iBars(market,PERIOD_H1); i++){
         if(iFractals(market,PERIOD_H1,MODE_UPPER,i) != 0 && iCustom(market,PERIOD_H1,"ZigZag",12,5,3,0,i) != 0){
            if((float)iFractals(market,PERIOD_H1,MODE_UPPER,i) == (float)iCustom(market,PERIOD_H1,"ZigZag",12,5,3,0,i)){
               if(iCustom(market,PERIOD_H1,"ZigZag",12,5,3,0,i) > iClose(market,PERIOD_H1,0)){
                  if(iClose(market,PERIOD_H1,i) > iOpen(market,PERIOD_H1,i)){
                     return iClose(market,PERIOD_H1,i);
                  }
                  else if(iClose(market,PERIOD_H1,i) < iOpen(market,PERIOD_H1,i)){
                     return iOpen(market,PERIOD_H1,i);
                  }
                  
               }
            }
         
         }
      }
   }
   else if(order_type == 1){
      for(int i = 0; i < iBars(market,PERIOD_H1); i++){
         if(iFractals(market,PERIOD_H1,MODE_LOWER,i) != 0 && iCustom(market,PERIOD_H1,"ZigZag",12,5,3,0,i) != 0){
            if((float)iFractals(market,PERIOD_H1,MODE_LOWER,i) == (float)iCustom(market,PERIOD_H1,"ZigZag",12,5,3,0,i)){
               if(iCustom(market,PERIOD_H1,"ZigZag",12,5,3,0,i) < iClose(market,PERIOD_H1,0)){
                  if(iClose(market,PERIOD_H1,i) > iOpen(market,PERIOD_H1,i)){
                     return iOpen(market,PERIOD_H1,i);
                  }
                  else if(iClose(market,PERIOD_H1,i) < iOpen(market,PERIOD_H1,i)){
                     return iClose(market,PERIOD_H1,i);
                  }
               }
            }
         }
      }
   }
   return 0;

}

int Strategy(string market){
   double adx = iADX(market,PERIOD_H1,14,PRICE_CLOSE,MODE_MAIN,0);
   
   double ema9 = iMA(market,PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,0);
   double ema12 = iMA(market,PERIOD_H1,12,0,MODE_EMA,PRICE_CLOSE,0);
   double ema21 = iMA(market,PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE,0);
   double ema55 = iMA(market,PERIOD_H1,55,0,MODE_EMA,PRICE_CLOSE,0);
   
   
   double ema9_prev = iMA(market,PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,1);
   double ema12_prev = iMA(market,PERIOD_H1,12,0,MODE_EMA,PRICE_CLOSE,1);
   double ema21_prev = iMA(market,PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE,1);
   double ema55_prev = iMA(market,PERIOD_H1,55,0,MODE_EMA,PRICE_CLOSE,1);
   
   //double macd = iMACD(market,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   //double signal = iMACD(market,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   
   double vol = iVolume(market,PERIOD_H1,0);
   double vMA = 0;
   for(int i = 0; i < 20; i++){
      vMA = iVolume(market,PERIOD_H1,i) + vMA;
   }
   vMA = vMA/20;
   
   if(vol > vMA && adx > 20){
      if(ema9 > ema12){
         if(ema12 > ema21){
            if(ema21 > ema55){
               if(ema9_prev > ema12_prev){
                  if(ema12_prev > ema21_prev && iClose(market,PERIOD_H1,1) > iOpen(market,PERIOD_H1,1)){
                     if(ema21_prev > ema55_prev){
                        Print("Buying activated ",market);
                        return 1;
                     }
                  }
               }
            }
         }
      }
      else if(ema9 < ema12){
         if(ema12 < ema21){
            if(ema21 < ema55){
               if(ema9_prev < ema12_prev){
                  if(ema12_prev < ema21_prev && iClose(market,PERIOD_H1,1) < iOpen(market,PERIOD_H1,1)){
                     if(ema21_prev < ema55_prev){
                        Print("Selling activated ",market);
                        return 2;
                     }
                  }
               }
            }
         }
      }
   }
   return 0;
}

int trendConfirm(string market){
   double ema9 = iMA(market,PERIOD_H4 ,9,0,MODE_EMA,PRICE_CLOSE,0);
   double ema12 = iMA(market,PERIOD_H4,12,0,MODE_EMA,PRICE_CLOSE,0);
   double ema21 = iMA(market,PERIOD_H4,21,0,MODE_EMA,PRICE_CLOSE,0);
   double ema55 = iMA(market,PERIOD_H4,55,0,MODE_EMA,PRICE_CLOSE,0);
   
   double ema9_d = iMA(market,PERIOD_D1,9,0,MODE_EMA,PRICE_CLOSE,0);
   double ema12_d = iMA(market,PERIOD_D1,12,0,MODE_EMA,PRICE_CLOSE,0);
   double ema21_d = iMA(market,PERIOD_D1,21,0,MODE_EMA,PRICE_CLOSE,0);
   double ema55_d = iMA(market,PERIOD_D1,55,0,MODE_EMA,PRICE_CLOSE,0);
   
   double adx = iADX(market,PERIOD_H4,14,PRICE_CLOSE,MODE_MAIN,0);
   
   double adx_d = iADX(market,PERIOD_D1,14,PRICE_CLOSE,MODE_MAIN,0);
   
   if(ema9 > ema12 && adx > 20){
      if(ema12 > ema21){
         if(ema21 > ema55){
            if(ema9_d > ema12_d && adx_d > 20){
               if(ema12_d > ema21_d){
                  if(ema21_d > ema55_d){
                     Print("Buying activated ",market);
                     return 1;
                  }
               }
            }
         }
      }
      
   }
   else if(ema9 < ema12 && adx > 20){
      if(ema12 < ema21){
         if(ema21 < ema55){
            if(ema9_d < ema12_d && adx_d > 20){
               if(ema12_d < ema21_d){
                  if(ema21_d < ema55_d){
                     Print("Selling activated ",market);
                     return 2;
                  }
               }
            }
         }
      }
   }
   return 0;
}


void marketExit(){
   double remove_trade = false;
   double sl = 0;
   Comment("Monitoring ",OrdersTotal()," currently picked");
   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS)){
         //Assigning timeframe to parameters
         if(OrderComment() == mdesc){
            market = OrderSymbol();
            double ema9 = iMA(market,PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,0);
            double ema12 = iMA(market,PERIOD_H1,12,0,MODE_EMA,PRICE_CLOSE,0);
            double ema21 = iMA(market,PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE,0);
            double ema55 = iMA(market,PERIOD_H1,55,0,MODE_EMA,PRICE_CLOSE,0);
            
            if(OrderType() == OP_BUY){
               if(ema9 < ema12){
                  if(ema12 < ema21){
                     if(ema21 < ema55){
                        remove_trade = true;
                     }
                  }
               }
               
            }
            else if(OrderType() == OP_SELL){
               if(ema9 > ema12){
                  if(ema12 > ema21){
                     if(ema21 > ema55){
                        remove_trade = true;
                     }
                  }
               }
            }
            
            if(remove_trade){
               if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3)){
                  Alert("closing of ",OrderSymbol()," is successful");
               }else{
                  Alert("Failed to close market, please check the program to detect error ",GetLastError());
               }
            }
            if(OrderType() == OP_BUY){
               if(OrderOpenPrice() > OrderStopLoss()){
                  if(OrderProfit() >= OrderLots() * 500){// for creating a breakeven
                     sl = OrderClosePrice() + OrderOpenPrice();
                     sl = sl/2;
                     if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,clrRed)){
                        Print(OrderSymbol()," modified successfully");
                     }
                     
                  }
               }
            }
            else if(OrderType() == OP_SELL){
               if(OrderOpenPrice() < OrderStopLoss()){
                  if(OrderProfit() >= OrderLots() * 500){// for creating a breakeven
                     sl = OrderClosePrice() + OrderOpenPrice();
                     sl = sl/2;
                     if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,clrRed)){
                        Print(OrderSymbol()," modified successfully");
                     }
                     
                  }
               }
            }
            if(OrderProfit() >= OrderLots() * 500 && OrderStopLoss() == 0){// for creating a breakeven
               sl = OrderClosePrice() + OrderOpenPrice();
               sl = sl/2;
               if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,clrRed)){
                  Print(OrderSymbol()," modified successfully");
               }
               
            }
            /* 
            if(OrderProfit() <= OrderLots() * -300){// for creating a breakeven
               OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),8);  
            } 
            */ 
         }
         remove_trade = false;
      }
    }
         
}
