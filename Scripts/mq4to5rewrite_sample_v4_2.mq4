//+------------------------------------------------------------------+
//|                                       mq4tomq5_script_sample.mq4 |
//|                                                            keiji |
//|                                  http://www.dr-ea.com/meta-blog/ |
//+------------------------------------------------------------------+
#property copyright "keiji"
#property link      "http://www.dr-ea.com/meta-blog/"
#property show_inputs
#include <stdlib.mqh>

extern string  MQL4FileName   = "FileName";
extern int     FileType       = 1;
extern string  note           = "FileType  0 :Indicator,  1 :EA,  2 :Script";

//top code
string FuncAddTop()
{
   return("\n//:::::::::::::::::::::::::::::::::::::::::::::\n"+
         "#include <mt4accountinfo.mqh>\n"+
         "#include <mt4string.mqh>\n"+
         "#include <mt4datetime.mqh>\n"+
         "#include <mt4objects_1.mqh>\n"+
         "#include <mt4timeseries_2.mqh>\n"+
         "//Etc.\n"+
         "//:::::::::::::::::::::::::::::::::::::::::::::::\n");
}
//code in OnInit()
string FuncAddInInit()
{
   return("\n  //:::::::::::::::::::::::::::::::::::::::::::::\n"+
         "  double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);\n"+
         "  double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);\n"+
         "  int Bars=Bars(Symbol(),PERIOD_CURRENT);\n"+
         "  double Point=Point();\n"+
         "  //Etc.\n"+
         "  //:::::::::::::::::::::::::::::::::::::::::::::::\n");
}
//code in OnCalculate(),OnTick(),OnStart()
string FuncAddInStart()
{
   return("\n  //:::::::::::::::::::::::::::::::::::::::::::::\n"+
         "  double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);\n"+
         "  double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);\n"+
         "  int Bars=Bars(Symbol(),PERIOD_CURRENT);\n"+
         "  double Point=Point();\n"+
         "  //Etc.\n"+
         "  //:::::::::::::::::::::::::::::::::::::::::::::::\n");
}
//code in OnDeinit()
string FuncAddInDeinit()
{
   return("\n  //:::::::::::::::::::::::::::::::::::::::::::::\n"+
         "  double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);\n"+
         "  double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);\n"+
         "  int Bars=Bars(Symbol(),PERIOD_CURRENT);\n"+
         "  double Point=Point();\n"+
         "  //Etc.\n"+
         "  //:::::::::::::::::::::::::::::::::::::::::::::::\n");
}

