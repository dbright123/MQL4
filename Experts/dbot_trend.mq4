//+------------------------------------------------------------------+
//|                                                   dbot_trend.mq4 |
//|                                Dbright Software Development(DSD) |
//|                                       https://www.dbright.org/ea |
//+------------------------------------------------------------------+

#property copyright "Dbright Software Development(DSD)"
#property link      "https://www.dbright.org/ea"
#property version   "5.15"
#property strict
#property icon "bot.ico"
#property description "DBot FX is a powerful trading algorithm that uses a combination of technical indicators and market analysis to identify profitable trading opportunities. It is designed to be easy to use and can be used by traders of all experience levels."


extern string mdesc = "DBot Trend"; //Market description

extern double lot_size = 0.01; // lot size

string market = "";
int n = 0;

double price = 0;
double tp = 0;
double ema9, ema12, ema21, ema55, vol, vMA;

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
     market = "GBPUSD";
     if(IsTesting()) market = Symbol();
     //Print("checking ",market," ",n);
     
     if(orderConfirm(market)){
        lot_size = (lot_size > 0.01) ? lot_size : 0.01;
        price = 0;
        tp = 0;
        //adx = iADX(market,PERIOD_M30,14,PRICE_CLOSE,MODE_MAIN,0);
        
        ema9 = iMA(market,PERIOD_D1,9,0,MODE_EMA,PRICE_CLOSE,0);
        ema12 = iMA(market,PERIOD_D1,12,0,MODE_EMA,PRICE_CLOSE,0);
        ema21 = iMA(market,PERIOD_D1,21,0,MODE_EMA,PRICE_CLOSE,0);
        ema55 = iMA(market,PERIOD_D1,55,0,MODE_EMA,PRICE_CLOSE,0);
        
        vol = iVolume(market,PERIOD_M30,0);
        vMA = 0;
        for(int i = 0; i < 20; i++){
          vMA = iVolume(market,PERIOD_M30,i) + vMA;
        }
        vMA = vMA/20;
        
        if(vol > vMA && TimeHour(TimeGMT()) > 8 && TimeHour(TimeGMT()) < 12){
          //Day chart for current trend movement
          if(ema9 > ema12 && iClose(market,PERIOD_D1,0) > ema9){
            if(ema12 > ema21){
               if(ema21 > ema55){
                  ema9 = iMA(market,PERIOD_H4,9,0,MODE_EMA,PRICE_CLOSE,0);
                  ema12 = iMA(market,PERIOD_H4,12,0,MODE_EMA,PRICE_CLOSE,0);
                  ema21 = iMA(market,PERIOD_H4,21,0,MODE_EMA,PRICE_CLOSE,0);
                  ema55 = iMA(market,PERIOD_H4,55,0,MODE_EMA,PRICE_CLOSE,0);
                  
                  
                  if(ema9 > ema12 && iClose(market,PERIOD_H4,0)){
                     if(ema12 > ema21){
                        if(ema21 > ema55){
                           ema9 = iMA(market,PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,0);
                           ema12 = iMA(market,PERIOD_H1,12,0,MODE_EMA,PRICE_CLOSE,0);
                           ema21 = iMA(market,PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE,0);
                           ema55 = iMA(market,PERIOD_H1,55,0,MODE_EMA,PRICE_CLOSE,0);
                           
                           if(ema9 > ema12 && iClose(market,PERIOD_H1,0) > ema9){
                              if(ema12 > ema21){
                                 if(ema21 > ema55){
                                    ema9 = iMA(market,PERIOD_M30,9,0,MODE_EMA,PRICE_CLOSE,0);
                                    ema12 = iMA(market,PERIOD_M30,12,0,MODE_EMA,PRICE_CLOSE,0);
                                    ema21 = iMA(market,PERIOD_M30,21,0,MODE_EMA,PRICE_CLOSE,0);
                                    ema55 = iMA(market,PERIOD_M30,55,0,MODE_EMA,PRICE_CLOSE,0);
                                    
                                    if(ema9 > ema12 && iClose(market,PERIOD_M30,0) > ema9){
                                       if(ema12 > ema21 && iClose(market,PERIOD_M30,1) > iOpen(market,PERIOD_M30,1)){
                                          if(ema21 > ema55){
                                             for(int i = 1; i < 100; i++){
                                                if(iClose(market,PERIOD_H4,i) > iClose(market,PERIOD_M30,0)){
                                                   if(iClose(market,PERIOD_H4,i) - iClose(market,PERIOD_M30,0) > 0.001 && iClose(market,PERIOD_H4,i) > iHigh(market,PERIOD_H4,0)){
                                                      tp = iClose(market,PERIOD_H4,i);
                                                      price = MarketInfo(market,MODE_ASK);
                                                      OrderSend(market,OP_BUY,lot_size,price,3,0,tp,mdesc);
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
                        }
                        
                     }
                     
                  }
               }
            }
          }
          else if(ema9 < ema12 && iClose(market,PERIOD_D1,0) < ema9){
            if(ema12 < ema21){
               if(ema21 < ema55){
                  ema9 = iMA(market,PERIOD_H4,9,0,MODE_EMA,PRICE_CLOSE,0);
                  ema12 = iMA(market,PERIOD_H4,12,0,MODE_EMA,PRICE_CLOSE,0);
                  ema21 = iMA(market,PERIOD_H4,21,0,MODE_EMA,PRICE_CLOSE,0);
                  ema55 = iMA(market,PERIOD_H4,55,0,MODE_EMA,PRICE_CLOSE,0);
                  
                  if(ema9 < ema12 && iClose(market,PERIOD_H4,0) < ema9){
                     if(ema12 < ema21){
                        if(ema21 < ema55){
                           ema9 = iMA(market,PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,0);
                           ema12 = iMA(market,PERIOD_H1,12,0,MODE_EMA,PRICE_CLOSE,0);
                           ema21 = iMA(market,PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE,0);
                           ema55 = iMA(market,PERIOD_H1,55,0,MODE_EMA,PRICE_CLOSE,0);
                           
                           if(ema9 < ema12 && iClose(market,PERIOD_H1,0) < ema9){
                              if(ema12 < ema21){
                                 if(ema21 < ema55){
                                    ema9 = iMA(market,PERIOD_M30,9,0,MODE_EMA,PRICE_CLOSE,0);
                                    ema12 = iMA(market,PERIOD_M30,12,0,MODE_EMA,PRICE_CLOSE,0);
                                    ema21 = iMA(market,PERIOD_M30,21,0,MODE_EMA,PRICE_CLOSE,0);
                                    ema55 = iMA(market,PERIOD_M30,55,0,MODE_EMA,PRICE_CLOSE,0);
                                    
                                    if(ema9 < ema12 && iClose(market,PERIOD_M30,0) < ema9){
                                       if(ema12 < ema21 && iClose(market,PERIOD_M30,1) < iOpen(market,PERIOD_M30,1)){
                                          if(ema21 < ema55){
                                             for(int i = 1; i < 100; i++){
                                                if(iClose(market,PERIOD_H4,i) < iClose(market,PERIOD_M30,0)){
                                                   if(iClose(market,PERIOD_M30,0) - iClose(market,PERIOD_H4,i) > 0.001 && iClose(market,PERIOD_H4,i) < iLow(market,PERIOD_H4,0)){
                                                      tp = iClose(market,PERIOD_H4,i);
                                                      price = MarketInfo(market,MODE_BID);
                                                      OrderSend(market,OP_SELL,lot_size,price,3,0,tp,mdesc);
                                                      
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
                        }
                        
                     }
                     
                  }
               }
            }
          }
          //Day checking
        }
     }
     
     
     marketExit();
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


void marketExit(){
   double remove_trade = false;
   double sl = 0;
   Comment("Monitoring ",OrdersTotal()," currently picked");
   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS)){
         //Assigning timeframe to parameters
         if(OrderComment() == mdesc){
            market = OrderSymbol();
            /*
            if(OrderProfit() >= OrderLots() * 100 && OrderStopLoss() == 0){// for creating a breakeven
               sl = OrderClosePrice() + OrderOpenPrice();
               sl = sl/2;
               if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,clrRed)){
                  Print(OrderSymbol()," modified successfully");
               }
               
            }
           */ 
           //Entering a swap trade
           lot_size = (lot_size > 0.01) ? lot_size : 0.01;
           price = 0;
           tp = 0;
           //adx = iADX(market,PERIOD_M30,14,PRICE_CLOSE,MODE_MAIN,0);
           
           ema9 = iMA(market,PERIOD_D1,9,0,MODE_EMA,PRICE_CLOSE,0);
           ema12 = iMA(market,PERIOD_D1,12,0,MODE_EMA,PRICE_CLOSE,0);
           ema21 = iMA(market,PERIOD_D1,21,0,MODE_EMA,PRICE_CLOSE,0);
           ema55 = iMA(market,PERIOD_D1,55,0,MODE_EMA,PRICE_CLOSE,0);
           
           vol = iVolume(market,PERIOD_M30,0);
           vMA = 0;
           for(int i = 0; i < 20; i++){
             vMA = iVolume(market,PERIOD_M30,i) + vMA;
           }
           vMA = vMA/20;
           
           if(vol > vMA){
             //Day chart for current trend movement
             if(ema9 > ema12 && iClose(market,PERIOD_D1,0) > ema9){
               if(ema12 > ema21 && OrderType() == OP_SELL){
                  if(ema21 > ema55){
                     ema9 = iMA(market,PERIOD_H4,9,0,MODE_EMA,PRICE_CLOSE,0);
                     ema12 = iMA(market,PERIOD_H4,12,0,MODE_EMA,PRICE_CLOSE,0);
                     ema21 = iMA(market,PERIOD_H4,21,0,MODE_EMA,PRICE_CLOSE,0);
                     ema55 = iMA(market,PERIOD_H4,55,0,MODE_EMA,PRICE_CLOSE,0);
                     
                     if(ema9 > ema12 && iClose(market,PERIOD_H4,0) > ema9){
                        if(ema12 > ema21){
                           if(ema21 > ema55){
                              ema9 = iMA(market,PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,0);
                              ema12 = iMA(market,PERIOD_H1,12,0,MODE_EMA,PRICE_CLOSE,0);
                              ema21 = iMA(market,PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE,0);
                              ema55 = iMA(market,PERIOD_H1,55,0,MODE_EMA,PRICE_CLOSE,0);
                              
                              if(ema9 > ema12 && iClose(market,PERIOD_H1,0) > ema9){
                                 if(ema12 > ema21){
                                    if(ema21 > ema55){
                                       ema9 = iMA(market,PERIOD_M30,9,0,MODE_EMA,PRICE_CLOSE,0);
                                       ema12 = iMA(market,PERIOD_M30,12,0,MODE_EMA,PRICE_CLOSE,0);
                                       ema21 = iMA(market,PERIOD_M30,21,0,MODE_EMA,PRICE_CLOSE,0);
                                       ema55 = iMA(market,PERIOD_M30,55,0,MODE_EMA,PRICE_CLOSE,0);
                                       
                                       if(ema9 > ema12 && iClose(market,PERIOD_M30,0) > ema9){
                                          if(ema12 > ema21 && iClose(market,PERIOD_M30,1) > iOpen(market,PERIOD_M30,1)){
                                             if(ema21 > ema55){
                                                for(int i = 1; i < 100; i++){
                                                   if(iClose(market,PERIOD_H4,i) > iClose(market,PERIOD_M30,0)){
                                                      if(iClose(market,PERIOD_H4,i) - iClose(market,PERIOD_M30,0) > 0.001 && iClose(market,PERIOD_H4,i) > iHigh(market,PERIOD_H4,0)){
                                                         tp = iClose(market,PERIOD_H4,i);
                                                         price = MarketInfo(market,MODE_ASK);
                                                         OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
                                                         OrderSend(market,OP_BUY,lot_size,price,3,0,tp,mdesc);
                                                         
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
                           }
                           
                        }
                        
                     }
                  }
               }
             }
             else if(ema9 < ema12 && iClose(market,PERIOD_D1,0) < ema9){
               if(ema12 < ema21 && OrderType() == OP_BUY){
                  if(ema12 < ema55){
                     ema9 = iMA(market,PERIOD_H4,9,0,MODE_EMA,PRICE_CLOSE,0);
                     ema12 = iMA(market,PERIOD_H4,12,0,MODE_EMA,PRICE_CLOSE,0);
                     ema21 = iMA(market,PERIOD_H4,21,0,MODE_EMA,PRICE_CLOSE,0);
                     ema55 = iMA(market,PERIOD_H4,55,0,MODE_EMA,PRICE_CLOSE,0);
                     
                     if(ema9 < ema12 && iClose(market,PERIOD_H4,0) < ema9){
                        if(ema12 < ema21){
                           if(ema21 < ema55){
                              ema9 = iMA(market,PERIOD_H1,9,0,MODE_EMA,PRICE_CLOSE,0);
                              ema12 = iMA(market,PERIOD_H1,12,0,MODE_EMA,PRICE_CLOSE,0);
                              ema21 = iMA(market,PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE,0);
                              ema55 = iMA(market,PERIOD_H1,55,0,MODE_EMA,PRICE_CLOSE,0);
                              
                              if(ema9 < ema12 && iClose(market,PERIOD_H1,0) < ema9){
                                 if(ema12 < ema21){
                                    if(ema21 < ema55){
                                       ema9 = iMA(market,PERIOD_M30,9,0,MODE_EMA,PRICE_CLOSE,0);
                                       ema12 = iMA(market,PERIOD_M30,12,0,MODE_EMA,PRICE_CLOSE,0);
                                       ema21 = iMA(market,PERIOD_M30,21,0,MODE_EMA,PRICE_CLOSE,0);
                                       ema55 = iMA(market,PERIOD_M30,55,0,MODE_EMA,PRICE_CLOSE,0);
                                       
                                       if(ema9 < ema12 && iClose(market,PERIOD_M30,0) < ema9){
                                          if(ema12 < ema21 && iClose(market,PERIOD_M30,1) < iOpen(market,PERIOD_M30,1)){
                                             if(ema21 < ema55){
                                                for(int i = 1; i < 100; i++){
                                                   if(iClose(market,PERIOD_H4,i) < iClose(market,PERIOD_M30,0)){
                                                      if(iClose(market,PERIOD_M30,0) - iClose(market,PERIOD_H4,i) > 0.001 && iClose(market,PERIOD_H4,i) < iLow(market,PERIOD_H4,0)){
                                                         tp = iClose(market,PERIOD_H4,i);
                                                         price = MarketInfo(market,MODE_BID);
                                                         OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
                                                         OrderSend(market,OP_SELL,lot_size,price,3,0,tp,mdesc);
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
                           }
                           
                        }
                        
                     }
                  }
               }
             }
             //Day checking
           }
            
         }
         
      }
    }
         
}
