//+------------------------------------------------------------------+
//|                                                          msp.mq4 |
//|                                             OMAGE MICHEAL BRIGHT |
//|                               Dbright Software Development (DSD) |
//+------------------------------------------------------------------+
#property copyright "Dbright Software Development (DSD)"
#property link      "https://www.dbright.org"
#property version   "1.00"
#property strict
#property show_inputs
#property script_show_inputs

#property description "This application is Master/Slave program,"
#property description "where what is traded on a trading platform can easily be"
#property description "moved or copied to another trading platform automatically"
#property description "by the use of server communication standing as a middle man"
#property description "between all trading platforms"
#property description "---------------------------------------------------------------"
#property description "PHP source code for server is open source and can be gotten on github"
#property description "https://www.github.com/dbright123/MSP"
#property description "for people who want to change servers or use local network"
#property description "you can download source code but please you have to configure url on "
#property description "Expert adviser under tools then click on options"
#property description " "
#property description "as for the source code for the program which you want to run on metatrader"
#property description "you will have to buy the source code, for futher discussion on purchase"
#property description "contact me at micheal.omage@gmail.com"

#property icon "msp.ico"

extern string id = "uniqueMasterID"; //Please set your unique ID
extern string server = "https://dbright123.000webhostapp.com/"; // Server link to either give or receive command

enum Type
  {
   Slave = 0,
   Master
  };
enum Speed
  {
   Fast = 0,
   Medium,
   Slow
  };
  
extern Type type = Slave; //master or slave

