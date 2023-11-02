#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Navy

input int Len = 14;
input int TH = 20;

double DIPlus[];
double DIMinus[];  
double ADX[];

double TrueRange;
double DirectionalMovementPlus;
double DirectionalMovementMinus;
double SmoothedTrueRange;
double SmoothedDirectionalMovementPlus;
double SmoothedDirectionalMovementMinus;

int init() {
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, DIPlus);
   SetIndexLabel(0, "DI+");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, DIMinus);
   SetIndexLabel(1, "DI-");
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, ADX);
   SetIndexLabel(2, "ADX");
   
   return(0);
}

int start() {
   TrueRange = MathMax(MathMax(High[0]-Low[0], MathAbs(High[0]-Close[1])), MathAbs(Low[0]-Close[1]));
   DirectionalMovementPlus = High[0]-High[1] > Low[1]-Low[0] ? MathMax(High[0]-High[1], 0) : 0;
   DirectionalMovementMinus = Low[1]-Low[0] > High[0]-High[1] ? MathMax(Low[1]-Low[0], 0) : 0;
   
   SmoothedTrueRange = iSmooth(TrueRange, Len);
   SmoothedDirectionalMovementPlus = iSmooth(DirectionalMovementPlus, Len);
   SmoothedDirectionalMovementMinus = iSmooth(DirectionalMovementMinus, Len);
   
   DIPlus[0] = SmoothedDirectionalMovementPlus/SmoothedTrueRange*100;
   DIMinus[0] = SmoothedDirectionalMovementMinus/SmoothedTrueRange*100;
   DX = MathAbs(DIPlus[0]-DIMinus[0]) / (DIPlus[0]+DIMinus[0])*100;
   ADX[0] = iMAOnArray(DX, 0, Len, 0, MODE_SMA, 0);
   
   return(0);  
}

double iSmooth(double data, int period) {
   static double prev;
   double smooth = prev-(prev/period)+data;
   prev = smooth;
   return(smooth);
}