string text;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
{
//----
   string filename=MQL4FileName+".mq4";
   int handle;
   int linecnt=0,includeline=0;
   handle=FileOpen(filename,FILE_CSV|FILE_READ,"\t");
   if(handle<0)
   {
      Alert("File " + filename + " not found, the last error is ", ErrorDescription(GetLastError()));
      return(false);
   }
   else
   {
      while(!FileIsEnding(handle))
      {
         text=FileReadString(handle);
         linecnt++;
         if(StringSubstr(text,0,2)!="//" && StringSubstr(text,0,2)!="#p")
         {
            if(FuncFind(text, "int ") || FuncFind(text, "double ") || FuncFind(text, "string ") || FuncFind(text, "bool ") ||
               FuncFind(text, "color ") || FuncFind(text, "datetime "))
            {
               includeline=linecnt;
               break;
            }
         }
      }
      FileSeek(handle,0,SEEK_SET);
   }
   
   string filename1="mq4_"+MQL4FileName+".mq5";
   int handle1;
   handle1=FileOpen(filename1,FILE_CSV | FILE_WRITE,"\t");
   if(handle1<0)
   {
      Alert("File " + filename1+" not Open, the last error is ", ErrorDescription(GetLastError()));
      return(false);
   }
   string filename2="mq4_"+MQL4FileName+".txt";
   int handle2;
   handle2=FileOpen(filename2,FILE_CSV | FILE_READ | FILE_WRITE,"\t");
   if(handle2<0)
   {
      Alert("File " + filename2+" not Open, the last error is ", ErrorDescription(GetLastError()));
      return(false);
   }
   if(handle>0 && handle1>0 && handle2>0)
   {
      bool init=false,start=false,deinit=false;
      bool changeinit=false,changestart=false,changedeinit=false;
      linecnt=0;
      while(!FileIsEnding(handle))
      {
         text=FileReadString(handle);
         linecnt++;
         string mq4word,mq5word;
         //-------------------------------FuncRewrite(string mql4 word, stirng mql5 word);
         
         //REWRITE************************************************************************
         //extern to input
         mq4word= "extern";
         mq5word= "input";
         FuncRewrite(mq4word, mq5word);
         
         //Account Info
         mq4word= "AccountBalance(";
         mq5word= "AccountInfoDouble(ACCOUNT_BALANCE";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "AccountCredit(";
         mq5word= "AccountInfoDouble(ACCOUNT_CREDIT";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "AccountCompany(";
         mq5word= "AccountInfoString(ACCOUNT_COMPANY";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "AccountCurrency(";
         mq5word= "AccountInfoString(ACCOUNT_CURRENCY";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "AccountEquity(";
         mq5word= "AccountInfoDouble(ACCOUNT_EQUITY";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "AccountFreeMargin(";
         mq5word= "AccountInfoDouble(ACCOUNT_FREEMARGIN";
         FuncRewrite(mq4word, mq5word);
         
         //AccountFreeMarginCheck(string symbol, int cmd, double volume)
         //AccountFreeMarginMode()
         
         mq4word= "AccountLeverage(";
         mq5word= "AccountInfoInteger(ACCOUNT_LEVERAGE";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "AccountMargin(";
         mq5word= "AccountInfoDouble(ACCOUNT_MARGIN";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "AccountName(";
         mq5word= "AccountInfoString(ACCOUNT_NAME";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "AccountNumber(";
         mq5word= "AccountInfoInteger(ACCOUNT_LOGIN";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "AccountProfit(";
         mq5word= "AccountInfoDouble(ACCOUNT_PROFIT";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "AccountServer(";
         mq5word= "AccountInfoString(ACCOUNT_SERVER";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "AccountStopoutLevel(";
         mq5word= "AccountInfoDouble(ACCOUNT_MARGIN_SO_SO";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "AccountStopoutMode(";
         mq5word= "AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE";
         FuncRewrite(mq4word, mq5word);


         //String Function
         mq4word= "CharToStr(";
         mq5word= "CharToString(";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "DoubleToStr(";
         mq5word= "DoubleToString(";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "StrToDouble(";
         mq5word= "StringToDouble(";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "StrToInteger(";
         mq5word= "StringToInteger(";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "StrToTime(";
         mq5word= "StringToTime(";
         FuncRewrite(mq4word, mq5word);
         
         mq4word= "TimeToStr(";
         mq5word= "TimeToString(";
         FuncRewrite(mq4word, mq5word);

         
         int i=0;
         //Change & ADD****************************************************
         //top part
         if(linecnt==includeline) text=FuncAddTop()+"\n"+text;
         
         //init
         if(!init && !changeinit)
         {
            for(i=0;i<StringLen(text)-5;i++)
            {
               if(StringSubstr(text,i,6)==" init(")
               {
                  init=true;
                  break;
               }
            }
         }
         if(init)
         {
            if(!changeinit)
            {
               text=StringSubstr(text,0,i)+" OnInit("+StringSubstr(text,i+6);
               changeinit=true;
            }
            while(i<StringLen(text))
            {
               if(StringSubstr(text,i,1)=="{")
               {
                  text=StringSubstr(text,0,i+1)+FuncAddInInit()+StringSubstr(text,i+1);
                  init=false;
                  break;
               }
               i++;
            }
         }
         //start
         if(!start && !changestart)
         {
            for(i=0;i<StringLen(text)-6;i++)
            {
               if(StringSubstr(text,i,7)==" start(")
               {
                  start=true;
                  break;
               }
            }
         }
         if(start)
         {
            if(!changestart)
            {
               switch(FileType)
               {
                  case 0:  text="int OnCalculate(const int rates_total,\n"+
                                "                const int prev_calculated,\n"+
                                "                const datetime& time[],\n"+
                                "                const double& open[],\n"+
                                "                const double& high[],\n"+
                                "                const double& low[],\n"+
                                "                const double& close[],\n"+
                                "                const long& tick_volume[],\n"+
                                "                const long& volume[],\n"+
                                "                const int& spread[]"+
                                StringSubstr(text,i+7);break;
                  case 1:  text="void OnTick("+StringSubstr(text,i+7);break;
                  case 2:  text=StringSubstr(text,0,i)+" OnStart("+StringSubstr(text,i+7);break;
               }
               changestart=true;
            }
            while(i<StringLen(text))
            {
               if(StringSubstr(text,i,1)=="{")
               {
                  text=StringSubstr(text,0,i+1)+FuncAddInStart()+StringSubstr(text,i+1);
                  start=false;
                  break;
               }
               i++;
            }
         }
         //deinit
         if(!deinit && !changedeinit)
         {
            for(i=0;i<StringLen(text)-7;i++)
            {
               if(StringSubstr(text,i,8)==" deinit(")
               {
                  deinit=true;
                  break;
               }
            }
         }
         if(deinit)
         {
            if(!changedeinit)
            {
               text=StringSubstr(text,0,i)+" OnDeinit("+StringSubstr(text,i+8);
               changedeinit=true;
            }
            while(i<StringLen(text))
            {
               if(StringSubstr(text,i,1)=="{")
               {
                  text=StringSubstr(text,0,i+1)+FuncAddInDeinit()+StringSubstr(text,i+1);
                  deinit=false;
                  break;
               }
               i++;
            }
         }
         FileWrite(handle2,text);
      }
      FileClose(handle);
      FileFlush(handle2);
      
      bool findstart=false,findfirst=false;
      int cnt=0,lastsemi=0,lastreturn=0;
      int strtlinecnt=0;
      if(FileType==0 && changestart)
      {
         FileSeek(handle2,0,SEEK_SET);
         while(!FileIsEnding(handle2))
         {
            text=FileReadString(handle2);
            strtlinecnt++;
            if(!findstart)
            {
               for(i=0;i<StringLen(text)-12;i++)
               {
                  if(StringSubstr(text,i,12)=="OnCalculate(")
                  {
                     findstart=true;
                     break;
                  }
               }
            }
            if(findstart)
            {
               for(i=0;i<StringLen(text);i++)
               {
                  if(StringSubstr(text,i,1)=="{")
                  {
                     cnt++;
                     if(!findfirst) findfirst=true;
                  }
                  else if(StringSubstr(text,i,1)=="}") cnt--;
                  else if(StringSubstr(text,i,6)=="return") lastreturn=strtlinecnt;
                  else if(StringSubstr(text,i,1)==";") lastsemi=strtlinecnt;
               }
            }
            if(findfirst && cnt==0) break;
         }
      }
      else if(FileType==1 && changestart)
      {
         FileSeek(handle2,0,SEEK_SET);
         while(!FileIsEnding(handle2))
         {
            text=FileReadString(handle2);
            strtlinecnt++;
            if(!findstart)
            {
               for(i=0;i<=StringLen(text)-12;i++)
               {
                  if(StringSubstr(text,i,12)=="void OnTick(")
                  {
                     findstart=true;
                     break;
                  }
               }
            }
            if(findstart)
            {
               for(i=0;i<StringLen(text);i++)
               {
                  if(StringSubstr(text,i,1)=="{")
                  {
                     cnt++;
                     if(!findfirst) findfirst=true;
                  }
                  else if(StringSubstr(text,i,1)=="}") cnt--;
                  else if(StringSubstr(text,i,6)=="return") lastreturn=strtlinecnt;
                  else if(StringSubstr(text,i,1)==";") lastsemi=strtlinecnt;
               }
            }
            if(findfirst && cnt==0) break;
         }
      }
      linecnt=0;
      FileSeek(handle2, 0, SEEK_SET);
      while(!FileIsEnding(handle2))
      {
         linecnt++;
         text=FileReadString(handle2);
         if(FileType==0)
         {
            if(lastreturn==lastsemi && lastreturn==linecnt) text="   return(rates_total);";
            if(lastreturn==0 && strtlinecnt==linecnt) text="   return(rates_total);\n"+text;
         }
         if(FileType==1 && lastreturn==lastsemi && lastreturn==linecnt) text="//"+text;
         FileWrite(handle1,text);
      }
      FileClose(handle1);
      FileClose(handle2);
      FileDelete(filename2);
   }
   
   Alert("Complete rewriting!");
//----
   return(0);
}

bool FuncFind(string txt, string word)
{
   int length=StringLen(word);
   for(int i=0;i<=StringLen(txt)-length;i++)
   {
      if(StringSubstr(txt,i,length)==word) return(true);
   }
   return(false);
}

string FuncRewrite(string mq4word, string mq5word)
{
   int length=StringLen(mq4word);
   for(int i=0;i<=StringLen(text)-length;i++)
   {
      if(StringSubstr(text,i,length)==mq4word)
      {
         if(i==0) text=mq5word+StringSubstr(text,length);
         else text=StringSubstr(text,0,i)+mq5word+StringSubstr(text,i+length);
      }
   }
}