input Speed refreshrate = Fast; //Refresh rate in seconds


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   MessageBox("Hello Trader,\n this is to confirm that EA is operating as \n"+
              ((type == Master)?"master":"slave")+" with id of "+id+
              "\n communicating with server using \n"+server,
              "Confirmation",
              MB_OK);

   MessageBox("Hello Trader, Please note to be able to communicate with server through this link "+server+
              "\nadd the link addresses in the list of allowed URLs in the 'Expert Advisors' tab on 'Options' \n"+
              "\n for any issues please contact us at https://www.dbright.org",
              "Announcement",
              MB_OK);

   if(refreshrate == Fast)
     {
      EventSetTimer(10);
     }
   else
      if(refreshrate == Medium)
        {
         EventSetTimer(30);
        }
      else
        {
         EventSetTimer(60);
        }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(reason != 5)
      ExpertRemove();
   Alert(reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   Comment(
      ((type == Master)? "Master Activated" : "Slave Activated"),
      "\n",
      id,
      "\n",
      server,
      "\n",
      "workings : ",GetTickCount()
   );

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

   Print("Time : ",TimeHour(TimeGMT())," : ",TimeMinute(TimeGMT()));
   if(IsExpertEnabled())
     {
      if(IsConnected())
        {
         if(type == Master)
           {
            master();
           }
         else
            if(type == Slave)
              {
               slave();
              }
            else
              {
               Print("No command for tester");
              }
        }
      else
        {
         Alert("No Internet Connection enabled");
        }
     }
   else
     {
      Alert("Please enable EA for trading");
     }
   Print("Error ",GetLastError());
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void slave()
  {
   Print("Copying market from ",id);
   char result[] = {};
   string result_header = "";
   string output = "";
   char data[] = {};
   int res = WebRequest(
                "GET",
                server+"?id="+id,
                NULL,
                5000,
                data,
                result,
                result_header
             );
   Print(res);
   if(res != -1)
     {
      Print("External data received");

      output = CharArrayToString(result);
      Print(output);
      Print(result_header);
      if(output == "registered")
        {
         Print(id," paired");
         Print("loading ");
         res = WebRequest(
                  "GET",
                  server+"?id="+id+"&result=demand",
                  NULL,
                  5000,
                  data,
                  result,
                  result_header
               );
         Print(res);
         if(res != 1)
           {
            output = CharArrayToString(result);
            Print(output);

            string outputFormat[] = {};

            if(StringSplit(output,StringGetCharacter("-",0),outputFormat) != -1)
              {
               Print("Loading!!!");
               if(id == outputFormat[0])
                 {
                  Print("accepted");
                  for(int i = 1; i < ArraySize(outputFormat); i++)
                    {
                     StringReplace(outputFormat[i],"[","");
                     StringReplace(outputFormat[i],"]","");
                    }

                  string ticket[] = {};
                  string order_name[] = {};
                  string order_type[] = {};
                  string lot_size[] = {};
                  string price[] = {};
                  string sl[] = {};
                  string tp[] = {};
                  string comment[] = {};

                  StringSplit(outputFormat[1],StringGetCharacter("-",0),ticket);
                  StringSplit(outputFormat[2],StringGetCharacter("-",0),order_name);
                  StringSplit(outputFormat[3],StringGetCharacter("-",0),order_type);
                  StringSplit(outputFormat[4],StringGetCharacter("-",0),lot_size);
                  StringSplit(outputFormat[5],StringGetCharacter("-",0),price);
                  StringSplit(outputFormat[6],StringGetCharacter("-",0),sl);
                  StringSplit(outputFormat[7],StringGetCharacter("-",0),tp);
                  StringSplit(outputFormat[8],StringGetCharacter("-",0),comment);


                  for(int i = 0; i < ArraySize(order_name); i++)
                    {
                     Print(order_name[i]," ",ticket[i]);
                    }


                  int Ticket[] = {},
                                 Order_type[] = {};

                  float  Lot_size[] = {},
                                      Price[] = {},
                                                Sl[] = {},
                                                       Tp[] = {};


                  ArrayResize(Ticket,ArraySize(ticket));
                  ArrayResize(Order_type,ArraySize(ticket));
                  ArrayResize(Lot_size,ArraySize(ticket));
                  ArrayResize(Price,ArraySize(ticket));
                  ArrayResize(Sl,ArraySize(ticket));
                  ArrayResize(Tp,ArraySize(ticket));

                  for(int i = 0; i < ArraySize(ticket); i ++)
                    {
                     Ticket[i] = (int)StringToInteger(ticket[i]);
                     Order_type[i] = (int)StringToInteger(order_type[i]);
                     Lot_size[i] = (float)StringToDouble(lot_size[i]);
                     Price[i] = (float)StringToDouble(price[i]);
                     Sl[i] = (float)StringToDouble(sl[i]);
                     Tp[i] = (float)StringToDouble(tp[i]);
                    }

                  if(OrdersTotal() == 0)
                    {
                     Print("Adding Trades");
                     // Add new trades
                     //use ordersend to add order
                     for(int i = 0; i < ArraySize(Ticket); i++)
                       {
                        if(OrderSend(order_name[i],Order_type[i],Lot_size[i],Price[i],8,Sl[i],Tp[i],comment[i]) != -1)
                          {
                           Print("Successfully added");
                          }
                        else
                          {
                           Print("An error was encountered, please report issues to manufacturer");
                          }
                       }

                    }
                  else
                    {
                     Print("Updating trades");
                     // Updating trades

                     bool permit = true;// gives permission to delete trade
                     int c = 0;

                     for(int i = 0; i < OrdersTotal(); i++)//Removal of unplanned market or duplicate
                       {
                        if(OrderSelect(i,SELECT_BY_POS))
                          {
                           for(int n = 0; n < ArraySize(order_name); n++)
                             {
                              if(OrderSymbol() == order_name[n])
                                {
                                 permit = false;
                                 c++;
                                 if(c >= 2)
                                   {
                                    permit = true;

                                   }
                                }
                             }
                           if(permit)
                             {
                              if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3))
                                {
                                 Print("Unplanned market removed ",OrderSymbol());
                                }
                              else
                                {
                                 OrderDelete(OrderTicket());
                                }
                              c = 0;
                             }
                          }
                       }

                     if(OrdersTotal() == ArraySize(order_name))
                       {
                        //Balance trade by checking update on take profit and stoploss
                        for(int i = 0; i < OrdersTotal(); i++)
                          {
                           if(OrderSelect(i,SELECT_BY_POS))
                             {
                              for(int n = 0; n < ArraySize(order_name); n++)
                                {
                                 if(OrderSymbol() == order_name[n])
                                   {
                                    if(Sl[n] != OrderStopLoss() || Tp[n] != OrderTakeProfit())
                                      {
                                       Print("Updating stoploss for ",OrderSymbol());
                                       if(OrderModify(OrderTicket(),OrderOpenPrice(),Sl[n],Tp[n],0))
                                         {
                                          Print("Update made to ",OrderSymbol());
                                         }
                                       else
                                         {
                                          Print("Unable to update ",OrderSymbol());
                                         }
                                      }
                                    else
                                      {
                                       Print("No changes have been made yet on ",OrderSymbol());
                                      }
                                   }
                                }
                             }
                           else
                             {
                              Print("An error occurred during computation");
                             }
                          }
                       }
                     else
                       {
                        //Making sure the number of trade on master is the same on slave trade
                        string missing_trade[] = {};
                        int length = 0;
                        bool present = false;
                        for(int n = 0; n < ArraySize(order_name); n++)
                          {
                           for(int i = 0; i < OrdersTotal(); i++)
                             {
                              if(OrderSelect(i,SELECT_BY_POS))
                                {
                                 if(OrderSymbol() == order_name[n])
                                   {
                                    present = true;//checking if a particular order is present
                                   }
                                }

                             }

                           if(!present)
                             {
                              ArrayResize(missing_trade,++length);
                              missing_trade[length - 1] = order_name[n];
                             }

                          }

                        for(int i = 0; i < ArraySize(missing_trade); i++)
                          {
                           //Adding missing trade to market
                           for(int n = 0; n < ArraySize(order_name); n++)
                             {
                              if(missing_trade[i] == order_name[n])
                                {
                                 if(OrderSend(order_name[n],Order_type[n],Lot_size[n],Price[n],8,Sl[n],Tp[n],comment[n]) != -1)
                                   {
                                    Print("Missing trade added successfully");
                                    break;
                                   }
                                }
                             }
                          }
                       }
                    }


                 }
               else
                 {
                  Print("rejected");
                 }
              }
            else
              {
               Print("Please contact customer care for error ",GetLastError());
              }
           }
         else
           {
            Print("Unable to communicate well with server");
           }
        }
      else
        {
         Print("ID not recognised");
        }

     }
   else
     {
      Print("Unable to communicate well with server");
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void master()
  {
   int total = OrdersTotal();
   string ticket[] = {};
   string order_name[] = {};
   string order_type[] = {};
   string lot_size[] = {};
   string price[] = {};
   string sl[] = {};
   string tp[] = {};
   string comment[] = {};

   ArrayResize(ticket,total);
   ArrayResize(order_name,total);
   ArrayResize(order_type,total);
   ArrayResize(lot_size,total);
   ArrayResize(price,total);
   ArrayResize(sl,total);
   ArrayResize(tp,total);
   ArrayResize(comment,total);


   string Ticket = "",
          Order_name = "",
          Order_type = "",
          Lot_size = "",
          Price = "",
          Sl = "",
          Tp = "",
          Order_comment="";
   Print("Registering order on server to update other trading platforms");
   for(int i = 0; i < total; i ++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {

         order_name[i] = OrderSymbol();
         Print("Order name ", order_name[i]);

         ticket[i] = IntegerToString(OrderTicket());
         Print("Ticket ",ticket[i]);

         order_type[i] = IntegerToString(OrderType());
         Print("Order Type ",order_type[i]);

         lot_size[i] = DoubleToString(OrderLots());
         Print("lot size ",lot_size[i]);

         price[i] = DoubleToString(OrderOpenPrice());
         Print("price ",price[i]);

         sl[i] = DoubleToString(OrderStopLoss());
         Print("stoploss ",sl[i]);

         tp[i] = DoubleToString(OrderTakeProfit());
         Print("take profit ",tp[i]);

         if(OrderComment() == "")
           {
            comment[i] = id;
           }
         else
           {
            comment[i] = OrderComment();
           }

         Print("Order Type ",comment[i]);

        }
     }

   for(int i = 0; i < total; i++)
     {
      if(i == 0)
        {
         Ticket = "["+ticket[i];
         Order_name = "["+order_name[i];
         Order_type = "["+order_type[i];
         Lot_size = "["+lot_size[i];
         Price = "["+price[i];
         Sl = "["+sl[i];
         Tp = "["+tp[i];
         Order_comment = "["+comment[i];
        }
      else
         if(i == total - 1)
           {
            Ticket = Ticket + "," + ticket[i] + "]";
            Order_name = Order_name + "," + order_name[i] + "]";
            Order_type = Order_type + "," + order_type[i] + "]";
            Lot_size = Lot_size + "," + lot_size[i] + "]";
            Price = Price + "," + price[i] + "]";
            Sl = Sl + "," + sl[i] + "]";
            Tp = Tp + "," + tp[i] + "]";
            Order_comment = Order_comment + "," + comment[i] + "]";
           }
         else
           {
            Ticket = Ticket + "," + ticket[i];
            Order_name = Order_name + "," + order_name[i];
            Order_type = Order_type + "," + order_type[i];
            Lot_size = Lot_size + "," + lot_size[i];
            Price = Price + "," + price[i];
            Sl = Sl + "," + sl[i];
            Tp = Tp + "," + tp[i];
            Order_comment = Order_comment + "," + comment[i];
           }
     }

   string post = "id="+id+
                 "&Ticket="+Ticket+
                 "&Order_name="+Order_name+
                 "&Order_type="+Order_type+
                 "&Lot_size="+Lot_size+
                 "&Price="+Price+
                 "&Sl="+Sl+
                 "&Tp="+Tp+
                 "&Order_comment="+Order_comment;

   Print(id);
   Print(Ticket);
   Print(Order_name);
   Print(Order_type);
   Print(Lot_size);
   Print(Price);
   Print(Sl);
   Print(Tp);
   Print(Order_comment);

   char data[] = {};
   StringToCharArray(post,data,0,StringLen(post));
   char result[] = {};
   string result_header = "";
   string output = "";

   Print("response code");
   int res = WebRequest("POST",server,NULL,5000,data,result,result_header);
   Print(res);
   if(res != -1)
     {
      Print("External data received");

      output = CharArrayToString(result);
      Print(output);

      Print(result_header);
     }
   else
     {
      Print("Unable to communicate well with server");
     }

  }
//+------------------------------------------------------------------+
