//+------------------------------------------------------------------+
//|                                                dzizzag_trend.mq4 |
//|                                    Dbright Software Developments |
//|                                           https://dbrightdev.com |
//+------------------------------------------------------------------+
#property copyright "Dbright Software Developments"
#property link      "https://dbrightdev.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//extern ENUM_TIMEFRAMES tf = NULL;
extern string mdesc = "dbot_booking";
double l_zigzag = 0;
int OnInit()
  {
//---
   Alert("System is currently active on ",Symbol());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Alert(reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   string market = Symbol();
   double ema = iMA(market,PERIOD_H4,200,0,MODE_EMA,PRICE_CLOSE,0);
   double zigzag = iCustom(market,PERIOD_H4,"zigzag",0,0);
   double atr = 0;
   double lotsize = AccountEquity()/100;
   lotsize = lotsize * 0.01;
   lotsize = (lotsize > 0.01) ? lotsize : 0.01;
   //Checking 4H Trend 
   for(int i = 0; i < Bars; i++){
      zigzag = iCustom(market,PERIOD_H4,"zigzag",0,i);    
      if(zigzag != 0){
         ema = iMA(market,PERIOD_H4,200,0,MODE_EMA,PRICE_CLOSE,i);
         if(zigzag > ema ){
            if(iClose(market,PERIOD_H4,1) > iOpen(market,PERIOD_H4,1)){//Bullish Candle
               for(int i = 0; i < Bars; i++){
                  zigzag = iCustom(market,PERIOD_M30,"zigzag",0,i); 
                  if(zigzag != 0){
                     ema = iMA(market,PERIOD_M30,200,0,MODE_EMA,PRICE_CLOSE,i);
                     //atr = iATR(market,PERIOD_M30,14,i);
                     if(ema > zigzag){
                        if(iClose(market,PERIOD_M30,1) > iOpen(market,PERIOD_M30,1)){//Bullish Candle
                           marketOrder(market,OP_BUY,lotsize,zigzag,i);
                        }
                     }
                     break;
                  }
                  
               }
            }
         }
         else if(zigzag < ema){
            if(iClose(market,PERIOD_H4,1) < iOpen(market,PERIOD_H4,1)){//Bearish Candle
               for(int i = 0; i < Bars; i++){
                  zigzag = iCustom(market,PERIOD_M30,"zigzag",0,i); 
                  if(zigzag != 0){
                     ema = iMA(market,PERIOD_M30,200,0,MODE_EMA,PRICE_CLOSE,i);
                     
                     if(ema < zigzag){
                        if(iClose(market,PERIOD_M30,1) < iOpen(market,PERIOD_M30,1)){//Bearish Candle
                           marketOrder(market,OP_SELL,lotsize,zigzag,i);
                        }
                     }
                     break;
                  }
                  
               }
            }
         }
         break;
      }
   }
   breakeven();
   
  }
//+------------------------------------------------------------------+

void marketOrder(string market, ENUM_ORDER_TYPE order, double lotsize,double zigzag, int shift){
   if(OrdersTotal() < 4){
      double atr = iATR(market,PERIOD_M30,14,shift);
      bool permit = true;
      int t = 0;     
      double tp = 6 * atr, sl = 3 * atr;
      double cp = iClose(market,PERIOD_M30,shift);
      for(int i = 0; i < OrdersTotal(); i++){
         if(OrderSelect(i,SELECT_BY_POS)){
            if(market == OrderSymbol() && zigzag == l_zigzag){
               permit = false;
            }
         }
      }
      if(permit){
         if(order == OP_BUY){
            tp = MathAbs(cp + tp);
            sl = MathAbs(cp - sl);
            t = OrderSend(market,OP_BUYLIMIT,lotsize,cp,8,sl,tp,mdesc);
            if(t < 1){
               Print(market," Failed to buy");
            }
            else if(t > 2){
               l_zigzag = zigzag;
            }
         }
         else if(order == OP_SELL){
            tp = MathAbs(cp - tp);
            //sl = MathAbs(cp + sl);
            t = OrderSend(market,OP_SELLLIMIT,lotsize,cp,8,sl,tp,mdesc);
            if(t < 1){
               Print(market," Failed to sell");
            }
            else if(t > 2){
               l_zigzag = zigzag;
            }
         }
      }
   }
}

void breakeven(){
   double be = 0, zigzag = 0;
   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS)){
        if(OrderComment() == mdesc){
         
         if(OrderType() == OP_BUY){
            if(OrderOpenPrice() > OrderStopLoss()){
               for(int i = 0; i < Bars; i++){
                  zigzag = iCustom(OrderSymbol(),PERIOD_M30,"zigzag",0,i); 
                  if(zigzag != 0){
                     if(zigzag > OrderOpenPrice()){
                        if(OrderClosePrice() > zigzag){
                           if(OrderModify(OrderTicket(),OrderOpenPrice(),zigzag,OrderTakeProfit(),0)){
                              Alert(OrderSymbol()," now has a breakeven");
                           }
                        }
                     }
                     break;
                  }
               }
            }
         }
         else if(OrderType() == OP_SELL){
            if(OrderOpenPrice() < OrderStopLoss()){
               for(int i = 0; i < Bars; i++){
                  zigzag = iCustom(OrderSymbol(),PERIOD_M30,"zigzag",0,i); 
                  if(zigzag != 0){
                     if(zigzag < OrderOpenPrice()){
                        if(OrderClosePrice() < zigzag){
                           if(OrderModify(OrderTicket(),OrderOpenPrice(),zigzag,OrderTakeProfit(),0)){
                              Alert(OrderSymbol()," now has a breakeven");
                           }
                        }
                     }
                     break;
                  }
               }
            }
         }
        }
      }
   }
}