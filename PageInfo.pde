class PageInfo {
  String imageFilename;
  
  /* layout position in OCR:
     0 1
     2 3
     4 5
  */
  int layoutPosition;
  int width, height;
  
  int ocr_l, ocr_r, ocr_t, ocr_b;
  
  StringBuilder text = new StringBuilder(),
                allText = new StringBuilder(); // allText includes headers and footers
  
  Vector<LineInfo> lines = new Vector<LineInfo>();
  Vector<WordInfo> words = new Vector<WordInfo>();
  Vector<CharInfo> chars = new Vector<CharInfo>();
  
  float ratio = 3.0;
  
  
  void doBounds() {
    ocr_l = (int)(0 + (layoutPosition % 2) * width/ratio);
    ocr_r = (int)(ocr_l + width/ratio);
    
    ocr_t = (int)(0 + (layoutPosition / 2) * height/ratio);
    ocr_b = (int)(ocr_t + height/ratio);
  }
  
  int ocrToImgX(int x) {
    return (int)((x - ocr_l) * ratio);
  }
  int ocrToImgY(int y) {
    return (int)((y - ocr_t) * ratio);
  }
  
  void addLine(LineInfo line) {
    lines.add(line);
    
    allText.append(line.text).append("\n");
    if (!line.header) text.append(line.text).append("\n");
  }
  
  
  void addChar(CharInfo ci) {
    chars.add(ci);
  }
  
  void addWord(WordInfo wi) {
    words.add(wi);
  }
}