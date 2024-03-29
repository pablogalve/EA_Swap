//+------------------------------------------------------------------+
//|                                                       swapEA.mq4 |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property version   "1.10"
#property strict

enum operations{
   buy,
   sell,
};

enum daysOfWeek{
   sunday,
   monday,
   tuesday,
   wednesday,
   thursday,
   friday,
   saturday,
};

input daysOfWeek swapDay = wednesday;
int magic = 154;
int slippage = 10;
input double lots = 0.1;
input int SL = 0; //SL (in points). 0=No SL

input int swapHour = 23; //Swap is charged at 23:00h

input int CloseHour = 1; //Close 1h after 3x swap
input int CloseMinute = 30; //Close 30min after 3x swap
//input int CloseSecond = 0;

input int OpenHour = 1; //Open 1h before 3x swap
input int OpenMinute = 30; //Open 30min before 3x swap
//input int OpenSecond = 0;

input operations operation = buy;

input int maxSpread = 10; //Close if spread <= (in points)
double spread = MarketInfo(0,MODE_SPREAD);


string description = "description";

int OnInit()
  {
  
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
  {
  
  }
  
void OnTick()
  {
        
   if(DayOfWeek() == swapDay && (Hour()==swapHour - CloseHour - 1) && (Minute()==59 - CloseMinute) && (Seconds() >= 0 && Seconds() <= 60) && activeOrders(magic)==0)
   {
      if(CheckVolumeValue(lots,description)==true)
      {
         if(SL == 0)
         {
         //We don't have a stop loss
            if(operation == buy)
               int buy = OrderSend(Symbol(),OP_BUY,lots,Ask,slippage,0,0,NULL,magic,NULL,clrGreen);
            else if(operation == sell)   
               int sell = OrderSend(Symbol(),OP_SELL,lots,Bid,slippage,0,0,NULL,magic,NULL,clrRed);  
         }else
         {
            if(operation == buy)
               int buy = OrderSend(Symbol(),OP_BUY,lots,Ask,slippage,Ask-(SL*_Point),0,NULL,magic,NULL,clrGreen);
            else if(operation == sell)   
               int sell = OrderSend(Symbol(),OP_SELL,lots,Bid,slippage,Bid+(SL*_Point),0,NULL,magic,NULL,clrRed);
         }
             
      }
   }
   //We have already received our 3x swap
   if(getSwap(magic) > 0)
   {
      spread = MarketInfo(0,MODE_SPREAD);
      if(spread <= maxSpread*_Point)
      {
         CloseOrders(magic);
      } 
   }            
   
   //If we have to close the order on next day
   if((swapHour + OpenHour + 1) >= 24)
   {
      if(DayOfWeek() == swapDay+1 && (Hour()==(swapHour + OpenHour - 24)) && (Minute()==(0 + OpenMinute)) && (Seconds() >= 0 && Seconds() <= 60) && activeOrders(magic)==1)
      {
         CloseOrders(magic); 
      } 
   }else //if order is closed the same day
   {
      if(DayOfWeek() == swapDay && (Hour()==(swapHour + OpenHour)) && (Minute()==(0 + OpenMinute)) && (Seconds() >= 0 && Seconds() <= 60) && activeOrders(magic)==1)
      {
         CloseOrders(magic); 
      }      
   }      
   
                         
  }
  
  
  void CloseOrders(int magicN)
{
   for(int i = OrdersTotal()-1;i>=0;i--)
   {      
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber() == magicN)
      {
         if(OrderType() == OP_BUY)
         {
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

int activeOrders(int magicE)
{
   int orders =0;
   
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber() == magicE)
      {
         orders++;
      }
   }
   return orders;
}

bool CheckVolumeValue(double volume,string &description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                               volume_step,ratio*volume_step);
      return(false);
     }
   description="Correct volume value";
   return(true);
  }

//Returns the swap accrued by an order generated by this EA
double getSwap(int magic)
{   
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber() == magic)
      {
         return OrderSwap();
      }
   }
   //There are not open orders
   return 0;
}