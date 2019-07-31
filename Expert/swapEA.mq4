//+------------------------------------------------------------------+
//|                                                       swapEA.mq4 |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int magic = 154;
int slippage = 10;
input int CloseHour = 0;
input int CloseMinute = 0;
input int CloseSecond = 0;
input int OpenHour = 0;
input int OpenMinute = 0;
input int OpenSecond = 0;

int OnInit()
  {
  
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
  {
  
  }
  
void OnTick()
  {
   if(DayOfWeek() == 3)
      if(Hour()==23 - CloseHour)
         if(Minute()==59 - CloseMinute)
            if(Seconds()==00 - CloseSecond)
               int buy = OrderSend(Symbol(),OP_BUY,0.1,Ask,slippage,0,0,NULL,magic,NULL,clrGreen);
               
   if(DayOfWeek() == 4)
      if(Hour()==00 + OpenHour)
         if(Minute()==04 + OpenMinute)
            if(Seconds()==00 + OpenSecond)
               CloseOrders(magic);            
  }
  
  
  
  void CloseOrders(int magicN)
{
   for(int i = OrdersTotal()-1;i>=0;i--)
   {
      
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      Print("Magic: " , OrderMagicNumber());
      if(OrderMagicNumber() == magicN)
      {
         Print("2");
         if(OrderType() == OP_BUY)
         {
            Print("3");
            OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),slippage);
         }
         if(OrderType() == OP_SELL)
         {
            OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),slippage);
         }         
      }else{
         Print("OrderMagicNumber Error: " , GetLastError());
      }
   }
}