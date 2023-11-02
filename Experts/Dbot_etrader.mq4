//+------------------------------------------------------------------+
//|                                                      Dbot_FX Experiment.mq4 |
//|                                Dbright Software Development(DSD) |
//|                                       https://www.dbright.org/ea |
//+------------------------------------------------------------------+
#property copyright "Dbright Software Development(DSD)"
#property link      "https://www.dbright.org/ea"
#property version   "4.50"
#property strict
#property icon "bot.ico"
#property description "DBot EFX is a powerful trading algorithm that uses a combination of technical indicators and market analysis to identify profitable trading opportunities. It is designed to be easy to use and can be used by traders of all experience levels."


extern string mdesc = "DBot EFX"; //Market description

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
         if(Strategy(market)== 1){
            Print("Getting ready to buy ",market);
            price = MarketInfo(market,MODE_ASK);
            OrderSend(market,OP_BUY,lot_size,price,3,0,0,mdesc);

         }else if(Strategy(market) == 2){
            Print("Getting ready to sell ",market);
            OrderSend(market,OP_SELL,lot_size,price,3,0,0,mdesc);

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

int Strategy(string market){
   double adx = iADX(market,PERIOD_M30,14,PRICE_CLOSE,MODE_MAIN,0);
   
   double ema9 = iMA(market,PERIOD_M30,9,0,MODE_EMA,PRICE_CLOSE,0);
   double ema12 = iMA(market,PERIOD_M30,12,0,MODE_EMA,PRICE_CLOSE,0);
   double ema21 = iMA(market,PERIOD_M30,21,0,MODE_EMA,PRICE_CLOSE,0);
   double ema55 = iMA(market,PERIOD_M30,55,0,MODE_EMA,PRICE_CLOSE,0);
   
   
   double ema9_prev = iMA(market,PERIOD_M30,9,0,MODE_EMA,PRICE_CLOSE,1);
   double ema12_prev = iMA(market,PERIOD_M30,12,0,MODE_EMA,PRICE_CLOSE,1);
   double ema21_prev = iMA(market,PERIOD_M30,21,0,MODE_EMA,PRICE_CLOSE,1);
   double ema55_prev = iMA(market,PERIOD_M30,55,0,MODE_EMA,PRICE_CLOSE,1);
   
   
   double vol = iVolume(market,PERIOD_M30,0);
   double vMA = 0;
   for(int i = 0; i < 20; i++){
      vMA = iVolume(market,PERIOD_M30,i) + vMA;
   }
   vMA = vMA/20;
   
   if(vol > vMA && adx > 20){
      if(ema9 > ema12){
         if(ema12 > ema21){
            if(ema21 > ema55){
               if(ema9_prev > ema12_prev){
                  if(ema12_prev > ema21_prev && iClose(market,PERIOD_M30,1) > iOpen(market,PERIOD_M30,1)){
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
                  if(ema12_prev < ema21_prev && iClose(market,PERIOD_M30,1) < iOpen(market,PERIOD_M30,1)){
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


void marketExit(){
   double remove_trade = false;
   double sl = 0;
   Comment("Monitoring ",OrdersTotal()," currently picked");
   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS)){
         //Assigning timeframe to parameters
         if(OrderComment() == mdesc){
            market = OrderSymbol();
            double ema9 = iMA(market,PERIOD_M30,9,0,MODE_EMA,PRICE_CLOSE,0);
            double ema12 = iMA(market,PERIOD_M30,12,0,MODE_EMA,PRICE_CLOSE,0);
            double ema21 = iMA(market,PERIOD_M30,21,0,MODE_EMA,PRICE_CLOSE,0);
            double ema55 = iMA(market,PERIOD_M30,55,0,MODE_EMA,PRICE_CLOSE,0);
            
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
            /*
            if(OrderProfit() >= OrderLots() * 200 || OrderProfit() <= OrderLots() * -200){// for creating a 1:2 RR
               OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),8);  
            } 
            */
         }
         remove_trade = false;
      }
    }
         
}
