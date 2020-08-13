#include "Dialog.mqh"
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>

class LediaEAPanel : public CAppDialog {
public:
                     LediaEAPanel(void){};
                    ~LediaEAPanel(void){};
   //--- create
   virtual bool      CreatePanel(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   bool createInput(CEdit &inp, const string name, const int x, const int y, const int x2,const int y2, const color c1, const color c2, const color c3, const bool center);
   bool createLabel(CLabel &lab, string text,const string name,const int font_size,const int x,const int y,const int x2, const int y2,const color clr,const string font);
   bool createButton(CButton &btn, const string name,const int x,const int y,const int x1,const int y2, const string text,const string font,const int font_size,const color clr,const color back_clr,const color brdclr);

};
  
//+
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool LediaEAPanel::CreatePanel(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {     
      if(!Create(chart,name,subwin,x1,y1,x2,y2))
         return(false);
   //--- create background
      //---
      if (DARK_MODE) {
         //color border, color bg, color clientarea, color cborder, color cap, color capborder
         if(!setBackColor(clrBlack, clrBlack, C'160,160,160', C'40,40,40', clrBlack, clrBlack, clrBlack, C'40,40,40')) return(false);
      }
      else if(!setBackColor(C'164,30,38', C'164,30,38', clrSnow, C'245,245,245', C'164,30,38', C'164,30,38', C'164,30,38', C'164,30,38')) return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| createInput                                                      |
//+------------------------------------------------------------------+
  bool LediaEAPanel::createInput(
                      CEdit &inp,
                      const string name="LediaEA_Input",
                      const int x=0,
                      const int y=0,
                      const int x2=50,
                      const int y2=20,
                      const color             clr=clrBlack,             // text color
                      const color             bgclr=clrWhite,         // background color
                      const color              brdclr=clrGray,               // in the background
                      const bool center=true
                      )
  {
   if (!inp.Create(0, name, 0, x,y,x2,y2))
      return(false);
   if(!inp.Color(clr))
      return(false);
   if(!inp.ColorBackground(bgclr))
      return(false);
   if(!inp.ColorBorder(brdclr))
      return(false);
   if(center)
      if (!inp.TextAlign(ALIGN_CENTER))
         return(false);
   if (!Add(inp)) return(false);
   return(true);
  }
//+------------------------------------------------------------------+
//| createButton                                                      |
//+------------------------------------------------------------------+
  bool LediaEAPanel::createButton(
                      CButton &btn,
                      const string            name="LediaEA_Button",        // button name
                      const int               x=0,                      // X coordinate
                      const int               y=20,// Y coordinate
                      const int               x2=60,                 // button width
                      const int               y2=20,                // button height
                      const string            text="LediaEA",               // text
                      const string            font="Courier New",       // font
                      const int               font_size=10,             // font size
                      const color             clr=clrBlack,             // text color
                      const color             bgclr=clrGray,         // background color
                      const color              brdclr=clrGray               // in the background
                      )
  {
   btn.Create(0, name, 0, x, y, x2, y2);
   btn.Font(font);
   btn.FontSize(font_size);
   btn.Text(text);
   btn.Color(clr);
   btn.ColorBackground(bgclr);
   btn.ColorBorder(brdclr);
   if(!Add(btn)) return(false);;
   return(true);
  }
//+------------------------------------------------------------------+
//| createLabel                                                      |
//+------------------------------------------------------------------+
  bool LediaEAPanel::createLabel(
   CLabel &lab,
   string   text="",                       // text 
   const string   name="LediaEA Label",   // label name 
   const int   font_size=17,               // font size  
   const int   x=0,                        // X coordinate 
   const int   y=0,                        // Y coordinate
   const int   x2=0,                        // X coordinate 
   const int   y2=0,                        // Y coordinate
   const color clr=clrGold,                 // color 
   const string   font="Arial"  // font,
)
  {
   if (!lab.Create(0, name, 0, x,y,x2,y2))
      return(false);
   if(!lab.Font(font))
      return(false);
   if(!lab.FontSize(font_size))
      return(false);
   if(!lab.Color(clr))
      return(false);
   if(!lab.Text(text))
      return(false);
   if(!Add(lab)) return(false);
   return(true);
 }
