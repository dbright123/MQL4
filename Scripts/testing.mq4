//+------------------------------------------------------------------+
//|                                                      testing.mq4 |
//|                                     Dbright Software Development |
//|                                       https://www.dbright.org/ea |
//+------------------------------------------------------------------+
#property copyright "Dbright Software Development"
#property link      "https://www.dbright.org/ea"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

void OnStart()
  {
//---
     string market = "GBPUSD";
     int tf = PERIOD_D1;
     double val=iCustom(market,tf,"s_and_d",2,13);
     Print(val);
     Print((int)MarketInfo("XAUUSD",MODE_DIGITS));
     Print(1/MathPow(10,2));
     
     for(int i = 0; i < 1000; i++){
         if(iCustom(market,tf,"s_and_d",0,i) != 0){
            Print("dz -->>", iCustom(market,tf,"s_and_d",0,i));
            Print(i);
            break;
         }
         else if(iCustom(market,tf,"s_and_d",1,i) != 0){
            Print("sz -->>", iCustom(market,tf,"s_and_d",1,i));
            Print(i);
            break;
         }
         else if(iCustom(market,tf,"s_and_d",2,i) != 0){
            Print("dz fast -->>", iCustom(market,tf,"s_and_d",2,i));
            Print(i);
            break;
         }
         else if(iCustom(market,tf,"s_and_d",3,i) != 0){
            Print("sz fast -->>", iCustom(market,tf,"s_and_d",3,i));
            Print(i);
            break;
         }
     }
  }
//+------------------------------------------------------------------+

 