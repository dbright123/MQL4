//+------------------------------------------------------------------+
//|                                                  dbot_zigzag.mq4 |
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
extern ENUM_TIMEFRAMES tf = NULL;
extern double lots = 0.01;

int OnInit()
  {
   Alert("System is currently active on ",Symbol());
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
   double price = iClose(market,tf,0);
   double ema21 = iMA(market,tf,21,0,MODE_EMA,PRICE_CLOSE,0), ema50 = iMA(market,tf,50,0,MODE_EMA,PRICE_CLOSE,0), ema200 = iMA(market,tf,200,0,MODE_EMA,PRICE_CLOSE,0);
   double adx = iADX(market,tf,14,PRICE_CLOSE,MODE_MAIN,0), di_plus = iADX(market,tf,14,PRICE_CLOSE,MODE_PLUSDI,0), di_minus = iADX(market,tf,14,PRICE_CLOSE, MODE_MINUSDI,0);
   double zigzag = iCustom(market,tf,"zigzag",0,0);
   double tp = 0;
   
   if(OrdersTotal() == 0){//Ordering Market
      //Determine the weak trend
      if(adx > 20){
         if(price > ema200){//Buy Condition
            if(ema21 > ema50 && ema50 > ema200){
               if(di_plus > di_minus){                 
                  for(int i = 0; i < Bars; i++){
                     zigzag = iCustom(market,tf,"zigzag",0,i);
                     if(zigzag != 0){
                        if(price > zigzag && Close[0] > Open[0]){
                           tp = MathAbs(price - zigzag);
                           tp = 2 * tp;
                           tp = price + tp;
                           int t = OrderSend(market,OP_BUY,lots,Ask,8,zigzag,tp,"dbot_zigzag");
                           if(t < 1){
                              Alert(market," failed to buy ",GetLastError());
                           }
                           break;
                        }
                     }
                  }                  
               }
            }
         }
         else if(price < ema200){// Sell condition
            if(ema21 < ema50 && ema50 < ema200){
               if(di_plus < di_minus){
                  for(int i = 0; i < Bars; i++){
                     zigzag = iCustom(market,tf,"zigzag",0,i);
                     if(zigzag != 0){
                        if(price < zigzag && Close[0] < Open[0]){
                           tp = MathAbs(price - zigzag);
                           tp = 2 * tp;
                           tp = price - tp;
                           int t = OrderSend(market,OP_SELL,lots,Bid,8,zigzag,tp,"dbot_zigzag");
                           if(t < 1){
                              Alert(market," failed to buy ",GetLastError());
                           }
                           break;
                        }
                     }
                  }
                  
               }
            }
         }
      }
      
   }else{ //Monitoring forex market
      for(int i = 0; i < OrdersTotal(); i++){
         if(OrderSelect(i,SELECT_BY_POS)){
            if(OrderSymbol() == market){
               double ema21 = iMA(market,tf,21,0,MODE_EMA,PRICE_CLOSE,0), ema50 = iMA(market,tf,50,0,MODE_EMA,PRICE_CLOSE,0), ema200 = iMA(market,tf,200,0,MODE_EMA,PRICE_CLOSE,0);
               
               if(OrderType() == OP_BUY){
                  if(ema200 > ema50 && ema50 > ema21){//Emergency close
                     if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),8,clrBlue)){
                        Alert(market," Close successfully");
                     }
                  }
                  //Modifying stoploss
                  //sl = 0;
                  for(int i = 0; i < Bars; i++){
                     zigzag = iCustom(market,tf,"zigzag",0,i);
                     if(zigzag != 0){
                        if(zigzag > OrderStopLoss() && OrderClosePrice() > zigzag && zigzag > OrderOpenPrice()){
                           if(OrderModify(OrderTicket(),OrderOpenPrice(),zigzag,OrderTakeProfit(),0,clrGreen)){
                              Alert(market," stoploss updated to ",zigzag);
                           }
                        }
                        break;
                     }
                  }
               }
               else if(OrderType() == OP_SELL){
                  if(ema200 < ema50 && ema50 < ema21){//Emergency close
                     if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),8,clrBlue)){
                        Alert(market," Close successfully");
                     }
                  }
                  //Modifying stoploss
                  //sl = 0;
                  for(int i = 0; i < Bars; i++){
                     zigzag = iCustom(market,tf,"zigzag",0,i);
                     if(zigzag != 0){
                        if(zigzag < OrderStopLoss() && OrderClosePrice() < zigzag && zigzag < OrderOpenPrice()){
                           if(OrderModify(OrderTicket(),OrderOpenPrice(),zigzag,OrderTakeProfit(),0,clrGreen)){
                              Alert(market," stoploss updated to ",zigzag);
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
//+------------------------------------------------------------------+
