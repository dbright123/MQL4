//+------------------------------------------------------------------+
//|                                                    dbot_gold.mq4 |
//|                                Dbright Software Development(DSD) |
//|                                       https://www.dbright.org/ea |
//+------------------------------------------------------------------+

#property copyright "Dbright Software Development(DSD)"
#property link      "https://www.dbright.org/ea"
#property version   "5.15"
#property strict
#property icon "bot.ico"
#property description "DBot FX is a powerful trading algorithm that uses a combination of technical indicators and market analysis to identify profitable trading opportunities. It is designed to be easy to use and can be used by traders of all experience levels."


extern string mdesc = "DBot Gold"; //Market description

extern double lot_size = 0.01; // lot size

extern string market = "XAUUSD";

int n = 0;
double bup, bdn, bmid, rsi;
double price = 0;
double tp = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
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
   if(IsTesting()) market = Symbol();
   lot_size = (lot_size > 0.01) ? lot_size : 0.01;
   if(orderConfirm(market)){
      bup = iBands(market,PERIOD_M30,20,2,0,PRICE_CLOSE,MODE_UPPER,0);
      //bmid = iBands(market,PERIOD_M30,20,2,0,PRICE_CLOSE,MODE_MAIN,0);
      bdn = iBands(market,PERIOD_M30,20,2,0,PRICE_CLOSE,MODE_LOWER,0);
      
      rsi = iRSI(market,PERIOD_M30,14,PRICE_CLOSE,0);
      
      if(rsi > 70){//Selling at overbought
         if(iClose(market,PERIOD_M30,0) > bup){
            price = MarketInfo(market,MODE_BID);
            OrderSend(market,OP_SELL,lot_size,price,3,0,0,mdesc);
         }
      }else if(rsi < 30){//Buying at oversold
         if(iClose(market,PERIOD_M30,0) < bdn){
            price = MarketInfo(market,MODE_ASK);
            OrderSend(market,OP_BUY,lot_size,price,3,0,0,mdesc);
         }
      }
   }
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

void marketExit(){
   Comment("Monitoring ",OrdersTotal()," currently picked");
   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS)){
         //Assigning timeframe to parameters
         if(OrderComment() == mdesc){
            market = OrderSymbol();
            bmid = iBands(market,PERIOD_M30,20,2,0,PRICE_CLOSE,MODE_MAIN,0);
            if(OrderType() == OP_BUY){
               if(iClose(market,PERIOD_M30,0) > bmid){
                  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
               }
            }else if(OrderType() == OP_SELL){
               if(iClose(market,PERIOD_M30,0) < bmid){
                  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
               }
            }
         }
         
      }
   }
}
