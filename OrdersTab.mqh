#include "Dialog.mqh"
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Arrays\ArrayString.mqh>
#include <Arrays\ArrayInt.mqh>
#include <Controls\ListView.mqh>

class OrdersTab {
   public:
      OrdersTab(void){};
      ~OrdersTab(void){};
      
      CArrayString orders;
      CArrayInt orders_count;
      CLabel tab_title;
      CListView orders_list;
      CButton close_all;
      CButton close_selected;

      string active_symbol;
      int trades_count;
      int title_height;
      CButton buttons[];
      int button_heights;
      
      void onCloseSelected(void);
      void Show();
      void Hide();
      void onCurrencyClick(const string c);
      bool CreateTab(void);
      void getCurrencies(void);
      bool checkOrders(void);
      void createButtons(void);
      void rebuild(void);
      void resetButtons(void);
      string GetOrderType(const int t);
      void onCloseAll(void);
};

void OrdersTab::Hide(void){
   for(int i=0;i<ArraySize(buttons);i++) buttons[i].Hide();
   tab_title.Hide();
   active_symbol=NULL;
   orders_list.Hide();
   close_all.Hide();
   close_selected.Hide();
   active_symbol=NULL;
}

void OrdersTab::Show(void){
   tab_title.Show();
   getCurrencies();
   createButtons();
   for(int i=0;i<ArraySize(buttons);i++) buttons[i].Show();
}

bool OrdersTab::CreateTab(void){
   const int title_y1=HEADER_HEIGHT+10;
   const int title_y2=title_y1+20;
   title_height=title_y2;
   tab_title.Create(0,LEDIA_NAME_PREFIX+"Orders_Tab_Title",0, 5,title_y1,200,title_y2);
   tab_title.Text("Open Positions / Select Pair: "+active_symbol);
   tab_title.Color(clrWhite);
   tab_title.Hide();
   LediaGUI.Add(tab_title);
   trades_count=OrdersTotal();
   close_all.Create(0,LEDIA_NAME_PREFIX+"OrdersCloseAll",0,5,LEDIA_CLIENT_HEIGHT-60,(LEDIA_CLIENT_WIDTH/2)-TABS_SPACE,LEDIA_CLIENT_HEIGHT-30);
   close_all.Text("Close ALL");
   close_all.Hide();
   LediaGUI.Add(close_all);
   close_selected.Create(0,LEDIA_NAME_PREFIX+"OrdersCloseSelected",0,LEDIA_CLIENT_WIDTH/2,LEDIA_CLIENT_HEIGHT-60,LEDIA_CLIENT_WIDTH-TABS_SPACE,LEDIA_CLIENT_HEIGHT-30);
   close_selected.Text("Close Selected");
   close_selected.Hide();
   LediaGUI.Add(close_selected);
   //orders_list.Create(0,LEDIA_NAME_PREFIX+"OrdersList",0,5,button_heights+10,LEDIA_CLIENT_WIDTH-TABS_SPACE,LEDIA_CLIENT_HEIGHT-150);
   //orders_list.Hide();
   //LediaGUI.Add(orders_list);
   return(true);
}

void OrdersTab::createButtons(void){
   resetButtons();
   int x_axis=20;
   int row=0;
   int rowspaace=35;
   int maxw=LEDIA_CLIENT_WIDTH-TABS_SPACE;
   for(int i=0;i<orders.Total();i++){
      int x1=x_axis+5;
      int x2=x1+(i+1)*40;
      if(x2>maxw){
         //--- next row
         x_axis=0;
         row++;
         x1=x_axis+5;
         x2=x1+(i+1)*40;
      }
      if (i==0) x2+=60;
      int y1=title_height+20+(rowspaace*row);
      int y2=y1+20;
      buttons[i].Create(0,LEDIA_NAME_PREFIX+"LOrders_"+orders[i],0,x1,y1,x2, y2);
      buttons[i].Hide();
      buttons[i].Text(orders[i]+"("+IntegerToString(orders_count[i])+")");
      LediaGUI.Add(buttons[i]);
      x_axis=x2;
      button_heights=y2;
   }
}

