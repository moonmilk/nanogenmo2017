class LineInfo {
  StringBuilder text = new StringBuilder();
  int from, to;
  
  PageInfo page;
  
  int x,y,w,h;
  int ocr_l, ocr_r, ocr_t, ocr_b;
  
  boolean header = false; // true if this line is probably part of a header line
  
  Vector<WordInfo> words = new Vector<WordInfo>();
  Vector<CharInfo> chars = new Vector<CharInfo>();
  
  LineInfo(PageInfo _pi) {
    page = _pi;
    //page.addLine(this);
  }
  
  void setBounds(int l, int r, int t, int b) {
    ocr_l = l;
    ocr_r = r;
    ocr_t = t;
    ocr_b = b;
    
    x = page.ocrToImgX(l);
    y = page.ocrToImgY(t);
    w = page.ocrToImgX(r)-x;
    h = page.ocrToImgY(b)-y;
  }
  
  void addChar(CharInfo ci) {
    chars.add(ci);
    text.append(ci.text);
    page.addChar(ci);
  }
  
  void doneAddingChars() {
    page.addLine(this);
  }
  
}