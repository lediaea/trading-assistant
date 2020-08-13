class LediaEAAssistant {
   public:
   string previous_mouse;
   bool moving;
   string moving_object;
  
   int init() {
      LediaGUI = new LediaEAGUI();
      previous_mouse="";
      moving=false;
      //--- create application dialog
      if(!LediaGUI.CreateLedia()) return(INIT_FAILED);
      return(INIT_SUCCEEDED);
   }
   
   void ExecuteTrade(void){
      Print("EXECCCC");
      double trade[];
      string comment;
      LediaGUI.GetTradeInfo(trade, comment);
      int OP=trade[1]>trade[2]?OP_BUY:OP_SELL;
      if(comment=="Trade Comment") comment=NULL;
      int ticket;
      if(LediaGUI.IsCustomPrice()){
         if(OP==OP_BUY){
            if(trade[1]<Ask) OP=OP_BUYLIMIT;
            else OP=OP_BUYSTOP;
         }
         else {
            if(trade[1]<Bid) OP=OP_SELLSTOP;
            else OP=OP_SELLLIMIT;
         }
      }
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
         Alert("Check if automated trading is allowed in the terminal settings!");
         return;
      }
      else 
        { 
         if(!MQLInfoInteger(MQL_TRADE_ALLOWED)){
            Alert("Automated trading is forbidden in the program settings for ",__FILE__); 
            return;
         }
        }
      if(trade[0]==0){
         Alert("You can take this risk on this position, you have to take higher risk");
         return;
      }
      ticket= OrderSend(Symbol(),OP,trade[0],trade[1],3,trade[2],trade[3],comment,LEDIA_ID,0,clrNONE);
      if (ticket<0){
         Alert("OrderSend failed with error #",GetLastError());
      }
      else {
         if(RESET_COMMENT_AFTER_TRADE) LediaGUI.ResetComment();
      }
   }
   
   void Destroy(const int reason) {
      //--- clear comments
      Comment("");
      // destroy panel
      LediaGUI.Destroy(reason);
      ObjectDelete(0, "tm");
   }
   
   bool IsNewBar(){
      static datetime lastbar;
      datetime curbar = (datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
      if(lastbar != curbar){
         lastbar = curbar;
         return true;
      }
      return false;
   }
   
   string MouseLeftButtonState(uint state) {
      string res;
      res+=(((state& 1)== 1)?"DN":"UP");   // mouse left
      return(res);
   }
   
   string ObjectZone(long lparam, double dparam) {
      long ChartX = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
      long ChartY = ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
      for( int i=ObjectsTotal(); i>=0; i-- ) {
         string name = ObjectName(i);
         long X_Start=0, X_Size=0, X_End=0, Y_Start=0, Y_Size=0, Y_End=0;
         if( ObjectType(name)!=OBJ_RECTANGLE_LABEL ) continue;
         X_Size = (int)ObjectGetInteger(0,name,OBJPROP_XSIZE);
         Y_Size = (int)ObjectGetInteger(0,name,OBJPROP_YSIZE);
         switch((int)ObjectGetInteger(0,name,OBJPROP_CORNER)) {
            case CORNER_LEFT_UPPER : { 
               X_Start = (long)ObjectGetInteger(0,name,OBJPROP_XDISTANCE);
               Y_Start = (long)ObjectGetInteger(0,name,OBJPROP_YDISTANCE);
               break;
            }
            case CORNER_RIGHT_UPPER : { 
               X_Start = ChartX-(long)ObjectGetInteger(0,name,OBJPROP_XDISTANCE);
               Y_Start = (long)ObjectGetInteger(0,name,OBJPROP_YDISTANCE);
               break;
            }
            case CORNER_LEFT_LOWER : { 
               X_Start = (long)ObjectGetInteger(0,name,OBJPROP_XDISTANCE);
               Y_Start = ChartY-(long)ObjectGetInteger(0,name,OBJPROP_YDISTANCE);
               break;
            }
            case CORNER_RIGHT_LOWER : { 
               X_Start = ChartX-(long)ObjectGetInteger(0,name,OBJPROP_XDISTANCE);
               Y_Start = ChartY-(long)ObjectGetInteger(0,name,OBJPROP_YDISTANCE);
               break;
            }
         }
         X_End   = X_Start + X_Size;
         Y_End   = Y_Start + Y_Size;
         if( lparam >= X_Start && lparam <= X_End && dparam >= Y_Start && dparam <= Y_End ) return(name);
      }
      return("");
   }
   
   void ChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam) {
      LediaGUI.ChartEvent(id,lparam,dparam,sparam);
      if (LEDIAEA_ENABLED){
         if(id==CHARTEVENT_MOUSE_MOVE) {
            if (previous_mouse !="" && previous_mouse != MouseLeftButtonState((uint)sparam)){
               const string obj=ObjectZone(lparam,dparam);
               if (obj== LEDIA_NAME_PREFIX+"custom_entry_rec" || obj==LEDIA_NAME_PREFIX+"take_profit_rec" || obj==LEDIA_NAME_PREFIX+"stop_loss_rec"){
                  if(MouseLeftButtonState((uint)sparam)=="DN"){
                     moving_object=obj;
                     moving=true;
                  }                  
               }
               if(moving && MouseLeftButtonState((uint)sparam)=="UP"){
                  moving=false;
                  moving_object="";
               }
            }
            if (moving){
               datetime t;
               double p;
               int sub;
               ChartXYToTimePrice(0,lparam,dparam,sub,t,p);
               LediaGUI.dragLevels(p, moving_object);
            }
            previous_mouse=MouseLeftButtonState((uint)sparam);
         }
         
         if(!moving && id==CHARTEVENT_CHART_CHANGE){
            LediaGUI.ScaleChange();
         }
         if(id==1000&&LediaGUI.active_tab==1&&StringFind(sparam,LEDIA_NAME_PREFIX+"LOrders_")>=0){
            Tabs_Orders.onCurrencyClick(StringSubstr(sparam,StringLen(LEDIA_NAME_PREFIX+"LOrders_")));
         }
      }
   }
};
