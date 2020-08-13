//+------------------------------------------------------------------+
//|                                             LediaEAAssistant.mq4 |
//|                                         Copyright 2020, LediaEA. |
//|                                          https://www.lediaea.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, LediaEA."
#property link      "https://www.lediaea.com"
#property version   "1.0"
#property description "Smart trading assistant | LediaEA. Empower your trading."
#include <Controls\Button.mqh>
#include <Controls\Picture.mqh>
#include <Controls\Label.mqh>
#resource "Assest\\lediaea.bmp"
#resource "Assest\\lediaea_white.bmp"

//+------------------------------------------------------------------+
//| Class LediaEAGUI                                                 |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+

class LediaEAGUI : public LediaEAPanel
  {
public:
                     LediaEAGUI(void);
                    ~LediaEAGUI(void);
   //--- create
   virtual bool      CreateLedia(void);
   void ResetComment(void);
   void ShiftVisual(void);
   void ScaleChange(void);
   bool IsCustomPrice(void);
   void GetTradeInfo(double &arr[], string &comment);
   void dragLevels(const double price, const string target);
   //--- chart event handler
   //--- chart events processing
   
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   int active_tab;
   // buttons
   CButton toggle_button; //toggle button
   CButton assistant_tab;
   CButton orders_tab;
   CPicture logo;
   CLabel warn;

private:
   void OnClickToggle(void);
   void CreateLogo(const int x1, const int x2, const int y1, const int y2);
   void ChangeTabA(void);
   void ChangeTabO(void);
   void createTabs(void);
  };
  
//+------------------------------------------------------------------+
//| Event handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(LediaEAGUI)
   ON_EVENT(ON_CLICK,toggle_button,OnClickToggle);
   ON_EVENT(ON_CLICK, assistant_tab, ChangeTabA);
   ON_EVENT(ON_CLICK, orders_tab, ChangeTabO);
   //--- orders tab
   ON_EVENT(ON_CLICK,Tabs_Orders.close_selected,Tabs_Orders.onCloseSelected);
   ON_EVENT(ON_CLICK,Tabs_Orders.close_all,Tabs_Orders.onCloseAll);
   //--- assistant tab events
   ON_EVENT(ON_CHANGE, Tabs_Assistant.custom_price, Tabs_Assistant.onCustomPriceChange);
   ON_EVENT(ON_CHANGE, Tabs_Assistant.use_balance, Tabs_Assistant.onUseBalanceChange);
   ON_EVENT(ON_CHANGE, Tabs_Assistant.use_equity, Tabs_Assistant.onUseBalanceChange);
   ON_EVENT(ON_END_EDIT, Tabs_Assistant.radio_group, Tabs_Assistant.CalculateRisk);
   ON_EVENT(ON_END_EDIT, Tabs_Assistant.risk_percent_input, Tabs_Assistant.CalculateRisk);
   ON_EVENT(ON_END_EDIT, Tabs_Assistant.risk_fixed_input, Tabs_Assistant.CalculateRisk);
   ON_EVENT(ON_END_EDIT, Tabs_Assistant.risk_ratio, Tabs_Assistant.RiskRewardRatioEdit);
   ON_EVENT(ON_END_EDIT, Tabs_Assistant.stop_loss, Tabs_Assistant.SetStopLossPosition);
   ON_EVENT(ON_END_EDIT, Tabs_Assistant.take_profit, Tabs_Assistant.SetTakeProfitPosition);
   ON_EVENT(ON_CLICK, Tabs_Assistant.execute, Tabs_Assistant.onExecuteTrade);
