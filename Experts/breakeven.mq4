//+------------------------------------------------------------------+
//|                                                    breakeven.mq4 |
//|                                Dbright Software Development(DSD) |
//|                                       https://www.dbright.org/ea |
//+------------------------------------------------------------------+
#property copyright "Dbright Software Development(DSD)"
#property link      "https://www.dbright.org/ea"
#property version   "1.00"
#property strict
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
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double sl = 0.0;
   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS)){
         if(OrderProfit() > OrderLots() * 80){
            if(OrderType() == OP_BUY){
               if(OrderStopLoss() <= OrderOpenPrice()){
                  sl = OrderClosePrice() + OrderOpenPrice();
                  sl = sl/2;
                  if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0)){
                     Print(OrderSymbol(), " was successfully modified");
                  }
               }
               else if(OrderStopLoss() > OrderOpenPrice()){
               //Increment can be by 100 by loop
                  for(int t = 100; t > 0; t--){
                     sl = OrderStopLoss() + MathPow(t,(int)MarketInfo(OrderSymbol(),MODE_DIGITS));
                     if(OrderClosePrice() > sl){
                        if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0)){
                           Print(OrderSymbol(), " was successfully modified");
                           break;
                        }
                     }
                  }
               }
            }
            else if(OrderType() == OP_SELL){
               if(OrderStopLoss() == 0 || OrderStopLoss() >= OrderOpenPrice()){
                  sl = OrderClosePrice() + OrderOpenPrice();
                  sl = sl/2;
                  if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0)){
                     Print(OrderSymbol(), " was successfully modified");
                  }
               }
               else if(OrderStopLoss() != 0 && OrderStopLoss() < OrderOpenPrice()){
                  //Increment can be by 100 by loop
                  for(int t = 100; t > 0; t--){
                     sl = OrderStopLoss() - MathPow(t,(int)MarketInfo(OrderSymbol(),MODE_DIGITS));
                     if(OrderClosePrice() < sl){
                        if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0)){
                           Print(OrderSymbol(), " was successfully modified");
                           break;
                        }
                     }
                  }
               }
            }
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
   Comment("Working");
  }
//+------------------------------------------------------------------+
