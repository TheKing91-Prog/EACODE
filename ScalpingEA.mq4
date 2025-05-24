//+------------------------------------------------------------------+
//|                                                   ScalpingEA.mq4 |
//|                      Copyright 2023, Your Name/Company |
//|                                      http://www.example.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Your Name/Company"
#property link      "http://www.example.com"
#property version   "1.00"
#property strict

// Input Parameters
input int FastMA_Period = 10;           // Period for the Fast Moving Average
input int SlowMA_Period = 20;           // Period for the Slow Moving Average
input int RSI_Period = 14;            // Period for the RSI calculation
input int RSI_Overbought_Level = 70;  // RSI level considered as overbought
input int RSI_Oversold_Level = 30;  // RSI level considered as oversold
input int StopLoss_Pips = 10;         // Stop Loss in Pips from entry price
input int TakeProfit_Pips = 20;       // Take Profit in Pips from entry price
input double LotSize = 0.01;          // Trade volume in lots
input int MagicNumber = 12345;        // Unique identifier for orders placed by this EA

// Static variable to store the bar time of the last trade.
// This is used to prevent opening multiple trades on the same bar.
static datetime lastTradeOpenTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//| Called when the EA is loaded onto a chart.                       |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Print("ScalpingEA initialized. Symbol: ", Symbol(), ", Timeframe: ", EnumToString((ENUM_TIMEFRAMES)Period()));
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//| Called when the EA is removed from a chart or MetaTrader closes. |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("ScalpingEA deinitialized. Reason code: ", reason);
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//| Called on every new tick for the symbol the EA is attached to.   |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   // Calculate Moving Averages
   double fastMA = iMA(NULL, 0, FastMA_Period, 0, MODE_SMA, PRICE_CLOSE, 0);
   double slowMA = iMA(NULL, 0, SlowMA_Period, 0, MODE_SMA, PRICE_CLOSE, 0);

   // Calculate RSI
   double rsiValue = iRSI(NULL, 0, RSI_Period, PRICE_CLOSE, 0);

   // Log current market data and indicator values
   Print("Symbol: ", Symbol(), ", Time: ", TimeToString(TimeCurrent(), TIME_SECONDS), ", Bid: ", Bid, ", Ask: ", Ask, ", FastMA: ", fastMA, ", SlowMA: ", slowMA, ", RSI: ", rsiValue);

   // Check if a trade was already opened on the current bar to prevent multiple trades per bar.
   if(Time[0] == lastTradeOpenTime)
     {
      // Print("Trade already opened on this bar (", TimeToString(Time[0]), "). Skipping."); // Optional: for very verbose logging
      return; 
     }

   // --- Buy Signal Logic: Fast MA crossed above Slow MA AND RSI is oversold ---
   if(fastMA > slowMA && rsiValue < RSI_Oversold_Level)
     {
      Print("BUY signal conditions met for ", Symbol());
      // Open Buy Order
      double stopLossPrice = Ask - StopLoss_Pips * _Point;
      double takeProfitPrice = Ask + TakeProfit_Pips * _Point;
      int ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, stopLossPrice, takeProfitPrice, "Buy Order", MagicNumber, 0, Green);
      if(ticket > 0)
        {
         Print("OrderSend successful for ", Symbol(), ". Ticket: ", ticket, ". OrderType: BUY. SL: ", stopLossPrice, " TP: ", takeProfitPrice);
         lastTradeOpenTime = Time[0]; // Update last trade open time only on successful trade
        }
      else
        {
         Print("OrderSend failed for ", Symbol(), ". OrderType: BUY. Error: ", GetLastError());
        }
     }

   // --- Sell Signal Logic: Fast MA crossed below Slow MA AND RSI is overbought ---
   if(fastMA < slowMA && rsiValue > RSI_Overbought_Level)
     {
      Print("SELL signal conditions met for ", Symbol());
      // Open Sell Order
      double stopLossPrice = Bid + StopLoss_Pips * _Point;
      double takeProfitPrice = Bid - TakeProfit_Pips * _Point;
      int ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, stopLossPrice, takeProfitPrice, "Sell Order", MagicNumber, 0, Red);
      if(ticket > 0)
        {
         Print("OrderSend successful for ", Symbol(), ". Ticket: ", ticket, ". OrderType: SELL. SL: ", stopLossPrice, " TP: ", takeProfitPrice);
         lastTradeOpenTime = Time[0]; // Update last trade open time only on successful trade
        }
      else
        {
         Print("OrderSend failed for ", Symbol(), ". OrderType: SELL. Error: ", GetLastError());
        }
     }
//---
  }
//+------------------------------------------------------------------+
