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
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include "CheckBox.mqh"
#include "RadioGroup.mqh"

//+------------------------------------------------------------------+
//| Class LediaEAAssistantTab                                               |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+

class LediaEAAssistantTab
  {
public:
                     LediaEAAssistantTab(void);
                    ~LediaEAAssistantTab(void);
   //--- create
   virtual bool      CreateTab(const int TOGGLE_Y2);
   void CustomPriceChange(void);
   bool CreateLines(void);
   void ScaleChange(void);
   void Drag(const double price, const string target);
   void ReArrangeTP(void);
   //--- chart event handler
   
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   void LediaMoveLine(const string line, const double current_p, bool tp);
   void SetStopLossPosition(void);
   void setCurrentPrice(double p);
   void onExecuteTrade(void);
   void SetTakeProfitPosition(void);
   void CalculateRisk(void);
   void Hide(void);
   void Show(void);
   void CreateBottomLabels(void);
   bool CreateTradeComment(void);
   void LediaLineCreator(const string name, const datetime current_t, const double current_p, const color bxclr, const color txtclr, const color lnclr);
   CEdit   stop_loss;
   CButton execute;
   CEdit   take_profit;
   CEdit   trade_comment;
   CEdit   entry;
   CEdit   risk_ratio;
   CLabel  stop_loss_pips;
   CLabel  take_profit_pips;
   CLabel  stop_loss_pips_label;
   CLabel  take_profit_pips_label;
   CLabel  stop_loss_label;
   CLabel  take_profit_label;
   CLabel  entry_label;
   CLabel  risk_management;
   CEdit   risk_percent_input;
   CEdit   risk_fixed_input;
   CLabel  percent_sign;
   CLabel  RRR;
   CLabel  currency_sign;
   CCheckBox custom_price;
   CCheckBox use_balance;
   CCheckBox use_equity;
   CRadioGroup radio_group;
   CLabel volume_input;
   CLabel volume_value;
   bool risk_from_balance;
   bool custom_price_selected;
   
   double risk_reward_ratio;
   bool CreateCustomCheck(const int y1, const int y2);
   void onCustomPriceChange(void);
   bool CreateRiskInputs(const int y1);
   void onUseBalanceChange(void);
   void CreateExecuteButton(void);
   bool CreateRadioGroup(const int TP_INPUT_Y2);
   void createVolumeInput(void);
   void CreateRiskRewardRatio(const int y, const int x, const int x2);
   void RiskRewardRatioEdit(void);
  };
  
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
LediaEAAssistantTab::LediaEAAssistantTab()
  {
   this.custom_price_selected=false;
   this.risk_from_balance=true;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
LediaEAAssistantTab::~LediaEAAssistantTab(void)
  {
      DeleteObj(0,LEDIA_NAME_PREFIX+"take_profit_rec");
      DeleteObj(0,LEDIA_NAME_PREFIX+"take_profit_price");
      DeleteObj(0,LEDIA_NAME_PREFIX+"take_profit_line");
      DeleteObj(0,LEDIA_NAME_PREFIX+"stop_loss_rec");
      DeleteObj(0,LEDIA_NAME_PREFIX+"stop_loss_price");
      DeleteObj(0,LEDIA_NAME_PREFIX+"stop_loss_line");
      DeleteObj(0,LEDIA_NAME_PREFIX+"custom_entry_rec");
      DeleteObj(0,LEDIA_NAME_PREFIX+"custom_entry_price");
      DeleteObj(0,LEDIA_NAME_PREFIX+"custom_entry_line");
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool LediaEAAssistantTab::CreateTab(const int TOGGLE_Y2)
  {
   //--- entry label
      const int ENTRY_LABEL_X1=(LEDIA_CLIENT_WIDTH / 2) - 80 - TABS_SPACE;;
      const int ENTRY_LABEL_Y1=TOGGLE_Y2 + VERTICAL_SPACE+3;
      const int ENTRY_LABEL_X2=LEDIA_CLIENT_WIDTH-5;
      const int ENTRY_LABEL_Y2=ENTRY_LABEL_Y1 + INPUT_HEIGHT;;
      //--- entry input
      const int ENTRY_INPUT_X1=(LEDIA_CLIENT_WIDTH / 2) - 50 - TABS_SPACE;
      const int ENTRY_INPUT_Y1=TOGGLE_Y2 + VERTICAL_SPACE;
      const int ENTRY_INPUT_X2=LEDIA_CLIENT_WIDTH - 100 - TABS_SPACE;
      const int ENTRY_INPUT_Y2=ENTRY_LABEL_Y1 + INPUT_HEIGHT;;
      //--- stop loss label
      const int SL_LABEL_X1=5;
      const int SL_LABEL_X2=(LEDIA_CLIENT_WIDTH / 2)-5-HALF_TABS_SPACE;
      const int SL_LABEL_Y1=ENTRY_INPUT_Y2 + VERTICAL_SPACE;
      const int SL_LABEL_Y2=SL_LABEL_Y1 + 10;
      //--- take profit label
      const int TP_LABEL_X1=SL_LABEL_X2+5;
      const int TP_LABEL_Y1=ENTRY_INPUT_Y2 + VERTICAL_SPACE;
      const int TP_LABEL_X2=LEDIA_CLIENT_WIDTH - HALF_TABS_SPACE - 5;
      const int TP_LABEL_Y2=SL_LABEL_Y1 + 10;
      //--- stop loss input
      const int SL_INPUT_X1=SL_LABEL_X1;
      const int SL_INPUT_X2=(LEDIA_CLIENT_WIDTH / 2)-5-HALF_TABS_SPACE;
      const int SL_INPUT_Y1=SL_LABEL_Y2 + VERTICAL_SPACE_SMALL;
      const int SL_INPUT_Y2=SL_INPUT_Y1 + INPUT_HEIGHT;
      //--- take profit input
      const int TP_INPUT_X1=SL_INPUT_X2+5;
      const int TP_INPUT_Y1=SL_INPUT_Y1;
      const int TP_INPUT_X2=LEDIA_CLIENT_WIDTH-5-TABS_SPACE;
      const int TP_INPUT_Y2=SL_INPUT_Y2;
      
      //--- createa labels
     if(!LediaGUI.createLabel(stop_loss_label, "Stop loss", LEDIA_NAME_PREFIX+"stop_loss_label", 8, SL_LABEL_X1, SL_LABEL_Y1, SL_LABEL_X2, SL_LABEL_Y2, clrLightCoral))
      return(false);
     if(!LediaGUI.createLabel(take_profit_label, "Take Profit", LEDIA_NAME_PREFIX+"take_profit_label", 8, TP_LABEL_X1, TP_LABEL_Y1, TP_LABEL_X2, TP_LABEL_Y2, DARK_MODE ? clrLightGreen : clrGreen))
      return(false);
     if(!LediaGUI.createLabel(entry_label, "Entry:", LEDIA_NAME_PREFIX+"entry_label", 8, ENTRY_LABEL_X1, ENTRY_LABEL_Y1, ENTRY_LABEL_X2, ENTRY_LABEL_Y2, DARK_MODE ? clrWhite : clrBlack))
      return(false);
     if(!LediaGUI.createInput(entry, LEDIA_NAME_PREFIX+"entry_input", ENTRY_INPUT_X1,ENTRY_INPUT_Y1,ENTRY_INPUT_X2,ENTRY_INPUT_Y2, clrBlack, clrDarkGray, clrSlateGray))
      return(false);
     entry.ReadOnly(true);
     entry.Text(DoubleToString(NormalizeDouble(Ask, Digits)));
      //--- create stoploss input
     if(!LediaGUI.createInput(stop_loss, LEDIA_NAME_PREFIX+"stop_loss_input", SL_INPUT_X1, SL_INPUT_Y1,SL_INPUT_X2, SL_INPUT_Y2, clrFireBrick, clrMistyRose, clrLightPink))
      return(false);
     if(!CreateCustomCheck(ENTRY_INPUT_Y1, ENTRY_INPUT_Y2))
      return(false);
     if(!LediaGUI.createInput(take_profit, LEDIA_NAME_PREFIX+"take_profit_input", TP_INPUT_X1,TP_INPUT_Y1 ,TP_INPUT_X2,TP_INPUT_Y2 , clrGreen, clrHoneydew, clrLightGreen))
      return(false);
     if(!CreateRiskInputs(TP_INPUT_Y2))
      return(false);
     if(!CreateRadioGroup(TP_INPUT_Y2))
      return(false);
     if(!CreateTradeComment()) return(false);
     createVolumeInput();
     CreateExecuteButton();
     CreateBottomLabels();
     if(!CreateLines()) return(false);
//--- succeed
   return(true);
}
  
void LediaEAAssistantTab::setCurrentPrice(double p) {
   entry.Text(DoubleToString(p, Digits));
   CalculateRisk();
}

bool LediaEAAssistantTab::CreateCustomCheck(const int y1, const int y2) {
   custom_price.Create(0, LEDIA_NAME_PREFIX+"custom_price_check",0,(LEDIA_CLIENT_WIDTH/2) + 50,y1+2, LEDIA_CLIENT_WIDTH - TABS_SPACE, y2);
   custom_price.Text("Custom price");
   custom_price.Color(DARK_MODE ? clrWhite : clrBlack);
   custom_price.ColorBackground(DARK_MODE ? C'40,40,40' : C'245,245,245');
   custom_price.ColorBorder(DARK_MODE ? C'40,40,40' : C'245,245,245');
   custom_price.FontSize(7);
   LediaGUI.Add(custom_price);
   return(true);
}

void LediaEAAssistantTab::CreateBottomLabels(void){
   stop_loss_pips_label.Create(0, LEDIA_NAME_PREFIX+"stop_loss_bottom_label",0,5,345, 45, 350);
   stop_loss_pips_label.Text("SL Pips:");
   stop_loss_pips_label.Color(DARK_MODE ? clrWhite : clrBlack);
   stop_loss_pips_label.ColorBackground(DARK_MODE ? C'40,40,40' : C'245,245,245');
   stop_loss_pips_label.ColorBorder(DARK_MODE ? C'40,40,40' : C'245,245,245');
   stop_loss_pips_label.FontSize(8);
   
   take_profit_pips_label.Create(0, LEDIA_NAME_PREFIX+"take_profit_bottom_label",0,100,345, 145, 350);
   take_profit_pips_label.Text("TP Pips:");
   take_profit_pips_label.Color(DARK_MODE ? clrWhite : clrBlack);
   take_profit_pips_label.ColorBackground(DARK_MODE ? C'40,40,40' : C'245,245,245');
   take_profit_pips_label.ColorBorder(DARK_MODE ? C'40,40,40' : C'245,245,245');
   take_profit_pips_label.FontSize(8);
   
   take_profit_pips.Create(0, LEDIA_NAME_PREFIX+"take_profit_bottom_pips",0,145,345, 186, 350);
   take_profit_pips.Text("730");
   take_profit_pips.Color(DARK_MODE ? clrWhite : clrBlack);
   take_profit_pips.ColorBackground(DARK_MODE ? C'40,40,40' : C'245,245,245');
   take_profit_pips.ColorBorder(DARK_MODE ? C'40,40,40' : C'245,245,245');
   take_profit_pips.FontSize(8);
   
   stop_loss_pips.Create(0, LEDIA_NAME_PREFIX+"stop_loss_bottom_pips",0,50,345, 86, 350);
   stop_loss_pips.Text("330");
   stop_loss_pips.Color(DARK_MODE ? clrWhite : clrBlack);
   stop_loss_pips.ColorBackground(DARK_MODE ? C'40,40,40' : C'245,245,245');
   stop_loss_pips.ColorBorder(DARK_MODE ? C'40,40,40' : C'245,245,245');
   stop_loss_pips.FontSize(8);
   
   LediaGUI.Add(stop_loss_pips_label);
   LediaGUI.Add(stop_loss_pips);
   LediaGUI.Add(take_profit_pips_label);
   LediaGUI.Add(take_profit_pips);
}

void LediaEAAssistantTab::onCustomPriceChange() {
   custom_price_selected=!custom_price_selected;
   custom_price.Checked(custom_price_selected);
   if (custom_price_selected){
      entry.ReadOnly(false);
      LediaLineCreator(LEDIA_NAME_PREFIX+"custom_entry",Time[40],StringToDouble(entry.Text()),ENTRY_BOX_COLOR,ENTRY_TEXT_COLOR,ENTRY_LINE_COLOR);
   }
   else {
      entry.ReadOnly(true);
      DeleteObj(0,LEDIA_NAME_PREFIX+"custom_entry_line");
      DeleteObj(0,LEDIA_NAME_PREFIX+"custom_entry_rec");
      DeleteObj(0,LEDIA_NAME_PREFIX+"custom_entry_text");
   }
}

bool LediaEAAssistantTab::CreateRadioGroup(const int TP_INPUT_Y2) {
   const int X1=5;
   const int Y1=TP_INPUT_Y2+VERTICAL_SPACE;
   const int X2=(LEDIA_CLIENT_WIDTH/2)-HALF_TABS_SPACE;
   const int Y2=Y1+15;
   LediaGUI.createLabel(risk_management, "Risk Management:", LEDIA_NAME_PREFIX+"risk_management", 11, X1, Y1, X2, Y2, clrLightCoral);
   radio_group.Create(0, LEDIA_NAME_PREFIX+"risk_group", 0, 5, Y2+VERTICAL_SPACE_SMALL, (LEDIA_CLIENT_WIDTH / 2)-HALF_TABS_SPACE-5, Y2+VERTICAL_SPACE_SMALL+40);
   radio_group.AddItem("Percent", 0);
   radio_group.AddItem("Fixed Amount ("+AccountCurrency()+")", 1);
   radio_group.ColorBackground(DARK_MODE ? C'40,40,40' : C'245,245,245');
   radio_group.ColorBorder(clrLightCoral);
   LediaGUI.Add(radio_group);
   radio_group.Value(0);
   return(true);
}

bool LediaEAAssistantTab::CreateRiskInputs(const int TP_INPUT_Y2) {
   const int y1=TP_INPUT_Y2+VERTICAL_SPACE+65;
   const int y2=y1+VERTICAL_SPACE+VERTICAL_SPACE;
   const int PERCENT_INPUT_X1=(LEDIA_CLIENT_WIDTH / 2)+HALF_TABS_SPACE;
   const int PERCENT_INPUT_X2=LEDIA_CLIENT_WIDTH - TABS_SPACE-5;
   const int PERCENT_INPUT_Y1=TP_INPUT_Y2+VERTICAL_SPACE+VERTICAL_SPACE_SMALL;
   const int PERCENT_INPUT_Y2=PERCENT_INPUT_Y1+INPUT_HEIGHT;
   
   const int FIXED_INPUT_X1=PERCENT_INPUT_X1;
   const int FIXED_INPUT_X2=PERCENT_INPUT_X2;
   const int FIXED_INPUT_Y1=PERCENT_INPUT_Y2+VERTICAL_SPACE_SMALL;
   const int FIXED_INPUT_Y2=FIXED_INPUT_Y1+INPUT_HEIGHT;
   
   LediaGUI.createLabel(percent_sign, "%", LEDIA_NAME_PREFIX+"risk_management_percent_sign_input", 10, PERCENT_INPUT_X1-20, PERCENT_INPUT_Y1+3, PERCENT_INPUT_X2, PERCENT_INPUT_Y2, clrLightCoral);
   LediaGUI.createInput(risk_percent_input, LEDIA_NAME_PREFIX+"risk_management_percent_input",PERCENT_INPUT_X1 , PERCENT_INPUT_Y1,PERCENT_INPUT_X2, PERCENT_INPUT_Y2, clrBlack, clrDarkGray, clrSlateGray, false);
   
   LediaGUI.createLabel(currency_sign, AccountCurrency(), LEDIA_NAME_PREFIX+"risk_management_currency_sign_input", 8, FIXED_INPUT_X1-25, FIXED_INPUT_Y1+3, FIXED_INPUT_X2, FIXED_INPUT_Y2, clrLightCoral);
   LediaGUI.createInput(risk_fixed_input, LEDIA_NAME_PREFIX+"risk_management_fixed_input", FIXED_INPUT_X1, FIXED_INPUT_Y1,FIXED_INPUT_X2, FIXED_INPUT_Y2, clrBlack, clrDarkGray, clrSlateGray, false);
   
   CreateRiskRewardRatio(FIXED_INPUT_Y2, FIXED_INPUT_X1, FIXED_INPUT_X2);
   
   risk_percent_input.Text("2");
   
   risk_fixed_input.Text(DoubleToString(AccountInfoDouble(risk_from_balance ? ACCOUNT_BALANCE : ACCOUNT_EQUITY) * 0.02, 3));
   
   use_balance.Create(0, LEDIA_NAME_PREFIX+"use_balance_check", 0,5,y1, 90, y2);
   use_balance.Text("Use balance");
   use_balance.Color(DARK_MODE ? clrWhite : clrBlack);
   use_balance.ColorBackground(DARK_MODE ? C'40,40,40' : C'245,245,245');
   use_balance.ColorBorder(DARK_MODE ? C'40,40,40' : C'245,245,245');
   use_balance.FontSize(7);
   
   use_balance.Checked(true);
   
   use_equity.Create(0, LEDIA_NAME_PREFIX+"use_equity_chech", 0,90,y1, (LEDIA_CLIENT_WIDTH / 2) - HALF_TABS_SPACE, y2);
   use_equity.Text("Use Equity");
   use_equity.Color(DARK_MODE ? clrWhite : clrBlack);
   use_equity.ColorBackground(DARK_MODE ? C'40,40,40' : C'245,245,245');
   use_equity.ColorBorder(DARK_MODE ? C'40,40,40' : C'245,245,245');
   use_equity.FontSize(7);
   
   LediaGUI.Add(use_equity);
   LediaGUI.Add(use_balance);
   return(true);
}

void LediaEAAssistantTab::onUseBalanceChange(void) {
   risk_from_balance=!risk_from_balance;
   use_balance.Checked(risk_from_balance);
   use_equity.Checked(!risk_from_balance);
   CalculateRisk();
}

void LediaEAAssistantTab::CalculateRisk(void){
   const double balance = risk_from_balance ? AccountInfoDouble(ACCOUNT_BALANCE) : AccountInfoDouble(ACCOUNT_EQUITY);
   if(radio_group.Value()==0) {
      // risk percentage
      const double totalRisk = balance * (StringToDouble(risk_percent_input.Text()) / 100);
      risk_fixed_input.Text(DoubleToString(NormalizeDouble(totalRisk, 3), 3));
   }
   else {
      // risk fixed
      const double totalRisk = StringToDouble(risk_fixed_input.Text()) / balance * 100;
      risk_percent_input.Text(DoubleToString(NormalizeDouble(totalRisk, 3),3));
   }
  
   // tick value from broker
   double tick_value=MarketInfo(Symbol(),MODE_TICKVALUE);
   //If the digits are 3 or 5 we normalize multiplying by 10
   if(Digits==3||Digits==5)tick_value=tick_value*10;
   //We apply the formula to calculate the position size and assign the value to the variable
   const double SLPips = MathAbs(NormalizeDouble(StringToDouble(stop_loss.Text())-StringToDouble(entry.Text()),Digits)/Point);
   const double TPPips = MathAbs(NormalizeDouble(StringToDouble(take_profit.Text())-StringToDouble(entry.Text()),Digits)/Point);
   // set calcs
   stop_loss_pips.Text(DoubleToString(SLPips, 0));
   take_profit_pips.Text(DoubleToString(TPPips, 0));
   
   if(SLPips>0 && tick_value >0){
      double LotSize=(balance*StringToDouble(risk_percent_input.Text())/100)/(SLPips*tick_value);
      LotSize=MathRound(LotSize/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP);
      volume_value.Text(DoubleToString(LotSize,2));
   }
   else {
      volume_value.Text("0.00");
   }
}

void LediaEAAssistantTab::createVolumeInput(void) {
   LediaGUI.createLabel(volume_input, "Volume:", LEDIA_NAME_PREFIX+"volume_input", 17, 90,245, 175, 265);
   LediaGUI.createLabel(volume_value, "0.00", LEDIA_NAME_PREFIX+"volume_value", 17, 175,245, 150, 265);
   volume_value.ColorBackground(clrLightCyan);
   volume_value.ColorBorder(clrForestGreen);
}

void LediaEAAssistantTab::CreateRiskRewardRatio(const int y, const int x, const int x2){
   const int y1=y+VERTICAL_SPACE_SMALL;
   const int y2=y1+INPUT_HEIGHT;
   LediaGUI.createLabel(RRR, "R/R 1:", LEDIA_NAME_PREFIX+"risk_reward_ratio_label", 8, x - 35, y1+3, x2, y2, clrRoyalBlue);
   LediaGUI.createInput(risk_ratio, LEDIA_NAME_PREFIX+"risk_reward_ratio_input", x, y1, x2, y2, clrRoyalBlue, clrAliceBlue, clrLightBlue);
   risk_ratio.Text("2");
}

void LediaEAAssistantTab::RiskRewardRatioEdit(void){
   risk_reward_ratio=StrToDouble(risk_ratio.Text());
   ReArrangeTP();
}
void LediaEAAssistantTab::CreateExecuteButton(void){
   LediaGUI.createButton(execute, LEDIA_NAME_PREFIX+"execute", 50, 310, LEDIA_CLIENT_WIDTH - 50, 340, "Execute", "Courier New", 15, clrMaroon, C'164,30,38', clrMaroon);
}

bool LediaEAAssistantTab::CreateTradeComment(void){
   if(!LediaGUI.createInput(trade_comment, LEDIA_NAME_PREFIX+"trade_comment_input", 50,280 ,LEDIA_CLIENT_WIDTH - 50,300))
      return(false);
   trade_comment.Text("Trade Comment");
   return(true);
}

void LediaEAAssistantTab::Hide(void){
   execute.Disable();
   execute.Deactivate();
   stop_loss.Hide();
   execute.Hide();
   take_profit.Hide();
   entry.Hide();
   risk_ratio.Hide();
   stop_loss_label.Hide();
   take_profit_label.Hide();
   entry_label.Hide();
   risk_management.Hide();
   risk_percent_input.Hide();
   risk_fixed_input.Hide();
   percent_sign.Hide();
   RRR.Hide();
   currency_sign.Hide();
   custom_price.Hide();
   use_balance.Hide();
   use_equity.Hide();
   radio_group.Hide();
   volume_input.Hide();
   volume_value.Hide();
   trade_comment.Hide();
   stop_loss_pips_label.Hide();
   stop_loss_pips.Hide();
   take_profit_pips.Hide();
   take_profit_pips_label.Hide();
   
   DeleteObj(0,LEDIA_NAME_PREFIX+"take_profit_rec");
   DeleteObj(0,LEDIA_NAME_PREFIX+"take_profit_price");
   DeleteObj(0,LEDIA_NAME_PREFIX+"take_profit_line");
   DeleteObj(0,LEDIA_NAME_PREFIX+"stop_loss_rec");
   DeleteObj(0,LEDIA_NAME_PREFIX+"stop_loss_price");
   DeleteObj(0,LEDIA_NAME_PREFIX+"stop_loss_line");
   DeleteObj(0,LEDIA_NAME_PREFIX+"custom_entry_rec");
   DeleteObj(0,LEDIA_NAME_PREFIX+"custom_entry_price");
   DeleteObj(0,LEDIA_NAME_PREFIX+"custom_entry_line");
}

void LediaEAAssistantTab::Show(void){
   stop_loss.Show();
   execute.Show();
   take_profit.Show();
   entry.Show();
   risk_ratio.Show();
   stop_loss_label.Show();
   take_profit_label.Show();
   entry_label.Show();
   risk_management.Show();
   risk_percent_input.Show();
   risk_fixed_input.Show();
   percent_sign.Show();
   RRR.Show();
   currency_sign.Show();
   custom_price.Show();
   use_balance.Show();
   use_equity.Show();
   radio_group.Show();
   volume_input.Show();
   volume_value.Show();
   take_profit_pips.Show();
   take_profit_pips_label.Show();
   stop_loss_pips.Show();
   stop_loss_pips_label.Show();
   trade_comment.Show();
   CreateLines();
   if(custom_price_selected) LediaLineCreator(LEDIA_NAME_PREFIX+"custom_entry",Time[40],StringToDouble(entry.Text()),ENTRY_BOX_COLOR,ENTRY_TEXT_COLOR,ENTRY_LINE_COLOR);
}

bool LediaEAAssistantTab::CreateLines(){
   const double current_tp = StringToDouble(take_profit.Text());
   const double current_sl = StringToDouble(stop_loss.Text());
   const double p_value = StringToDouble(risk_ratio.Text());

   const double sl_price = current_sl==0?SymbolInfoDouble(Symbol(),SYMBOL_BID)-300*Point:current_sl;
   const double tp_price = current_tp==0?SymbolInfoDouble(Symbol(),SYMBOL_BID)+(300 * p_value)*Point:current_tp;
   const datetime current_t =Time[40];
   // take profit related
   LediaLineCreator(LEDIA_NAME_PREFIX+"take_profit",current_t,tp_price,TAKE_PROFIT_BOX_COLOR,TAKE_PROFIT_TEXT_COLOR,TAKE_PROFIT_LINE_COLOR);
   //--- stop loss line creator
   LediaLineCreator(LEDIA_NAME_PREFIX+"stop_loss",current_t,sl_price,STOP_LOSS_BOX_COLOR,STOP_LOSS_TEXT_COLOR,STOP_LOSS_LINE_COLOR);
   stop_loss.Text(DoubleToString(sl_price, Digits));
   take_profit.Text(DoubleToString(tp_price, Digits));
   CalculateRisk();
   return(true);
}

void LediaEAAssistantTab::LediaLineCreator(const string name, const datetime current_t, const double current_p, const color bxclr, const color txtclr, const color lnclr){
   // line creator
   RectangleCreate(0,name+"_rec",0,current_t,current_p+10*Point,bxclr,STYLE_DASH,1,bxclr,false,false,true,1);
   TextCreate(0,name+"_price",0,current_t+2*PeriodSeconds(),current_p-20*Point,DoubleToString(current_p,5),"Arial",12,txtclr,0,0,false,false,true,2);
   HLineCreate(0,name+"_line",0,current_p,lnclr,STYLE_DASH,1,true,false,true,0);
}

void LediaEAAssistantTab::SetStopLossPosition(void){
   const double current_p=StringToDouble(stop_loss.Text());
   LediaMoveLine(LEDIA_NAME_PREFIX+"stop_loss", current_p);
   CalculateRisk();
}

void LediaEAAssistantTab::SetTakeProfitPosition(void){
   const double current_p=StringToDouble(take_profit.Text());
   LediaMoveLine(LEDIA_NAME_PREFIX+"take_profit", current_p, true);
   CalculateRisk();
}

void LediaEAAssistantTab::ScaleChange(void){
   if(LEDIAEA_ENABLED && LediaGUI.active_tab==0){
      DeleteObj(0,LEDIA_NAME_PREFIX+"take_profit_rec");
      DeleteObj(0,LEDIA_NAME_PREFIX+"take_profit_price");
      DeleteObj(0,LEDIA_NAME_PREFIX+"take_profit_line");
      DeleteObj(0,LEDIA_NAME_PREFIX+"stop_loss_rec");
      DeleteObj(0,LEDIA_NAME_PREFIX+"stop_loss_price");
      DeleteObj(0,LEDIA_NAME_PREFIX+"stop_loss_line");
      DeleteObj(0,LEDIA_NAME_PREFIX+"custom_entry_rec");
      DeleteObj(0,LEDIA_NAME_PREFIX+"custom_entry_price");
      DeleteObj(0,LEDIA_NAME_PREFIX+"custom_entry_line");
      CreateLines();
      if(custom_price_selected) LediaLineCreator(LEDIA_NAME_PREFIX+"custom_entry",Time[40],StringToDouble(entry.Text()),ENTRY_BOX_COLOR,ENTRY_TEXT_COLOR,ENTRY_LINE_COLOR);
   }
}

void LediaEAAssistantTab::LediaMoveLine(const string line="", const double current_p=0, bool tp=false){
   const datetime current_t=Time[40];
   // move line
   HLineMove(0,line+"_line",current_p);
   // move text
   TextMove(0, line+"_price", current_t+2*PeriodSeconds(),current_p-20*Point);
   // move rec
   RectLabelMove(0, line+"_rec", current_t,current_p+20*Point);
   
   if(tp){
      take_profit.Text(DoubleToString(current_p, 5));
      ObjectSetString(0, LEDIA_NAME_PREFIX+"take_profit_price",OBJPROP_TEXT,DoubleToString(current_p, 5));
   }
   else{
      stop_loss.Text(DoubleToString(current_p, 5));
      ObjectSetString(0, LEDIA_NAME_PREFIX+"stop_loss_price",OBJPROP_TEXT,DoubleToString(current_p, 5));
   }
   CalculateRisk();
}

void LediaEAAssistantTab::ReArrangeTP(void){
   const double price=StringToDouble(stop_loss.Text());
   const double entr=StringToDouble(entry.Text());
   const string position=price<entr?"S":"B";
   const double diff=MathAbs(NormalizeDouble(price-entr,Digits)/Point);
   const double dest=position=="S"?entr+(diff*StringToDouble(risk_ratio.Text())*Point):entr-(diff*StringToDouble(risk_ratio.Text())*Point);
   LediaMoveLine(LEDIA_NAME_PREFIX+"take_profit", dest, true);
}

void LediaEAAssistantTab::Drag(const double price, const string target){
   const bool tp=target==LEDIA_NAME_PREFIX+"take_profit_rec";
   const double entr=StringToDouble(entry.Text());
   if(tp){
      LediaMoveLine(LEDIA_NAME_PREFIX+"take_profit", price, true);
      const double slprice=StringToDouble(stop_loss.Text());
      const double diff=MathAbs(NormalizeDouble(slprice-entr,Digits)/Point);
      
      const double tpdiff=MathAbs(NormalizeDouble(price-entr,Digits)/Point);
      risk_ratio.Text(DoubleToString(NormalizeDouble(tpdiff/diff, 2),2));
   }
   else {
      if(target==LEDIA_NAME_PREFIX+"custom_entry_rec"){
         // drag entry
         //--- diff sl from current entry
         const double current_sl=StringToDouble(stop_loss.Text());
         const double diff=MathAbs(NormalizeDouble(current_sl-entr,Digits)/Point);
         const double newSL=price<current_sl?price+(diff*Point):price-(diff*Point);
         const double newTP=price<current_sl?price-(diff*StringToDouble(risk_ratio.Text())*Point):price+(diff*StringToDouble(risk_ratio.Text())*Point);
         
         LediaMoveLine(LEDIA_NAME_PREFIX+"custom_entry", price);
         LediaMoveLine(LEDIA_NAME_PREFIX+"stop_loss", newSL);
         LediaMoveLine(LEDIA_NAME_PREFIX+"take_profit", newTP, true);
         entry.Text(DoubleToString(price, Digits));
      }
      else {
         const string position=price<entr?"S":"B";
         const double diff=MathAbs(NormalizeDouble(price-entr,Digits)/Point);
         const double dest=position=="S"?entr+(diff*StringToDouble(risk_ratio.Text())*Point):entr-(diff*StringToDouble(risk_ratio.Text())*Point);
         LediaMoveLine(LEDIA_NAME_PREFIX+"take_profit", dest, true);
         LediaMoveLine(LEDIA_NAME_PREFIX+"stop_loss", price);
      }
   }
   CalculateRisk();

}

void LediaEAAssistantTab::onExecuteTrade(void){
   Print("ONEXECUTE");
   Ledia.ExecuteTrade();
}