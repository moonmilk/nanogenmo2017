/*
  do something with OCRs of The Human Document


  might want to export animated GIFs...
  https://github.com/01010101/GifAnimation
  
  masking (blue channel of mask image, or 1-channel int array, becomes alpha of victim image)
  https://processing.org/reference/PImage_mask_.html
  
  color palette generator
  https://palx.jxnblk.com/07c

*/

import java.util.Vector;

String RENDER_MODE = P2D;

String WORD_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'ʼ’’’";

Vector<PageInfo> pages = new Vector<PageInfo>(); 

int PAGE_LIMIT = 0; // during testing, reduce # of pages for faster loading

int testPageIndex = 0;
PageInfo[] testPage = new PageInfo[2];
PImage[] pageDisplay = new PImage[2];

// color table for letter synesthesia test
int synesthesia[] = {
0xDDAACC80, 0xFF999C80, 0xAA888880, 0x99772280, 0x7F6D3F80, 0xE2323880, 0x88661180, 0x77557780,
0x4C3D3D80, 0x88117780, 0x88111180, 0xBCADD880, 0x8899AA80, 0xA479F280, 0x55777780, 0x3277E280,
0x11887780, 0x563F7F80, 0x3D434C80, 0x11448880, 0x44229980, 0x0041A880, 0x66881180, 0x22997780,
0x66775580, 0x3F7F7180, 0x00A80580, 0x11887780, 0x11881180, 0x3D4C3D80
};

void setup() {
  //size(1252,1000,RENDER_MODE);
  size(2504,2000,RENDER_MODE);
  
  // layout file lists original image files and how they are packed 6up into OCR files
  JSONArray layout6 = loadJSONArray("layouts6-tidy.json");
  for (int i=0; i<layout6.size(); i++) {
    JSONObject sixup = layout6.getJSONObject(i);
    JSONArray pagexml = sixup.getJSONArray("pages");
    String upfile = sixup.getString("6up");
    
    String xmlfile = "6ocrsFrom" + upfile + ".xml";
    XML ocr6 = loadXML(xmlfile);
    XML[] lines = ocr6.getChildren("page/block/text/par/line");
    //for (int o=0; o<children.length; o++) {
    //  println(children[o].getContent()); 
    //}
    
    if (PAGE_LIMIT > 0 && pages.size() >= PAGE_LIMIT) break;
    
    for (int j=0; j<pagexml.size(); j++) {
      JSONObject page = pagexml.getJSONObject(j);
      JSONArray size = page.getJSONArray("size");
      PageInfo pi = new PageInfo();
      pages.add(pi);
      
      pi.layoutPosition = j;
      pi.imageFilename = page.getString("file");
      pi.width = size.getInt(0);
      pi.height = size.getInt(1);
      
      pi.doBounds();
      
      for (int l=0; l<lines.length; l++) {
        XML line = lines[l];
        int ocr_l = line.getInt("l");
        int ocr_r = line.getInt("r");
        int ocr_t = line.getInt("t");
        int ocr_b = line.getInt("b");
        
        if (ocr_l >= pi.ocr_l && ocr_r <= pi.ocr_r && ocr_t >= pi.ocr_t && ocr_b <= pi.ocr_b) {
          //println("found a line " + l + " for page " + i + " " + j);
          LineInfo li = new LineInfo(pi);
          li.setBounds(ocr_l, ocr_r, ocr_t, ocr_b);
          if (ocr_b - pi.ocr_t < 145) {
            //println("probably part of the page header " + line.getContent());
            li.header = true;
          }
          
          XML[] chars = line.getChildren("formatting/charParams");
          String lineText = "";
          String wordText = "";
          int word_l=999999, word_r=0, word_t=999999, word_b=0;
          int wordStart=0;
          WordInfo wi = new WordInfo(li);
          
          int lineIndex = 0;
          for (int c=0; c<chars.length; c++) {
            XML ch = chars[c];
            String text = ch.getContent();
            lineText += text;
            CharInfo ci = new CharInfo(li, lineIndex, text);

            ocr_l = ch.getInt("l");
            ocr_r = ch.getInt("r");
            ocr_t = ch.getInt("t");
            ocr_b = ch.getInt("b");
            
            ci.setBounds(ocr_l, ocr_r, ocr_t, ocr_b);
            
            
            if (!WORD_CHARS.contains(text) || c==chars.length-1) {
              // end of word 
              if (WORD_CHARS.contains(text)) {
                wordText += text;
              }
              if (c==chars.length-1 && WORD_CHARS.contains(text)) {
                if (ocr_l < word_l) word_l = ocr_l;
                if (ocr_r > word_r) word_r = ocr_r;
                if (ocr_t < word_t) word_t = ocr_t;
                if (ocr_b > word_b) word_b = ocr_b;
              }
              if (wordText.length() > 0) {
                wi.finish(word_l, word_r, word_t, word_b,
                  wordStart, lineIndex + (c==chars.length-1 && WORD_CHARS.contains(text) ? 1 : 0), 
                  wordText);
                //println(wordText);
              }
              wi = new WordInfo(li);
              wordStart = lineIndex+1;
              wordText = "";
              word_l=999999;
              word_r=0;
              word_t=999999;
              word_b=0;
            }
            else {
              // not end of word
              
              if (ocr_l < word_l) word_l = ocr_l;
              if (ocr_r > word_r) word_r = ocr_r;
              if (ocr_t < word_t) word_t = ocr_t;
              if (ocr_b > word_b) word_b = ocr_b;
              
              wordText += text;
              ci.setWord(wi);
            }
            
            lineIndex += text.length();
          }
          li.doneAddingChars();
        }
      }
      
    }
  }
  println("done reading datafiles");
  
  //for (int p=0; p<pages.size(); p++) {
  //  println(pages.get(p).text);
  //}
  
  loadTestPage();
  
  println("Working on page " + testPageIndex);
  while (true) {
    render();
    nextPage();
  }
}

