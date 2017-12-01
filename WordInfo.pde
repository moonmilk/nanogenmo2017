class WordInfo {
  String text;
  int from, to; // char index into line
  
  int x,y,w,h;
  
  LineInfo line;
  
  Vector<CharInfo> chars = new Vector<CharInfo>();
  
  WordInfo(LineInfo li) {
    line = li;
  }
  
  void finish(int l, int r, int t, int b, int _from, int _to, String _text) {
    x = line.page.ocrToImgX(l);
    y = line.page.ocrToImgY(t);
    w = line.page.ocrToImgX(r)-x;
    h = line.page.ocrToImgY(b)-y;
    from = _from;
    to = _to;
    text = _text;
    line.page.addWord(this);
  }
  
}