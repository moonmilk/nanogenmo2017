class CharInfo {
  String text;
  
  LineInfo line;
  WordInfo word;
  
  int x,y,w,h;
  int lineOffset;
  
  CharInfo(LineInfo _line, int _lineOffset, String _text) {
    line = _line;
    lineOffset = _lineOffset;
    text = _text;
    
    line.addChar(this);
  }
  
  void setBounds(int l, int r, int t, int b) {
    //ocr_l = l;
    //ocr_r = r;
    //ocr_t = t;
    //ocr_b = b;
    
    x = line.page.ocrToImgX(l);
    y = line.page.ocrToImgY(t);
    w = line.page.ocrToImgX(r)-x;
    h = line.page.ocrToImgY(b)-y;
  }
  
  void setWord(WordInfo wi) {
    word = wi;
  }
  
}