int grumpy = 20;


float r(float t) {
  //return random(-t,t);
  return randomGaussian()*t*2 - t;
}

void render() {
  grumpy = 6+testPageIndex / 10;
  background(0);
  
  pushMatrix();
  scale(width / 2 / (float)testPage[0].width, height / (float)testPage[0].height);
  image(pageDisplay[0],0,0);
  image(pageDisplay[1],testPage[0].width,0);
  
  // Saving a PGraphic doesn't seem to work, so can't offscreen render 'em :(
  //PGraphics[] pageTargets = new PGraphics[2];
  
  for (int p=0; p<=1; p++) {
    //pageTargets[p] = createGraphics(testPage[p].width*2, testPage[p].height, RENDER_MODE);
    //pageTargets[p].image(pageDisplay[p], 0, 0);
  }
  
  for (int p=0; p<=1; p++) {
    PGraphics pg = createGraphics(testPage[p].width, testPage[p].height, RENDER_MODE);
    pg.beginDraw();
    
    pg.noFill();
    
    pg.stroke(30,10,10,100);
    pg.strokeWeight(12+grumpy);
    pg.strokeJoin(ROUND);
    for (int c=0; c<testPage[p].chars.size(); c++) {
       CharInfo ci = testPage[p].chars.get(c);
       
       if (ci.text.equalsIgnoreCase("e")) {
  
          
          for (int g=0; g < grumpy+3; g++) {
            pg.beginShape();
            for (int h=0; h < 8; h++) {
              float www;
              www = ( 5+(grumpy-5)/ 2);
              float hhh;
              hhh = ( 6+(grumpy-5))/2;
              if (ci.w > 99) {
                www = ci.w /4.0 + 2;
                hhh = ci.h /4.0 + 2;
                pg.strokeWeight(50);
              }
              pg.curveVertex(ci.x+ci.w/2 + r(www), ci.y+ci.h/2 + r(hhh));
            }
            pg.endShape();
          }
          
          
       }
    
    }
    
    
    
    //int margin=4;
    // // animated e flames
    ////pg.fill(255,0,0,10);
    //for (int i=0; i<10; i++) {
    //  pg.noStroke();
    // // pg.fill(200+dy*3, 50-dy*2, 50-dy*2, 10);
    //  pg.fill(255,0,0,20);
    //
    //  for (int c=0; c<testPage.chars.size(); c++) {
    //    CharInfo ci = testPage.chars.get(c);
    //    if (ci.text.equalsIgnoreCase("e")) {
    //          
    //      int dx = (int)(randomGaussian()*10 - 5);
    //      int dy = (int)(randomGaussian()*20 - 15);
    //      pg.rect(dx+ci.x-margin,dy+ci.y-margin,ci.w+2*margin,ci.h+2*margin);
    //      //println("bup " + ci.x + "," + ci.y + " " +ci.w + ","+ci.h);
    //    }
    //    
    //    //// synesthesia test
    //    //char cc = ci.text.charAt(0);
    //    //int ccc = -1;
    //    //if (cc >= 'a' && cc <= 'z') ccc = cc-'a';
    //    //else if (cc >= 'A' && cc <= 'Z') ccc = cc-'A';
    //    //if (ccc >= 0) {
    //    //  fill(synesthesia[ccc]);
    //    //  rect(ci.x,ci.y, ci.w,ci.h);
    //    //}
    //    
    //  }
    //}
    
    //pg.filter(BLUR,6); // SLOOOOOW even in P2D or P3D mode, would probably be faster at screen resolution
    pg.endDraw();
    
    
    int dx1 = pageDisplay[0].width * p;
    int dx2 = pageDisplay[0].width * (1-p);
    
    // draw front side
    image(pg,dx1,0);
    
    //pageTargets[p].image(pg,0,0);
    
    
    // draw reverse side
    pg.filter(BLUR,10);
    
    pushMatrix();
    scale(-1,1);
    tint(255,150,60,35);
    image(pg,-pg.width-dx2,0); // straight image copy respects scale matrix and is much faster than blend
    //pageTargets[1-p].image(pg,-pg.width,0);
    noTint();
    popMatrix();
  }
  //blend(pg, 0,0,pg.width,pg.height, 0,0,width,height, MULTIPLY); // blend doesn't seem to respect the scale matrix so scale to screen res here
  
  //blend(pg, 0,0,pg.width,pg.height, 0,0,width,height, MULTIPLY);
  
  //noFill();
  //stroke(100,100,100,20);
  //strokeWeight(8);
  
  
  //for (int w=0; w<testPage.words.size(); w++) {
  //  WordInfo wi = testPage.words.get(w);
    //rect(wi.x-margin,wi.y-margin, wi.w+2*margin, wi.h+2*margin);
    
    /*
    // drawing curves is surprisingly slow?
    int[][] pts = new int[4][2];
    pts[0][0] = pts[3][0] = wi.x-margin;
    pts[0][1] = pts[1][1] = wi.y-margin;
    pts[1][0] = pts[2][0] = wi.x+wi.w+2*margin;
    pts[2][1] = pts[3][1] = wi.y+wi.h+2*margin;
    
    
    curveTightness(random(1.0));
    beginShape();
    for (int v=0; v<7; v++) {
      curveVertex(pts[v%4][0], pts[v%4][1]);
    }
    endShape();
    */
  //}
  
  //fill(0,255,0,100);
  //noStroke();
  //for (int l=0; l<testPage.lines.size(); l++) {
  //  LineInfo li = testPage.lines.get(l);
  //  if (li.header) {
  //    rect(li.x,li.y,li.w,li.h);
  //  }
  //}
  popMatrix();
  
  save("pageSpread-"+testPageIndex+".jpg");
  //pageTargets[0].save("page"+testPageIndex+".jpg");
  //pageTargets[1].save("page"+(testPageIndex+1)+".jpg");
  //exit();
}

void keyPressed() {
  if (key=='[') {
    prevPage();
  }
  else if (key==']') {
    nextPage();
  }
  
  else if (key==',' && grumpy > 0) grumpy--;
  else if (key=='.') grumpy++;
}

void prevPage() {
  testPageIndex -= 2;
  if (testPageIndex < 0) testPageIndex = pages.size()-2;
  loadTestPage();
}

void nextPage() {
  testPageIndex += 2;
  if (testPageIndex >= pages.size()-1) {
    exit();
    testPageIndex = 0;
  }
  loadTestPage();
}

void loadTestPage() {
  testPage[0] = pages.get(testPageIndex);
  testPage[1] = pages.get(testPageIndex+1);
  pageDisplay[0] = loadImage(testPage[0].imageFilename);
  pageDisplay[1] = loadImage(testPage[1].imageFilename);
  
}