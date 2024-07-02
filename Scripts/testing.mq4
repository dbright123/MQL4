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
     Print(TimeDayOfWeek(TimeGMT()), " Current day of week");
  }
//+------------------------------------------------------------------+

 