EVENT_MAP_END(LediaEAPanel)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
LediaEAGUI::LediaEAGUI(void)
  {
   this.active_tab=0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
LediaEAGUI::~LediaEAGUI(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool LediaEAGUI::CreateLedia(void)
  {
   //--- logo
      const int LOGO_X1=LEDIA_CLIENT_WIDTH / 2 - 75;
      const int LOGO_X2=100;
      const int LOGO_Y1=7;
      const int LOGO_Y2=42;
      //--- toggle spaces
      const int TOGGLE_X1=20;
      const int TOGGLE_X2=LEDIA_CLIENT_WIDTH - 20;
      const int TOGGLE_Y1=LOGO_Y2 + VERTICAL_SPACE_SMALL;
      const int TOGGLE_Y2=TOGGLE_Y1 + TOGGLE_BUTTON_HEIGHT;
      
      if(!CreatePanel(0,"LediaEA Assistant",1,40,40,LEDIA_WIDTH+40,LEDIA_HEIGHT+40))
         return(false);
         
       //--- create orders tab
      Tabs_Orders=new OrdersTab();
      Tabs_Orders.CreateTab();
      //--- create assistant tab
      Tabs_Assistant=new LediaEAAssistantTab();
      if(!Tabs_Assistant.CreateTab(TOGGLE_Y2)) return(false);
      CreateLogo(LOGO_X1, LOGO_X2,LOGO_Y1,LOGO_Y2);
     //--- create toggle button
      if(!createButton(toggle_button, LEDIA_NAME_PREFIX+"toggle", TOGGLE_X1, TOGGLE_Y1, TOGGLE_X2, TOGGLE_Y2, "Disable", "Courier New", 13, clrSeashell, C'164,30,38', C'129,21,32'))
         return (false);
      createTabs();
      Run();
//--- succeed
   return(true);
  }
  
//+------------------------------------------------------------------+
//| ON Toggle click                                                  |
//+------------------------------------------------------------------+
 void LediaEAGUI::OnClickToggle() {
   if(LEDIAEA_ENABLED){
      LEDIAEA_ENABLED=false;
      toggle_button.Text("Enable");
      toggle_button.Color(clrDarkGreen);
      toggle_button.ColorBackground(C'63,167,35');
      toggle_button.ColorBorder(C'53,148,28');
      assistant_tab.Hide();
      orders_tab.Hide();
      //--- hide tabs
      Tabs_Assistant.Hide();
   }
   else {
      LEDIAEA_ENABLED=true;
      toggle_button.Text("Disable");
      toggle_button.Color(clrSeashell);
      toggle_button.ColorBackground(C'164,30,38');
      toggle_button.ColorBorder(C'129,21,32');
      assistant_tab.Show();
      orders_tab.Show();
      //---  show active tab
      if (active_tab==0) Tabs_Assistant.Show();
   }
 }
//+------------------------------------------------------------------+
//| CreateLogo                                                       |
//+------------------------------------------------------------------+
void LediaEAGUI::CreateLogo(const int x1,const int x2, const int y1, const int y2){
   logo.Create(0, LEDIA_NAME_PREFIX+"logo", 0, x1, y1, x2, y2);
   logo.BmpName(DARK_MODE ? "::Assest\\lediaea.bmp" : "::Assest\\lediaea_white.bmp");
   logo.Alignment(WND_ALIGN_CLIENT,0,0,30,0);
   Add(logo);
}
//+------------------------------------------------------------------+
//| createTabs                                                       |
//+------------------------------------------------------------------+
void LediaEAGUI::createTabs(void){
   assistant_tab.Create(0, LEDIA_NAME_PREFIX+"tabs_assistant", 0, LEDIA_CLIENT_WIDTH-TAB_WIDTH, HEADER_HEIGHT, LEDIA_CLIENT_WIDTH+2, HEADER_HEIGHT+60);
   assistant_tab.Text("A");
   assistant_tab.ColorBackground(DARK_MODE ? C'40,40,40' : C'245,245,245');
   assistant_tab.ColorBorder(DARK_MODE ? clrBlack : C'164,30,38');
   assistant_tab.Color(DARK_MODE ? clrWhite : clrBlack);
   assistant_tab.FontSize(12);
   Add(assistant_tab);
   //orders_tab.Create(0, LEDIA_NAME_PREFIX+"tabs_orders", 0, LEDIA_CLIENT_WIDTH-TAB_WIDTH, HEADER_HEIGHT+65, LEDIA_CLIENT_WIDTH+2, HEADER_HEIGHT+125);
   //orders_tab.Text("O");
   //orders_tab.FontSize(8);
   //orders_tab.ColorBackground(C'164,30,38');
   //orders_tab.ColorBorder(DARK_MODE ? clrBlack : C'164,30,38');
   //orders_tab.Disable();
   //orders_tab.Deactivate();
   //Add(orders_tab);
}
//+------------------------------------------------------------------+
//| OnClick on tab Assistant                                         |
//+------------------------------------------------------------------+
void LediaEAGUI::ChangeTabA(void){
   Tabs_Assistant.Show();
   Tabs_Orders.Hide();
   active_tab=0;
   
   assistant_tab.ColorBackground(DARK_MODE ? C'40,40,40' : clrWhite);
   assistant_tab.ColorBorder(DARK_MODE ? clrBlack : C'164,30,38');
   assistant_tab.Color(DARK_MODE ? clrWhite : clrBlack);


   orders_tab.ColorBackground(C'164,30,38');
   orders_tab.ColorBorder(clrBlack);
}
//+------------------------------------------------------------------+
//| OnClick on tab Orders                                            |
//+------------------------------------------------------------------+
void LediaEAGUI::ChangeTabO(void){
   Tabs_Assistant.Hide();
   active_tab=1;
   
   orders_tab.ColorBackground(DARK_MODE ? C'40,40,40' : clrWhite);
   orders_tab.ColorBorder(DARK_MODE ? clrBlack : C'164,30,38');
   orders_tab.Color(DARK_MODE ? clrWhite : clrBlack);


   assistant_tab.ColorBackground(C'164,30,38');
   assistant_tab.ColorBorder(clrBlack);
   
   Tabs_Orders.Show();
}

void LediaEAGUI::ShiftVisual(void){
   Tabs_Assistant.ScaleChange();
}

void LediaEAGUI::dragLevels(const double price, const string target){
   Tabs_Assistant.Drag(price, target);
}

void LediaEAGUI::ScaleChange(void){
   Tabs_Assistant.ScaleChange();
}

void LediaEAGUI::GetTradeInfo(double &arr[], string &comment){
   ArrayResize(arr,4);
   ArrayFill(arr,0,1,StringToDouble(Tabs_Assistant.volume_value.Text()));
   ArrayFill(arr,1,1,StringToDouble(Tabs_Assistant.entry.Text()));
   ArrayFill(arr,2,1,StringToDouble(Tabs_Assistant.stop_loss.Text()));
   ArrayFill(arr,3,1,StringToDouble(Tabs_Assistant.take_profit.Text()));
   comment=Tabs_Assistant.trade_comment.Text();
}

void LediaEAGUI::ResetComment(void){
   Tabs_Assistant.trade_comment.Text("Trade Comment");
}

bool LediaEAGUI::IsCustomPrice(void){
   return(Tabs_Assistant.custom_price_selected);
}