void OrdersTab::getCurrencies(void){
   orders.Shutdown();
   orders_count.Shutdown();
   bool found=false;
   for(int i=0;i<OrdersTotal();i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true){
         if(OrderSymbol()==active_symbol) found=true;
         int index=orders.Search(OrderSymbol());
         if(index<0) {
            orders.Add(OrderSymbol());
            orders.Sort(0);
            orders_count.Add(1);
         }
         else {
            orders_count.Update(index, orders_count.At(index)+1);
         }
      }
   }
   if (active_symbol!=NULL && !found){
      active_symbol=NULL;
      orders_list.Hide();
   }
}

void OrdersTab::onCurrencyClick(const string c){
   active_symbol=c;
   orders_list.ItemsClear();
   orders_list.Destroy();
   close_all.Show();
   close_selected.Show();
   orders_list.Create(0,LEDIA_NAME_PREFIX+"OrdersList",0,5,button_heights+10,LEDIA_CLIENT_WIDTH-TABS_SPACE,LEDIA_CLIENT_HEIGHT-70);
   LediaGUI.Add(orders_list);
   orders_list.Show();
   
   tab_title.Text("Open Positions / Selected Pair: "+active_symbol);
   for(int i=0;i<OrdersTotal();i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true){
         if (OrderSymbol()==active_symbol){
            orders_list.AddItem(OrderSymbol()+" ["+GetOrderType(OrderType())+"] "+DoubleToString(OrderLots(), 2)+" / Entry: "+DoubleToString(OrderOpenPrice(), Digits)+" / Time: "+DoubleToString(OrderOpenPrice(), Digits),0);        
         }
      }
   }
}

void OrdersTab::onCloseSelected(void){
   int x=orders_list.Current();
   Print("close selecteD",x);
   if(x>=0){
      int counter=0;
      for(int i=0;i<OrdersTotal();i++){
         if(OrderSelect(i,SELECT_BY_POS) == true){
            if (OrderSymbol()==active_symbol){
               if(counter==x){
                  Print("Close THIS");
               }
               counter++;
            }
         }
      }
   }
}

void OrdersTab::onCloseAll(void){
Print("HOLLLLLLL");
   RefreshRates();
   Print("Let Delete All");
   for(int i=0;i<OrdersTotal();i++){
      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES) == true){
      Print("Order Selected");
         if (OrderSymbol()==active_symbol){
            Print("EVENT");
            //Bid and Ask Price for the Instrument of the order
            double BidPrice=MarketInfo(OrderSymbol(),MODE_BID);
            double AskPrice=MarketInfo(OrderSymbol(),MODE_ASK);
            //---
            //status
            bool res=false;
            //Closing the order using the correct price depending on the type of order
            if(OrderType()==OP_BUY){
               Print("But");
               res=OrderClose(OrderTicket(),OrderLots(),BidPrice,3);
               Print("RESULT",res);
            }
            if(OrderType()==OP_SELL){
               Print("SHOLAND");
               res=OrderClose(OrderTicket(),OrderLots(),AskPrice,3);
            }
            if(res) orders_list.ItemDelete(i);
         }
      }
   }
   Show();
}

string OrdersTab::GetOrderType(const int t){
   switch(t){
      case OP_BUY: return("BUY");
      case OP_SELL: return("SELL");
      case OP_BUYLIMIT: return("BUT LIMIT");
      case OP_BUYSTOP: return("BUY STOP");
      case OP_SELLLIMIT: return("SELL LIMIT");
      case OP_SELLSTOP: return("SELL STOP");
      default: return("ERR");
   }
}

bool OrdersTab::checkOrders(void){
   if (trades_count!=OrdersTotal()){
      trades_count=OrdersTotal();
      return(true);
   }
   return(false);
}

void OrdersTab::rebuild(void){
   Show();
}

void OrdersTab::resetButtons(void){
   for(int i=0;i<ArraySize(buttons);i++) {
      buttons[i].Destroy();
  //    LediaGUI.Delete(buttons[i]);
   }
   ArrayResize(buttons,orders_count.Total());
}